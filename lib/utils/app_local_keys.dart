/// Local storage keys for SharedPreferences
/// All keys used for local storage should be defined here
class AppLocalKeys {
  // Authentication Keys
  static const String isLoggedIn = 'is_logged_in';
  static const String savedEmail = 'saved_email';

  // User Data Keys
  static const String userId = 'user_id';
  static const String userName = 'user_name';
  static const String userEmail = 'user_email';
  static const String userPhone = 'user_phone';
  static const String userProfileImage = 'user_profile_image';
  static const String userToken = 'user_token';
  static const String userRefreshToken = 'user_refresh_token';

  // App Settings Keys
  static const String themeMode = 'theme_mode';
  static const String language = 'language';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String soundEnabled = 'sound_enabled';
  static const String vibrationEnabled = 'vibration_enabled';

  // Chat Settings Keys
  static const String lastSeen = 'last_seen';
  static const String readReceipts = 'read_receipts';
  static const String typingIndicator = 'typing_indicator';
  static const String onlineStatus = 'online_status';

  // Cache Keys
  static const String lastSyncTime = 'last_sync_time';
  static const String cachedChats = 'cached_chats';
  static const String cachedContacts = 'cached_contacts';

  // Other Keys
  static const String onboardingCompleted = 'onboarding_completed';
  static const String appVersion = 'app_version';
  static const String deviceId = 'device_id';
  static const String fcmToken = 'fcm_token';
}
