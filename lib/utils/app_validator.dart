import 'package:get/get.dart';
import 'package:online_chat/utils/app_string.dart';

/// Common validation utility class for form fields
/// Provides reusable validation methods throughout the app
class AppValidator {
  /// Validates email field
  /// Returns error message if invalid, null if valid
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppString.emailRequired;
    }
    if (!GetUtils.isEmail(value)) {
      return AppString.emailInvalid;
    }
    return null;
  }

  /// Validates password field
  /// [minLength] - Minimum password length (default: 6)
  /// Returns error message if invalid, null if valid
  static String? validatePassword(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return AppString.passwordRequired;
    }
    if (value.length < minLength) {
      return AppString.passwordMinLength;
    }
    return null;
  }

  /// Validates name field
  /// [minLength] - Minimum name length (default: 3)
  /// Returns error message if invalid, null if valid
  static String? validateName(String? value, {int minLength = 3}) {
    if (value == null || value.isEmpty) {
      return AppString.nameRequired;
    }
    if (value.trim().length < minLength) {
      return AppString.nameMinLength;
    }
    return null;
  }

  /// Validates confirm password field
  /// [password] - The original password to match against
  /// Returns error message if invalid, null if valid
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return AppString.confirmPasswordRequired;
    }
    if (value != password) {
      return AppString.passwordsDoNotMatch;
    }
    return null;
  }

  /// Validates required field
  /// [fieldName] - Name of the field for error message
  /// Returns error message if invalid, null if valid
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates phone number
  /// [minLength] - Minimum phone number length (default: 10)
  /// Returns error message if invalid, null if valid
  static String? validatePhone(String? value, {int minLength = 10}) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    // Remove common phone number characters
    final cleanedValue = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleanedValue.length < minLength) {
      return 'Phone number must be at least $minLength digits';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(cleanedValue)) {
      return 'Phone number must contain only digits';
    }
    return null;
  }

  /// Validates URL
  /// Returns error message if invalid, null if valid
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'URL is required';
    }
    final urlPattern = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    if (!urlPattern.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    return null;
  }

  /// Validates numeric value
  /// Returns error message if invalid, null if valid
  static String? validateNumeric(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }

  /// Validates minimum length
  /// [minLength] - Minimum required length
  /// [fieldName] - Name of the field for error message
  /// Returns error message if invalid, null if valid
  static String? validateMinLength(
      String? value, int minLength, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    return null;
  }

  /// Validates maximum length
  /// [maxLength] - Maximum allowed length
  /// [fieldName] - Name of the field for error message
  /// Returns error message if invalid, null if valid
  static String? validateMaxLength(
      String? value, int maxLength, String fieldName) {
    if (value != null && value.length > maxLength) {
      return '$fieldName must not exceed $maxLength characters';
    }
    return null;
  }

  /// Validates that value matches a pattern
  /// [pattern] - Regular expression pattern
  /// [errorMessage] - Error message to display
  /// Returns error message if invalid, null if valid
  static String? validatePattern(
      String? value, RegExp pattern, String errorMessage) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    if (!pattern.hasMatch(value)) {
      return errorMessage;
    }
    return null;
  }

  /// Validates age (must be a number between min and max)
  /// [minAge] - Minimum age (default: 13)
  /// [maxAge] - Maximum age (default: 120)
  /// Returns error message if invalid, null if valid
  static String? validateAge(String? value,
      {int minAge = 13, int maxAge = 120}) {
    if (value == null || value.isEmpty) {
      return 'Age is required';
    }
    final age = int.tryParse(value);
    if (age == null) {
      return 'Please enter a valid age';
    }
    if (age < minAge) {
      return 'Age must be at least $minAge';
    }
    if (age > maxAge) {
      return 'Age must not exceed $maxAge';
    }
    return null;
  }

  /// Validates OTP code (typically 4-6 digits)
  /// [length] - Expected OTP length (default: 6)
  /// Returns error message if invalid, null if valid
  static String? validateOtp(String? value, {int length = 6}) {
    if (value == null || value.isEmpty) {
      return 'OTP is required';
    }
    if (value.length != length) {
      return 'OTP must be $length digits';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'OTP must contain only digits';
    }
    return null;
  }

  /// Validates that two values match
  /// [value1] - First value
  /// [value2] - Second value to match
  /// [fieldName] - Name of the field for error message
  /// Returns error message if invalid, null if valid
  static String? validateMatch(
      String? value1, String? value2, String fieldName) {
    if (value1 == null || value1.isEmpty) {
      return '$fieldName is required';
    }
    if (value1 != value2) {
      return '$fieldName does not match';
    }
    return null;
  }
}
