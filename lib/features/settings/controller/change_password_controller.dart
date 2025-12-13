import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:online_chat/navigations/app_navigation.dart';
import 'package:online_chat/services/firebase_service.dart';
import 'package:online_chat/utils/app_snackbar.dart';
import 'package:online_chat/utils/app_string.dart';

class ChangePasswordController extends GetxController {
  // Form Key
  final formKey = GlobalKey<FormState>();

  // Text Controllers
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Focus Nodes
  final currentPasswordFocusNode = FocusNode();
  final newPasswordFocusNode = FocusNode();
  final confirmPasswordFocusNode = FocusNode();

  // Observables
  final RxBool isCurrentPasswordVisible = false.obs;
  final RxBool isNewPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;
  final RxBool isChanging = false.obs;


  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    currentPasswordFocusNode.dispose();
    newPasswordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    super.onClose();
  }

  /// Toggle current password visibility
  void toggleCurrentPasswordVisibility() {
    isCurrentPasswordVisible.value = !isCurrentPasswordVisible.value;
  }

  /// Toggle new password visibility
  void toggleNewPasswordVisibility() {
    isNewPasswordVisible.value = !isNewPasswordVisible.value;
  }

  /// Toggle confirm password visibility
  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  /// Validate current password
  String? validateCurrentPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppString.currentPasswordRequired;
    }
    if (value.length < 6) {
      return AppString.weakPasswordError;
    }
    return null;
  }

  /// Validate new password
  String? validateNewPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppString.newPasswordRequired;
    }
    if (value.length < 6) {
      return AppString.weakPasswordError;
    }
    // Check if new password is same as current password
    if (value == currentPasswordController.text.trim()) {
      return AppString.samePasswordError;
    }
    return null;
  }

  /// Validate confirm password
  String? validateConfirmPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppString.confirmPasswordRequired;
    }
    if (value != newPasswordController.text.trim()) {
      return AppString.passwordsDoNotMatch;
    }
    return null;
  }

  /// Change password
  Future<void> changePassword() async {
    // Unfocus text fields
    currentPasswordFocusNode.unfocus();
    newPasswordFocusNode.unfocus();
    confirmPasswordFocusNode.unfocus();

    // Validate form
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isChanging.value = true;

      final currentPassword = currentPasswordController.text.trim();
      final newPassword = newPasswordController.text.trim();

      // Change password using Firebase Service
      final success = await FirebaseService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (success) {
        // Clear form
        currentPasswordController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();

        // Navigate back
        AppNavigation.back();
      }
    } catch (e) {
      AppSnackbar.error(message: AppString.passwordChangeError);
    } finally {
      isChanging.value = false;
    }
  }
}
