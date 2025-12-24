import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? profileImage;
  final bool isOnline;
  final DateTime? lastSeen;
  final String? countryCode;
  final String? dialCode;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profileImage,
    this.isOnline = false,
    this.lastSeen,
    this.countryCode,
    this.dialCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profileImage': profileImage, // Only include if not null
      'isOnline': isOnline,
      'lastSeen': lastSeen?.toIso8601String(),
      'countryCode': countryCode, // Only include if not null
      'dialCode': dialCode, // Only include if not null
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      profileImage: json['profileImage'],
      isOnline: json['isOnline'] ?? false,
      lastSeen: json['lastSeen'] != null ? DateTime.parse(json['lastSeen']) : null,
      countryCode: json['countryCode'],
      dialCode: json['dialCode'],
    );
  }

  /// Create from Firestore document (includes document ID)
  factory UserModel.fromFirestore(Map<String, dynamic> json, String documentId) {
    return UserModel(
      id: documentId,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      profileImage: json['profileImage'],
      isOnline: json['isOnline'] ?? false,
      lastSeen: json['lastSeen'] != null
          ? (json['lastSeen'] is Timestamp ? (json['lastSeen'] as Timestamp).toDate() : DateTime.parse(json['lastSeen']))
          : null,
      countryCode: json['countryCode'],
      dialCode: json['dialCode'],
    );
  }

  /// Copy with method for updating fields
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    bool? isOnline,
    DateTime? lastSeen,
    String? countryCode,
    String? dialCode,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      countryCode: countryCode ?? this.countryCode,
      dialCode: dialCode ?? this.dialCode,
    );
  }
}
