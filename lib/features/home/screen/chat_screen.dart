import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:online_chat/features/home/controller/chat_controller.dart';
import 'package:online_chat/features/home/models/message_model.dart';
import 'package:online_chat/features/home/screen/calling_screen.dart';
import 'package:online_chat/features/home/screen/edit_members_screen.dart';
import 'package:online_chat/features/home/screen/user_detail_screen.dart';
import 'package:online_chat/features/home/widgets/chat_empty_state.dart';
import 'package:online_chat/features/home/widgets/date_separator.dart';
import 'package:online_chat/features/home/widgets/delete_message_confirmation_dialog.dart';
import 'package:online_chat/features/home/widgets/message_bubble.dart';
import 'package:online_chat/utils/app_color.dart';
import 'package:online_chat/utils/app_profile_image.dart';
import 'package:online_chat/utils/app_snackbar.dart';
import 'package:online_chat/utils/app_spacing.dart';
import 'package:online_chat/utils/app_string.dart';
import 'package:online_chat/utils/app_text.dart';
import 'package:online_chat/utils/app_textfield.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChatController());

    return Scaffold(
      backgroundColor: AppColor.chatBackground,
      appBar: _buildAppBar(controller),
      body: Column(
        verticalDirection: VerticalDirection.down,
        children: [
          // Reply preview
          Obx(() => controller.replyingToMessage.value != null ? _buildReplyPreview(controller) : const SizedBox.shrink()),
          // Messages list
          Expanded(
            child: Obx(() {
              if (controller.isLoadingMessages.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColor.primaryColor,
                  ),
                );
              }

              if (controller.messages.isEmpty) {
                return const ChatEmptyState();
              }

              return ListView.builder(
                controller: controller.scrollController,
                padding: EdgeInsets.all(Spacing.md),
                itemCount: controller.messages.length,
                addAutomaticKeepAlives: false,
                itemBuilder: (context, index) {
                  final message = controller.messages[index];
                  final previousMessage = index > 0 ? controller.messages[index - 1] : null;

                  // Check if we need to show date separator
                  final showDateSeparator = previousMessage == null ||
                      !_isSameDay(
                        previousMessage.timestamp,
                        message.timestamp,
                      );

                  return Column(
                    children: [
                      if (showDateSeparator) DateSeparator(date: message.timestamp),
                      Obx(() {
                        final isHighlighted = controller.highlightedMessageId.value == message.id;
                        return Container(
                          decoration: isHighlighted
                              ? BoxDecoration(
                                  color: AppColor.primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8.r),
                                )
                              : null,
                          padding: isHighlighted ? EdgeInsets.all(Spacing.xs) : EdgeInsets.zero,
                          child: MessageBubble(
                            message: message,
                            isItGroupChat: controller.chatType.value == ChatType.group,
                            isCurrentUser: controller.isCurrentUser(message.senderId),
                            isSending: (controller.isUploadingImage.value || controller.isUploadingFile.value || controller.isSending.value) &&
                                controller.pendingMessageIds.contains(message.id),
                            onReply: () {
                              controller.setReplyingToMessage(message);
                            },
                            onLongPress: () {
                              _showMessageOptions(context, controller, message);
                            },
                            onReplyPreviewTap: message.replyToMessageId != null
                                ? () {
                                    controller.scrollToMessage(
                                      message.replyToMessageId!,
                                    );
                                  }
                                : null,
                          ),
                        );
                      }),
                    ],
                  );
                },
              );
            }),
          ),
          // Input field
          _buildInputField(controller),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ChatController controller) {
    return AppBar(
      backgroundColor: AppColor.primaryColor,
      elevation: 0,
      leadingWidth: 30.r,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: AppColor.whiteColor,
          size: 24.sp,
        ),
        onPressed: () => Get.back(),
      ),
      title: Obx(() {
        final title = controller.getChatTitle();
        final image = controller.getChatImage();
        final isGroup = controller.chatType.value == ChatType.group;

        return InkWell(
          onTap: () => _onAppBarTap(controller, isGroup),
          child: Row(
            children: [
              AppProfileImage(
                width: 40.w,
                height: 40.h,
                username: title,
                imageUrl: image,
                fallbackIcon: isGroup ? Icons.group : Icons.person,
                fontSize: 20.sp,
              ),
              SizedBox(width: Spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText(
                      text: title,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColor.whiteColor,
                    ),
                    // Show member names for group chats, last seen for one-to-one
                    if (isGroup)
                      Obx(() {
                        final memberNames = controller.groupMemberNames;
                        if (memberNames.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return AppText(
                          text: memberNames.join(', '),
                          fontSize: 12.sp,
                          color: AppColor.whiteColor.withValues(alpha: 0.8),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        );
                      })
                    else
                      Obx(() {
                        final otherUser = controller.otherUser.value;
                        if (otherUser == null) {
                          return const SizedBox.shrink();
                        }
                        // Real-time status text based on updated otherUser value
                        String statusText;
                        if (otherUser.isOnline) {
                          statusText = AppString.online;
                        } else if (otherUser.lastSeen != null) {
                          statusText = '${AppString.lastSeen} ${_formatLastSeen(otherUser.lastSeen!)}';
                        } else {
                          statusText = AppString.offline;
                        }
                        return AppText(
                          text: statusText,
                          fontSize: 12.sp,
                          color: AppColor.whiteColor.withValues(alpha: 0.8),
                        );
                      }),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
      actions: [
        // Audio call button - Hide for groups with only one member
        Obx(() {
          final isGroup = controller.chatType.value == ChatType.group;
          final group = controller.group.value;

          // Hide button if it's a group with only one member
          if (isGroup && group != null) {
            if (group.members.length <= 1 || group.memberCount <= 1) {
              return const SizedBox.shrink();
            }
          }

          return IconButton(
            icon: Icon(
              Icons.call_rounded,
              color: AppColor.whiteColor,
              size: 24.sp,
            ),
            onPressed: () => _handleCallOption(controller, 'audio'),
            tooltip: 'Audio call',
          );
        }),
        SizedBox(width: Spacing.xs),
      ],
    );
  }

  Widget _buildReplyPreview(ChatController controller) {
    final replyMessage = controller.replyingToMessage.value!;
    return InkWell(
      onTap: () {
        // Scroll to the replied message
        if (replyMessage.replyToMessageId != null) {
          controller.scrollToMessage(replyMessage.replyToMessageId!);
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.xs),
        padding: EdgeInsets.all(Spacing.md),
        decoration: BoxDecoration(
          color: AppColor.primaryColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppColor.primaryColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 4.w,
              height: 50.h,
              decoration: BoxDecoration(
                color: AppColor.primaryColor,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(width: Spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.reply_rounded,
                        size: 16.sp,
                        color: AppColor.primaryColor,
                      ),
                      SizedBox(width: 4.w),
                      AppText(
                        text: '${AppString.replyingTo} ${replyMessage.senderName}',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColor.primaryColor,
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  AppText(
                    text: replyMessage.message.length > 50 ? '${replyMessage.message.substring(0, 50)}...' : replyMessage.message,
                    fontSize: 13.sp,
                    color: AppColor.darkGrey,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: Spacing.sm),
            IconButton(
              icon: Icon(
                Icons.close_rounded,
                color: AppColor.greyColor,
                size: 20.sp,
              ),
              onPressed: () => controller.clearReply(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(ChatController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        boxShadow: [
          BoxShadow(
            color: AppColor.greyColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Attachment button
              Container(
                decoration: BoxDecoration(
                  color: AppColor.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.attach_file_rounded,
                    color: AppColor.primaryColor,
                    size: 24.sp,
                  ),
                  onPressed: () {
                    // Close keyboard before opening attachment options
                    FocusManager.instance.primaryFocus?.unfocus();
                    _showAttachmentOptions(controller);
                  },
                ),
              ),
              SizedBox(width: Spacing.sm),
              // Text field
              Expanded(
                child: Obx(() {
                  final isSending = controller.isSending.value;
                  return AppTextField(
                    controller: controller.message,
                    hintText: AppString.typeMessage,
                    enabled: !isSending,
                    maxLines: null,
                    onTap: () {
                      // Scroll to bottom when focusing the input (keyboard opens)
                      Future.delayed(const Duration(milliseconds: 150), () {
                        controller.scrollToBottom(animate: true); // private but same lib
                      });
                    },
                    fillColor: AppColor.lightGrey.withValues(alpha: 0.3),
                    borderColor: Colors.transparent,
                    borderRadius: 8.r,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: Spacing.md,
                      vertical: Spacing.sm,
                    ),
                    hintStyle: TextStyle(
                      color: AppColor.greyColor,
                      fontSize: 14.sp,
                    ),
                    textStyle: TextStyle(
                      fontSize: 14.sp,
                      color: AppColor.blackColor,
                      fontWeight: FontWeight.w400,
                    ),
                    onChanged: (value) => controller.updateMessageText(value),
                    onSubmitted: (value) {
                      if (!isSending) {
                        controller.sendTextMessage();
                      }
                    },
                  );
                }),
              ),
              SizedBox(width: Spacing.sm),
              // Send button
              Obx(() {
                final hasText = controller.messageText.value.trim().isNotEmpty;
                final isUploading = controller.isUploadingImage.value || controller.isUploadingFile.value;
                final isSending = controller.isSending.value;
                final isLoading = isUploading || isSending;

                if (isLoading) {
                  return Container(
                    width: 44.w,
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColor.primaryColor,
                        ),
                      ),
                    ),
                  );
                }

                return GestureDetector(
                  onTap: hasText && !isSending ? () => controller.sendTextMessage() : null,
                  child: Container(
                    width: 44.w,
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: hasText ? AppColor.primaryColor : AppColor.lightGrey,
                      shape: BoxShape.circle,
                      boxShadow: hasText
                          ? [
                              BoxShadow(
                                color: AppColor.primaryColor.withValues(alpha: 0.3),
                                blurRadius: 8,
                                spreadRadius: 0,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      Icons.send_rounded,
                      color: hasText ? AppColor.whiteColor : AppColor.greyColor,
                      size: 20.sp,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showAttachmentOptions(ChatController controller) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(
          top: Spacing.md,
          left: Spacing.md,
          right: Spacing.md,
          bottom: Spacing.lg,
        ),
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: Spacing.lg),
              decoration: BoxDecoration(
                color: AppColor.lightGrey,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            AppText(
              text: AppString.attachFile,
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppColor.darkGrey,
            ),
            SizedBox(height: Spacing.xl),
            // Camera option
            _buildAttachmentOption(
              icon: Icons.camera_alt_rounded,
              title: AppString.camera,
              color: AppColor.primaryColor,
              onTap: () {
                Get.back();
                controller.pickAndSendImageFromCamera();
              },
            ),
            SizedBox(height: Spacing.md),
            // Gallery option
            _buildAttachmentOption(
              icon: Icons.photo_library_rounded,
              title: AppString.gallery,
              color: AppColor.primaryColor,
              onTap: () {
                Get.back();
                controller.pickAndSendImageFromGallery();
              },
            ),
            SizedBox(height: Spacing.md),
            // File upload option (PDF/ZIP)
            _buildAttachmentOption(
              icon: Icons.insert_drive_file_rounded,
              title: '${AppString.pdf} / ${AppString.zip}',
              color: AppColor.primaryColor,
              onTap: () {
                Get.back();
                controller.pickAndSendFile();
              },
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    final optionColor = color ?? AppColor.primaryColor;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColor.whiteColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppColor.lightGrey.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: optionColor.withValues(alpha: 0.08),
                blurRadius: 6,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      optionColor.withValues(alpha: 0.2),
                      optionColor.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10.r),
                  boxShadow: [
                    BoxShadow(
                      color: optionColor.withValues(alpha: 0.15),
                      blurRadius: 3,
                      spreadRadius: 0,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: optionColor,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: Spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText(
                      text: title,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColor.darkGrey,
                    ),
                    SizedBox(height: 1.h),
                    AppText(
                      text: _getAttachmentDescription(title),
                      fontSize: 11.sp,
                      color: AppColor.greyColor,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColor.greyColor.withValues(alpha: 0.5),
                size: 18.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getAttachmentDescription(String title) {
    switch (title) {
      case 'Camera':
        return 'Take a photo';
      case 'Gallery':
        return 'Choose from gallery';
      case 'PDF / ZIP':
        return 'Upload document or archive';
      default:
        return '';
    }
  }

  void _showMessageOptions(
    BuildContext context,
    ChatController controller,
    MessageModel message,
  ) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(Spacing.md),
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: Spacing.md),
              decoration: BoxDecoration(
                color: AppColor.lightGrey,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            _buildMessageOption(
              icon: Icons.reply,
              title: AppString.reply,
              onTap: () {
                Get.back();
                controller.setReplyingToMessage(message);
              },
            ),
            SizedBox(height: Spacing.sm),
            _buildMessageOption(
              icon: Icons.copy,
              title: AppString.copy,
              onTap: () {
                Get.back();
                _copyMessageToClipboard(message);
              },
            ),
            if (controller.isCurrentUser(message.senderId)) ...[
              SizedBox(height: Spacing.sm),
              _buildMessageOption(
                icon: Icons.delete,
                title: AppString.delete,
                color: AppColor.redColor,
                onTap: () {
                  Get.back();
                  _showDeleteMessageConfirmation(controller, message);
                },
              ),
            ],
            SizedBox(height: Spacing.md),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(Spacing.md),
        decoration: BoxDecoration(
          color: AppColor.lightGrey.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color ?? AppColor.primaryColor,
              size: 24.sp,
            ),
            SizedBox(width: Spacing.md),
            AppText(
              text: title,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: color ?? AppColor.darkGrey,
            ),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  String _formatLastSeen(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    // Format time as HH:MM AM/PM
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final timeString = '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';

    if (messageDate == today) {
      return 'today at $timeString';
    } else if (messageDate == yesterday) {
      return 'yesterday at $timeString';
    } else {
      // Format as "MMM d at HH:MM AM/PM" for older dates
      final dateString = DateFormat('MMM d').format(dateTime);
      return '$dateString at $timeString';
    }
  }

  void _copyMessageToClipboard(MessageModel message) {
    try {
      String textToCopy = message.message;

      // For image messages, copy a placeholder text
      if (message.type == MessageType.image) {
        textToCopy = AppString.imageMessage;
      } else if (message.type == MessageType.file) {
        // For file messages, copy file name if available
        textToCopy = message.fileName ?? AppString.fileMessage;
      }

      Clipboard.setData(ClipboardData(text: textToCopy));
      AppSnackbar.success(message: AppString.messageCopied);
    } catch (e) {
      AppSnackbar.error(message: AppString.operationFailed);
    }
  }

  void _showDeleteMessageConfirmation(
    ChatController controller,
    MessageModel message,
  ) {
    Get.dialog(
      DeleteMessageConfirmationDialog(
        onDelete: () => controller.deleteMessage(message.id),
      ),
      barrierDismissible: true,
    );
  }

  void _onAppBarTap(ChatController controller, bool isGroup) {
    if (isGroup) {
      // Navigate to edit members screen for group chats
      final group = controller.group.value;
      if (group != null) {
        Get.to(() => EditMembersScreen(group: group));
      }
    } else {
      // Navigate to user detail screen for one-to-one chats
      final otherUser = controller.otherUser.value;
      if (otherUser != null) {
        Get.to(() => UserDetailScreen(user: otherUser));
      }
    }
  }

  void _handleCallOption(ChatController controller, String callType) {
    final isVideoCall = callType == 'video';
    final isGroup = controller.chatType.value == ChatType.group;

    if (isGroup) {
      final group = controller.group.value;
      if (group != null) {
        Get.to(
          () => CallingScreen(
            group: group,
            chatId: controller.chatId.value,
            isIncoming: false,
            isVideoCall: isVideoCall,
          ),
        );
      }
    } else {
      final otherUser = controller.otherUser.value;
      if (otherUser != null) {
        Get.to(
          () => CallingScreen(
            user: otherUser,
            chatId: controller.chatId.value,
            isIncoming: false,
            isVideoCall: isVideoCall,
          ),
        );
      }
    }
  }
}
