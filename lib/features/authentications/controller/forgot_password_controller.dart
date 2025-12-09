import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:online_chat/navigations/app_navigation.dart';
import 'package:online_chat/services/firebase_service.dart';
import 'package:online_chat/utils/app_validator.dart';

class ForgotPasswordController extends GetxController {
  // Form Key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Text Controllers
  final TextEditingController emailController = TextEditingController();

  // Observables
  final RxBool isLoading = false.obs;
  final RxBool isEmailSent = false.obs;

  // Focus Nodes
  final FocusNode emailFocusNode = FocusNode();

  @override
  void onClose() {
    emailController.dispose();
    emailFocusNode.dispose();
    super.onClose();
  }

  // Email validation
  String? validateEmail(String? value) => AppValidator.validateEmail(value);

  // Handle send reset email
  Future<void> sendResetEmail() async {
    // Unfocus text fields
    emailFocusNode.unfocus();

    // Validate form
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;

      // Send password reset email via Firebase
      final success = await FirebaseService.sendPasswordResetEmail(
        emailController.text,
      );

      if (success) {
        isEmailSent.value = true;
      }
    } catch (e) {
      // Error is already handled in FirebaseService
    } finally {
      isLoading.value = false;
    }
  }

  // Navigate back to sign in
  void navigateToSignIn() {
    AppNavigation.back();
  }

  // Resend email
  void resendEmail() {
    isEmailSent.value = false;
    emailController.clear();
  }
}

