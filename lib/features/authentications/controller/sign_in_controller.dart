import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:online_chat/navigations/app_navigation.dart';
import 'package:online_chat/navigations/routes.dart';
import 'package:online_chat/services/firebase_service.dart';
import 'package:online_chat/utils/app_local_storage.dart';
import 'package:online_chat/utils/app_preference.dart';
import 'package:online_chat/utils/app_snackbar.dart';
import 'package:online_chat/utils/app_string.dart';
import 'package:online_chat/utils/app_validator.dart';

class SignInController extends GetxController {
  // Form Key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Text Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Observables
  final RxBool isPasswordVisible = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool rememberMe = false.obs;

  // Focus Nodes
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  @override
  void onInit() {
    super.onInit();
    // Load saved email if exists
    final savedEmail = AppLocalStorage.getSavedEmail();
    if (savedEmail.isNotEmpty) {
      emailController.text = savedEmail;
      rememberMe.value = true;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.onClose();
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // Toggle remember me
  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
  }

  // Email validation
  String? validateEmail(String? value) => AppValidator.validateEmail(value);

  // Password validation
  String? validatePassword(String? value) =>
      AppValidator.validatePassword(value);

  // Handle sign in
  Future<void> signIn() async {
    // Unfocus text fields
    emailFocusNode.unfocus();
    passwordFocusNode.unfocus();

    // Validate form
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;

      // Sign in with Firebase
      final userCredential = await FirebaseService.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      if (userCredential?.user != null) {
        // Get user data from Firestore
        final userData =
            await FirebaseService.getUserDocument(userCredential!.user!.uid);

        // Save email if remember me is checked
        if (rememberMe.value) {
          await AppLocalStorage.saveSavedEmail(emailController.text);
        } else {
          await AppLocalStorage.clearSavedEmail();
        }

        // Save login status and user data to local storage
        await AppLocalStorage.setUserLoggedIn(true);
        await AppLocalStorage.saveUserData(
          userId: userCredential.user!.uid,
          userEmail: userCredential.user!.email ?? emailController.text,
          userName: userData?['name'] ?? '',
          userPhone: userData?['phone'] ?? '',
          userProfileImage: userData?['profileImage'] ?? '',
        );

        // Load current user model into AppPreference
        await AppPreference.loadCurrentUser();

        // Show success message
        AppSnackbar.success(
          message: AppString.signInSuccess,
          duration: const Duration(seconds: 2),
        );

        // Navigate to home screen
        AppNavigation.offNamed(AppRoutes.homeScreen);
      }
    } catch (e) {
      // Error is already handled in FirebaseService
    } finally {
      isLoading.value = false;
    }
  }

  // Navigate to sign up
  void navigateToSignUp() {
    AppNavigation.offNamed(AppRoutes.signUp);
  }

  // Navigate to forgot password
  void navigateToForgotPassword() {
    AppNavigation.toNamed(AppRoutes.forgotPassword);
  }
}
