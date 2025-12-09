import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:online_chat/features/home/controller/home_controller.dart';
import 'package:online_chat/navigations/app_navigation.dart';
import 'package:online_chat/services/firebase_service.dart';
import 'package:online_chat/utils/app_snackbar.dart';
import 'package:online_chat/utils/app_string.dart';
import 'package:online_chat/utils/app_validator.dart';

class AddContactController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final FocusNode emailFocusNode = FocusNode();
  final RxBool isAdding = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    emailFocusNode.dispose();
    super.onClose();
  }

  String? validateEmail(String? value) {
    return AppValidator.validateEmail(value);
  }

  Future<void> addContact() async {
    emailFocusNode.unfocus();

    if (!formKey.currentState!.validate()) {
      return;
    }

    final email = emailController.text.trim().toLowerCase();
    final currentUserId = FirebaseService.getCurrentUserId();

    if (currentUserId == null) {
      AppSnackbar.error(message: AppString.userNotLoggedIn);
      return;
    }

    // Check if trying to add self
    final currentUser = FirebaseService.getCurrentUser();
    if (currentUser?.email?.toLowerCase() == email) {
      AppSnackbar.error(message: AppString.cannotAddYourself);
      return;
    }

    try {
      isAdding.value = true;

      // Check if user exists by email
      final userExists = await FirebaseService.checkUserExistsByEmail(email);

      if (!userExists.exists) {
        AppSnackbar.error(message: AppString.userNotFound);
        isAdding.value = false;
        return;
      }

      final userId = userExists.userId!;

      // Check if contact already exists
      final contactExists = await FirebaseService.checkContactExists(
        currentUserId: currentUserId,
        contactUserId: userId,
      );

      if (contactExists) {
        AppSnackbar.error(message: AppString.contactAlreadyExists);
        isAdding.value = false;
        return;
      }

      // Add contact to current user's document
      final success = await FirebaseService.addContact(
        currentUserId: currentUserId,
        contactUserId: userId,
      );

      if (success) {
        AppSnackbar.success(message: AppString.contactAddedSuccessfully);
        emailController.clear();

        // Refresh contacts in home controller
        try {
          final homeController = Get.find<HomeController>();
          await homeController.refreshContacts();
        } catch (e) {
          // Home controller might not be initialized, that's okay
        }

        // Show success message and navigate back
        AppSnackbar.success(message: AppString.contactAddedSuccessfully);
        await Future.delayed(const Duration(milliseconds: 500));
        AppNavigation.back();
      } else {
        AppSnackbar.error(message: AppString.contactAddError);
      }
    } catch (e) {
      AppSnackbar.error(message: AppString.contactAddError);
    } finally {
      isAdding.value = false;
    }
  }
}
