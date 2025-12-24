import 'package:get/get.dart';
import 'package:online_chat/features/home/models/user_model.dart';
import 'package:online_chat/services/firebase_service.dart';
import 'package:online_chat/utils/app_local_storage.dart';

/// AppPreference - Legacy wrapper for backward compatibility
/// Use AppLocalStorage for new code
/// This class maintains backward compatibility with existing code
@Deprecated('Use AppLocalStorage instead')
class AppPreference {
  // Reactive UserModel for current user
  static final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  /// Initialize local storage
  /// Must be called before using any storage methods
  static Future<void> init() async {
    await AppLocalStorage.init();
  }

  /// Check if user is logged in
  static bool isUserLogin() {
    return AppLocalStorage.isUserLoggedIn();
  }

  /// Save String value
  static Future<bool> setString(String key, String value) async {
    return await AppLocalStorage.setString(key, value);
  }

  /// Get String value
  static String getString(String key, {String defaultValue = ''}) {
    return AppLocalStorage.getString(key, defaultValue: defaultValue);
  }

  /// Save int value
  static Future<bool> setInt(String key, int value) async {
    return await AppLocalStorage.setInt(key, value);
  }

  /// Get int value
  static int getInt(String key, {int defaultValue = 0}) {
    return AppLocalStorage.getInt(key, defaultValue: defaultValue);
  }

  /// Save double value
  static Future<bool> setDouble(String key, double value) async {
    return await AppLocalStorage.setDouble(key, value);
  }

  /// Get double value
  static double getDouble(String key, {double defaultValue = 0.0}) {
    return AppLocalStorage.getDouble(key, defaultValue: defaultValue);
  }

  /// Save bool value
  static Future<bool> setBool(String key, bool value) async {
    return await AppLocalStorage.setBool(key, value);
  }

  /// Get bool value
  static bool getBool(String key, {bool defaultValue = false}) {
    return AppLocalStorage.getBool(key, defaultValue: defaultValue);
  }

  /// Save String list
  static Future<bool> setStringList(String key, List<String> value) async {
    return await AppLocalStorage.setStringList(key, value);
  }

  /// Get String list
  static List<String> getStringList(String key, {List<String> defaultValue = const []}) {
    return AppLocalStorage.getStringList(key, defaultValue: defaultValue);
  }

  /// Save Map/JSON object
  static Future<bool> setMap(String key, Map<String, dynamic> value) async {
    return await AppLocalStorage.setMap(key, value);
  }

  /// Get Map/JSON object
  static Map<String, dynamic>? getMap(String key) {
    return AppLocalStorage.getMap(key);
  }

  /// Save List of objects
  static Future<bool> setList(String key, List<dynamic> value) async {
    return await AppLocalStorage.setList(key, value);
  }

  /// Get List of objects
  static List<dynamic>? getList(String key) {
    return AppLocalStorage.getList(key);
  }

  /// Save DateTime object
  static Future<bool> setDateTime(String key, DateTime value) async {
    return await AppLocalStorage.setDateTime(key, value);
  }

  /// Get DateTime object
  static DateTime? getDateTime(String key) {
    return AppLocalStorage.getDateTime(key);
  }

  // ==================== USER MODEL METHODS ====================

  /// Load current user model from Firebase
  /// This should be called on app start or after login
  static Future<void> loadCurrentUser() async {
    try {
      final userModel = await FirebaseService.getCurrentUserModel();
      if (userModel != null) {
        currentUser.value = userModel;
        // Also update local storage
        await AppLocalStorage.saveUserName(userModel.name);
        await AppLocalStorage.saveUserEmail(userModel.email);
        if (userModel.phone != null) {
          await AppLocalStorage.saveUserPhone(userModel.phone!);
        }
        if (userModel.profileImage != null) {
          await AppLocalStorage.saveUserProfileImage(userModel.profileImage!);
        }
      }
    } catch (e) {
      // Handle error silently or log it
      currentUser.value = null;
    }
  }

  /// Update current user model
  /// This should be called whenever user data is updated
  static void updateCurrentUser(UserModel userModel) {
    currentUser.value = userModel;
  }

  /// Clear current user model
  /// This should be called on logout
  static void clearCurrentUser() {
    currentUser.value = null;
  }

  /// Get current user model
  static UserModel? getCurrentUser() {
    return currentUser.value;
  }
}
