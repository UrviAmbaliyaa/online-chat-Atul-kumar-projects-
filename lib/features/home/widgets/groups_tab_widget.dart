import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:online_chat/features/home/controller/home_controller.dart';
import 'package:online_chat/features/home/models/group_chat_model.dart';
import 'package:online_chat/features/home/widgets/exit_group_confirmation_dialog.dart';
import 'package:online_chat/features/home/widgets/group_details_dialog.dart';
import 'package:online_chat/services/firebase_service.dart';
import 'package:online_chat/utils/app_color.dart';
import 'package:online_chat/utils/app_snackbar.dart';
import 'package:online_chat/utils/app_spacing.dart';
import 'package:online_chat/utils/app_string.dart';
import 'package:online_chat/utils/app_text.dart';

class GroupsTabWidget extends StatelessWidget {
  final HomeController controller;

  const GroupsTabWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => controller.createdGroups.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: EdgeInsets.all(Spacing.md),
              itemCount: controller.createdGroups.length,
              itemBuilder: (context, index) {
                final group = controller.createdGroups[index];
                return _buildGroupItem(group, context);
              },
            ),
    );
  }

  Widget _buildGroupItem(GroupChatModel group, context) {
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
        leading: CircleAvatar(
          radius: 28.r,
          backgroundColor: AppColor.secondaryColor,
          backgroundImage:
              group.groupImage != null && group.groupImage!.startsWith('http')
                  ? NetworkImage(group.groupImage!)
                  : null,
          child:
              group.groupImage == null || !group.groupImage!.startsWith('http')
                  ? Icon(
                      Icons.group,
                      size: 28.sp,
                      color: AppColor.whiteColor,
                    )
                  : null,
        ),
        title: AppText(
          text: group.name,
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: AppColor.darkGrey,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (group.description != null) ...[
              SizedBox(height: 4.h),
              AppText(
                text: group.description!,
                fontSize: 14.sp,
                color: AppColor.greyColor,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            SizedBox(height: 4.h),
            Row(
              children: [
                Icon(
                  Icons.people_outline,
                  size: 14.sp,
                  color: AppColor.greyColor,
                ),
                SizedBox(width: 4.w),
                AppText(
                  text: '${group.memberCount} ${AppString.members}',
                  fontSize: 12.sp,
                  color: AppColor.greyColor,
                ),
              ],
            ),
          ],
        ),
        trailing: Builder(
          builder: (BuildContext itemContext) {
            final currentUserId = FirebaseService.getCurrentUserId();
            final isAdmin =
                currentUserId != null && _isUserAdmin(group, currentUserId);

            return PopupMenuButton<String>(
              color: AppColor.whiteColor,
              shadowColor: AppColor.primaryColor,
              icon: Icon(
                Icons.more_vert,
                color: AppColor.greyColor,
                size: 20.sp,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              itemBuilder: (BuildContext context) {
                final items = <PopupMenuItem<String>>[
                  PopupMenuItem<String>(
                    value: 'members',
                    child: Row(
                      children: [
                        Icon(
                          Icons.people_outline,
                          color: AppColor.darkGrey,
                          size: 20.sp,
                        ),
                        SizedBox(width: 12.w),
                        AppText(
                          text: AppString.members,
                          fontSize: 14.sp,
                          color: AppColor.darkGrey,
                        ),
                      ],
                    ),
                  ),
                ];

                // Only show exit option for non-admin members
                if (!isAdmin) {
                  items.add(
                    PopupMenuItem<String>(
                      value: 'exit',
                      child: Row(
                        children: [
                          Icon(
                            Icons.exit_to_app,
                            color: AppColor.lightRedColor,
                            size: 20.sp,
                          ),
                          SizedBox(width: 12.w),
                          AppText(
                            text: AppString.exitFromGroup,
                            fontSize: 14.sp,
                            color: AppColor.lightRedColor,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return items;
              },
              onSelected: (String value) {
                if (value == 'exit') {
                  _showExitGroupConfirmation(itemContext, group);
                } else if (value == 'members') {
                  _showGroupMembers(itemContext, group);
                }
              },
            );
          },
        ),
        onTap: () {
          // TODO: Navigate to group chat screen
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_outlined,
            size: 64.sp,
            color: AppColor.greyColor.withOpacity(0.5),
          ),
          SizedBox(height: Spacing.md),
          AppText(
            text: AppString.noGroupsFound,
            fontSize: 16.sp,
            color: AppColor.greyColor,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('MMM d, yyyy').format(dateTime);
  }

  bool _isUserAdmin(GroupChatModel group, String userId) {
    // Check if user is the creator (admin)
    return group.createdBy == userId;
  }

  void _showExitGroupConfirmation(BuildContext context, GroupChatModel group) {
    Get.dialog(
      ExitGroupConfirmationDialog(
        onExit: () => _exitFromGroup(group),
      ),
      barrierDismissible: true,
    );
  }

  Future<void> _exitFromGroup(GroupChatModel group) async {
    try {
      final currentUserId = FirebaseService.getCurrentUserId();
      if (currentUserId == null) {
        AppSnackbar.error(message: AppString.userNotLoggedIn);
        return;
      }

      // Check if user is the creator/admin (double check)
      if (group.createdBy == currentUserId ||
          _isUserAdmin(group, currentUserId)) {
        AppSnackbar.warning(message: AppString.adminCannotExitGroup);
        return;
      }

      final success = await FirebaseService.exitFromGroup(
        groupId: group.id,
        userId: currentUserId,
      );

      if (success) {
        AppSnackbar.success(message: AppString.groupExitedSuccessfully);
        // Refresh groups list
        await controller.refreshGroups();
      } else {
        AppSnackbar.error(message: AppString.exitGroupError);
      }
    } catch (e) {
      AppSnackbar.error(message: AppString.exitGroupError);
    }
  }

  void _showGroupMembers(BuildContext context, GroupChatModel group) {
    Get.dialog(
      GroupDetailsDialog(
        group: group,
        controller: controller,
      ),
      barrierDismissible: true,
    );
  }
}
