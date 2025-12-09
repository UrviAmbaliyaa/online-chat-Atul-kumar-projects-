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
      // Try to load from local storage
      final usersJson = AppLocalStorage.getList('added_users');

      if (usersJson != null && usersJson.isNotEmpty) {
        addedUsers.value = usersJson
            .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        // If no data, use sample data for demonstration
        addedUsers.value = _getSampleUsers();
      }
    } catch (e) {
      // If error, use sample data
      addedUsers.value = _getSampleUsers();
    }
  }

  // Load created groups
  Future<void> loadCreatedGroups() async {
    try {
      // Try to load from local storage
      final groupsJson = AppLocalStorage.getList('created_groups');

      if (groupsJson != null && groupsJson.isNotEmpty) {
        createdGroups.value = groupsJson
            .map(
                (json) => GroupChatModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        // If no data, use sample data for demonstration
        createdGroups.value = _getSampleGroups();
      }
    } catch (e) {
      // If error, use sample data
      createdGroups.value = _getSampleGroups();
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
}
