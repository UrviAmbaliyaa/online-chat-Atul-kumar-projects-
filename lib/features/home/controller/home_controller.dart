import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:online_chat/features/home/models/chat_info_model.dart';
import 'package:online_chat/features/home/models/group_chat_model.dart';
import 'package:online_chat/features/home/models/user_model.dart';
import 'package:online_chat/features/home/widgets/incoming_call_dialog.dart';
import 'package:online_chat/navigations/app_navigation.dart';
import 'package:online_chat/navigations/routes.dart';
import 'package:online_chat/services/call_notification_service.dart';
import 'package:online_chat/services/firebase_service.dart';
import 'package:online_chat/utils/app_local_storage.dart';
import 'package:online_chat/utils/app_preference.dart';
import 'package:online_chat/utils/app_snackbar.dart';
import 'package:online_chat/utils/firebase_constants.dart';
import 'package:online_chat/utils/session_service.dart';

class HomeController extends GetxController {
  // Observables
  final RxList<UserModel> addedUsers = <UserModel>[].obs;
  final RxList<GroupChatModel> createdGroups = <GroupChatModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt selectedTab = 0.obs; // 0 = Users, 1 = Groups
  final RxMap<String, String?> userLastMessages = <String, String?>{}.obs;
  final RxMap<String, ChatInfoModel> userChatInfo = <String, ChatInfoModel>{}.obs;
  final RxMap<String, ChatInfoModel> groupChatInfo = <String, ChatInfoModel>{}.obs;

  // Search
  final RxBool isSearching = false.obs;
  final RxString searchQuery = ''.obs;

  // Stream subscriptions
  final Map<String, StreamSubscription<ChatInfoModel?>> _chatInfoSubscriptions = {};
  StreamSubscription<QuerySnapshot>? _callNotificationSubscription;

  @override
  void onInit() {
    super.onInit();
    loadData();
    // Load current user model if not already loaded
    if (AppPreference.currentUser.value == null) {
      AppPreference.loadCurrentUser();
    }
    // Start session monitoring after home init
    SessionService.ensure();
    // Initialize FCM token and listen for call notifications
    _initializeCallNotifications();
  }

  @override
  void onClose() {
    // Cancel all stream subscriptions
    for (var subscription in _chatInfoSubscriptions.values) {
      subscription.cancel();
    }
    _chatInfoSubscriptions.clear();
    _callNotificationSubscription?.cancel();
    super.onClose();
  }

  // Search controls
  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      clearSearch();
    }
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  void clearSearch() {
    searchQuery.value = '';
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

      // Sort users by last message time (most recent first)
      final sortedContacts = await _sortUsersByLastMessage(contacts);
      addedUsers.value = sortedContacts;

      // Setup real-time chat info streams for all contacts
      _setupChatInfoStreams(contactIds, isGroup: false);

      // Save to local storage for offline access
      final usersJson = sortedContacts.map((user) => user.toJson()).toList();
      await AppLocalStorage.setList('added_users', usersJson);
    } catch (e) {
      // Fallback to local storage on error
      try {
        final usersJson = AppLocalStorage.getList('added_users');
        if (usersJson != null && usersJson.isNotEmpty) {
          addedUsers.value = usersJson.map((json) => UserModel.fromJson(json as Map<String, dynamic>)).toList();
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

      // Sort groups by last message time (most recent first)
      final sortedGroups = _sortGroupsByLastMessage(groups);
      createdGroups.value = sortedGroups;

      // Setup real-time chat info streams for all groups
      final groupIds = sortedGroups.map((group) => group.id).toList();
      _setupChatInfoStreams(groupIds, isGroup: true);

      // Save to local storage for offline access
      final groupsJson = sortedGroups.map((group) => group.toJson()).toList();
      await AppLocalStorage.setList('created_groups', groupsJson);
    } catch (e) {
      // Fallback to local storage on error
      try {
        final groupsJson = AppLocalStorage.getList('created_groups');
        if (groupsJson != null && groupsJson.isNotEmpty) {
          createdGroups.value = groupsJson.map((json) => GroupChatModel.fromJson(json as Map<String, dynamic>)).toList();
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
  @override
  Future<void> refresh() async {
    await loadData();
  }

  // Refresh contacts after adding new contact
  Future<void> refreshContacts() async {
    await loadAddedUsers();
    // Streams are already set up in loadAddedUsers
  }

  // Refresh groups after creating new group
  Future<void> refreshGroups() async {
    await loadCreatedGroups();
  }

  // Logout user
  Future<void> logout() async {
    try {
      isLoading.value = true;

      // Set user offline before signing out
      await FirebaseService.setUserOffline();

      // Sign out from Firebase
      final success = await FirebaseService.signOut();

      if (success) {
        // Clear local storage
        await AppLocalStorage.logout();
        // Clear in-memory current user cache
        AppPreference.clearCurrentUser();

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

  /// Load last messages for users
  Future<void> _loadLastMessages(List<String> userIds) async {
    try {
      final currentUserId = FirebaseService.getCurrentUserId();
      if (currentUserId == null || userIds.isEmpty) {
        return;
      }

      final lastMessages = await FirebaseService.getLastMessagesForUsers(
        currentUserId: currentUserId,
        userIds: userIds,
      );

      userLastMessages.value = lastMessages;
    } catch (e) {
      // Silently fail - last messages are optional
    }
  }

  /// Get last message for a specific user
  String? getLastMessageForUser(String userId) {
    final chatInfo = userChatInfo[userId];
    return chatInfo?.lastMessage ?? userLastMessages[userId];
  }

  /// Get unread count for a specific user
  int getUnreadCountForUser(String userId) {
    final chatInfo = userChatInfo[userId];
    return chatInfo?.unreadCount ?? 0;
  }

  /// Get unread count for a specific group
  int getUnreadCountForGroup(String groupId) {
    final chatInfo = groupChatInfo[groupId];
    return chatInfo?.unreadCount ?? 0;
  }

  /// Get chat info for a user (with real-time updates)
  ChatInfoModel? getChatInfoForUser(String userId) {
    return userChatInfo[userId];
  }

  /// Get chat info for a group (with real-time updates)
  ChatInfoModel? getChatInfoForGroup(String groupId) {
    return groupChatInfo[groupId];
  }

  /// Setup real-time chat info streams
  void _setupChatInfoStreams(List<String> chatIds, {required bool isGroup}) {
    final currentUserId = FirebaseService.getCurrentUserId();
    if (currentUserId == null) return;

    for (var chatId in chatIds) {
      // Cancel existing subscription if any
      _chatInfoSubscriptions[chatId]?.cancel();

      // For one-to-one chats, we need to get the chat ID from user IDs
      String actualChatId = chatId;
      if (!isGroup) {
        actualChatId = FirebaseService.getOneToOneChatId(currentUserId, chatId);
      }

      // Create new stream subscription
      final subscription = FirebaseService.streamChatInfo(
        chatId: actualChatId,
        currentUserId: currentUserId,
      ).listen((chatInfo) {
        if (chatInfo != null) {
          if (isGroup) {
            groupChatInfo[chatId] = chatInfo;
            // Sort groups in real-time when chat info updates
            _sortGroupsList();
          } else {
            userChatInfo[chatId] = chatInfo;
            // Update last message map for backward compatibility
            userLastMessages[chatId] = chatInfo.lastMessage;
            // Sort users in real-time when chat info updates
            _sortUsersList();
          }
        }
      });

      _chatInfoSubscriptions[actualChatId] = subscription;
    }
  }

  /// Sort users by last message time
  Future<List<UserModel>> _sortUsersByLastMessage(
    List<UserModel> users,
  ) async {
    final currentUserId = FirebaseService.getCurrentUserId();
    if (currentUserId == null) return users;

    // Get chat info for all users
    final List<Map<String, dynamic>> usersWithTime = [];
    for (var user in users) {
      final chatId = FirebaseService.getOneToOneChatId(currentUserId, user.id);
      try {
        final chatDoc = await FirebaseFirestore.instance.collection(FirebaseConstants.chatCollection).doc(chatId).get();

        DateTime? lastMessageTime;
        if (chatDoc.exists && chatDoc.data() != null) {
          final data = chatDoc.data()!;
          final lastMsgTime = data['lastMessageTime'];
          if (lastMsgTime != null) {
            if (lastMsgTime is Timestamp) {
              lastMessageTime = lastMsgTime.toDate();
            } else if (lastMsgTime is String) {
              lastMessageTime = DateTime.parse(lastMsgTime);
            }
          }
        }

        usersWithTime.add({
          'user': user,
          'lastMessageTime': lastMessageTime,
        });
      } catch (e) {
        usersWithTime.add({
          'user': user,
          'lastMessageTime': null,
        });
      }
    }

    // Sort by last message time (most recent first)
    usersWithTime.sort((a, b) {
      final timeA = a['lastMessageTime'] as DateTime?;
      final timeB = b['lastMessageTime'] as DateTime?;

      if (timeA == null && timeB == null) return 0;
      if (timeA == null) return 1; // Put nulls at the end
      if (timeB == null) return -1; // Put nulls at the end
      return timeB.compareTo(timeA); // Most recent first
    });

    return usersWithTime.map((item) => item['user'] as UserModel).toList();
  }

  /// Sort groups by last message time
  List<GroupChatModel> _sortGroupsByLastMessage(
    List<GroupChatModel> groups,
  ) {
    final sortedGroups = List<GroupChatModel>.from(groups);
    sortedGroups.sort((a, b) {
      final timeA = a.lastMessageTime;
      final timeB = b.lastMessageTime;

      if (timeA == null && timeB == null) return 0;
      if (timeA == null) return 1; // Put nulls at the end
      if (timeB == null) return -1; // Put nulls at the end
      return timeB.compareTo(timeA); // Most recent first
    });

    return sortedGroups;
  }

  /// Sort users list in real-time based on chat info
  void _sortUsersList() {
    if (addedUsers.isEmpty) return;

    final sortedUsers = List<UserModel>.from(addedUsers);
    sortedUsers.sort((a, b) {
      final chatInfoA = userChatInfo[a.id];
      final chatInfoB = userChatInfo[b.id];

      final timeA = chatInfoA?.lastMessageTime;
      final timeB = chatInfoB?.lastMessageTime;

      if (timeA == null && timeB == null) return 0;
      if (timeA == null) return 1; // Put nulls at the end
      if (timeB == null) return -1; // Put nulls at the end
      return timeB.compareTo(timeA); // Most recent first
    });

    // Only update if order changed
    bool orderChanged = false;
    for (int i = 0; i < sortedUsers.length; i++) {
      if (sortedUsers[i].id != addedUsers[i].id) {
        orderChanged = true;
        break;
      }
    }

    if (orderChanged) {
      addedUsers.value = sortedUsers;
    }
  }

  /// Sort groups list in real-time based on chat info
  void _sortGroupsList() {
    if (createdGroups.isEmpty) return;

    final sortedGroups = List<GroupChatModel>.from(createdGroups);
    sortedGroups.sort((a, b) {
      // First check chat info, then fallback to group's lastMessageTime
      final chatInfoA = groupChatInfo[a.id];
      final chatInfoB = groupChatInfo[b.id];

      final timeA = chatInfoA?.lastMessageTime ?? a.lastMessageTime;
      final timeB = chatInfoB?.lastMessageTime ?? b.lastMessageTime;

      if (timeA == null && timeB == null) return 0;
      if (timeA == null) return 1; // Put nulls at the end
      if (timeB == null) return -1; // Put nulls at the end
      return timeB.compareTo(timeA); // Most recent first
    });

    // Only update if order changed
    bool orderChanged = false;
    for (int i = 0; i < sortedGroups.length; i++) {
      if (sortedGroups[i].id != createdGroups[i].id) {
        orderChanged = true;
        break;
      }
    }

    if (orderChanged) {
      createdGroups.value = sortedGroups;
    }
  }

  /// Initialize call notifications listener
  Future<void> _initializeCallNotifications() async {
    try {
      final currentUserId = FirebaseService.getCurrentUserId();
      if (currentUserId == null) return;

      // Initialize FCM token
      await CallNotificationService.initializeFcmToken(currentUserId);

      // Listen for incoming call notifications
      _callNotificationSubscription = FirebaseFirestore.instance
          .collection(FirebaseConstants.userCollection)
          .doc(currentUserId)
          .collection('callNotifications')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final notification = snapshot.docs.first.data();
          final isRead = notification['isRead'] as bool? ?? false;
          final ts = notification['timestamp'];
          DateTime? tsDate;
          if (ts is Timestamp) tsDate = ts.toDate();
          // Ignore stale notifications (> 60 seconds old)
          if (tsDate != null &&
              DateTime.now().difference(tsDate) > const Duration(minutes: 1)) {
            // Mark as read/cleanup to prevent popup spam after being offline
            try {
              FirebaseFirestore.instance
                  .collection(FirebaseConstants.userCollection)
                  .doc(currentUserId)
                  .collection('callNotifications')
                  .doc(notification['id'] as String)
                  .update({'isRead': true});
            } catch (_) {}
            return;
          }
          
          // Only handle unread notifications
          if (!isRead) {
            _handleIncomingCallNotification(notification);
          }
        }
      });
    } catch (e) {
      // Silently fail - call notifications are optional
      print('Error initializing call notifications: $e');
    }
  }

  /// Handle incoming call notification
  Future<void> _handleIncomingCallNotification(
    Map<String, dynamic> notification,
  ) async {
    try {
      final notificationId = notification['id'] as String?;
      final callerId = notification['callerId'] as String?;
      final chatId = notification['chatId'] as String?;
      final isVideoCall = notification['isVideoCall'] as bool? ?? false;
      final isGroupCall = notification['isGroupCall'] as bool? ?? false;

      if (notificationId == null || callerId == null || chatId == null) {
        return;
      }

      // Mark as read immediately to avoid repeated dialogs
      final currentUserId = FirebaseService.getCurrentUserId();
      if (currentUserId != null) {
        try {
          await FirebaseFirestore.instance
              .collection(FirebaseConstants.userCollection)
              .doc(currentUserId)
              .collection('callNotifications')
              .doc(notificationId)
              .update({'isRead': true});
        } catch (_) {
          // ignore
        }
      }

      // Get caller information
      UserModel? caller;
      GroupChatModel? group;

      if (isGroupCall) {
        // Get group information
        final groupDoc = await FirebaseFirestore.instance.collection(FirebaseConstants.groupCollection).doc(chatId).get();

        if (groupDoc.exists && groupDoc.data() != null) {
          final data = groupDoc.data()!;
          group = GroupChatModel(
            id: data['id'] ?? chatId,
            name: data['name'] ?? '',
            description: data['description'],
            groupImage: data['groupImage'],
            createdBy: data['createdBy'] ?? '',
            createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            members: List<String>.from(data['members'] ?? []),
            memberCount: data['memberCount'] ?? 0,
            lastMessage: data['lastMessage'],
            lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate(),
          );
        }
      } else {
        // Get caller user information
        final callerDoc = await FirebaseFirestore.instance.collection(FirebaseConstants.userCollection).doc(callerId).get();

        if (callerDoc.exists && callerDoc.data() != null) {
          caller = UserModel.fromFirestore(callerDoc.data()!, callerId);
        }
      }

      // Show incoming call dialog instead of navigating directly
      if (isGroupCall && group != null) {
        Get.dialog(
          IncomingCallDialog(
            group: group,
            chatId: chatId,
            isVideoCall: isVideoCall,
            notificationId: notificationId,
          ),
          barrierDismissible: false,
        );
      } else if (!isGroupCall && caller != null) {
        Get.dialog(
          IncomingCallDialog(
            caller: caller,
            chatId: chatId,
            isVideoCall: isVideoCall,
            notificationId: notificationId,
          ),
          barrierDismissible: false,
        );
      }
    } catch (e) {
      log('Error handling call notification: $e');
    }
  }
}
