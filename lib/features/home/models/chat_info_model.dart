import 'package:cloud_firestore/cloud_firestore.dart';

class ChatInfoModel {
  final String chatId;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;

  ChatInfoModel({
    required this.chatId,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'chatId': chatId,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime?.toIso8601String(),
      'unreadCount': unreadCount,
    };
  }

  factory ChatInfoModel.fromJson(Map<String, dynamic> json) {
    return ChatInfoModel(
      chatId: json['chatId'] ?? '',
      lastMessage: json['lastMessage'],
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.parse(json['lastMessageTime'])
          : null,
      unreadCount: json['unreadCount'] ?? 0,
    );
  }

  factory ChatInfoModel.fromFirestore(
    Map<String, dynamic> data,
    String chatId,
    String currentUserId,
  ) {
    final messages = List<Map<String, dynamic>>.from(data['messages'] ?? []);
    
    // Count unread messages (messages not read by current user)
    int unreadCount = 0;
    for (var message in messages) {
      final readBy = List<String>.from(message['readBy'] ?? []);
      final senderId = message['senderId'] as String?;
      
      // Count as unread if:
      // 1. Current user didn't send it
      // 2. Current user hasn't read it
      if (senderId != currentUserId && !readBy.contains(currentUserId)) {
        unreadCount++;
      }
    }

    final lastMessageTime = data['lastMessageTime'];
    DateTime? lastMessageDateTime;
    if (lastMessageTime != null) {
      if (lastMessageTime is Timestamp) {
        lastMessageDateTime = lastMessageTime.toDate();
      } else if (lastMessageTime is String) {
        lastMessageDateTime = DateTime.parse(lastMessageTime);
      }
    }

    return ChatInfoModel(
      chatId: chatId,
      lastMessage: data['lastMessage'] as String?,
      lastMessageTime: lastMessageDateTime,
      unreadCount: unreadCount,
    );
  }
}

