import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:online_chat/features/home/models/group_chat_model.dart';
import 'package:online_chat/features/home/models/message_model.dart';
import 'package:online_chat/features/home/models/user_model.dart';
import 'package:online_chat/features/home/screen/media_preview_screen.dart';
import 'package:online_chat/services/firebase_service.dart';
import 'package:online_chat/utils/app_file_picker.dart';
import 'package:online_chat/utils/app_image_picker.dart';
import 'package:online_chat/utils/app_snackbar.dart';
import 'package:online_chat/utils/app_string.dart';

class ChatController extends GetxController {
  // Chat info
  final Rx<ChatType> chatType = ChatType.oneToOne.obs;
  final RxString chatId = ''.obs;
  final TextEditingController message = TextEditingController();
  final Rx<UserModel?> otherUser = Rx<UserModel?>(null);
  final Rx<GroupChatModel?> group = Rx<GroupChatModel?>(null);
  final RxList<String> groupMemberNames = <String>[].obs;

  // Messages
  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final RxBool isLoadingMessages = false.obs;

  // Message input
  final RxString messageText = ''.obs;
  final Rx<MessageModel?> replyingToMessage = Rx<MessageModel?>(null);

  // Upload states
  final RxBool isUploadingImage = false.obs;
  final RxBool isUploadingFile = false.obs;
  final RxBool isSending = false.obs;

  // Track pending messages (messages being sent)
  final RxSet<String> pendingMessageIds = <String>{}.obs;

  // Scroll controller
  final ScrollController scrollController = ScrollController();

  // Pending picked file for live-updated media preview (for non-image files)
  final Rx<File?> pendingPickedFile = Rx<File?>(null);

  // Track highlighted message (for reply navigation)
  final RxString highlightedMessageId = ''.obs;

  StreamSubscription<DocumentSnapshot>? _messagesSubscription;
  StreamSubscription<DocumentSnapshot>? _userPresenceSubscription;

  @override
  void onInit() {
    super.onInit();
    _initializeChat();
  }

  @override
  void onClose() {
    _messagesSubscription?.cancel();
    _userPresenceSubscription?.cancel();
    scrollController.dispose();
    super.onClose();
  }

  void _initializeChat() {
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      if (args['chatType'] == 'group' && args['group'] is GroupChatModel) {
        chatType.value = ChatType.group;
        group.value = args['group'] as GroupChatModel;
        chatId.value = group.value!.id;
        _loadGroupMemberNames();
      } else if (args['chatType'] == 'oneToOne' && args['user'] is UserModel) {
        chatType.value = ChatType.oneToOne;
        otherUser.value = args['user'] as UserModel;
        final currentUserId = FirebaseService.getCurrentUserId();
        if (currentUserId != null) {
          chatId.value = FirebaseService.getOneToOneChatId(
            currentUserId,
            otherUser.value!.id,
          );
        }
        groupMemberNames.clear();
        // Set up real-time presence listener for the other user
        _setupUserPresenceListener(otherUser.value!.id);
      }
    }
    _loadMessages();
  }

  /// Set up real-time presence listener for the other user (online status and lastSeen)
  void _setupUserPresenceListener(String userId) {
    // Cancel existing subscription if any
    _userPresenceSubscription?.cancel();

    // Set up real-time stream for user presence
    _userPresenceSubscription = FirebaseService.streamUserPresence(userId).listen(
      (docSnapshot) {
        if (docSnapshot.exists && otherUser.value != null) {
          try {
            final data = docSnapshot.data() as Map<String, dynamic>;
            final isOnline = data['isOnline'] as bool? ?? false;
            final lastSeenTimestamp = data['lastSeen'];
            DateTime? lastSeen;
            if (lastSeenTimestamp != null) {
              if (lastSeenTimestamp is Timestamp) {
                lastSeen = lastSeenTimestamp.toDate();
              } else if (lastSeenTimestamp is String) {
                lastSeen = DateTime.parse(lastSeenTimestamp);
              }
            }

            // Update otherUser with new presence data
            otherUser.value = otherUser.value!.copyWith(
              isOnline: isOnline,
              lastSeen: lastSeen,
            );
          } catch (e) {
            log('Error updating user presence: $e');
          }
        }
      },
      onError: (error) {
        log('Error in user presence stream: $error');
      },
    );
  }

  /// Load group member names (first 4, excluding current user)
  Future<void> _loadGroupMemberNames() async {
    if (chatType.value != ChatType.group || group.value == null) {
      groupMemberNames.clear();
      return;
    }

    try {
      final currentUserId = FirebaseService.getCurrentUserId();
      final memberIds = group.value!.members
          .where((id) => id != currentUserId) // Exclude current user
          .take(4) // Take first 4
          .toList();

      if (memberIds.isEmpty) {
        groupMemberNames.clear();
        return;
      }

      final users = await FirebaseService.getUsersByIds(memberIds);
      groupMemberNames.value = users.map((user) => user.name).toList();
    } catch (e) {
      groupMemberNames.clear();
    }
  }

  void _loadMessages() {
    if (chatId.value.isEmpty) return;

    isLoadingMessages.value = true;

    _messagesSubscription?.cancel();
    _messagesSubscription = FirebaseService.streamMessages(chatId.value).listen(
      (snapshot) {
        final previousMessageCount = messages.length;

        if (!snapshot.exists || snapshot.data() == null) {
          messages.value = [];
          isLoadingMessages.value = false;
          return;
        }

        final data = snapshot.data() as Map<String, dynamic>;
        final messagesList = data['messages'] as List<dynamic>? ?? [];

        // Filter messages older than 7 days
        final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

        final newMessages = messagesList
            .map((msg) {
              try {
                final msgMap = msg as Map<String, dynamic>;
                DateTime msgTimestamp;
                if (msgMap['timestamp'] is Timestamp) {
                  msgTimestamp = (msgMap['timestamp'] as Timestamp).toDate();
                } else if (msgMap['timestamp'] is String) {
                  msgTimestamp = DateTime.parse(msgMap['timestamp']);
                } else {
                  // Fallback to current time if timestamp is invalid
                  msgTimestamp = DateTime.now();
                }

                // Only include messages from last 7 days
                if (msgTimestamp.isBefore(sevenDaysAgo)) {
                  return null;
                }

                // Add chatId and chatType from document level
                final messageWithChatInfo = Map<String, dynamic>.from(msgMap);
                messageWithChatInfo['chatId'] = chatId.value;
                messageWithChatInfo['chatType'] = chatType.value.name;

                return MessageModel.fromJson(
                  messageWithChatInfo,
                  msgMap['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
                );
              } catch (e) {
                return null;
              }
            })
            .whereType<MessageModel>()
            .toList();

        // Remove messages from pending list if they appear in the stream (successfully sent)
        final currentMessageIds = newMessages.map((m) => m.id).toSet();
        pendingMessageIds.removeWhere((id) => currentMessageIds.contains(id));

        messages.value = newMessages;
        isLoadingMessages.value = false;

        // Mark unread messages as read in a single batched call
        _markAllUnreadAsReadBatch(newMessages);

        // Auto-scroll to bottom when new message arrives or on initial load
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (newMessages.isNotEmpty) {
            // If it's the first load or a new message was added, scroll to bottom
            if (previousMessageCount == 0 || newMessages.length > previousMessageCount) {
              _scrollToBottom(animate: previousMessageCount > 0);
            }
          }
        });
      },
      onError: (error, starck) {
        log(":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: 11111 >>>>>>> $error >>>>>>> $starck");
        isLoadingMessages.value = false;

        AppSnackbar.error(message: AppString.sendMessageError);
      },
    );
  }

  void _scrollToBottom({bool animate = true}) {
    if (scrollController.hasClients) {
      if (animate) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        // Jump to bottom immediately on initial load
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    }
  }

  /// Public wrapper to allow UI widgets to request scroll-to-bottom
  void scrollToBottom({bool animate = true}) {
    _scrollToBottom(animate: animate);
  }

  /// Scroll to a specific message by its ID
  /// [messageId] - The ID of the message to scroll to
  void scrollToMessage(String messageId) {
    if (!scrollController.hasClients) {
      return;
    }

    // Find the index of the message
    final messageIndex = messages.indexWhere((msg) => msg.id == messageId);
    if (messageIndex == -1) {
      return;
    }

    // Highlight the message
    highlightedMessageId.value = messageId;

    // Clear highlight after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (highlightedMessageId.value == messageId) {
        highlightedMessageId.value = '';
      }
    });

    // Wait for the next frame to ensure the list is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;

      // Use Scrollable.ensureVisible approach would require GlobalKey
      // For now, we'll use a more accurate estimation
      // Average message height is around 60-120px depending on content
      // We'll use 80px as base and add padding
      final padding = 16.0; // ListView padding
      final estimatedMessageHeight = 90.0; // Average message height
      final dateSeparatorHeight = 40.0; // Date separator height

      // Count date separators before this message
      int dateSeparatorCount = 0;
      for (int i = 0; i < messageIndex; i++) {
        if (i == 0) {
          dateSeparatorCount++;
        } else {
          final prevDate = messages[i - 1].timestamp;
          final currDate = messages[i].timestamp;
          if (prevDate.year != currDate.year || prevDate.month != currDate.month || prevDate.day != currDate.day) {
            dateSeparatorCount++;
          }
        }
      }

      // Calculate offset: padding + (message index * message height) + (date separators * separator height)
      final estimatedOffset = padding + (messageIndex * estimatedMessageHeight) + (dateSeparatorCount * dateSeparatorHeight);

      final maxScroll = scrollController.position.maxScrollExtent;
      final targetOffset = estimatedOffset.clamp(0.0, maxScroll);

      // Scroll with animation
      scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  void updateMessageText(String text) {
    messageText.value = text;
    // Auto-scroll to bottom when user starts typing
    // Delay slightly to allow keyboard/layout changes
    Future.microtask(() {
      _scrollToBottom(animate: true);
    });
  }

  void setReplyingToMessage(MessageModel? message) {
    replyingToMessage.value = message;
  }

  void clearReply() {
    replyingToMessage.value = null;
    message.clear();
  }

  Future<void> _ensureReciprocalContact() async {
    try {
      if (chatType.value != ChatType.oneToOne || otherUser.value == null) {
        return;
      }
      final currentUserId = FirebaseService.getCurrentUserId();
      final otherId = otherUser.value!.id;
      if (currentUserId == null || currentUserId == otherId) return;

      final exists = await FirebaseService.checkContactExists(
        currentUserId: otherId,
        contactUserId: currentUserId,
      );
      if (!exists) {
        await FirebaseService.addContact(
          currentUserId: otherId,
          contactUserId: currentUserId,
        );
      }
    } catch (_) {
      // Non-critical: ignore failures
    }
  }

  Future<void> sendTextMessage() async {
    if (messageText.value.trim().isEmpty || isSending.value) return;
    if (isSending.value) return;
    isSending.value = true;

    try {
      final currentUserId = FirebaseService.getCurrentUserId();
      if (currentUserId == null) {
        AppSnackbar.error(message: AppString.userNotLoggedIn);
        isSending.value = false;
        return;
      }

      final currentUser = await FirebaseService.getCurrentUserDocument();
      if (currentUser == null) {
        AppSnackbar.error(message: AppString.userNotFound);
        isSending.value = false;
        return;
      }

      final messageId = await FirebaseService.sendMessage(
        chatId: chatId.value,
        senderId: currentUserId,
        senderName: currentUser['name'] ?? 'Unknown',
        senderImage: currentUser['profileImage'],
        message: messageText.value.trim(),
        type: MessageType.text.name,
        chatType: chatType.value.name,
        replyToMessageId: replyingToMessage.value?.id,
        replyToMessage: replyingToMessage.value?.message,
        replyToSenderName: replyingToMessage.value?.senderName,
      );

      if (messageId != null) {
        // Add to pending messages
        pendingMessageIds.add(messageId);
        messageText.value = '';

        clearReply();

        // Ensure sender is auto-added to recipient's contacts
        _ensureReciprocalContact();
      }
    } catch (error, starck) {
      log(":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: 11111 >>>>>>> $error >>>>>>> $starck");
      AppSnackbar.error(message: AppString.sendMessageError);
    } finally {
      isSending.value = false;
    }
  }

  Future<void> sendImageMessage(File imageFile) async {
    if (isUploadingImage.value) return;
    isUploadingImage.value = true;

    try {
      final imageUrl = await FirebaseService.uploadChatImage(
        file: imageFile,
        chatId: chatId.value,
      );

      if (imageUrl == null) {
        isUploadingImage.value = false;
        return;
      }

      final currentUserId = FirebaseService.getCurrentUserId();
      if (currentUserId == null) {
        AppSnackbar.error(message: AppString.userNotLoggedIn);
        isUploadingImage.value = false;
        return;
      }

      final currentUser = await FirebaseService.getCurrentUserDocument();
      if (currentUser == null) {
        AppSnackbar.error(message: AppString.userNotFound);
        isUploadingImage.value = false;
        return;
      }

      final messageId = await FirebaseService.sendMessage(
        chatId: chatId.value,
        senderId: currentUserId,
        senderName: currentUser['name'] ?? 'Unknown',
        senderImage: currentUser['profileImage'],
        message: AppString.image,
        type: MessageType.image.name,
        chatType: chatType.value.name,
        imageUrl: imageUrl,
        replyToMessageId: replyingToMessage.value?.id,
        replyToMessage: replyingToMessage.value?.message,
        replyToSenderName: replyingToMessage.value?.senderName,
      );

      if (messageId != null) {
        pendingMessageIds.add(messageId);

        // Ensure sender is auto-added to recipient's contacts
        _ensureReciprocalContact();
      }

      clearReply();
    } catch (e) {
      AppSnackbar.error(message: AppString.uploadImageError);
    } finally {
      isUploadingImage.value = false;
    }
  }

  Future<void> sendFileMessage(File file) async {
    isUploadingFile.value = true;

    try {
      final fileUrl = await FirebaseService.uploadChatFile(
        file: file,
        chatId: chatId.value,
      );

      if (fileUrl == null) {
        isUploadingFile.value = false;
        return;
      }

      final currentUserId = FirebaseService.getCurrentUserId();
      if (currentUserId == null) {
        AppSnackbar.error(message: AppString.userNotLoggedIn);
        isUploadingFile.value = false;
        return;
      }

      final currentUser = await FirebaseService.getCurrentUserDocument();
      if (currentUser == null) {
        AppSnackbar.error(message: AppString.userNotFound);
        isUploadingFile.value = false;
        return;
      }

      final fileName = file.path.split('/').last;
      final fileSize = AppFilePicker.getFileSize(file);
      final fileExtension = AppFilePicker.getFileExtension(file.path);

      final messageId = await FirebaseService.sendMessage(
        chatId: chatId.value,
        senderId: currentUserId,
        senderName: currentUser['name'] ?? 'Unknown',
        senderImage: currentUser['profileImage'],
        message: fileName,
        type: MessageType.file.name,
        chatType: chatType.value.name,
        fileUrl: fileUrl,
        fileName: fileName,
        fileSize: fileSize,
        fileExtension: fileExtension,
        replyToMessageId: replyingToMessage.value?.id,
        replyToMessage: replyingToMessage.value?.message,
        replyToSenderName: replyingToMessage.value?.senderName,
      );

      if (messageId != null) {
        pendingMessageIds.add(messageId);

        // Ensure sender is auto-added to recipient's contacts
        _ensureReciprocalContact();
      }

      clearReply();
    } catch (e) {
      AppSnackbar.error(message: AppString.uploadFileError);
    } finally {
      isUploadingFile.value = false;
    }
  }

  /// Pick and send image from gallery
  Future<void> pickAndSendImageFromGallery() async {
    final image = await AppImagePicker.pickImageFromGallery(
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    if (image != null) {
      Get.to(() => MediaPreviewScreen(file: image, isImage: true));
    }
  }

  /// Pick and send image from camera
  Future<void> pickAndSendImageFromCamera() async {
    final image = await AppImagePicker.pickImageFromCamera(
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    if (image != null) {
      Get.to(() => MediaPreviewScreen(file: image, isImage: true));
    }
  }

  /// Pick and send image (legacy method - uses image source dialog)
  Future<void> pickAndSendImage() async {
    AppImagePicker.showImageSourceDialog(
      onGallerySelected: (image) {
        sendImageMessage(image);
      },
      onCameraSelected: (image) {
        sendImageMessage(image);
      },
    );
  }

  Future<void> pickImageFromCamera() async {
    final image = await AppImagePicker.pickImageFromCamera();
    if (image != null) {
      sendImageMessage(image);
    }
  }

  Future<void> pickImageFromGallery() async {
    final image = await AppImagePicker.pickImageFromGallery();
    if (image != null) {
      sendImageMessage(image);
    }
  }

  Future<void> pickAndSendFile() async {
    // Reset pending file and navigate immediately to preview
    pendingPickedFile.value = null;
    Get.to(() => const MediaPreviewScreen(isImage: false));

    // Start the picker in background; update preview when done
    final file = await AppFilePicker.pickPDFOrZIP();
    log("file ::::::::::::::::::::::::::$file");
    if (file == null) {
      // User cancelled picking - close preview if still open
      if (Get.isOverlaysOpen || Get.currentRoute.contains('MediaPreviewScreen')) {
        if (Get.key.currentState?.canPop() == true) {
          Get.back();
        }
      }
      return;
    }
    pendingPickedFile.value = file;
  }

  String getChatTitle() {
    if (chatType.value == ChatType.group) {
      return group.value?.name ?? '';
    } else {
      return otherUser.value?.name ?? '';
    }
  }

  String? getChatImage() {
    if (chatType.value == ChatType.group) {
      return group.value?.groupImage;
    } else {
      return otherUser.value?.profileImage;
    }
  }

  bool isCurrentUser(String userId) {
    return FirebaseService.getCurrentUserId() == userId;
  }

  /// Delete a message
  /// [messageId] - The ID of the message to delete
  Future<void> deleteMessage(String messageId) async {
    try {
      final currentUserId = FirebaseService.getCurrentUserId();
      if (currentUserId == null) {
        AppSnackbar.error(message: AppString.userNotLoggedIn);
        return;
      }

      if (chatId.value.isEmpty) {
        AppSnackbar.error(message: AppString.chatNotFound);
        return;
      }

      final success = await FirebaseService.deleteMessage(
        chatId: chatId.value,
        messageId: messageId,
        userId: currentUserId,
      );

      if (success) {
        AppSnackbar.success(message: AppString.messageDeletedSuccessfully);
      }
    } catch (e) {
      AppSnackbar.error(message: AppString.deleteMessageError);
    }
  }

  /// Mark all unread messages as read with a single backend call.
  /// Optimized to minimize Firestore writes.
  Future<void> _markAllUnreadAsReadBatch(List<MessageModel> messagesList) async {
    final currentUserId = FirebaseService.getCurrentUserId();
    if (currentUserId == null || messagesList.isEmpty) return;

    try {
      // Collect unread message IDs (not sent by current user and not yet read by them)
      final unreadIds = messagesList.where((msg) => msg.senderId != currentUserId && !msg.readBy.contains(currentUserId)).map((m) => m.id).toList();

      if (unreadIds.isEmpty) return;

      // Single Firestore write to mark all as read
      // Fire-and-forget; UI already shows messages immediately
      // ignore: unawaited_futures
      FirebaseService.markMessagesAsReadBatch(
        chatId: chatId.value,
        userId: currentUserId,
        messageIds: unreadIds,
      );
    } catch (e) {
      // Silently fail - marking as read is not critical
    }
  }
}
