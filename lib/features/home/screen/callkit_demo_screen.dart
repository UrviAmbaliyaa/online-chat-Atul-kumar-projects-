import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:online_chat/utils/app_button.dart';
import 'package:online_chat/utils/app_color.dart';
import 'package:online_chat/utils/app_spacing.dart';
import 'package:online_chat/utils/app_text.dart';

class CallkitDemoScreen extends StatefulWidget {
  const CallkitDemoScreen({super.key});

  @override
  State<CallkitDemoScreen> createState() => _CallkitDemoScreenState();
}

class _CallkitDemoScreenState extends State<CallkitDemoScreen> {
  String? _lastCallId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.ScaffoldColor,
      appBar: AppBar(
        backgroundColor: AppColor.whiteColor,
        elevation: 0,
        title: AppText(
          text: 'CallKit Demo',
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: AppColor.darkGrey,
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildButton('Simulate Incoming (Audio)', _showIncomingAudio),
            SizedBox(height: Spacing.sm),
            _buildButton('Simulate Incoming (Video)', _showIncomingVideo),
            SizedBox(height: Spacing.sm),
            _buildButton('Start Outgoing (Display Only)', _startOutgoing),
            SizedBox(height: Spacing.sm),
            _buildButton('End Current Call', _endCurrent),
            SizedBox(height: Spacing.sm),
            _buildButton('Show Missed Notification', _showMissed),
            SizedBox(height: Spacing.sm),
            _buildButton('Active Calls (console log)', _printActiveCalls),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      backgroundColor: AppColor.primaryColor,
      borderRadius: 8,
      height: 44.h,
    );
  }

  Future<void> _showIncomingAudio() async {
    final id = _generateUuid();
    _lastCallId = id;
    final params = CallKitParams(
      id: id,
      nameCaller: 'John Doe',
      appName: 'Online Chat',
      avatar: 'https://i.pravatar.cc/100?img=12',
      handle: '+1 202 555 0101',
      type: 0, // 0 = audio, 1 = video
      textAccept: 'Accept',
      textDecline: 'Decline',
      duration: 30000,
      extra: {'demo': true},
      android: const AndroidParams(
        isCustomNotification: true,
        backgroundColor: '#0955fa',
        actionColor: '#4CAF50',
        incomingCallNotificationChannelName: 'Incoming Calls',
        // Put incomming_call.mp3 under android/app/src/main/res/raw/
        // and reference it without extension:
        ringtonePath: 'incomming_call',
      ),
      ios: const IOSParams(
        handleType: 'number',
        supportsVideo: true,
        maximumCallGroups: 2,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'default',
      ),
    );
    await FlutterCallkitIncoming.showCallkitIncoming(params);
  }

  Future<void> _showIncomingVideo() async {
    final id = _generateUuid();
    _lastCallId = id;
    final params = CallKitParams(
      id: id,
      nameCaller: 'Jane Smith',
      appName: 'Online Chat',
      avatar: 'https://i.pravatar.cc/100?img=25',
      handle: '+44 20 7946 0958',
      type: 1, // video
      textAccept: 'Accept',
      textDecline: 'Decline',
      duration: 30000,
      extra: {'demo': true},
      android: const AndroidParams(
        isCustomNotification: true,
        backgroundColor: '#0955fa',
        actionColor: '#4CAF50',
        incomingCallNotificationChannelName: 'Incoming Calls',
        ringtonePath: 'incomming_call',
      ),
      ios: const IOSParams(
        handleType: 'number',
        supportsVideo: true,
        maximumCallGroups: 2,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'default',
      ),
    );
    await FlutterCallkitIncoming.showCallkitIncoming(params);
  }

  Future<void> _startOutgoing() async {
    final id = _generateUuid();
    _lastCallId = id;
    final params = CallKitParams(
      id: id,
      nameCaller: 'Outgoing to Alex',
      appName: 'Online Chat',
      avatar: 'https://i.pravatar.cc/100?img=31',
      handle: '+33 1 23 45 67 89',
      type: 0,
      extra: {'outgoing': true},
      android: const AndroidParams(
        isCustomNotification: true,
        backgroundColor: '#0955fa',
        actionColor: '#4CAF50',
        incomingCallNotificationChannelName: 'Outgoing Calls',
        ringtonePath: 'incomming_call',
      ),
      ios: const IOSParams(
        handleType: 'number',
        supportsVideo: false,
        maximumCallGroups: 2,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'default',
      ),
    );
    await FlutterCallkitIncoming.startCall(params);
  }

  Future<void> _endCurrent() async {
    final id = _lastCallId;
    if (id != null) {
      await FlutterCallkitIncoming.endCall(id);
    } else {
      final actives = await FlutterCallkitIncoming.activeCalls();
      if (actives.isNotEmpty) {
        await FlutterCallkitIncoming.endCall(actives.first['id'] as String);
      }
    }
  }

  Future<void> _showMissed() async {
    if (_lastCallId == null) {
      _lastCallId = _generateUuid();
    }
    await FlutterCallkitIncoming.showMissCallNotification(
      CallKitParams(
        id: _lastCallId!,
        nameCaller: 'Missed caller',
        appName: 'Online Chat',
        avatar: 'https://i.pravatar.cc/100?img=40',
        handle: '+91 99 999 9999',
        type: 0,
        android: const AndroidParams(
          isCustomNotification: true,
          backgroundColor: '#0955fa',
          actionColor: '#4CAF50',
          incomingCallNotificationChannelName: 'Missed Calls',
          ringtonePath: 'system_ringtone_default',
        ),
        ios: const IOSParams(
          handleType: 'number',
          supportsVideo: false,
          maximumCallGroups: 2,
          maximumCallsPerCallGroup: 1,
          audioSessionMode: 'default',
        ),
      ),
    );
  }

  Future<void> _printActiveCalls() async {
    final calls = await FlutterCallkitIncoming.activeCalls();
    // ignore: avoid_print
    print('[CallKitDemo] Active calls: $calls');
  }

  String _generateUuid() {
    final rnd = Random();
    return List.generate(32, (_) => rnd.nextInt(16).toRadixString(16)).join();
  }
}


