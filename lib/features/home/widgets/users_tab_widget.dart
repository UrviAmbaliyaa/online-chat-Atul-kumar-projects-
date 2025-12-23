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
import 'package:online_chat/services/firebase_service.dart';
import 'package:online_chat/utils/firebase_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      margin: EdgeInsets.only(bottom: Spacing.xs),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: AppColor.lightGrey.withOpacity(0.25),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        dense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: Spacing.sm,
          vertical: Spacing.xs,
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
        leading: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseService.streamDocument(
            collection: FirebaseConstants.userCollection,
            docId: user.id,
          ),
          builder: (context, snapshot) {
            final data = snapshot.data?.data() as Map<String, dynamic>?;
            final isOnlineLive = data?['isOnline'] as bool?;
            final isOnline = isOnlineLive ?? user.isOnline;
            return Stack(
              children: [
                AppProfileImage(
                  width: 44.w,
                  height: 44.h,
                  username: user.name,
                  imageUrl: user.profileImage,
                  fontSize: 16.sp,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12.w,
                    height: 12.h,
                    decoration: BoxDecoration(
                      color:
                          isOnline ? AppColor.accentColor : AppColor.greyColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColor.whiteColor,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        title: Row(
          children: [
            Expanded(
              child: AppText(
                text: user.name,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.darkGrey,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Obx(() {
              final unreadCount = controller.getUnreadCountForUser(user.id);
              if (unreadCount > 0) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: AppText(
                    text: unreadCount > 99 ? '99+' : unreadCount.toString(),
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
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
              padding: EdgeInsets.only(top: 2.h),
              child: AppText(
                text: lastMessage.length > 42
                    ? '${lastMessage.substring(0, 42)}...'
                    : lastMessage,
                fontSize: 12.sp,
                color: AppColor.greyColor,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }
          return Padding(
            padding: EdgeInsets.only(top: 2.h),
            child: AppText(
              text: AppString.noMessagesYet,
              fontSize: 12.sp,
              color: AppColor.greyColor.withOpacity(0.6),
            ),
          );
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
