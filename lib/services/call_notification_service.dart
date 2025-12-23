import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:online_chat/utils/firebase_constants.dart';

/// Service for sending call notifications to users
class CallNotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Send call notification to a single user
  /// [userId] - Target user ID
  /// [callerName] - Name of the person making the call
  /// [callerId] - ID of the person making the call
  /// [callerImage] - Profile image URL of the caller (optional)
  /// [chatId] - Chat ID (group ID or one-to-one chat ID)
  /// [isVideoCall] - Whether it's a video call or audio call
  /// [isGroupCall] - Whether it's a group call
  /// [groupName] - Group name if it's a group call (optional)
  static Future<bool> sendCallNotification({
    required String userId,
    required String callerName,
    required String callerId,
    String? callerImage,
    required String chatId,
    required bool isVideoCall,
    required bool isGroupCall,
    String? groupName,
  }) async {
    try {
      // Store call notification in Firestore
      // The app will listen to these notifications and show them
      // For actual push notifications, you would need a backend server
      // to send FCM messages. This Firestore-based approach allows
      // real-time call notifications within the app.
      await _storeCallNotification(
        userId: userId,
        callerId: callerId,
        callerName: callerName,
        callerImage: callerImage,
        chatId: chatId,
        isVideoCall: isVideoCall,
        isGroupCall: isGroupCall,
        groupName: groupName,
      );

      log('Call notification sent to user: $userId');
      return true;
    } catch (e, stackTrace) {
      log(
        'Error sending call notification: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Send call notifications to multiple users (for group calls)
  /// [userIds] - List of target user IDs (excluding the caller)
  /// [callerName] - Name of the person making the call
  /// [callerId] - ID of the person making the call
  /// [callerImage] - Profile image URL of the caller (optional)
  /// [chatId] - Group ID
  /// [isVideoCall] - Whether it's a video call or audio call
  /// [groupName] - Group name
  static Future<void> sendGroupCallNotifications({
    required List<String> userIds,
    required String callerName,
    required String callerId,
    String? callerImage,
    required String chatId,
    required bool isVideoCall,
    required String groupName,
  }) async {
    try {
      // Send notifications to all members in parallel
      final futures = userIds.map((userId) => sendCallNotification(
            userId: userId,
            callerName: callerName,
            callerId: callerId,
            callerImage: callerImage,
            chatId: chatId,
            isVideoCall: isVideoCall,
            isGroupCall: true,
            groupName: groupName,
          ));

      await Future.wait(futures);
      log('Group call notifications sent to ${userIds.length} users');
    } catch (e, stackTrace) {
      log(
        'Error sending group call notifications: $e',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Get FCM token for a user from Firestore
  static Future<String?> _getUserFcmToken(String userId) async {
    try {
      final userDoc = await _firestore
          .collection(FirebaseConstants.userCollection)
          .doc(userId)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data()!;
        return data['fcmToken'] as String?;
      }
      return null;
    } catch (e) {
      log('Error getting FCM token for user $userId: $e');
      return null;
    }
  }

  /// Store call notification in Firestore (for real-time listening)
  static Future<void> _storeCallNotification({
    required String userId,
    required String callerId,
    required String callerName,
    String? callerImage,
    required String chatId,
    required bool isVideoCall,
    required bool isGroupCall,
    String? groupName,
  }) async {
    try {
      final notificationId = DateTime.now().millisecondsSinceEpoch.toString();
      
      await _firestore
          .collection(FirebaseConstants.userCollection)
          .doc(userId)
          .collection('callNotifications')
          .doc(notificationId)
          .set({
        'id': notificationId,
        'callerId': callerId,
        'callerName': callerName,
        'callerImage': callerImage,
        'chatId': chatId,
        'isVideoCall': isVideoCall,
        'isGroupCall': isGroupCall,
        'groupName': groupName,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });
    } catch (e) {
      log('Error storing call notification: $e');
    }
  }

  /// Save FCM token for current user
  /// [userId] - Current user ID
  /// [fcmToken] - FCM token to save
  static Future<bool> saveFcmToken({
    required String userId,
    required String fcmToken,
  }) async {
    try {
      await _firestore
          .collection(FirebaseConstants.userCollection)
          .doc(userId)
          .update({
        'fcmToken': fcmToken,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      log('Error saving FCM token: $e');
      return false;
    }
  }

  /// Get current user's FCM token
  static Future<String?> getCurrentUserFcmToken() async {
    try {
      final token = await _messaging.getToken();
      return token;
    } catch (e) {
      log('Error getting FCM token: $e');
      return null;
    }
  }

  /// Initialize FCM token for current user
  /// [userId] - Current user ID
  static Future<void> initializeFcmToken(String userId) async {
    try {
      // Request permission for notifications
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // Get FCM token
        final token = await getCurrentUserFcmToken();
        if (token != null) {
          await saveFcmToken(userId: userId, fcmToken: token);
          log('FCM token initialized for user: $userId');
        }

        // Listen for token refresh
        _messaging.onTokenRefresh.listen((newToken) {
          saveFcmToken(userId: userId, fcmToken: newToken);
          log('FCM token refreshed for user: $userId');
        });
      }
    } catch (e) {
      log('Error initializing FCM token: $e');
    }
  }

  /// Delete call notification after it's handled
  /// [userId] - User ID
  /// [notificationId] - Notification ID
  static Future<void> deleteCallNotification({
    required String userId,
    required String notificationId,
  }) async {
    try {
      await _firestore
          .collection(FirebaseConstants.userCollection)
          .doc(userId)
          .collection('callNotifications')
          .doc(notificationId)
          .delete();
    } catch (e) {
      log('Error deleting call notification: $e');
    }
  }

  /// Cancel call notifications for specific users for a given chat
  /// Used when the caller ends the call before it's accepted/rejected.
  static Future<void> cancelCallNotificationsForUsers({
    required List<String> userIds,
    required String chatId,
    DateTime? since,
  }) async {
    final ts = since != null ? Timestamp.fromDate(since) : null;
    try {
      for (final uid in userIds) {
        Query query = _firestore
            .collection(FirebaseConstants.userCollection)
            .doc(uid)
            .collection('callNotifications')
            .where('chatId', isEqualTo: chatId);
        if (ts != null) {
          query = query.where('timestamp', isGreaterThan: ts);
        }
        final snap = await query.get();
        for (final doc in snap.docs) {
          await doc.reference.delete();
        }
      }
    } catch (e) {
      log('Error cancelling call notifications: $e');
    }
  }
}

