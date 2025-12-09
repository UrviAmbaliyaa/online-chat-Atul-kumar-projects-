import 'package:online_chat/features/home/models/user_model.dart';
import 'package:online_chat/utils/country_code_picker.dart';

/// Model for editing user profile
/// Contains only editable fields
class EditProfileModel {
  final String name;
  final String phone;
  final String countryCode;
  final String dialCode;
  final String? profileImage;

  EditProfileModel({
    required this.name,
    required this.phone,
    required this.countryCode,
    required this.dialCode,
    this.profileImage,
  });

  /// Convert to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'countryCode': countryCode,
      'dialCode': dialCode,
      if (profileImage != null) 'profileImage': profileImage,
    };
  }

  /// Create from UserModel
  factory EditProfileModel.fromUserModel(UserModel user) {
    // Use country code and dial code from user model if available
    String countryCode = user.countryCode ?? 'US';
    String dialCode = user.dialCode ?? '+1';
    String phone = user.phone ?? '';

    // If phone has dial code prefix, remove it
    if (phone.startsWith(dialCode)) {
      phone = phone.substring(dialCode.length);
    } else if (phone.startsWith('+')) {
      // Try to extract from phone number
      for (var country in CountryCodePicker.countries) {
        if (phone.startsWith(country.dialCode)) {
          countryCode = country.code;
          dialCode = country.dialCode;
          phone = phone.substring(country.dialCode.length);
          break;
        }
      }
    }

    return EditProfileModel(
      name: user.name,
      phone: phone,
      countryCode: countryCode,
      dialCode: dialCode,
      profileImage: user.profileImage,
    );
  }

  /// Create from Map (from Firebase)
  factory EditProfileModel.fromJson(Map<String, dynamic> json) {
    return EditProfileModel(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      countryCode: json['countryCode'] ?? 'US',
      dialCode: json['dialCode'] ?? '+1',
      profileImage: json['profileImage'],
    );
  }

  /// Convert to UserModel (for updating)
  /// [userId] - User ID
  /// [email] - User email (not editable)
  UserModel toUserModel({
    required String userId,
    required String email,
    bool isOnline = false,
    DateTime? lastSeen,
  }) {
    return UserModel(
      id: userId,
      name: name,
      email: email,
      phone: '$dialCode$phone',
      profileImage: profileImage,
      isOnline: isOnline,
      lastSeen: lastSeen,
      countryCode: countryCode,
      dialCode: dialCode,
    );
  }

  /// Copy with method for updating fields
  EditProfileModel copyWith({
    String? name,
    String? phone,
    String? countryCode,
    String? dialCode,
    String? profileImage,
  }) {
    return EditProfileModel(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      countryCode: countryCode ?? this.countryCode,
      dialCode: dialCode ?? this.dialCode,
      profileImage: profileImage ?? this.profileImage,
    );
  }
}
