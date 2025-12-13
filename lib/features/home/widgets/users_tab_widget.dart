import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:online_chat/features/home/controller/home_controller.dart';
import 'package:online_chat/features/home/models/user_model.dart';
import 'package:online_chat/features/home/screen/chat_screen.dart';
import 'package:online_chat/navigations/app_navigation.dart';
import 'package:online_chat/utils/app_color.dart';
import 'package:online_chat/utils/app_profile_image.dart';
import 'package:online_chat/utils/app_spacing.dart';
import 'package:online_chat/utils/app_string.dart';
import 'package:online_chat/utils/app_text.dart';

class UsersTabWidget extends StatelessWidget {
  final HomeController controller;

  const UsersTabWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => controller.addedUsers.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: EdgeInsets.all(Spacing.md),
              itemCount: controller.addedUsers.length,
              itemBuilder: (context, index) {
                final user = controller.addedUsers[index];
                return _buildUserItem(user);
              },
            ),
    );
  }

  Widget _buildUserItem(UserModel user) {
    return Container(
      margin: EdgeInsets.only(bottom: Spacing.sm),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColor.lightGrey.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm,
        ),
        onTap: () {
          AppNavigation.push(
            const ChatScreen(),
            arguments: {
              'chatType': 'oneToOne',
              'user': user,
            },
          );
        },
        leading: Stack(
          children: [
            AppProfileImage(
              width: 56.w,
              height: 56.h,
              username: user.name,
              imageUrl: user.profileImage,
                      fontSize: 18.sp,
            ),
            if (user.isOnline)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 16.w,
                  height: 16.h,
                  decoration: BoxDecoration(
                    color: AppColor.accentColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColor.whiteColor,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: AppText(
          text: user.name,
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: AppColor.darkGrey,
        ),
            ),
            Obx(() {
              final unreadCount = controller.getUnreadCountForUser(user.id);
              if (unreadCount > 0) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 6.w,
                    vertical: 2.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: AppText(
                    text: unreadCount > 99 ? '99+' : unreadCount.toString(),
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColor.whiteColor,
            ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
        subtitle: Obx(() {
          final chatInfo = controller.getChatInfoForUser(user.id);
          final lastMessage = chatInfo?.lastMessage ?? 
              controller.getLastMessageForUser(user.id);
          
          if (lastMessage != null && lastMessage.isNotEmpty) {
            return Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: AppText(
                text: lastMessage.length > 50
                    ? '${lastMessage.substring(0, 50)}...'
                    : lastMessage,
                fontSize: 13.sp,
            color: AppColor.greyColor,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
          ),
            );
          } else {
            return Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: AppText(
                text: AppString.noMessagesYet,
                fontSize: 13.sp,
                color: AppColor.greyColor.withOpacity(0.6),
              ),
            );
          }
        }),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline,
            size: 64.sp,
            color: AppColor.greyColor.withOpacity(0.5),
          ),
          SizedBox(height: Spacing.md),
          AppText(
            text: AppString.noUsersFound,
            fontSize: 16.sp,
            color: AppColor.greyColor,
          ),
        ],
      ),
    );
  }

  String _formatLastSeen(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }
}
