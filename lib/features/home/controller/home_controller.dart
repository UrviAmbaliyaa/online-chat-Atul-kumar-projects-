import 'package:get/get.dart';
import 'package:online_chat/features/home/models/group_chat_model.dart';
import 'package:online_chat/features/home/models/user_model.dart';
import 'package:online_chat/navigations/app_navigation.dart';
import 'package:online_chat/navigations/routes.dart';
import 'package:online_chat/services/firebase_service.dart';
import 'package:online_chat/utils/app_local_storage.dart';
import 'package:online_chat/utils/app_preference.dart';
import 'package:online_chat/utils/app_snackbar.dart';

class HomeController extends GetxController {
  // Observables
  final RxList<UserModel> addedUsers = <UserModel>[].obs;
  final RxList<GroupChatModel> createdGroups = <GroupChatModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt selectedTab = 0.obs; // 0 = Users, 1 = Groups

  @override
  void onInit() {
    super.onInit();
    loadData();
    // Load current user model if not already loaded
    if (AppPreference.currentUser.value == null) {
      AppPreference.loadCurrentUser();
    }
  }

  // Load users and groups
  Future<void> loadData() async {
    isLoading.value = true;

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Load added users (from local storage or API)
      await loadAddedUsers();

      // Load created groups (from local storage or API)
      await loadCreatedGroups();
    } catch (e) {
      // Handle error
      print('Error loading data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Load added users
  Future<void> loadAddedUsers() async {
    try {
      final currentUserId = FirebaseService.getCurrentUserId();
      if (currentUserId == null) {
        addedUsers.value = [];
        return;
      }

      // Get contacts from Firebase
      final contactIds = await FirebaseService.getUserContacts(currentUserId);

      if (contactIds.isEmpty) {
        addedUsers.value = [];
        return;
      }

      // Get user models for contacts
      final contacts = await FirebaseService.getUsersByIds(contactIds);
      addedUsers.value = contacts;

      // Save to local storage for offline access
      final usersJson = contacts.map((user) => user.toJson()).toList();
      await AppLocalStorage.setList('added_users', usersJson);
    } catch (e) {
      // Fallback to local storage on error
      try {
        final usersJson = AppLocalStorage.getList('added_users');
        if (usersJson != null && usersJson.isNotEmpty) {
          addedUsers.value = usersJson
              .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          addedUsers.value = [];
        }
      } catch (e2) {
        addedUsers.value = [];
      }
    }
  }

  // Load created groups
  Future<void> loadCreatedGroups() async {
    try {
      final currentUserId = FirebaseService.getCurrentUserId();
      if (currentUserId == null) {
        createdGroups.value = [];
        return;
      }

      // Get groups from Firebase where user is a member
      final groups = await FirebaseService.getUserGroups(currentUserId);
      createdGroups.value = groups;

      // Save to local storage for offline access
      final groupsJson = groups.map((group) => group.toJson()).toList();
      await AppLocalStorage.setList('created_groups', groupsJson);
    } catch (e) {
      // Fallback to local storage on error
      try {
        final groupsJson = AppLocalStorage.getList('created_groups');
        if (groupsJson != null && groupsJson.isNotEmpty) {
          createdGroups.value = groupsJson
              .map((json) =>
                  GroupChatModel.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          createdGroups.value = [];
        }
      } catch (e2) {
        createdGroups.value = [];
      }
    }
  }

  // Save added users to local storage
  Future<void> saveAddedUsers() async {
    final usersJson = addedUsers.map((user) => user.toJson()).toList();
    await AppLocalStorage.setList('added_users', usersJson);
  }

  // Save created groups to local storage
  Future<void> saveCreatedGroups() async {
    final groupsJson = createdGroups.map((group) => group.toJson()).toList();
    await AppLocalStorage.setList('created_groups', groupsJson);
  }

  // Add a new user
  Future<void> addUser(UserModel user) async {
    if (!addedUsers.any((u) => u.id == user.id)) {
      addedUsers.add(user);
      await saveAddedUsers();
    }
  }

  // Remove a user
  Future<void> removeUser(String userId) async {
    addedUsers.removeWhere((user) => user.id == userId);
    await saveAddedUsers();
  }

  // Create a new group
  Future<void> createGroup(GroupChatModel group) async {
    if (!createdGroups.any((g) => g.id == group.id)) {
      createdGroups.add(group);
      await saveCreatedGroups();
    }
  }

  // Delete a group
  Future<void> deleteGroup(String groupId) async {
    createdGroups.removeWhere((group) => group.id == groupId);
    await saveCreatedGroups();
  }

  // Switch tab
  void switchTab(int index) {
    selectedTab.value = index;
  }

  // Refresh data
  Future<void> refresh() async {
    await loadData();
  }

  // Refresh contacts after adding new contact
  Future<void> refreshContacts() async {
    await loadAddedUsers();
  }

  // Refresh groups after creating new group
  Future<void> refreshGroups() async {
    await loadCreatedGroups();
  }

  // Logout user
  Future<void> logout() async {
    try {
      isLoading.value = true;

      // Sign out from Firebase
      final success = await FirebaseService.signOut();

      if (success) {
        // Clear local storage
        await AppLocalStorage.logout();

        // Show success message
        AppSnackbar.success(
          message: 'Logged out successfully',
        );

        // Navigate to sign in screen
        AppNavigation.replaceAllNamed(AppRoutes.signIn);
      }
    } catch (e) {
      AppSnackbar.error(
        message: 'Failed to logout. Please try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Sample data for demonstration
  List<UserModel> _getSampleUsers() {
    return [
      UserModel(
        id: 'user1',
        name: 'John Doe',
        email: 'john@example.com',
        phone: '+1234567890',
        isOnline: true,
      ),
      UserModel(
        id: 'user2',
        name: 'Jane Smith',
        email: 'jane@example.com',
        phone: '+1234567891',
        isOnline: false,
        lastSeen: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      UserModel(
        id: 'user3',
        name: 'Mike Johnson',
        email: 'mike@example.com',
        phone: '+1234567892',
        isOnline: true,
      ),
    ];
  }

  List<GroupChatModel> _getSampleGroups() {
    final currentUserId = AppLocalStorage.getUserId();
    if (currentUserId.isEmpty) {
      // If no user ID, use a default
      return [];
    }
    return [
      GroupChatModel(
        id: 'group1',
        name: 'Project Team',
        description: 'Team collaboration group',
        createdBy: currentUserId,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        members: [currentUserId, 'user1', 'user2', 'user3'],
        memberCount: 4,
        lastMessage: 'Hey everyone!',
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      GroupChatModel(
        id: 'group2',
        name: 'Friends Circle',
        description: 'Close friends group',
        createdBy: currentUserId,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        members: [currentUserId, 'user1', 'user2'],
        memberCount: 3,
        lastMessage: 'See you tomorrow!',
        lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  // Navigate to add contact
  void navigateToAddContact() {
    AppNavigation.toNamed(AppRoutes.addContactScreen);
  }

  // Navigate to add group
  void navigateToAddGroup() {
    AppNavigation.toNamed(AppRoutes.addGroupScreen);
  }
}
