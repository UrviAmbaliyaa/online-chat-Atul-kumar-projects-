import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:online_chat/utils/app_local_keys.dart';

/// Common local storage management utility
/// Provides centralized methods for managing local data storage
class AppLocalStorage {
  static late SharedPreferences _prefs;

  /// Initialize SharedPreferences
  /// Must be called before using any storage methods
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ==================== AUTHENTICATION METHODS ====================

  /// Check if user is logged in
  static bool isUserLoggedIn() {
    return _prefs.getBool(AppLocalKeys.isLoggedIn) ?? false;
  }

  /// Set user login status
  static Future<bool> setUserLoggedIn(bool value) async {
    return await _prefs.setBool(AppLocalKeys.isLoggedIn, value);
  }

  /// Save user email
  static Future<bool> saveUserEmail(String email) async {
    return await _prefs.setString(AppLocalKeys.userEmail, email);
  }

  /// Get user email
  static String getUserEmail() {
    return _prefs.getString(AppLocalKeys.userEmail) ?? '';
  }

  /// Save saved email (for remember me feature)
  static Future<bool> saveSavedEmail(String email) async {
    return await _prefs.setString(AppLocalKeys.savedEmail, email);
  }

  /// Get saved email
  static String getSavedEmail() {
    return _prefs.getString(AppLocalKeys.savedEmail) ?? '';
  }

  /// Clear saved email
  static Future<bool> clearSavedEmail() async {
    return await _prefs.remove(AppLocalKeys.savedEmail);
  }

  // ==================== USER DATA METHODS ====================

  /// Save user ID
  static Future<bool> saveUserId(String userId) async {
    return await _prefs.setString(AppLocalKeys.userId, userId);
  }

  /// Get user ID
  static String getUserId() {
    return _prefs.getString(AppLocalKeys.userId) ?? '';
  }

  /// Save user name
  static Future<bool> saveUserName(String name) async {
    return await _prefs.setString(AppLocalKeys.userName, name);
  }

  /// Get user name
  static String getUserName() {
    return _prefs.getString(AppLocalKeys.userName) ?? '';
  }

  /// Save user phone
  static Future<bool> saveUserPhone(String phone) async {
    return await _prefs.setString(AppLocalKeys.userPhone, phone);
  }

  /// Get user phone
  static String getUserPhone() {
    return _prefs.getString(AppLocalKeys.userPhone) ?? '';
  }

  /// Save user profile image path
  static Future<bool> saveUserProfileImage(String imagePath) async {
    return await _prefs.setString(AppLocalKeys.userProfileImage, imagePath);
  }

  /// Get user profile image path
  static String getUserProfileImage() {
    return _prefs.getString(AppLocalKeys.userProfileImage) ?? '';
  }

  /// Save user token
  static Future<bool> saveUserToken(String token) async {
    return await _prefs.setString(AppLocalKeys.userToken, token);
  }

  /// Get user token
  static String getUserToken() {
    return _prefs.getString(AppLocalKeys.userToken) ?? '';
  }

  /// Save user refresh token
  static Future<bool> saveUserRefreshToken(String token) async {
    return await _prefs.setString(AppLocalKeys.userRefreshToken, token);
  }

  /// Get user refresh token
  static String getUserRefreshToken() {
    return _prefs.getString(AppLocalKeys.userRefreshToken) ?? '';
  }

  /// Save complete user data
  static Future<bool> saveUserData({
    String? userId,
    String? userName,
    String? userEmail,
    String? userPhone,
    String? userProfileImage,
    String? userToken,
  }) async {
    bool success = true;
    if (userId != null) {
      success = success && await saveUserId(userId);
    }
    if (userName != null) {
      success = success && await saveUserName(userName);
    }
    if (userEmail != null) {
      success = success && await saveUserEmail(userEmail);
    }
    if (userPhone != null) {
      success = success && await saveUserPhone(userPhone);
    }
    if (userProfileImage != null) {
      success = success && await saveUserProfileImage(userProfileImage);
    }
    if (userToken != null) {
      success = success && await saveUserToken(userToken);
    }
    return success;
  }

  /// Clear all user data
  static Future<bool> clearUserData() async {
    bool success = true;
    success = success && await _prefs.remove(AppLocalKeys.userId);
    success = success && await _prefs.remove(AppLocalKeys.userName);
    success = success && await _prefs.remove(AppLocalKeys.userEmail);
    success = success && await _prefs.remove(AppLocalKeys.userPhone);
    success = success && await _prefs.remove(AppLocalKeys.userProfileImage);
    success = success && await _prefs.remove(AppLocalKeys.userToken);
    success = success && await _prefs.remove(AppLocalKeys.userRefreshToken);
    return success;
  }

  /// Logout user (clear login status and user data)
  static Future<bool> logout() async {
    bool success = await setUserLoggedIn(false);
    success = success && await clearUserData();
    return success;
  }

  // ==================== APP SETTINGS METHODS ====================

  /// Save theme mode
  static Future<bool> saveThemeMode(String themeMode) async {
    return await _prefs.setString(AppLocalKeys.themeMode, themeMode);
  }

  /// Get theme mode
  static String getThemeMode({String defaultValue = 'light'}) {
    return _prefs.getString(AppLocalKeys.themeMode) ?? defaultValue;
  }

  /// Save language
  static Future<bool> saveLanguage(String language) async {
    return await _prefs.setString(AppLocalKeys.language, language);
  }

  /// Get language
  static String getLanguage({String defaultValue = 'en'}) {
    return _prefs.getString(AppLocalKeys.language) ?? defaultValue;
  }

  /// Save notifications enabled status
  static Future<bool> saveNotificationsEnabled(bool enabled) async {
    return await _prefs.setBool(AppLocalKeys.notificationsEnabled, enabled);
  }

  /// Get notifications enabled status
  static bool getNotificationsEnabled({bool defaultValue = true}) {
    return _prefs.getBool(AppLocalKeys.notificationsEnabled) ?? defaultValue;
  }

  /// Save sound enabled status
  static Future<bool> saveSoundEnabled(bool enabled) async {
    return await _prefs.setBool(AppLocalKeys.soundEnabled, enabled);
  }

  /// Get sound enabled status
  static bool getSoundEnabled({bool defaultValue = true}) {
    return _prefs.getBool(AppLocalKeys.soundEnabled) ?? defaultValue;
  }

  /// Save vibration enabled status
  static Future<bool> saveVibrationEnabled(bool enabled) async {
    return await _prefs.setBool(AppLocalKeys.vibrationEnabled, enabled);
  }

  /// Get vibration enabled status
  static bool getVibrationEnabled({bool defaultValue = true}) {
    return _prefs.getBool(AppLocalKeys.vibrationEnabled) ?? defaultValue;
  }

  // ==================== CHAT SETTINGS METHODS ====================

  /// Save last seen visibility
  static Future<bool> saveLastSeen(bool visible) async {
    return await _prefs.setBool(AppLocalKeys.lastSeen, visible);
  }

  /// Get last seen visibility
  static bool getLastSeen({bool defaultValue = true}) {
    return _prefs.getBool(AppLocalKeys.lastSeen) ?? defaultValue;
  }

  /// Save read receipts enabled
  static Future<bool> saveReadReceipts(bool enabled) async {
    return await _prefs.setBool(AppLocalKeys.readReceipts, enabled);
  }

  /// Get read receipts enabled
  static bool getReadReceipts({bool defaultValue = true}) {
    return _prefs.getBool(AppLocalKeys.readReceipts) ?? defaultValue;
  }

  /// Save typing indicator enabled
  static Future<bool> saveTypingIndicator(bool enabled) async {
    return await _prefs.setBool(AppLocalKeys.typingIndicator, enabled);
  }

  /// Get typing indicator enabled
  static bool getTypingIndicator({bool defaultValue = true}) {
    return _prefs.getBool(AppLocalKeys.typingIndicator) ?? defaultValue;
  }

  /// Save online status visibility
  static Future<bool> saveOnlineStatus(bool visible) async {
    return await _prefs.setBool(AppLocalKeys.onlineStatus, visible);
  }

  /// Get online status visibility
  static bool getOnlineStatus({bool defaultValue = true}) {
    return _prefs.getBool(AppLocalKeys.onlineStatus) ?? defaultValue;
  }

  // ==================== GENERIC METHODS ====================

  /// Save String value
  static Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  /// Get String value
  static String getString(String key, {String defaultValue = ''}) {
    return _prefs.getString(key) ?? defaultValue;
  }

  /// Save int value
  static Future<bool> setInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }

  /// Get int value
  static int getInt(String key, {int defaultValue = 0}) {
    return _prefs.getInt(key) ?? defaultValue;
  }

  /// Save double value
  static Future<bool> setDouble(String key, double value) async {
    return await _prefs.setDouble(key, value);
  }

  /// Get double value
  static double getDouble(String key, {double defaultValue = 0.0}) {
    return _prefs.getDouble(key) ?? defaultValue;
  }

  /// Save bool value
  static Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  /// Get bool value
  static bool getBool(String key, {bool defaultValue = false}) {
    return _prefs.getBool(key) ?? defaultValue;
  }

  /// Save String list
  static Future<bool> setStringList(String key, List<String> value) async {
    return await _prefs.setStringList(key, value);
  }

  /// Get String list
  static List<String> getStringList(String key,
      {List<String> defaultValue = const []}) {
    return _prefs.getStringList(key) ?? defaultValue;
  }

  /// Save Map/JSON object (converted to JSON string)
  static Future<bool> setMap(String key, Map<String, dynamic> value) async {
    final jsonString = jsonEncode(value);
    return await _prefs.setString(key, jsonString);
  }

  /// Get Map/JSON object
  static Map<String, dynamic>? getMap(String key) {
    final jsonString = _prefs.getString(key);
    if (jsonString != null) {
      try {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Save List of objects (converted to JSON string)
  static Future<bool> setList(String key, List<dynamic> value) async {
    final jsonString = jsonEncode(value);
    return await _prefs.setString(key, jsonString);
  }

  /// Get List of objects
  static List<dynamic>? getList(String key) {
    final jsonString = _prefs.getString(key);
    if (jsonString != null) {
      try {
        return jsonDecode(jsonString) as List<dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Save DateTime object
  static Future<bool> setDateTime(String key, DateTime value) async {
    return await _prefs.setString(key, value.toIso8601String());
  }

  /// Get DateTime object
  static DateTime? getDateTime(String key) {
    final dateString = _prefs.getString(key);
    if (dateString != null) {
      try {
        return DateTime.parse(dateString);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Remove a key
  static Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  /// Clear all data
  static Future<bool> clear() async {
    return await _prefs.clear();
  }

  /// Check if key exists
  static bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  /// Get all keys
  static Set<String> getKeys() {
    return _prefs.getKeys();
  }
}

