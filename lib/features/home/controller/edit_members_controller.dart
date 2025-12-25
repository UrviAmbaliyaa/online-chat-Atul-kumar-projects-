import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:online_chat/features/home/controller/chat_controller.dart';
import 'package:online_chat/features/home/controller/home_controller.dart';
import 'package:online_chat/features/home/models/group_chat_model.dart';
import 'package:online_chat/features/home/models/message_model.dart';
import 'package:online_chat/features/home/models/user_model.dart';
import 'package:online_chat/features/home/widgets/delete_group_confirmation_dialog.dart';
import 'package:online_chat/navigations/app_navigation.dart';
import 'package:online_chat/services/firebase_service.dart';
import 'package:online_chat/utils/app_snackbar.dart';
import 'package:online_chat/utils/app_string.dart';

class EditMembersController extends GetxController {
  final GroupChatModel group;
  final HomeController homeController;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController groupNameController = TextEditingController();
  final FocusNode groupNameFocusNode = FocusNode();

  final RxList<UserModel> availableContacts = <UserModel>[].obs;
  final RxList<UserModel> filteredContacts = <UserModel>[].obs;
  final RxList<UserModel> groupMembers = <UserModel>[].obs;
  final RxMap<String, bool> memberAdminStatus = <String, bool>{}.obs; // userId -> isAdmin
  final RxList<String> selectedMemberIds = <String>[].obs;
  final RxList<String> currentMemberIds = <String>[].obs;
  final RxBool isLoading = true.obs; // Start with true to show shimmer immediately
  final RxBool isUpdating = false.obs;
  final RxBool isDeletingGroup = false.obs;
  final RxBool isCurrentUserAdmin = false.obs;
  final TextEditingController searchController = TextEditingController();

  EditMembersController({
    required this.group,
    required this.homeController,
  });

  @override
  void onInit() {
    super.onInit();
    groupNameController.text = group.name;
    currentMemberIds.value = List.from(group.members);
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _checkAdminStatus();
    await loadContacts();
  }

  @override
  void onClose() {
    groupNameController.dispose();
    groupNameFocusNode.dispose();
    searchController.dispose();
    super.onClose();
  }

  Future<void> _checkAdminStatus() async {
    try {
      final currentUserId = FirebaseService.getCurrentUserId();
      if (currentUserId == null) return;

      final groupDoc = await FirebaseFirestore.instance.collection('group').doc(group.id).get();

      if (groupDoc.exists) {
        final admins = List<String>.from(groupDoc.data()?['admins'] ?? []);
        isCurrentUserAdmin.value = admins.contains(currentUserId);
      }
    } catch (e) {
      // Error checking admin status
    }
  }

  Future<void> loadContacts() async {
    try {
      isLoading.value = true;

      // Load all group members with admin status
      final membersList = await FirebaseService.getGroupMembers(group.id);
      groupMembers.value = membersList.map((m) => m['user'] as UserModel).toList();

      // Store admin status for each member
      memberAdminStatus.clear();
      for (var memberData in membersList) {
        final user = memberData['user'] as UserModel;
        final isAdmin = memberData['isAdmin'] as bool;
        memberAdminStatus[user.id] = isAdmin;
      }

      // For admins: also load available contacts to add new members
      if (isCurrentUserAdmin.value) {
        availableContacts.value = homeController.addedUsers.toList();
        filteredContacts.value = availableContacts.toList();

        // Pre-select current members (excluding current user)
        final currentUserId = FirebaseService.getCurrentUserId();
        selectedMemberIds.value = group.members.where((id) => id != currentUserId).toList();
      } else {
        // For non-admins: show only group members
        availableContacts.value = [];
        filteredContacts.value = [];
      }

      // Listen to search changes
      searchController.addListener(_filterContacts);
    } catch (e) {
      availableContacts.value = [];
      filteredContacts.value = [];
      groupMembers.value = [];
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
    if (!isCurrentUserAdmin.value) return;

    // Prevent selecting admins or current user
    final currentUserId = FirebaseService.getCurrentUserId();
    if (userId == currentUserId) return; // Can't select yourself
    if (memberAdminStatus[userId] == true) return; // Can't select admins

    if (selectedMemberIds.contains(userId)) {
      selectedMemberIds.remove(userId);
    } else {
      selectedMemberIds.add(userId);
    }
  }

  bool isMemberSelected(String userId) {
    return selectedMemberIds.contains(userId);
  }

  Future<void> updateGroup() async {
    groupNameFocusNode.unfocus();

    if (!formKey.currentState!.validate()) {
      return;
    }

    final currentUserId = FirebaseService.getCurrentUserId();
    if (currentUserId == null) {
      AppSnackbar.error(message: AppString.userNotLoggedIn);
      return;
    }

    try {
      isUpdating.value = true;

      // Update group name if changed
      if (groupNameController.text.trim() != group.name) {
        final nameSuccess = await FirebaseService.updateGroupName(
          groupId: group.id,
          newName: groupNameController.text.trim(),
        );
        if (!nameSuccess) {
          isUpdating.value = false;
          return;
        }
      }

      // Update members
      final currentUserId = FirebaseService.getCurrentUserId()!;
      final allMembers = [currentUserId, ...selectedMemberIds];

      // Get current members from Firebase
      final groupDoc = await FirebaseFirestore.instance.collection('group').doc(group.id).get();

      if (groupDoc.exists) {
        final currentMembers = List<String>.from(groupDoc.data()?['members'] ?? []);

        // Find members to add and remove
        final membersToAdd = allMembers.where((id) => !currentMembers.contains(id)).toList();
        final membersToRemove = currentMembers.where((id) => !allMembers.contains(id) && id != currentUserId).toList();

        // Add new members
        if (membersToAdd.isNotEmpty) {
          await FirebaseService.addGroupMembers(
            groupId: group.id,
            memberIds: membersToAdd,
            adminId: currentUserId,
          );
        }

        // Remove members (admin only)
        if (membersToRemove.isNotEmpty && isCurrentUserAdmin.value) {
          for (final memberId in membersToRemove) {
            await FirebaseService.removeGroupMember(
              groupId: group.id,
              memberId: memberId,
              adminId: currentUserId,
            );
          }
        }
      }
      await homeController.refreshGroups();

      // Update ChatController's group if it exists (when user is in chat screen)
      try {
        if (Get.isRegistered<ChatController>()) {
          final chatController = Get.find<ChatController>();
          // Check if this ChatController is for the group we just updated
          if (chatController.chatType.value == ChatType.group && chatController.group.value?.id == group.id) {
            final updatedGroup = homeController.createdGroups.firstWhereOrNull((g) => g.id == group.id);
            if (updatedGroup != null) {
              chatController.group.value = updatedGroup;
            }
          }
        }
      } catch (e) {
        // ChatController doesn't exist or not found, which is fine
      }

      AppNavigation.back();
      AppSnackbar.success(message: AppString.groupUpdatedSuccessfully);
    } catch (e) {
      AppSnackbar.error(message: AppString.groupUpdateError);
    } finally {
      isUpdating.value = false;
    }
  }

  void showDeleteGroupConfirmation() {
    Get.dialog(
      DeleteGroupConfirmationDialog(
        onDelete: deleteGroup,
      ),
      barrierDismissible: true,
    );
  }

  Future<void> deleteGroup() async {
    try {
      isDeletingGroup.value = true;
      final currentUserId = FirebaseService.getCurrentUserId();
      if (currentUserId == null) {
        AppSnackbar.error(message: AppString.userNotLoggedIn);
        return;
      }

      final success = await FirebaseService.deleteGroup(
        groupId: group.id,
        adminId: currentUserId,
      );

      if (success) {
        await homeController.refreshGroups();
        AppNavigation.back(); // Close edit screen
        AppNavigation.back(); // Close group details dialog
        AppSnackbar.success(message: AppString.groupDeletedSuccessfully);
      } else {
        AppSnackbar.error(message: AppString.deleteGroupError);
      }
    } catch (e) {
      AppSnackbar.error(message: AppString.deleteGroupError);
    } finally {
      isDeletingGroup.value = false;
    }
  }
}
