import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:online_chat/features/home/controller/home_controller.dart';
import 'package:online_chat/features/home/models/user_model.dart';
import 'package:online_chat/utils/app_color.dart';
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
        leading: Stack(
          children: [
            Container(
              width: 56.w,
              height: 56.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColor.primaryColor,
                    AppColor.secondaryColor,
                    AppColor.accentColor,
                  ],
                ),
              ),
              child: ClipOval(
                child: user.profileImage != null &&
                        user.profileImage!.startsWith('http')
                    ? CachedNetworkImage(
                        imageUrl: user.profileImage!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColor.primaryColor,
                                AppColor.secondaryColor,
                                AppColor.accentColor,
                              ],
                            ),
                          ),
                          child: Center(
                            child: AppText(
                              text: user.name.isNotEmpty
                                  ? user.name[0].toUpperCase()
                                  : 'U',
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColor.whiteColor,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColor.primaryColor,
                                AppColor.secondaryColor,
                                AppColor.accentColor,
                              ],
                            ),
                          ),
                          child: Center(
                            child: AppText(
                              text: user.name.isNotEmpty
                                  ? user.name[0].toUpperCase()
                                  : 'U',
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColor.whiteColor,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColor.primaryColor,
                              AppColor.secondaryColor,
                              AppColor.accentColor,
                            ],
                          ),
                        ),
                        child: Center(
                          child: AppText(
                            text: user.name.isNotEmpty
                                ? user.name[0].toUpperCase()
                                : 'U',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColor.whiteColor,
                          ),
                        ),
                      ),
              ),
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
        title: AppText(
          text: user.name,
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: AppColor.darkGrey,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4.h),
            AppText(
              text: user.email,
              fontSize: 14.sp,
              color: AppColor.greyColor,
            ),
            SizedBox(height: 4.h),
            AppText(
              text: user.isOnline
                  ? AppString.online
                  : user.lastSeen != null
                      ? '${AppString.lastSeen} ${_formatLastSeen(user.lastSeen!)}'
                      : AppString.offline,
              fontSize: 12.sp,
              color: user.isOnline ? AppColor.accentColor : AppColor.greyColor,
            ),
          ],
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
}
