import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:online_chat/features/home/controller/home_controller.dart';
import 'package:online_chat/features/home/models/user_model.dart';
import 'package:online_chat/navigations/app_navigation.dart';
import 'package:online_chat/services/firebase_service.dart';
import 'package:online_chat/utils/app_snackbar.dart';
import 'package:online_chat/utils/app_string.dart';

class AddGroupController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController groupNameController = TextEditingController();
  final FocusNode groupNameFocusNode = FocusNode();

  final RxList<UserModel> availableContacts = <UserModel>[].obs;
  final RxList<UserModel> filteredContacts = <UserModel>[].obs;
  final RxList<String> selectedMemberIds = <String>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isCreating = false.obs;
  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadContacts();
  }

  @override
  void onClose() {
    groupNameController.dispose();
    groupNameFocusNode.dispose();
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadContacts() async {
    try {
      isLoading.value = true;
      final homeController = Get.find<HomeController>();
      availableContacts.value = homeController.addedUsers.toList();
      filteredContacts.value = availableContacts.toList();

      // Listen to search changes
      searchController.addListener(_filterContacts);
    } catch (e) {
      availableContacts.value = [];
      filteredContacts.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  void _filterContacts() {
    final query = searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      filteredContacts.value = availableContacts.toList();
    } else {
      filteredContacts.value =
          availableContacts.where((contact) => contact.name.toLowerCase().contains(query) || contact.email.toLowerCase().contains(query)).toList();
    }
  }

  String? validateGroupName(String? value) {
    if (value == null || value.isEmpty) {
      return AppString.groupNameRequired;
    }
    if (value.trim().length < 3) {
      return AppString.groupNameMinLength;
    }
    return null;
  }

  void toggleMemberSelection(String userId) {
    if (selectedMemberIds.contains(userId)) {
      selectedMemberIds.remove(userId);
    } else {
      selectedMemberIds.add(userId);
    }
  }

  bool isMemberSelected(String userId) {
    return selectedMemberIds.contains(userId);
  }

  Future<void> createGroup() async {
    groupNameFocusNode.unfocus();

    if (!formKey.currentState!.validate()) {
      return;
    }

    final currentUserId = FirebaseService.getCurrentUserId();
    if (currentUserId == null) {
      AppSnackbar.error(message: AppString.userNotLoggedIn);
      return;
    }

    if (selectedMemberIds.isEmpty) {
      AppSnackbar.error(message: AppString.selectAtLeastOneMember);
      return;
    }

    try {
      isCreating.value = true;

      // Create group members list (include current user as admin)
      final allMembers = [currentUserId, ...selectedMemberIds];

      // Create group in Firebase
      final groupId = await FirebaseService.createGroup(
        name: groupNameController.text.trim(),
        createdBy: currentUserId,
        members: allMembers,
      );

      if (groupId != null) {
        // Refresh groups in home controller
        try {
          final homeController = Get.find<HomeController>();
          await homeController.refreshGroups();
        } catch (e) {
          // Home controller might not be initialized, that's okay
        }

        // Navigate back
        await Future.delayed(const Duration(milliseconds: 500));
        AppNavigation.back();
        AppSnackbar.success(message: AppString.groupCreatedSuccessfully);
      } else {
        AppSnackbar.error(message: AppString.groupCreateError);
      }
    } catch (e) {
      AppSnackbar.error(message: AppString.groupCreateError);
    } finally {
      isCreating.value = false;
    }
  }
}
