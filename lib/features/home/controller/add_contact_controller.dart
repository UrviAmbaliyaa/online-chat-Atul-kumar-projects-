import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:online_chat/features/home/controller/home_controller.dart';
import 'package:online_chat/features/home/models/user_model.dart';
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

  // Suggestions
  final RxList<UserModel> suggestions = <UserModel>[].obs;
  final RxBool isSearching = false.obs;
  final RxString _searchQuery = ''.obs;
  Worker? _debounceWorker;

  @override
  void onInit() {
    super.onInit();
    emailController.addListener(_onEmailChanged);
    _debounceWorker = debounce<String>(
      _searchQuery,
      (_) => _searchUsers(),
      time: const Duration(milliseconds: 300),
    );
  }

  @override
  void onClose() {
    emailController.dispose();
    emailFocusNode.dispose();
    _debounceWorker?.dispose();
    super.onClose();
  }

  String? validateEmail(String? value) {
    return AppValidator.validateEmail(value);
  }

  void _onEmailChanged() {
    _searchQuery.value = emailController.text.trim();
  }

  Future<void> _searchUsers() async {
    final query = _searchQuery.value;
    if (query.isEmpty) {
      suggestions.clear();
      return;
    }

    try {
      isSearching.value = true;
      final currentUserId = FirebaseService.getCurrentUserId();
      final homeController = Get.isRegistered<HomeController>()
          ? Get.find<HomeController>()
          : null;
      final addedIds = homeController?.addedUsers.map((u) => u.id).toSet() ?? {};

      final results =
          await FirebaseService.searchUsersByQuery(query: query, limit: 20);

      final filtered = results.where((u) {
        if (currentUserId != null && u.id == currentUserId) return false;
        if (addedIds.contains(u.id)) return false;
        return true;
      }).toList();

      suggestions.assignAll(filtered);
    } catch (_) {
      suggestions.clear();
    } finally {
      isSearching.value = false;
    }
  }

  void selectSuggestion(UserModel user) {
    emailController.text = user.email;
    emailController.selection = TextSelection.fromPosition(
      TextPosition(offset: emailController.text.length),
    );
    suggestions.clear();
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
