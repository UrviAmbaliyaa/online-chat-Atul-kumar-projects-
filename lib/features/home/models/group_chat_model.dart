class GroupChatModel {
  final String id;
  final String name;
  final String? description;
  final String? groupImage;
  final String createdBy;
  final DateTime createdAt;
  final List<String> members;
  final int memberCount;
  final String? lastMessage;
  final DateTime? lastMessageTime;

  GroupChatModel({
    required this.id,
    required this.name,
    this.description,
    this.groupImage,
    required this.createdBy,
    required this.createdAt,
    required this.members,
    required this.memberCount,
    this.lastMessage,
    this.lastMessageTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'groupImage': groupImage,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'members': members,
      'memberCount': memberCount,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime?.toIso8601String(),
    };
  }

  factory GroupChatModel.fromJson(Map<String, dynamic> json) {
    return GroupChatModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      groupImage: json['groupImage'],
      createdBy: json['createdBy'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      members: List<String>.from(json['members'] ?? []),
      memberCount: json['memberCount'] ?? 0,
      lastMessage: json['lastMessage'],
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.parse(json['lastMessageTime'])
          : null,
    );
  }
}
