import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:online_chat/features/home/models/group_chat_model.dart';
import 'package:online_chat/features/home/models/user_model.dart';
import 'package:online_chat/features/home/screen/calling_screen.dart';
import 'package:online_chat/services/call_notification_service.dart';
import 'package:online_chat/services/firebase_service.dart';
import 'package:online_chat/utils/app_color.dart';
import 'package:online_chat/utils/app_profile_image.dart';
import 'package:online_chat/utils/app_spacing.dart';
import 'package:online_chat/utils/app_string.dart';
import 'package:online_chat/utils/app_text.dart';

import '../../../utils/firebase_constants.dart';

class IncomingCallDialog extends StatefulWidget {
  final UserModel? caller;
  final GroupChatModel? group;
  final String chatId;
  final bool isVideoCall;
  final String notificationId;

  const IncomingCallDialog({
    super.key,
    this.caller,
    this.group,
    required this.chatId,
    required this.isVideoCall,
    required this.notificationId,
  });

  @override
  State<IncomingCallDialog> createState() => _IncomingCallDialogState();
}

class _IncomingCallDialogState extends State<IncomingCallDialog> with SingleTickerProviderStateMixin {
  bool _isRinging = true;
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription<DocumentSnapshot>? _notifSubscription;
  Timer? _autoCloseTimer;

  @override
  void initState() {
    super.initState();
    _startRingtone();
    _listenNotificationCancelled();
    // Auto-close after 60 seconds if not acted upon
    _autoCloseTimer = Timer(const Duration(minutes: 1), () async {
      try {
        final currentUserId = FirebaseService.getCurrentUserId();
        if (currentUserId != null) {
          await CallNotificationService.deleteCallNotification(
            userId: currentUserId,
            notificationId: widget.notificationId,
          );
        }
      } catch (_) {}
      if (mounted) {
        Get.back();
      }
    });
  }

  @override
  void dispose() {
    _stopRingtone();
    _notifSubscription?.cancel();
    _autoCloseTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _startRingtone() async {
    try {
      // Set audio player to loop mode
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);

      // Play the ringtone audio file
      // Replace 'ringtone.mp3' with your actual audio file name
      await _audioPlayer.play(AssetSource('audio/incomming_call.mp3'));

      _isRinging = true;
    } catch (e) {
      // If audio file is not found, fallback to silent or handle error
      print('Error playing ringtone: $e');
      // You can set a default system sound or continue without audio
      _isRinging = false;
    }
  }

  Future<void> _stopRingtone() async {
    try {
      await _audioPlayer.stop();
      _isRinging = false;
    } catch (e) {
      print('Error stopping ringtone: $e');
    }
  }

  void _listenNotificationCancelled() {
    final currentUserId = FirebaseService.getCurrentUserId();
    if (currentUserId == null) return;
    // Close when the call notification document is deleted by caller cancellation
    _notifSubscription = FirebaseFirestore.instance
        .collection(FirebaseConstants.userCollection)
        .doc(currentUserId)
        .collection('callNotifications')
        .doc(widget.notificationId)
        .snapshots()
        .listen((docSnap) {
      if (!docSnap.exists) {
        // Caller ended/cancelled - close dialog
        _stopRingtone();
        if (mounted) {
          Get.back();
        }
      }
    });
  }

  Future<void> _handleAccept() async {
    _stopRingtone();

    // Delete notification
    final currentUserId = FirebaseService.getCurrentUserId();
    if (currentUserId != null) {
      await CallNotificationService.deleteCallNotification(
        userId: currentUserId,
        notificationId: widget.notificationId,
      );
    }

    // Close dialog
    Get.back();

    // Navigate to calling screen
    if (widget.group != null) {
      Get.to(
        () => CallingScreen(
          group: widget.group,
          chatId: widget.chatId,
          isIncoming: true,
          isVideoCall: widget.isVideoCall,
        ),
      );
    } else if (widget.caller != null) {
      Get.to(
        () => CallingScreen(
          user: widget.caller,
          chatId: widget.chatId,
          isIncoming: true,
          isVideoCall: widget.isVideoCall,
        ),
      );
    }
  }

  Future<void> _handleReject() async {
    _stopRingtone();

    // Delete notification
    final currentUserId = FirebaseService.getCurrentUserId();
    if (currentUserId != null) {
      await CallNotificationService.deleteCallNotification(
        userId: currentUserId,
        notificationId: widget.notificationId,
      );
    }

    // Store rejection status in Firestore so caller knows call was rejected
    // This will be checked by the caller's CallingController
    try {
      final firestore = FirebaseFirestore.instance;
      final rejectionData = {
        'rejectedBy': currentUserId,
        'chatId': widget.chatId,
        'timestamp': FieldValue.serverTimestamp(),
        'isVideoCall': widget.isVideoCall,
      };

      if (widget.group != null) {
        // For group calls, store rejection in group document
        await firestore.collection('group').doc(widget.chatId).collection('callRejections').doc(currentUserId).set(rejectionData);
      } else if (widget.caller != null) {
        // For one-to-one calls, store rejection in chat document
        await firestore.collection('chat').doc(widget.chatId).collection('callRejections').doc(currentUserId).set(rejectionData);
      }
    } catch (e) {
      // Silently fail - rejection notification is optional
      print('Error storing call rejection: $e');
    }

    // Close dialog
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final isGroup = widget.group != null;
    final title = isGroup ? widget.group?.name ?? AppString.groupCall : widget.caller?.name ?? AppString.incomingCall;
    final image = isGroup ? widget.group?.groupImage : widget.caller?.profileImage;
    final subtitle = isGroup ? '${widget.group?.memberCount ?? 0} ${AppString.participants}' : widget.caller?.email ?? '';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColor.primaryColor.withValues(alpha: 0.95),
              AppColor.secondaryColor.withValues(alpha: 0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: AppColor.blackColor.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(Spacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Call type indicator
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Spacing.md,
                  vertical: Spacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColor.whiteColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.isVideoCall ? Icons.videocam : Icons.call,
                      color: AppColor.whiteColor,
                      size: 16.sp,
                    ),
                    SizedBox(width: Spacing.xs),
                    AppText(
                      text: widget.isVideoCall ? '${AppString.video} Call' : '${AppString.audio} Call',
                      fontSize: 12.sp,
                      color: AppColor.whiteColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ),
              SizedBox(height: Spacing.lg),
              // Profile image with pulsing animation
              _buildProfileImage(title, image, isGroup)
                  .animate(onPlay: (controller) => controller.repeat())
                  .scale(
                    duration: 2000.ms,
                    begin: const Offset(1, 1),
                    end: const Offset(1.05, 1.05),
                    curve: Curves.easeInOut,
                  )
                  .then()
                  .scale(
                    duration: 2000.ms,
                    begin: const Offset(1.05, 1.05),
                    end: const Offset(1, 1),
                    curve: Curves.easeInOut,
                  ),
              SizedBox(height: Spacing.lg),
              // Name
              AppText(
                text: title,
                fontSize: 24.sp,
                color: AppColor.whiteColor,
                fontWeight: FontWeight.w700,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: Spacing.xs),
              // Subtitle
              AppText(
                text: subtitle,
                fontSize: 14.sp,
                color: AppColor.whiteColor.withValues(alpha: 0.8),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: Spacing.xl * 1.5),
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Reject button (Red)
                  _buildActionButton(
                    icon: Icons.call_end,
                    backgroundColor: AppColor.redColor,
                    iconColor: AppColor.whiteColor,
                    onPressed: _handleReject,
                    isReject: true,
                  ),
                  SizedBox(width: Spacing.xl),
                  // Accept button (Green)
                  _buildActionButton(
                    icon: widget.isVideoCall ? Icons.videocam : Icons.call,
                    backgroundColor: AppColor.accentColor,
                    iconColor: AppColor.whiteColor,
                    onPressed: _handleAccept,
                    isReject: false,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage(String title, String? image, bool isGroup) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer pulsing ring
        Container(
          width: 120.w,
          height: 120.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColor.whiteColor.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
        )
            .animate(onPlay: (controller) => controller.repeat())
            .scale(duration: 2000.ms, begin: const Offset(1, 1), end: const Offset(1.2, 1.2))
            .fade(duration: 2000.ms, begin: 0.5, end: 0.0),
        // Middle ring
        Container(
          width: 110.w,
          height: 110.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColor.whiteColor.withValues(alpha: 0.4),
              width: 2,
            ),
          ),
        )
            .animate(onPlay: (controller) => controller.repeat())
            .scale(duration: 2000.ms, begin: const Offset(1, 1), end: const Offset(1.15, 1.15), delay: 300.ms)
            .fade(duration: 2000.ms, begin: 0.6, end: 0.0, delay: 300.ms),
        // Profile image
        Container(
          width: 100.w,
          height: 100.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColor.whiteColor.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: AppProfileImage(
            width: 100.w,
            height: 100.h,
            username: title,
            imageUrl: image,
            fallbackIcon: isGroup ? Icons.group : Icons.person,
            fontSize: 40.sp,
            borderWidth: 3,
            borderColor: AppColor.whiteColor,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
    required VoidCallback onPressed,
    required bool isReject,
  }) {
    final buttonSize = 60.w;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withValues(alpha: 0.5),
              blurRadius: 15,
              spreadRadius: 3,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: (buttonSize * 0.5).sp,
        ),
      ).animate().scale(duration: 100.ms).then().scale(duration: 100.ms, begin: const Offset(1.1, 1.1), end: const Offset(1, 1)),
    );
  }
}
