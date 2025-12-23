import 'dart:async';
import 'dart:developer' as developer;

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:online_chat/features/home/models/group_chat_model.dart';
import 'package:online_chat/features/home/models/user_model.dart';
import 'package:online_chat/services/agora_token_service.dart';
import 'package:online_chat/services/call_notification_service.dart';
import 'package:online_chat/services/firebase_service.dart';
import 'package:online_chat/utils/app_color.dart';
import 'package:online_chat/utils/app_preference.dart';
import 'package:online_chat/utils/app_snackbar.dart';
import 'package:online_chat/utils/app_string.dart';
import 'package:online_chat/utils/firebase_constants.dart';
import 'package:permission_handler/permission_handler.dart';

enum CallState {
  calling,
  ringing,
  connected,
  ended,
  rejected,
  busy,
  failed,
}

class CallingController extends GetxController {
  final UserModel? user;
  final GroupChatModel? group;
  final String chatId;
  final bool isIncoming;
  final bool isVideoCall;

  // Agora SDK
  RtcEngine? _engine;
  int? _localUid;

  int? get localUid => _localUid;
  final remoteUsers = <int>[].obs;
  final remoteVideoViews = <int, Widget>{};
  VideoViewController? _localVideoViewController;

  // Call state
  final callState = CallState.calling.obs;
  final isConnected = false.obs;
  final isMuted = false.obs;
  final isSpeakerOn = false.obs;
  final isVideoEnabled = true.obs;

  // Call duration
  Timer? _callDurationTimer;
  final callStartTime = Rx<DateTime?>(null);
  final callDuration = Duration.zero.obs;
  Timer? _remoteEmptyTimer;

  // Call rejection listener
  StreamSubscription<QuerySnapshot>? _rejectionListener;

  // Agora App ID
  static const String appId = AgoraTokenService.appId;

  // Token will be generated dynamically based on channel name
  String _token = '';
  int _desiredUid = 0;

  CallingController({
    this.user,
    this.group,
    required this.chatId,
    this.isIncoming = false,
    this.isVideoCall = false,
  });

  @override
  void onInit() {
    super.onInit();
    _initializeAgora();
  }

  @override
  void onClose() {
    _callDurationTimer?.cancel();
    _rejectionListener?.cancel();
    _localVideoViewController?.dispose();
    _engine?.leaveChannel();
    _engine?.release();
    super.onClose();
  }

  Future<void> _initializeAgora() async {
    try {
      // Request permissions
      final permissionGranted = await _requestPermissions();
      if (!permissionGranted) {
        _handleError(
          userMessage: isVideoCall
              ? AppString.cameraPermissionDenied
              : AppString.callPermissionDenied,
          developerMessage:
              'Permissions not granted for ${isVideoCall ? 'video' : 'audio'} call',
        );
        return;
      }

      // Create RtcEngine instance
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));

      // Register event handlers
      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            _localUid = connection.localUid;
            developer.log(
                'Call connected successfully. Local UID: ${connection.localUid}');
          },
          onTokenPrivilegeWillExpire: (RtcConnection connection, String token) async {
            try {
              final channelName = getChannelName();
              final newToken = await AgoraTokenService.getTokenWithRetry(
                channelName: channelName,
                uid: _desiredUid == 0 ? 1 : _desiredUid,
                expireTime: 86400,
              );
              if (newToken.isNotEmpty) {
                await _engine?.renewToken(newToken);
                developer.log('Token renewed for channel: $channelName');
              }
            } catch (e) {
              developer.log('Token renewal failed: $e');
            }
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            remoteUsers.add(remoteUid);

            if (remoteUsers.length == 1) {
              callState.value = CallState.connected;
              isConnected.value = true;
              callStartTime.value = DateTime.now();
              // Cancel any pending auto-end due to empty channel
              _remoteEmptyTimer?.cancel();
              _remoteEmptyTimer = null;
              // Cancel rejection listener once someone joins (call is accepted)
              _rejectionListener?.cancel();
              _rejectionListener = null;
              developer.log('User joined, cancelling rejection listener');
            }
            _startCallDurationTimer();
            developer.log('User joined: $remoteUid');
            if (isVideoCall) {
              _setupRemoteVideo(remoteUid);
            }
          },
          onUserOffline: (RtcConnection connection, int remoteUid,
              UserOfflineReasonType reason) {
            developer.log("remoteUsers.length :::::::::::::::::::${remoteUsers}");
            remoteUsers.remove(remoteUid);
            remoteVideoViews.remove(remoteUid);
            if(remoteUsers.length == 0){
              // If no remotes in the channel, wait a short grace period to avoid
              // immediate call end on transient disconnects.
              _remoteEmptyTimer?.cancel();
              _remoteEmptyTimer = Timer(const Duration(seconds: 5), () {
                if (remoteUsers.isEmpty) {
                  _leaveChhanal();
                }
              });
            }
            developer.log('User offline: $remoteUid, reason: $reason');
          },
          onLeaveChannel: (RtcConnection connection, RtcStats stats) {
            _leaveChhanal(stats: stats);
          },
          onError: (ErrorCodeType err, String msg) {
            callState.value = CallState.failed;
            _handleAgoraError(err, msg);
          },
        ),
      );

      // Choose a deterministic local UID (non-zero) for token and join
      _desiredUid = Random().nextInt(0x7FFFFFFF - 1) + 1;

      // Enable video if it's a video call
      if (isVideoCall) {
        await _engine!.enableVideo();
        await _setupLocalVideo();
        await _engine!.startPreview();
      } else {
        await _engine!.enableAudio();
      }

      // Generate token dynamically for the channel (channel name is determined at runtime)
      // The channel name is: group ID for group calls, or "call_${user.id}" for one-to-one calls
      await _generateToken();

      // Send call notifications to all members (only if it's an outgoing call)
      if (!isIncoming) {
        _sendCallNotifications();
        // Listen for call rejections
        _listenForCallRejections();
      }

      // Join channel with the dynamically generated token
      await _joinChannel();
    } catch (e, stackTrace) {
      developer.log(
        'Error initializing Agora: $e',
        error: e,
        stackTrace: stackTrace,
      );
      _handleError(
        userMessage: 'Failed to start call. Please try again.',
        developerMessage: 'Agora initialization error: $e',
      );
    }
  }

  void _leaveChhanal({RtcStats? stats}) {
    callState.value = CallState.ended;
    isConnected.value = false;
    _callDurationTimer?.cancel();
    _remoteEmptyTimer?.cancel();
    _remoteEmptyTimer = null;
    // Cancel rejection listener when call ends
    _rejectionListener?.cancel();
    _rejectionListener = null;
    developer.log('Left channel. Duration: ${stats?.duration}ms');

    try {
      final started = callStartTime.value ?? DateTime.now();
      final ended = DateTime.now();
      final dur = ended.difference(started);
      final missed = callStartTime.value == null || dur.inSeconds <= 0;

      if (user != null) {
        // One-to-one call
        FirebaseService.recordOneToOneCall(
          otherUserId: user!.id,
          isVideo: isVideoCall,
          missed: missed,
          startedAt: started,
          endedAt: missed ? null : ended,
          duration: missed ? null : dur,
        );
      } else if (group != null) {
        // Group call
        FirebaseService.recordGroupCall(
          groupId: group!.id,
          isVideo: isVideoCall,
          startedAt: started,
          endedAt: missed ? null : ended,
          duration: missed ? null : dur,
          missed: missed,
        );
      }
    } catch (_) {}
  }

  Future<bool> _requestPermissions() async {
    try {
      if (isVideoCall) {
        final cameraStatus = await Permission.camera.request();
        final microphoneStatus = await Permission.microphone.request();

        if (cameraStatus.isDenied || microphoneStatus.isDenied) {
          developer.log(
              'Permissions denied - Camera: $cameraStatus, Microphone: $microphoneStatus');
          return false;
        }
        return cameraStatus.isGranted && microphoneStatus.isGranted;
      } else {
        final microphoneStatus = await Permission.microphone.request();
        if (microphoneStatus.isDenied) {
          developer.log('Microphone permission denied: $microphoneStatus');
          return false;
        }
        return microphoneStatus.isGranted;
      }
    } catch (e, stackTrace) {
      developer.log(
        'Error requesting permissions: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Generate token dynamically based on channel name
  ///
  /// The channel name is determined dynamically:
  /// - For group calls: Uses the group ID
  /// - For one-to-one calls: Uses "call_${user.id}"
  /// - Fallback: "call_unknown"
  Future<void> _generateToken() async {
    try {
      final String channelName = getChannelName();
      developer.log(
        'Generating token for channel: $channelName (${group != null ? "Group" : "One-to-One"})',
        name: 'CallingController',
      );

      _token = await AgoraTokenService.getTokenWithRetry(
        channelName: channelName,
        uid: _desiredUid == 0 ? 1 : _desiredUid,
        expireTime: 86400, // 24 hours
      );

      if (_token.isEmpty) {
        developer.log(
          'Token generation returned empty. Using App ID only mode (development). Channel: $channelName',
          name: 'CallingController',
        );
      } else {
        developer.log(
          'Token generated successfully for channel: $channelName',
          name: 'CallingController',
        );
      }
    } catch (e, stackTrace) {
      developer.log(
        'Error generating token for channel ${getChannelName()}: $e',
        error: e,
        stackTrace: stackTrace,
        name: 'CallingController',
      );
      // Continue with empty token (App ID only mode for development)
      _token = '';
    }
  }

  Future<void> _joinChannel() async {
    try {
      final String channelName = getChannelName();
      final uid = _desiredUid == 0 ? 1 : _desiredUid; // match token uid

      developer.log('Joining channel: $channelName');
      await _engine!.joinChannel(
        token: _token.isEmpty ? '' : _token,
        channelId: channelName,
        uid: uid,
        options: ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );
    } catch (e, stackTrace) {
      developer.log(
        'Error joining channel: $e',
        error: e,
        stackTrace: stackTrace,
      );
      _handleError(
        userMessage:
            'Failed to connect to call. Please check your internet connection.',
        developerMessage: 'Channel join error: $e',
      );
    }
  }

  String getChannelName() {
    if (group != null) {
      return group!.id;
    }
    if (user != null && user!.id.isNotEmpty) {
      return chatId;
    }
    return 'call_unknown';
  }

  /// Get the current channel name (public getter)
  String get currentChannelName => getChannelName();

  Future<void> _setupLocalVideo() async {
    _localVideoViewController = VideoViewController(
      rtcEngine: _engine!,
      canvas: const VideoCanvas(uid: 0),
    );
    update();
  }

  void _setupRemoteVideo(int remoteUid) {
    final videoViewController = VideoViewController.remote(
      rtcEngine: _engine!,
      canvas: VideoCanvas(uid: remoteUid),
      connection: RtcConnection(channelId: getChannelName()),
    );
    remoteVideoViews[remoteUid] = AgoraVideoView(
      controller: videoViewController,
    );
    update();
  }

  Widget getLocalVideoView() {
    if (_localVideoViewController != null) {
      return AgoraVideoView(
        controller: _localVideoViewController!,
      );
    }
    return Container(
      color: AppColor.darkGrey,
      child: Center(
        child: Icon(
          Icons.person,
          color: AppColor.whiteColor,
          size: 50.sp,
        ),
      ),
    );
  }

  Widget getRemoteVideoView(int uid) {
    if (remoteVideoViews.containsKey(uid)) {
      return remoteVideoViews[uid]!;
    }
    return Container(
      color: AppColor.darkGrey,
      child: Center(
        child: Icon(
          Icons.person,
          color: AppColor.whiteColor,
          size: 50.sp,
        ),
      ),
    );
  }

  void _startCallDurationTimer() {
    _callDurationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (callStartTime.value != null) {
        callDuration.value = DateTime.now().difference(callStartTime.value!);
      }
    });
  }

  String getCallDuration() {
    final duration = callDuration.value;
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String getCallStatus() {
    switch (callState.value) {
      case CallState.calling:
        return isIncoming ? AppString.incomingCall : AppString.calling;
      case CallState.ringing:
        return AppString.ringing;
      case CallState.connected:
        return AppString.connected;
      case CallState.ended:
        return AppString.callEnded;
      case CallState.rejected:
        return AppString.callRejected;
      case CallState.busy:
        return AppString.userBusy;
      case CallState.failed:
        return AppString.callFailed;
    }
  }

  Future<void> toggleMute() async {
    try {
      isMuted.value = !isMuted.value;
      await _engine?.muteLocalAudioStream(isMuted.value);
      developer.log('Microphone ${isMuted.value ? "muted" : "unmuted"}');
    } catch (e, stackTrace) {
      developer.log(
        'Error toggling mute: $e',
        error: e,
        stackTrace: stackTrace,
      );
      isMuted.value = !isMuted.value; // Revert on error
      AppSnackbar.error(
        message: 'Failed to ${isMuted.value ? "unmute" : "mute"} microphone.',
      );
    }
  }

  Future<void> toggleSpeaker() async {
    try {
      isSpeakerOn.value = !isSpeakerOn.value;
      await _engine?.setEnableSpeakerphone(isSpeakerOn.value);
      developer.log('Speaker ${isSpeakerOn.value ? "enabled" : "disabled"}');
    } catch (e, stackTrace) {
      developer.log(
        'Error toggling speaker: $e',
        error: e,
        stackTrace: stackTrace,
      );
      isSpeakerOn.value = !isSpeakerOn.value; // Revert on error
      AppSnackbar.error(
        message: 'Failed to toggle speaker.',
      );
    }
  }

  Future<void> toggleVideo() async {
    if (!isVideoCall) return;
    try {
      isVideoEnabled.value = !isVideoEnabled.value;
      await _engine?.muteLocalVideoStream(!isVideoEnabled.value);
      if (isVideoEnabled.value && _localVideoViewController == null) {
        await _setupLocalVideo();
      }
      update();
      developer.log('Video ${isVideoEnabled.value ? "enabled" : "disabled"}');
    } catch (e, stackTrace) {
      developer.log(
        'Error toggling video: $e',
        error: e,
        stackTrace: stackTrace,
      );
      isVideoEnabled.value = !isVideoEnabled.value; // Revert on error
      AppSnackbar.error(
        message:
            'Failed to ${isVideoEnabled.value ? "enable" : "disable"} video.',
      );
    }
  }

  Future<void> endCall() async {
    try {
      callState.value = CallState.ended;
      // Cancel rejection listener before ending call
      _rejectionListener?.cancel();
      _rejectionListener = null;
      await _engine?.leaveChannel();
      _callDurationTimer?.cancel();
      developer.log('Call ended by user');
      // Get.back();
    } catch (e, stackTrace) {
      developer.log(
        'Error ending call: $e',
        error: e,
        stackTrace: stackTrace,
      );
      // Still close the screen even if there's an error
      _callDurationTimer?.cancel();
      _rejectionListener?.cancel();
      _rejectionListener = null;
      Get.back();
    }
  }

  Future<void> rejectCall() async {
    try {
      callState.value = CallState.rejected;
      await _engine?.leaveChannel();
      developer.log('Call rejected');
      Get.back();
    } catch (e, stackTrace) {
      developer.log(
        'Error rejecting call: $e',
        error: e,
        stackTrace: stackTrace,
      );
      // Still close the screen even if there's an error
      Get.back();
    }
  }

  Future<void> acceptCall() async {
    callState.value = CallState.ringing;
    // Call will be connected when onJoinChannelSuccess is called
  }

  /// Handle Agora-specific errors with user-friendly messages
  void _handleAgoraError(ErrorCodeType err, String msg) {
    String userMessage;

    switch (err) {
      case ErrorCodeType.errInvalidAppId:
        userMessage = 'Invalid call configuration. Please contact support.';
        break;
      case ErrorCodeType.errInvalidChannelName:
        userMessage = 'Invalid call channel. Please try again.';
        break;
      case ErrorCodeType.errTokenExpired:
        userMessage = 'Call session expired. Please try again.';
        break;
      case ErrorCodeType.errInvalidToken:
        userMessage = 'Invalid call credentials. Please try again.';
        break;
      case ErrorCodeType.errJoinChannelRejected:
        userMessage = 'Unable to join call. Please try again.';
        break;
      case ErrorCodeType.errLeaveChannelRejected:
        userMessage = 'Unable to leave call.';
        break;
      case ErrorCodeType.errAlreadyInUse:
        userMessage = 'Call service is already in use.';
        break;
      case ErrorCodeType.errAborted:
        userMessage = 'Call was interrupted.';
        break;
      case ErrorCodeType.errInitNetEngine:
        userMessage = 'Network error. Please check your internet connection.';
        break;
      default:
        userMessage = 'Call error occurred. Please try again.';
    }

    _handleError(
      userMessage: userMessage,
      developerMessage: 'Agora Error [${err.name}]: $msg',
    );
  }

  /// Handle errors with both user-friendly and developer-friendly messages
  void _handleError({
    required String userMessage,
    required String developerMessage,
  }) {
    // Log developer-friendly message
    developer.log(
      developerMessage,
      name: 'CallingController',
      error: developerMessage,
    );

    // Show user-friendly message
    AppSnackbar.error(
      message: userMessage,
      duration: const Duration(seconds: 4),
    );

    // Update call state
    callState.value = CallState.failed;
    isConnected.value = false;
  }

  /// Send call notifications to all members
  /// For group calls: sends to all members except the caller
  /// For one-to-one calls: sends to the other user
  Future<void> _sendCallNotifications() async {
    try {
      final currentUser = AppPreference.getCurrentUser();
      if (currentUser == null) {
        developer.log('Cannot send call notifications: current user is null');
        return;
      }

      final callerId = currentUser.id;
      final callerName = currentUser.name;
      final callerImage = currentUser.profileImage;

      if (group != null) {
        // Group call: send notifications to all members except the caller
        final memberIds = group!.members
            .where((memberId) => memberId != callerId)
            .toList();

        if (memberIds.isNotEmpty) {
          await CallNotificationService.sendGroupCallNotifications(
            userIds: memberIds,
            callerName: callerName,
            callerId: callerId,
            callerImage: callerImage,
            chatId: chatId,
            isVideoCall: isVideoCall,
            groupName: group!.name,
          );
          developer.log(
            'Call notifications sent to ${memberIds.length} group members',
          );
        }
      } else if (user != null) {
        // One-to-one call: send notification to the other user
        await CallNotificationService.sendCallNotification(
          userId: user!.id,
          callerName: callerName,
          callerId: callerId,
          callerImage: callerImage,
          chatId: chatId,
          isVideoCall: isVideoCall,
          isGroupCall: false,
        );
        developer.log('Call notification sent to user: ${user!.id}');
      }
    } catch (e, stackTrace) {
      developer.log(
        'Error sending call notifications: $e',
        error: e,
        stackTrace: stackTrace,
      );
      // Don't show error to user as this is a background operation
    }
  }

  /// Listen for call rejections and end call if rejected
  void _listenForCallRejections() {
    try {
      final currentUserId = FirebaseService.getCurrentUserId();
      if (currentUserId == null) return;

      final firestore = FirebaseFirestore.instance;
      final callStartTime = DateTime.now();
      Query query;

      if (group != null) {
        // For group calls, listen to group call rejections
        query = firestore
            .collection(FirebaseConstants.groupCollection)
            .doc(chatId)
            .collection('callRejections')
            .where('rejectedBy', isNotEqualTo: currentUserId)
            .where('timestamp', isGreaterThan: Timestamp.fromDate(callStartTime));
      } else {
        // For one-to-one calls, listen to chat call rejections
        query = firestore
            .collection(FirebaseConstants.chatCollection)
            .doc(chatId)
            .collection('callRejections')
            .where('rejectedBy', isNotEqualTo: currentUserId)
            .where('timestamp', isGreaterThan: Timestamp.fromDate(callStartTime));
      }

      _rejectionListener = query.snapshots().listen((snapshot) {
        // Only process rejections if call is still active and not connected yet
        if (snapshot.docs.isNotEmpty && 
            callState.value != CallState.ended && 
            !isConnected.value && 
            remoteUsers.isEmpty) {
          // Call was rejected, end the call
          developer.log('Call rejected by user, ending call');
          AppSnackbar.error(message: 'Call was rejected');
          endCall();
        }
      });
    } catch (e, stackTrace) {
      developer.log(
        'Error listening for call rejections: $e',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}
