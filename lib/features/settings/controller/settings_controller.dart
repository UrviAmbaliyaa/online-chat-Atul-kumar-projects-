import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:online_chat/navigations/app_navigation.dart';
import 'package:online_chat/navigations/routes.dart';
import 'package:online_chat/services/firebase_service.dart';
import 'package:online_chat/utils/app_color.dart';
import 'package:online_chat/utils/app_local_storage.dart';
import 'package:online_chat/utils/app_snackbar.dart';
import 'package:online_chat/utils/app_string.dart';
import 'package:online_chat/utils/app_text.dart';

class SettingsController extends GetxController {
  // User Data Observables
  final RxString userName = ''.obs;
  final RxString userEmail = ''.obs;
  final RxString userPhone = ''.obs;
  final RxString userProfileImage = ''.obs;

  // Settings Observables
  final RxBool notificationsEnabled = true.obs;
  final RxBool soundEnabled = true.obs;
  final RxBool vibrationEnabled = true.obs;
  final RxBool lastSeenEnabled = true.obs;
  final RxBool readReceiptsEnabled = true.obs;
  final RxBool typingIndicatorEnabled = true.obs;
  final RxBool onlineStatusEnabled = true.obs;
  final RxString selectedTheme = 'light'.obs;
  final RxString selectedLanguage = 'en'.obs;

  // UI State
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    loadSettings();
  }

  /// Load user data from local storage
  void loadUserData() {
    userName.value = AppLocalStorage.getUserName();
    userEmail.value = AppLocalStorage.getUserEmail();
    userPhone.value = AppLocalStorage.getUserPhone();
    userProfileImage.value = AppLocalStorage.getUserProfileImage();
  }

  /// Load settings from local storage
  void loadSettings() {
    notificationsEnabled.value = AppLocalStorage.getNotificationsEnabled();
    soundEnabled.value = AppLocalStorage.getSoundEnabled();
    vibrationEnabled.value = AppLocalStorage.getVibrationEnabled();
    lastSeenEnabled.value = AppLocalStorage.getLastSeen();
    readReceiptsEnabled.value = AppLocalStorage.getReadReceipts();
    typingIndicatorEnabled.value = AppLocalStorage.getTypingIndicator();
    onlineStatusEnabled.value = AppLocalStorage.getOnlineStatus();
    selectedTheme.value = AppLocalStorage.getThemeMode();
    selectedLanguage.value = AppLocalStorage.getLanguage();
    
    // Apply saved theme
    _applyTheme(selectedTheme.value);
  }
  
  /// Apply theme mode
  void _applyTheme(String theme) {
    if (theme == 'dark') {
      Get.changeThemeMode(ThemeMode.dark);
    } else {
      Get.changeThemeMode(ThemeMode.light);
    }
  }

  /// Toggle notifications
  Future<void> toggleNotifications(bool value) async {
    notificationsEnabled.value = value;
    await AppLocalStorage.saveNotificationsEnabled(value);
    await _saveSettings();
  }

  /// Toggle sound
  Future<void> toggleSound(bool value) async {
    soundEnabled.value = value;
    await AppLocalStorage.saveSoundEnabled(value);
    await _saveSettings();
  }

  /// Toggle vibration
  Future<void> toggleVibration(bool value) async {
    vibrationEnabled.value = value;
    await AppLocalStorage.saveVibrationEnabled(value);
    await _saveSettings();
  }

  /// Toggle last seen
  Future<void> toggleLastSeen(bool value) async {
    lastSeenEnabled.value = value;
    await AppLocalStorage.saveLastSeen(value);
    await _saveSettings();
  }

  /// Toggle read receipts
  Future<void> toggleReadReceipts(bool value) async {
    readReceiptsEnabled.value = value;
    await AppLocalStorage.saveReadReceipts(value);
    await _saveSettings();
  }

  /// Toggle typing indicator
  Future<void> toggleTypingIndicator(bool value) async {
    typingIndicatorEnabled.value = value;
    await AppLocalStorage.saveTypingIndicator(value);
    await _saveSettings();
  }

  /// Toggle online status
  Future<void> toggleOnlineStatus(bool value) async {
    onlineStatusEnabled.value = value;
    await AppLocalStorage.saveOnlineStatus(value);
    await _saveSettings();
  }

  /// Change theme
  Future<void> changeTheme(String theme) async {
    selectedTheme.value = theme;
    await AppLocalStorage.saveThemeMode(theme);
    
    // Apply theme immediately
    if (theme == 'dark') {
      Get.changeThemeMode(ThemeMode.dark);
    } else {
      Get.changeThemeMode(ThemeMode.light);
    }
    
    await _saveSettings();
  }

  /// Change language
  Future<void> changeLanguage(String language) async {
    selectedLanguage.value = language;
    await AppLocalStorage.saveLanguage(language);
    await _saveSettings();
  }

  /// Save settings
  Future<void> _saveSettings() async {
    try {
      isSaving.value = true;
      await Future.delayed(const Duration(milliseconds: 300));
      AppSnackbar.success(message: AppString.settingsSaved);
    } catch (e) {
      AppSnackbar.error(message: AppString.settingsSaveError);
    } finally {
      isSaving.value = false;
    }
  }

  /// Navigate to edit profile
  void navigateToEditProfile() {
    // TODO: Navigate to edit profile screen
    AppSnackbar.info(message: AppString.featureComingSoon);
  }

  /// Navigate to change password
  void navigateToChangePassword() {
    AppNavigation.toNamed(AppRoutes.forgotPassword);
  }

  /// Show delete account confirmation
  void showDeleteAccountConfirmation() {
    Get.dialog(
      AlertDialog(
        title: AppText(
          text: AppString.deleteAccount,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        content: AppText(
            text: AppString.deleteAccountConfirmation,
            fontSize: 14,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: AppText(
              text: AppString.no,
              color: AppColor.greyColor,
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _deleteAccount();
            },
            child: AppText(
              text: AppString.yes,
              color: AppColor.redColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Delete account
  Future<void> _deleteAccount() async {
    try {
      isLoading.value = true;
      // TODO: Implement account deletion
      AppSnackbar.info(message: AppString.featureComingSoon);
    } catch (e) {
      AppSnackbar.error(message: AppString.operationFailed);
    } finally {
      isLoading.value = false;
    }
  }

  /// Show logout confirmation
  void showLogoutConfirmation() {
    Get.dialog(
      AlertDialog(
        title: AppText(
          text: AppString.logout,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        content: AppText(
          text: AppString.logoutConfirmation,
          fontSize: 14,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: AppText(
              text: AppString.no,
              color: AppColor.greyColor,
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              logout();
            },
            child: AppText(
              text: AppString.yes,
              color: AppColor.redColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Logout user
  Future<void> logout() async {
    try {
      isLoading.value = true;

      // Sign out from Firebase
      final success = await FirebaseService.signOut();

      if (success) {
        // Clear local storage
        await AppLocalStorage.logout();

        // Show success message
        AppSnackbar.success(message: AppString.logoutSuccess);

        // Navigate to sign in screen
        AppNavigation.replaceAllNamed(AppRoutes.signIn);
      } else {
        AppSnackbar.error(message: AppString.logoutError);
      }
    } catch (e) {
      AppSnackbar.error(message: AppString.logoutError);
    } finally {
      isLoading.value = false;
    }
  }

  /// Navigate to terms of service
  void navigateToTermsOfService() {
    // TODO: Navigate to terms of service screen
    AppSnackbar.info(message: AppString.featureComingSoon);
  }

  /// Navigate to privacy policy
  void navigateToPrivacyPolicy() {
    // TODO: Navigate to privacy policy screen
    AppSnackbar.info(message: AppString.featureComingSoon);
  }

  /// Navigate to help and support
  void navigateToHelpAndSupport() {
    // TODO: Navigate to help and support screen
    AppSnackbar.info(message: AppString.featureComingSoon);
  }

  /// Navigate to report a bug
  void navigateToReportBug() {
    // TODO: Navigate to report bug screen
    AppSnackbar.info(message: AppString.featureComingSoon);
  }
}

