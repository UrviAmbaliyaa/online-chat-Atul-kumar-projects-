import 'package:online_chat/utils/app_string.dart';

/// Firebase Constants - Centralized Firebase configuration
class FirebaseConstants {
  // Collection Names
  static const String userCollection = 'user';
  static const String chatCollection = 'chat';
  static const String groupCollection = 'group';
  static const String messageCollection = 'message';

  // Storage Paths
  static const String profileImagesPath = 'profile_images';
  static const String chatImagesPath = 'chat_images';
  static const String chatVideosPath = 'chat_videos';
  static const String chatFilesPath = 'chat_files';

  // Firebase Auth Error Codes
  static const String authErrorUserNotFound = 'user-not-found';
  static const String authErrorWrongPassword = 'wrong-password';
  static const String authErrorEmailAlreadyInUse = 'email-already-in-use';
  static const String authErrorWeakPassword = 'weak-password';
  static const String authErrorInvalidEmail = 'invalid-email';
  static const String authErrorUserDisabled = 'user-disabled';
  static const String authErrorTooManyRequests = 'too-many-requests';
  static const String authErrorOperationNotAllowed = 'operation-not-allowed';

  // Firebase Firestore Error Codes
  static const String firestoreErrorPermissionDenied = 'permission-denied';
  static const String firestoreErrorNotFound = 'not-found';
  static const String firestoreErrorUnavailable = 'unavailable';
  static const String firestoreErrorDeadlineExceeded = 'deadline-exceeded';

  // Get Auth Error Message
  static String getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case authErrorUserNotFound:
        return AppString.userNotFound;
      case authErrorWrongPassword:
        return AppString.wrongPassword;
      case authErrorEmailAlreadyInUse:
        return AppString.emailAlreadyInUse;
      case authErrorWeakPassword:
        return AppString.weakPassword;
      case authErrorInvalidEmail:
        return AppString.invalidEmail;
      case authErrorUserDisabled:
        return AppString.userDisabled;
      case authErrorTooManyRequests:
        return AppString.tooManyRequests;
      case authErrorOperationNotAllowed:
        return AppString.operationNotAllowed;
      default:
        return AppString.authErrorDefault;
    }
  }

  // Get Firestore Error Message
  static String getFirestoreErrorMessage(String errorCode,
      {String? defaultMessage}) {
    switch (errorCode) {
      case firestoreErrorPermissionDenied:
        return AppString.updateProfilePermissionDenied;
      case firestoreErrorNotFound:
        return AppString.updateProfileNotFound;
      case firestoreErrorUnavailable:
        return AppString.updateProfileUnavailable;
      case firestoreErrorDeadlineExceeded:
        return AppString.updateProfileTimeout;
      default:
        return defaultMessage ?? AppString.profileUpdateError;
    }
  }
}
