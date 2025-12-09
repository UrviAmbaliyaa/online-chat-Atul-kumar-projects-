import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:online_chat/features/home/models/user_model.dart';
import 'package:online_chat/features/settings/models/edit_profile_model.dart';
import 'package:online_chat/features/settings/widgets/delete_account_confirmation_dialog.dart';
import 'package:online_chat/navigations/app_navigation.dart';
import 'package:online_chat/services/firebase_service.dart';
import 'package:online_chat/utils/app_image_picker.dart';
import 'package:online_chat/utils/app_local_storage.dart';
import 'package:online_chat/utils/app_preference.dart';
import 'package:online_chat/utils/app_snackbar.dart';
import 'package:online_chat/utils/app_string.dart';
import 'package:online_chat/utils/app_validator.dart';
import 'package:online_chat/utils/country_code_picker.dart';
import 'package:online_chat/utils/phone_number_formatter.dart';

class EditProfileController extends GetxController {
  // Form Key
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Text Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  // Observables
  final Rx<File?> profileImage = Rx<File?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isDeletingAccount = false.obs;
  final Rx<CountryCode> selectedCountry = CountryCodePicker.countries[0].obs;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final Rx<EditProfileModel?> editProfileData = Rx<EditProfileModel?>(null);
  String?
      currentProfileImageUrl; // Store current profile image URL from Firebase

  // Focus Nodes
  final FocusNode nameFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode phoneFocusNode = FocusNode();

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  /// Load user data from Firebase and local storage
  Future<void> loadUserData() async {
    isLoading.value = true;
    try {
      // Try to load from Firebase first
      final userModel = await FirebaseService.getCurrentUserModel();

      if (userModel != null) {
        currentUser.value = userModel;
        editProfileData.value = EditProfileModel.fromUserModel(userModel);

        // Populate form fields from model
        nameController.text = userModel.name;
        emailController.text = userModel.email;

        // Handle phone number and country code
        if (userModel.phone != null && userModel.phone!.isNotEmpty) {
          final phoneNumber = userModel.phone!;

          // Use country code from model if available
          if (userModel.countryCode != null && userModel.dialCode != null) {
            // Find matching country from CountryCodePicker
            for (var country in CountryCodePicker.countries) {
              if (country.code == userModel.countryCode &&
                  country.dialCode == userModel.dialCode) {
                selectedCountry.value = country;
                // Remove dial code from phone number
                if (phoneNumber.startsWith(country.dialCode)) {
                  phoneController.text =
                      phoneNumber.substring(country.dialCode.length);
                } else {
                  phoneController.text = phoneNumber;
                }
                break;
              }
            }
          } else {
            // Fallback: try to extract from phone number
            if (phoneNumber.startsWith('+')) {
              for (var country in CountryCodePicker.countries) {
                if (phoneNumber.startsWith(country.dialCode)) {
                  selectedCountry.value = country;
                  phoneController.text =
                      phoneNumber.substring(country.dialCode.length);
                  break;
                }
              }
            } else {
              phoneController.text = phoneNumber;
            }
          }
        }

        // Handle profile image
        if (userModel.profileImage != null &&
            userModel.profileImage!.isNotEmpty) {
          if (userModel.profileImage!.startsWith('http')) {
            currentProfileImageUrl = userModel.profileImage;
          } else {
            try {
              profileImage.value = File(userModel.profileImage!);
            } catch (e) {
              profileImage.value = null;
            }
          }
        }

        // Update local storage with Firebase data
        await AppLocalStorage.saveUserName(userModel.name);
        await AppLocalStorage.saveUserEmail(userModel.email);
        if (userModel.phone != null) {
          await AppLocalStorage.saveUserPhone(userModel.phone!);
        }
        if (userModel.profileImage != null) {
          await AppLocalStorage.saveUserProfileImage(userModel.profileImage!);
        }
      } else {
        // Fallback to local storage if Firebase fails
        _loadFromLocalStorage();
      }
    } catch (e) {
      // Fallback to local storage on error
      _loadFromLocalStorage();
    } finally {
      isLoading.value = false;
    }
  }

  /// Load user data from local storage (fallback)
  void _loadFromLocalStorage() {
    nameController.text = AppLocalStorage.getUserName();
    emailController.text = AppLocalStorage.getUserEmail();

    // Load phone number and extract country code if present
    final savedPhone = AppLocalStorage.getUserPhone();
    if (savedPhone.isNotEmpty) {
      // Try to extract country code from saved phone (format: +91XXXXXXXXXX)
      final phoneWithCode = savedPhone.trim();
      if (phoneWithCode.startsWith('+')) {
        // Find matching country code
        for (var country in CountryCodePicker.countries) {
          if (phoneWithCode.startsWith(country.dialCode)) {
            selectedCountry.value = country;
            // Remove country code from phone number
            final phoneNumber =
                phoneWithCode.substring(country.dialCode.length);
            phoneController.text = phoneNumber;
            break;
          }
        }
      } else {
        // If no country code, assume default country and use the saved phone as-is
        phoneController.text = savedPhone;
      }
    }

    final profileImagePath = AppLocalStorage.getUserProfileImage();
    if (profileImagePath.isNotEmpty) {
      if (profileImagePath.startsWith('http')) {
        // Store URL if it's from Firebase Storage
        currentProfileImageUrl = profileImagePath;
      } else {
        // Try to load local file
        try {
          profileImage.value = File(profileImagePath);
        } catch (e) {
          profileImage.value = null;
        }
      }
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    nameFocusNode.dispose();
    emailFocusNode.dispose();
    phoneFocusNode.dispose();
    super.onClose();
  }

  /// Pick profile image from gallery
  Future<void> pickProfileImageFromGallery() async {
    final image = await AppImagePicker.pickImageFromGallery(
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (image != null) {
      profileImage.value = image;
    }
  }

  /// Pick profile image from camera
  Future<void> pickProfileImageFromCamera() async {
    final image = await AppImagePicker.pickImageFromCamera(
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (image != null) {
      profileImage.value = image;
    }
  }

  /// Show image source selection dialog
  void showImageSourceDialog() {
    AppImagePicker.showImageSourceDialog(
      onGallerySelected: (File image) {
        profileImage.value = image;
      },
      onCameraSelected: (File image) {
        profileImage.value = image;
      },
    );
  }

  /// Remove profile image
  void removeProfileImage() {
    profileImage.value = null;
  }

  /// Validate name
  String? validateName(String? value) => AppValidator.validateName(value);

  /// Validate email
  String? validateEmail(String? value) => AppValidator.validateEmail(value);

  /// Update selected country
  void updateSelectedCountry(CountryCode country) {
    selectedCountry.value = country;
  }

  /// Get phone number formatter based on selected country
  List<TextInputFormatter> getPhoneFormatters() {
    return [PhoneNumberFormatter.getFormatter(selectedCountry.value)];
  }

  /// Get max length for phone number based on selected country
  int? getPhoneMaxLength() {
    return PhoneNumberFormatter.getMaxLength(selectedCountry.value);
  }

  /// Validate phone
  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return AppString.phoneRequired;
    }
    final cleanedValue = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    return AppValidator.validatePhone(cleanedValue);
  }

  /// Update profile using models
  Future<void> updateProfile() async {
    // Unfocus text fields
    nameFocusNode.unfocus();
    emailFocusNode.unfocus();
    phoneFocusNode.unfocus();

    // Validate form
    if (!formKey.currentState!.validate()) {
      return;
    }

    // Check if user is logged in
    final userId = FirebaseService.getCurrentUserId();
    if (userId == null) {
      AppSnackbar.error(message: AppString.userNotLoggedIn);
      return;
    }

    try {
      isSaving.value = true;

      // Prepare phone number (cleaned, without dial code prefix)
      final cleanedPhone =
          phoneController.text.replaceAll(RegExp(r'[\s\-\(\)]'), '');

      // Step 1: Upload profile image if a new one is selected
      // Preserve existing profile image URL if no new image is selected
      String? profileImageUrl =
          currentProfileImageUrl ?? currentUser.value?.profileImage;

      if (profileImage.value != null) {
        final imagePath =
            'profile_images/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
        profileImageUrl = await FirebaseService.uploadFile(
          file: profileImage.value!,
          path: imagePath,
        );
        log("profileImageUrl ::::::::::::::::::::::${profileImageUrl}");
        if (profileImageUrl == null) {
          // Upload failed, show error and return
          AppSnackbar.error(message: AppString.profileImageUploadError);
          isSaving.value = false;
          return;
        }
      }

      // Step 2: Create EditProfileModel from form data
      // Note: profileImageUrl will be stored in the user document in Firestore
      final editModel = EditProfileModel(
        name: nameController.text.trim(),
        phone: cleanedPhone,
        countryCode: selectedCountry.value.code,
        dialCode: selectedCountry.value.dialCode,
        profileImage:
            profileImageUrl, // Profile image URL to be stored in user document
      );

      // Step 3: Get current user email (not editable)
      final currentEmail =
          currentUser.value?.email ?? AppLocalStorage.getUserEmail();
      log("currentEmail ::::::::::::::::::::${currentEmail}");
      if (currentEmail.isEmpty) {
        AppSnackbar.error(message: AppString.userEmailNotFound);
        isSaving.value = false;
        return;
      }

      // Step 4: Convert EditProfileModel to UserModel
      final updatedUserModel = editModel.toUserModel(
        userId: userId,
        email: currentEmail,
        isOnline: currentUser.value?.isOnline ?? false,
        lastSeen: currentUser.value?.lastSeen,
      );

      // Step 5: Update user profile in Firebase using UserModel
      final firebaseSuccess = await FirebaseService.updateUserProfile(
        userId: userId,
        userModel: updatedUserModel,
      );

      if (!firebaseSuccess) {
        // Firebase update failed - error already shown by FirebaseService
        isSaving.value = false;
        return;
      }

      // Step 6: Update local storage
      await AppLocalStorage.saveUserName(editModel.name);
      await AppLocalStorage.saveUserEmail(currentEmail);
      final fullPhoneNumber = '${editModel.dialCode}${editModel.phone}';
      await AppLocalStorage.saveUserPhone(fullPhoneNumber);

      if (profileImageUrl != null) {
        await AppLocalStorage.saveUserProfileImage(profileImageUrl);
      }

      // Step 7: Update current user model
      currentUser.value = updatedUserModel;
      editProfileData.value = editModel;

      // Step 8: Update global user model in AppPreference
      AppPreference.updateCurrentUser(updatedUserModel);
      // Step 10: Navigate back
      AppNavigation.back();
      // Step 9: Show success message
      AppSnackbar.success(message: AppString.profileUpdated);
    } catch (e) {
      log(":::::::::::::::::::::::::::::: $e");
      // Handle any unexpected errors
      final errorMessage = e.toString().contains('network')
          ? AppString.networkError
          : e.toString().contains('permission')
              ? AppString.permissionDenied
              : AppString.profileUpdateError;

      AppSnackbar.error(message: errorMessage);
    } finally {
      isSaving.value = false;
    }
  }

  /// Show delete account confirmation
  void showDeleteAccountConfirmation() {
    Get.dialog(
      DeleteAccountConfirmationDialog(
        onDelete: _deleteAccount,
      ),
      barrierDismissible: true,
    );
  }

  /// Delete account
  Future<void> _deleteAccount() async {
    try {
      isDeletingAccount.value = true;
      // TODO: Implement account deletion
      AppSnackbar.info(message: AppString.featureComingSoon);
    } catch (e) {
      AppSnackbar.error(message: AppString.operationFailed);
    } finally {
      isDeletingAccount.value = false;
    }
  }
}
