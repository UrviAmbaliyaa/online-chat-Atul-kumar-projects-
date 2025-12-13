import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  text,
  image,
  file,
}

enum ChatType {
  oneToOne,
  group,
}

class MessageModel {
  final String id;
  final String chatId; // For one-to-one: combination of user IDs, For group: group ID
  final String senderId;
  final String senderName;
  final String? senderImage;
  final String message;
  final MessageType type;
  final ChatType chatType;
  final String? imageUrl;
  final String? fileUrl;
  final String? fileName;
  final String? fileSize;
  final String? fileExtension;
  final String? replyToMessageId;
  final String? replyToMessage;
  final String? replyToSenderName;
  final DateTime timestamp;
  final bool isRead;
  final List<String> readBy; // List of user IDs who read the message

  MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    this.senderImage,
    required this.message,
    required this.type,
    required this.chatType,
    this.imageUrl,
    this.fileUrl,
    this.fileName,
    this.fileSize,
    this.fileExtension,
    this.replyToMessageId,
    this.replyToMessage,
    this.replyToSenderName,
    required this.timestamp,
    this.isRead = false,
    this.readBy = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'senderImage': senderImage,
      'message': message,
      'type': type.name,
      'chatType': chatType.name,
      'imageUrl': imageUrl,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'fileSize': fileSize,
      'fileExtension': fileExtension,
      'replyToMessageId': replyToMessageId,
      'replyToMessage': replyToMessage,
      'replyToSenderName': replyToSenderName,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'readBy': readBy,
    };
  }

  factory MessageModel.fromJson(Map<String, dynamic> json, String documentId) {
    return MessageModel(
      id: documentId,
      chatId: json['chatId'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      senderImage: json['senderImage'],
      message: json['message'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.text,
      ),
      chatType: ChatType.values.firstWhere(
        (e) => e.name == json['chatType'],
        orElse: () => ChatType.oneToOne,
      ),
      imageUrl: json['imageUrl'],
      fileUrl: json['fileUrl'],
      fileName: json['fileName'],
      fileSize: json['fileSize'],
      fileExtension: json['fileExtension'],
      replyToMessageId: json['replyToMessageId'],
      replyToMessage: json['replyToMessage'],
      replyToSenderName: json['replyToSenderName'],
      timestamp: json['timestamp'] is Timestamp
          ? (json['timestamp'] as Timestamp).toDate()
          : DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
      readBy: List<String>.from(json['readBy'] ?? []),
    );
  }

  MessageModel copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? senderName,
    String? senderImage,
    String? message,
    MessageType? type,
    ChatType? chatType,
    String? imageUrl,
    String? fileUrl,
    String? fileName,
    String? fileSize,
    String? fileExtension,
    String? replyToMessageId,
    String? replyToMessage,
    String? replyToSenderName,
    DateTime? timestamp,
    bool? isRead,
    List<String>? readBy,
  }) {
    return MessageModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderImage: senderImage ?? this.senderImage,
      message: message ?? this.message,
      type: type ?? this.type,
      chatType: chatType ?? this.chatType,
      imageUrl: imageUrl ?? this.imageUrl,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      fileExtension: fileExtension ?? this.fileExtension,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      replyToMessage: replyToMessage ?? this.replyToMessage,
      replyToSenderName: replyToSenderName ?? this.replyToSenderName,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      readBy: readBy ?? this.readBy,
    );
  }
}

