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

class UsersTabWidget extends StatefulWidget {
  final HomeController controller;

  const UsersTabWidget({
    super.key,
    required this.controller,
  });

  @override
  State<UsersTabWidget> createState() => _UsersTabWidgetState();
}

class _UsersTabWidgetState extends State<UsersTabWidget> {
  static const int _pageSize = 20;
  final ScrollController _scrollController = ScrollController();
  int _visibleCount = _pageSize;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    final offset = _scrollController.offset;
    if (offset >= max - 200) {
      setState(() {
        _visibleCount += _pageSize;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final query = widget.controller.searchQuery.value.trim().toLowerCase();
        final list = query.isEmpty
            ? widget.controller.addedUsers
            : widget.controller.addedUsers.where((u) => u.name.toLowerCase().contains(query) || (u.email.toLowerCase().contains(query))).toList();
        final count = list.length;
        final showCount = count == 0 ? 0 : (_visibleCount.clamp(0, count));
        return count == 0
            ? _buildEmptyState()
            : ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(Spacing.md),
                itemCount: showCount + (showCount < count ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= showCount) {
                    return _buildLoadMoreIndicator();
                  }
                  final user = list[index];
                  return _buildUserItem(user);
                },
              );
      },
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
                      color: isOnline ? AppColor.accentColor : AppColor.greyColor,
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
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
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
              final unreadCount = widget.controller.getUnreadCountForUser(user.id);
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
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(() {
              final chatInfo = widget.controller.getChatInfoForUser(user.id);
              final lastMessage = chatInfo?.lastMessage ?? widget.controller.getLastMessageForUser(user.id);
              if (lastMessage != null && lastMessage.isNotEmpty) {
                return Padding(
                  padding: EdgeInsets.only(top: 2.h),
                  child: AppText(
                    text: lastMessage.length > 42 ? '${lastMessage.substring(0, 42)}...' : lastMessage,
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
            Obx(() {
              final chatInfo = widget.controller.getChatInfoForUser(user.id);
              final lastTime = chatInfo?.lastMessageTime;
              if (lastTime != null) {
                return Padding(
                  padding: EdgeInsets.only(right: 6.w),
                  child: AppText(
                    text: _formatMessageTime(lastTime),
                    fontSize: 10.sp,
                    color: AppColor.greyColor,
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Spacing.sm),
      child: Center(
        child: SizedBox(
          width: 20.w,
          height: 20.h,
          child: const CircularProgressIndicator(strokeWidth: 2),
        ),
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

  String _formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (msgDate == today) {
      return DateFormat('h:mm a').format(dateTime); // e.g., 3:45 PM
    } else if (msgDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM d').format(dateTime); // e.g., Sep 12
    }
  }
}
