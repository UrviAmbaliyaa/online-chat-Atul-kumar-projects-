import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:online_chat/features/home/models/message_model.dart';
import 'package:online_chat/utils/app_color.dart';
import 'package:online_chat/utils/app_profile_image.dart';
import 'package:online_chat/utils/app_spacing.dart';
import 'package:online_chat/utils/app_string.dart';
import 'package:online_chat/utils/app_text.dart';
import 'package:url_launcher/url_launcher.dart';

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
          bottom: Spacing.xs,
          left: isCurrentUser ? 50.w : 0,
          right: isCurrentUser ? 0 : 50.w,
        ),
        child: Row(
          mainAxisAlignment:
              isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
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
                  horizontal: Spacing.md,
                  vertical: Spacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isCurrentUser
                      ? AppColor.primaryColor
                      : AppColor.whiteColor,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                          color: isCurrentUser
                              ? AppColor.whiteColor.withOpacity(0.7)
                              : AppColor.greyColor,
                        ),
                        if (isCurrentUser) ...[
                          SizedBox(width: 4.w),
                          Opacity(
                            opacity: 0.5,
                            child: Icon(
                              message.isRead
                                  ? Icons.done_all
                                  : Icons.check_outlined,
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
          color: (isCurrentUser ? AppColor.whiteColor : AppColor.primaryColor)
              .withOpacity(0.2),
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
              color: isCurrentUser
                  ? AppColor.whiteColor.withOpacity(0.8)
                  : AppColor.darkGrey,
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
    return ClipRRect(
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
    );
  }

  Widget _buildFileMessage() {
    final isPDF = message.fileExtension?.toLowerCase() == 'pdf';
    final isZIP = message.fileExtension?.toLowerCase() == 'zip' ||
        message.fileExtension?.toLowerCase() == 'rar' ||
        message.fileExtension?.toLowerCase() == '7z';

    return InkWell(
      onTap: () async {
        if (message.fileUrl != null) {
          final uri = Uri.parse(message.fileUrl!);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }
      },
      child: Container(
        padding: EdgeInsets.all(Spacing.md),
        decoration: BoxDecoration(
          color: (isCurrentUser ? AppColor.whiteColor : AppColor.lightGrey)
              .withOpacity(0.3),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(Spacing.sm),
              decoration: BoxDecoration(
                color: isCurrentUser
                    ? AppColor.whiteColor.withOpacity(0.2)
                    : AppColor.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                isPDF
                    ? Icons.picture_as_pdf
                    : isZIP
                        ? Icons.folder_zip
                        : Icons.insert_drive_file,
                color:
                    isCurrentUser ? AppColor.whiteColor : AppColor.primaryColor,
                size: 24.sp,
              ),
            ),
            SizedBox(width: Spacing.sm),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: message.fileName ?? 'File',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color:
                        isCurrentUser ? AppColor.whiteColor : AppColor.darkGrey,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (message.fileSize != null) ...[
                    SizedBox(height: 2.h),
                    AppText(
                      text: message.fileSize!,
                      fontSize: 12.sp,
                      color: isCurrentUser
                          ? AppColor.whiteColor.withOpacity(0.7)
                          : AppColor.greyColor,
                    ),
                  ],
                ],
              ),
            ),
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

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }
}
