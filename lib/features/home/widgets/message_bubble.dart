import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:online_chat/features/home/models/message_model.dart';
import 'package:online_chat/features/home/screen/media_preview_screen.dart';
import 'package:online_chat/utils/app_color.dart';
import 'package:online_chat/utils/app_profile_image.dart';
import 'package:online_chat/utils/app_snackbar.dart';
import 'package:online_chat/utils/app_spacing.dart';
import 'package:online_chat/utils/app_string.dart';
import 'package:online_chat/utils/app_text.dart';
import 'package:online_chat/utils/download_manager.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isCurrentUser;
  final bool isSending;
  final bool isItGroupChat;
  final VoidCallback? onReply;
  final VoidCallback? onLongPress;
  final VoidCallback? onReplyPreviewTap;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    this.isSending = false,
    this.onReply,
    this.onLongPress,
    required this.isItGroupChat,
    this.onReplyPreviewTap,
  });

  @override
  Widget build(BuildContext context) {
    log("isCurrentUser && message.isRead::::::::::::::::${isCurrentUser}");
    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        margin: EdgeInsets.only(
          bottom: Spacing.sm,
          top: Spacing.sm,
          left: isCurrentUser ? 50.w : 0,
          right: isCurrentUser ? 0 : 50.w,
        ),
        child: Row(
          mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isCurrentUser) ...[
              AppProfileImage(
                width: 32.w,
                height: 32.h,
                username: message.senderName,
                imageUrl: message.senderImage,
                fallbackIcon: !isItGroupChat ? Icons.person : null,
                fontSize: 16.sp,
              ),
              SizedBox(width: 8.w),
            ],
            Flexible(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Spacing.sm,
                  vertical: Spacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isCurrentUser ? AppColor.primaryColor : AppColor.whiteColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.r),
                    topRight: Radius.circular(12.r),
                    bottomLeft: Radius.circular(
                      isCurrentUser ? 12.r : 0,
                    ),
                    bottomRight: Radius.circular(
                      isCurrentUser ? 0 : 12.r,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.greyColor.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: !isCurrentUser ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                  children: [
                    // Reply preview
                    if (message.replyToMessageId != null) _buildReplyPreview(),
                    // Message content
                    _buildMessageContent(),
                    // Time and Status
                    SizedBox(height: 4.h),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppText(
                          text: _formatTime(message.timestamp),
                          fontSize: 11.sp,
                          color: isCurrentUser ? AppColor.whiteColor.withOpacity(0.7) : AppColor.greyColor,
                        ),
                        if (isCurrentUser) ...[
                          SizedBox(width: 4.w),
                          Opacity(
                            opacity: message.isRead ? 1 : 0.5,
                            child: Icon(
                              message.isRead ? Icons.done_all : Icons.check_outlined,
                              size: 14.sp,
                              color: AppColor.whiteColor,
                            ),
                          ),
                        ]
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyPreview() {
    return InkWell(
      onTap: onReplyPreviewTap,
      child: Container(
        margin: EdgeInsets.only(bottom: Spacing.sm),
        padding: EdgeInsets.all(Spacing.sm),
        decoration: BoxDecoration(
          color: (isCurrentUser ? AppColor.whiteColor : AppColor.primaryColor).withOpacity(0.2),
          borderRadius: BorderRadius.circular(8.r),
          border: Border(
            left: BorderSide(
              color: isCurrentUser ? AppColor.whiteColor : AppColor.primaryColor,
              width: 3.w,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              text: message.replyToSenderName ?? "User",
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: isCurrentUser ? AppColor.whiteColor : AppColor.primaryColor,
            ),
            SizedBox(height: 2.h),
            AppText(
              text: message.replyToMessage ?? '',
              fontSize: 12.sp,
              color: isCurrentUser ? AppColor.whiteColor.withOpacity(0.8) : AppColor.darkGrey,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent() {
    switch (message.type) {
      case MessageType.text:
        return AppText(
          text: message.message,
          fontSize: 14.sp,
          color: isCurrentUser ? AppColor.whiteColor : AppColor.darkGrey,
        );
      case MessageType.image:
        return _buildImageMessage();
      case MessageType.file:
        return _buildFileMessage();
    }
  }

  Widget _buildImageMessage() {
    final dm = Get.put(DownloadManager(), permanent: true);
    return Stack(
      children: [
        InkWell(
          onTap: () {
            if (message.imageUrl != null && message.imageUrl!.isNotEmpty) {
              Get.to(
                () => MediaPreviewScreen(
                  isImage: true,
                  networkUrl: message.imageUrl,
                  enableSend: false,
                  fileName: message.fileName,
                  fileExtension: 'jpg',
                ),
              );
            }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: CachedNetworkImage(
              imageUrl: message.imageUrl ?? '',
              width: 200.w,
              height: 200.h,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 200.w,
                height: 200.h,
                color: AppColor.lightGrey,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColor.primaryColor,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: 200.w,
                height: 200.h,
                color: AppColor.lightGrey,
                child: const Icon(
                  Icons.error,
                  color: AppColor.redColor,
                ),
              ),
            ),
          ),
        ),
        if (message.imageUrl != null && message.imageUrl!.isNotEmpty)
          Positioned(
            right: 6.w,
            bottom: 6.h,
            child: Obx(() {
              final isThisDownloading = dm.isDownloading.value && dm.currentUrl.value == message.imageUrl;
              if (isThisDownloading) {
                return Container(
                  width: 26.w,
                  height: 26.h,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(6.w),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColor.whiteColor,
                    ),
                  ),
                );
              }
              return _buildDownloadChip(
                onTap: () {
                  dm.enqueue(message.imageUrl!, fileName: message.fileName);
                },
              );
            }),
          ),
      ],
    );
  }

  Widget _buildFileMessage() {
    final isPDF = message.fileExtension?.toLowerCase() == 'pdf';
    final isZIP = message.fileExtension?.toLowerCase() == 'zip' ||
        message.fileExtension?.toLowerCase() == 'rar' ||
        message.fileExtension?.toLowerCase() == '7z';

    final dm = Get.put(DownloadManager(), permanent: true);
    return InkWell(
      onTap: () {
        if (message.fileUrl != null && message.fileUrl!.isNotEmpty) {
          Get.to(
            () => MediaPreviewScreen(
              isImage: false,
              networkUrl: message.fileUrl,
              enableSend: false,
              fileName: message.fileName,
              fileExtension: message.fileExtension,
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
        decoration: BoxDecoration(
          color: (isCurrentUser ? AppColor.whiteColor : AppColor.lightGrey).withOpacity(0.3),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              padding: EdgeInsets.all(Spacing.xs),
              decoration: BoxDecoration(
                color: isCurrentUser ? AppColor.whiteColor.withOpacity(0.2) : AppColor.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                isPDF
                    ? Icons.picture_as_pdf
                    : isZIP
                        ? Icons.folder_zip
                        : Icons.insert_drive_file,
                color: isCurrentUser ? AppColor.whiteColor : AppColor.primaryColor,
                size: 18.sp,
              ),
            ),
            SizedBox(width: Spacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText(
                    text: message.fileName ?? 'File',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: isCurrentUser ? AppColor.whiteColor : AppColor.darkGrey,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (message.fileSize != null) ...[
                    SizedBox(height: 2.h),
                    AppText(
                      text: message.fileSize!,
                      fontSize: 10.sp,
                      color: isCurrentUser ? AppColor.whiteColor.withOpacity(0.7) : AppColor.greyColor,
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: Spacing.xs),
            Obx(() {
              final isThisDownloading = dm.isDownloading.value && dm.currentUrl.value == message.fileUrl;
              return InkWell(
                onTap: () {
                  if (message.fileUrl == null || message.fileUrl!.isEmpty) {
                    return;
                  }
                  if (dm.isDownloading.value && dm.currentUrl.value != message.fileUrl) {
                    AppSnackbar.warning(message: AppString.downloading);
                  }
                  dm.enqueue(message.fileUrl!, fileName: message.fileName);
                },
                borderRadius: BorderRadius.circular(6.r),
                child: Container(
                  width: 28.w,
                  height: 28.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isCurrentUser ? AppColor.whiteColor.withOpacity(0.15) : AppColor.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: isThisDownloading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColor.primaryColor,
                          ),
                        )
                      : Icon(
                          Icons.download_rounded,
                          size: 18.sp,
                          color: isCurrentUser ? AppColor.whiteColor : AppColor.primaryColor,
                        ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSendingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText(
          text: AppString.sending,
          fontSize: 11.sp,
          color: AppColor.whiteColor.withOpacity(0.7),
        ),
        SizedBox(width: 4.w),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            3,
            (index) => Container(
              width: 3.w,
              height: 3.h,
              margin: EdgeInsets.symmetric(horizontal: 1.5.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColor.whiteColor.withOpacity(0.7),
              ),
            )
                .animate(onPlay: (controller) => controller.repeat())
                .fadeIn(
                  duration: 400.ms,
                  delay: (index * 200).ms,
                )
                .then()
                .fadeOut(
                  duration: 400.ms,
                )
                .then()
                .fadeIn(
                  duration: 400.ms,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadChip({required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.download_rounded,
                size: 14.sp,
                color: AppColor.whiteColor,
              ),
              SizedBox(width: 4.w),
              AppText(
                text: AppString.download,
                fontSize: 10.sp,
                color: AppColor.whiteColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }
}
