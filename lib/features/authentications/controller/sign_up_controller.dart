import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:online_chat/navigations/app_navigation.dart';
import 'package:online_chat/navigations/routes.dart';
import 'package:online_chat/services/firebase_service.dart';
import 'package:online_chat/utils/app_image_picker.dart';
import 'package:online_chat/utils/app_local_storage.dart';
import 'package:online_chat/utils/app_snackbar.dart';
import 'package:online_chat/utils/app_string.dart';
import 'package:online_chat/utils/app_validator.dart';
import 'package:online_chat/utils/country_code_picker.dart';
import 'package:online_chat/utils/phone_number_formatter.dart';

class SignUpController extends GetxController {
  // Form Key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Text Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Observables
  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool agreeToTerms = false.obs;
  final Rx<CountryCode> selectedCountry = CountryCodePicker.countries[0].obs;
  final Rx<File?> profileImage = Rx<File?>(null);

  // Focus Nodes
  final FocusNode nameFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode phoneFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmPasswordFocusNode = FocusNode();

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameFocusNode.dispose();
    emailFocusNode.dispose();
    phoneFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    super.onClose();
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // Toggle confirm password visibility
  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  // Toggle terms agreement
  void toggleAgreeToTerms() {
    agreeToTerms.value = !agreeToTerms.value;
  }

  // Name validation
  String? validateName(String? value) => AppValidator.validateName(value);

  // Email validation
  String? validateEmail(String? value) => AppValidator.validateEmail(value);

  // Password validation
  String? validatePassword(String? value) =>
      AppValidator.validatePassword(value);

  // Confirm password validation
  String? validateConfirmPassword(String? value) =>
      AppValidator.validateConfirmPassword(value, passwordController.text);

  // Phone validation
  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return AppString.phoneRequired;
    }
    // Remove formatting characters before validation
    final cleanedValue = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    return AppValidator.validatePhone(cleanedValue);
  }

  // Pick profile image from gallery
  Future<void> pickProfileImage() async {
    final image = await AppImagePicker.pickImageFromGallery();
    if (image != null) {
      profileImage.value = image;
    }
  }

  // Pick profile image from camera
  Future<void> pickProfileImageFromCamera() async {
    final image = await AppImagePicker.pickImageFromCamera();
    if (image != null) {
      profileImage.value = image;
    }
  }

  // Remove profile image
  void removeProfileImage() {
    profileImage.value = null;
  }

  // Show image source selection dialog
  void showImageSourceDialog() {
    AppImagePicker.showImageSourceDialog(
      onGallerySelected: (image) {
        profileImage.value = image;
      },
      onCameraSelected: (image) {
        profileImage.value = image;
      },
    );
  }

  // Update selected country
  void updateSelectedCountry(CountryCode country) {
    selectedCountry.value = country;
    // Clear phone number when country changes to avoid format conflicts
    phoneController.clear();
  }

  // Get phone number formatter based on selected country
  List<TextInputFormatter> getPhoneFormatters() {
    return [PhoneNumberFormatter.getFormatter(selectedCountry.value)];
  }

  // Get max length for phone number based on selected country
  int? getPhoneMaxLength() {
    return PhoneNumberFormatter.getMaxLength(selectedCountry.value);
  }

  // Handle sign up
  Future<void> signUp() async {
    // Unfocus text fields
    nameFocusNode.unfocus();
    emailFocusNode.unfocus();
    passwordFocusNode.unfocus();
    confirmPasswordFocusNode.unfocus();

    // Validate form
    if (!formKey.currentState!.validate()) {
      return;
    }

    // Check terms agreement
    // if (!agreeToTerms.value) {
    //   AppSnackbar.error(
    //     message: AppString.termsRequired,
    //   );
    //   return;
    // }

    try {
      isLoading.value = true;

      // Remove formatting from phone number
      final cleanedPhone =
          phoneController.text.replaceAll(RegExp(r'[\s\-\(\)]'), '');
      final fullPhoneNumber = '${selectedCountry.value.dialCode}$cleanedPhone';

      // Step 1: Create user with Firebase Authentication
      final userCredential = await FirebaseService.signUpWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      if (userCredential?.user == null) {
        return; // Error already handled in FirebaseService
      }

      final userId = userCredential!.user!.uid;
      String? profileImageUrl;

      // Step 2: Upload profile image if exists
      if (profileImage.value != null) {
        final imagePath =
            'profile_images/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
        profileImageUrl = await FirebaseService.uploadFile(
          file: profileImage.value!,
          path: imagePath,
        );
      }

      // Step 3: Create user document in Firestore "user" collection
      final userData = {
        'name': nameController.text,
        'email': emailController.text,
        'phone': fullPhoneNumber,
        'countryCode': selectedCountry.value.code,
        'dialCode': selectedCountry.value.dialCode,
        'profileImage': profileImageUrl ?? "",
        'isOnline': false,
      };

      final success = await FirebaseService.createUserDocument(
        userId: userId,
        userData: userData,
      );

      if (!success) {
        // If Firestore creation fails, delete the auth user
        await userCredential.user?.delete();
        return;
      }

      // Step 4: Save to local storage
      await AppLocalStorage.setUserLoggedIn(true);
      await AppLocalStorage.saveUserData(
        userId: userId,
        userName: nameController.text,
        userEmail: emailController.text,
        userPhone: fullPhoneNumber,
        userProfileImage: profileImageUrl,
      );

      // Show success message
      AppSnackbar.success(
        message: AppString.signUpSuccess,
        duration: const Duration(seconds: 2),
      );

      // Navigate to home screen
      AppNavigation.offNamed(AppRoutes.homeScreen);
    } catch (e) {
      // Error is already handled in FirebaseService
    } finally {
      isLoading.value = false;
    }
  }

  // Navigate to sign in
  void navigateToSignIn() {
    AppNavigation.offNamed(AppRoutes.signIn);
  }
}
