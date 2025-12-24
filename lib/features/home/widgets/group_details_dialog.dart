import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:online_chat/features/home/controller/home_controller.dart';
import 'package:online_chat/features/home/models/group_chat_model.dart';
import 'package:online_chat/features/home/models/user_model.dart';
import 'package:online_chat/navigations/app_navigation.dart';
import 'package:online_chat/navigations/routes.dart';
import 'package:online_chat/services/firebase_service.dart';
import 'package:online_chat/utils/app_button.dart';
import 'package:online_chat/utils/app_color.dart';
import 'package:online_chat/utils/app_snackbar.dart';
import 'package:online_chat/utils/app_spacing.dart';
import 'package:online_chat/utils/app_string.dart';
import 'package:online_chat/utils/app_text.dart';
import 'package:online_chat/utils/app_textfield.dart';

class GroupDetailsDialog extends StatefulWidget {
  final GroupChatModel group;
  final HomeController controller;

  const GroupDetailsDialog({
    super.key,
    required this.group,
    required this.controller,
  });

  @override
  State<GroupDetailsDialog> createState() => _GroupDetailsDialogState();
}

class _GroupDetailsDialogState extends State<GroupDetailsDialog> {
  late TextEditingController groupNameController;
  late FocusNode groupNameFocusNode;
  final RxBool isUpdating = false.obs;
  final RxBool isLoading = false.obs;
  final RxList<Map<String, dynamic>> members = <Map<String, dynamic>>[].obs;
  final RxBool isCurrentUserAdmin = false.obs;

  @override
  void initState() {
    super.initState();
    groupNameController = TextEditingController(text: widget.group.name);
    groupNameFocusNode = FocusNode();
    _loadGroupMembers();
    _checkAdminStatus();
  }

  @override
  void dispose() {
    groupNameController.dispose();
    groupNameFocusNode.dispose();
    super.dispose();
  }

  Future<void> _checkAdminStatus() async {
    try {
      final currentUserId = FirebaseService.getCurrentUserId();
      if (currentUserId == null) return;

      final groupDoc = await FirebaseFirestore.instance.collection('group').doc(widget.group.id).get();

      if (groupDoc.exists) {
        final admins = List<String>.from(groupDoc.data()?['admins'] ?? []);
        isCurrentUserAdmin.value = admins.contains(currentUserId);
      }
    } catch (e) {
      // Error checking admin status
    }
  }

  Future<void> _loadGroupMembers() async {
    try {
      isLoading.value = true;
      final membersList = await FirebaseService.getGroupMembers(widget.group.id);
      members.value = membersList;
    } catch (e) {
      AppSnackbar.error(message: AppString.errorLoadingMembers);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _updateGroupName() async {
    if (groupNameController.text.trim().isEmpty) {
      AppSnackbar.warning(message: AppString.groupNameRequired);
      return;
    }

    if (groupNameController.text.trim() == widget.group.name) {
      return; // No change
    }

    try {
      isUpdating.value = true;
      final success = await FirebaseService.updateGroupName(
        groupId: widget.group.id,
        newName: groupNameController.text.trim(),
      );

      if (success) {
        AppSnackbar.success(message: AppString.groupNameUpdated);
        await widget.controller.refreshGroups();
        Get.back();
      } else {
        AppSnackbar.error(message: AppString.groupUpdateError);
      }
    } catch (e) {
      AppSnackbar.error(message: AppString.groupUpdateError);
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> _removeMember(String userId, String userName) async {
    try {
      final success = await FirebaseService.removeGroupMember(
        groupId: widget.group.id,
        memberId: userId,
        adminId: FirebaseService.getCurrentUserId()!,
      );

      if (success) {
        AppSnackbar.success(message: AppString.memberRemovedSuccessfully);
        await _loadGroupMembers();
        await widget.controller.refreshGroups();
      } else {
        AppSnackbar.error(message: AppString.removeMemberError);
      }
    } catch (e) {
      AppSnackbar.error(message: AppString.removeMemberError);
    }
  }

  void _showAddMemberDialog() {
    // Navigate to edit members screen
    Get.back(); // Close current dialog
    AppNavigation.toNamed(
      AppRoutes.editMembersScreen,
      arguments: widget.group,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20.r),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.only(top: Spacing.sm, left: Spacing.lg, right: Spacing.lg),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColor.lightGrey.withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    text: AppString.groupDetails,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColor.darkGrey,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: AppColor.greyColor,
                      size: 24.sp,
                    ),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: Spacing.sm, top: Spacing.sm, left: Spacing.lg, right: Spacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Group Name Section
                    _buildGroupNameSection(),
                    SizedBox(height: Spacing.sm),
                    // Members Section
                    _buildMembersSection(),
                    SizedBox(height: Spacing.sm),
                    // Call History
                    _buildCallHistorySection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupNameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: AppString.groupName,
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: AppColor.darkGrey,
        ),
        SizedBox(height: Spacing.sm),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: groupNameController,
                hintText: AppString.groupNameHint,
                focusNode: groupNameFocusNode,
                textStyle: TextStyle(
                  fontSize: 15.sp,
                  color: AppColor.darkGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(width: Spacing.sm),
            Obx(
              () => CustomButton(
                text: AppString.update,
                onPressed: isUpdating.value ? () {} : () => _updateGroupName(),
                isLoading: isUpdating.value,
                backgroundColor: AppColor.primaryColor,
                borderRadius: 8,
                height: 44.h,
                width: 100.w,
                enableAnimation: false,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCallHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: AppString.callHistory,
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
          color: AppColor.darkGrey,
        ),
        SizedBox(height: Spacing.xs),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseService.streamGroupCallHistory(
            groupId: widget.group.id,
            limit: 25,
          ),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(color: AppColor.primaryColor),
                ),
              );
            }
            final docs = snapshot.data!.docs;
            if (docs.isEmpty) {
              return Padding(
                padding: EdgeInsets.all(Spacing.md),
                child: AppText(
                  text: AppString.noCallHistory,
                  fontSize: 12.sp,
                  color: AppColor.greyColor,
                ),
              );
            }
            return Container(
              decoration: BoxDecoration(
                color: AppColor.whiteColor,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColor.lightGrey.withOpacity(0.5), width: 1),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColor.lightGrey.withOpacity(0.3),
                ),
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final isVideo = (data['type'] ?? 'audio') == 'video';
                  final missed = (data['missed'] ?? false) as bool;
                  DateTime dt;
                  final startedAt = data['startedAt'];
                  if (startedAt is Timestamp) {
                    dt = startedAt.toDate();
                  } else if (startedAt is String) {
                    dt = DateTime.tryParse(startedAt) ?? DateTime.now();
                  } else {
                    dt = DateTime.now();
                  }
                  final durationSec = data['durationSec'] as int?;
                  final duration = durationSec != null ? _formatTimeLength(Duration(seconds: durationSec)) : null;
                  final iconColor = missed ? AppColor.lightRedColor : AppColor.primaryColor;
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.xs),
                    leading: Container(
                      width: 32.w,
                      height: 32.h,
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        isVideo ? Icons.videocam_rounded : Icons.call_rounded,
                        color: iconColor,
                        size: 16.sp,
                      ),
                    ),
                    title: AppText(
                      text: isVideo ? 'Group video call' : 'Group call',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColor.darkGrey,
                    ),
                    subtitle: AppText(
                      text: '${_formatTime(dt)}${duration != null ? ' • $duration' : ''}',
                      fontSize: 11.sp,
                      color: AppColor.greyColor,
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final timeString = '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
    if (dateOnly == today) {
      return 'today at $timeString';
    } else if (dateOnly == today.subtract(const Duration(days: 1))) {
      return 'yesterday at $timeString';
    } else {
      final dateString = DateFormat('MMM d').format(dateTime);
      return '$dateString at $timeString';
    }
  }

  String _formatTimeLength(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '${minutes.toString()}:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _buildMembersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText(
              text: AppString.members,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColor.darkGrey,
            ),
            Obx(
              () => isCurrentUserAdmin.value
                  ? TextButton.icon(
                      onPressed: _showAddMemberDialog,
                      icon: Icon(
                        Icons.person_add,
                        color: AppColor.primaryColor,
                        size: 18.sp,
                      ),
                      label: AppText(
                        text: AppString.addMember,
                        fontSize: 14.sp,
                        color: AppColor.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
        SizedBox(height: Spacing.sm),
        Obx(
          () => isLoading.value
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(Spacing.xl),
                    child: const CircularProgressIndicator(
                      color: AppColor.primaryColor,
                    ),
                  ),
                )
              : members.isEmpty
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(Spacing.xl),
                        child: AppText(
                          text: AppString.noMembersFound,
                          fontSize: 14.sp,
                          color: AppColor.greyColor,
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: members.length,
                      separatorBuilder: (context, index) => SizedBox(height: Spacing.sm),
                      itemBuilder: (context, index) {
                        final member = members[index];
                        final user = member['user'] as UserModel;
                        final isAdmin = member['isAdmin'] as bool;
                        final currentUserId = FirebaseService.getCurrentUserId();

                        return _buildMemberItem(user, isAdmin, currentUserId);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildMemberItem(UserModel user, bool isAdmin, String? currentUserId) {
    final isCurrentUser = user.id == currentUserId;
    final canDelete = isCurrentUserAdmin.value && !isCurrentUser && !isAdmin;

    return Container(
      padding: EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: AppColor.lightGrey.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Profile Avatar
          Container(
            width: 48.w,
            height: 48.h,
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
            child: user.profileImage != null && user.profileImage!.startsWith('http')
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: user.profileImage!,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => _buildAvatarPlaceholder(user.name),
                    ),
                  )
                : _buildAvatarPlaceholder(user.name),
          ),
          SizedBox(width: Spacing.md),
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: AppText(
                        text: user.name,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColor.darkGrey,
                      ),
                    ),
                    if (isAdmin)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: AppText(
                          text: AppString.admin,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColor.primaryColor,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 2.h),
                AppText(
                  text: user.email,
                  fontSize: 13.sp,
                  color: AppColor.greyColor,
                ),
              ],
            ),
          ),
          // Delete Button (Admin only, not for self or other admins)
          if (canDelete)
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: AppColor.lightRedColor,
                size: 20.sp,
              ),
              onPressed: () => _showRemoveMemberConfirmation(user.id, user.name),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatarPlaceholder(String name) {
    return Center(
      child: AppText(
        text: name.isNotEmpty ? name[0].toUpperCase() : 'U',
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: AppColor.whiteColor,
      ),
    );
  }

  void _showRemoveMemberConfirmation(String userId, String userName) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          title: AppText(
            text: AppString.removeMember,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColor.darkGrey,
          ),
          content: AppText(
            text: AppString.removeMemberConfirmation.replaceAll('{name}', userName),
            fontSize: 14.sp,
            color: AppColor.greyColor,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: AppText(
                text: AppString.cancel,
                fontSize: 14.sp,
                color: AppColor.greyColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _removeMember(userId, userName);
              },
              child: AppText(
                text: AppString.remove,
                fontSize: 14.sp,
                color: AppColor.lightRedColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      },
    );
  }
}
