import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:online_chat/features/home/controller/edit_members_controller.dart';
import 'package:online_chat/features/home/controller/home_controller.dart';
import 'package:online_chat/features/home/models/group_chat_model.dart';
import 'package:online_chat/features/home/models/user_model.dart';
import 'package:online_chat/services/firebase_service.dart';
import 'package:online_chat/utils/app_button.dart';
import 'package:online_chat/utils/app_color.dart';
import 'package:online_chat/utils/app_spacing.dart';
import 'package:online_chat/utils/app_string.dart';
import 'package:online_chat/utils/app_text.dart';
import 'package:online_chat/utils/app_textfield.dart';
import 'package:shimmer_skeleton/shimmer_skeleton.dart';

class EditMembersScreen extends StatelessWidget {
  final GroupChatModel group;

  const EditMembersScreen({
    super.key,
    required this.group,
  });

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    final controller = Get.put(EditMembersController(
      group: group,
      homeController: homeController,
    ));

    return Scaffold(
      backgroundColor: AppColor.ScaffoldColor,
      resizeToAvoidBottomInset: true,
      appBar: _buildAppBar(),
      body: Obx(
        () => controller.isLoading.value
            ? _buildShimmerLoader()
            : Form(
                key: controller.formKey,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(
                          left: Spacing.md,
                          right: Spacing.md,
                          top: Spacing.md,
                          bottom: Spacing.md,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Group Name Input
                            _buildGroupNameSection(controller),
                            SizedBox(height: Spacing.sm),
                            // Members Selection Section
                            _buildMembersSection(controller),
                            SizedBox(height: Spacing.sm),
                            // Call History Section
                            _buildCallHistorySection(controller),
                            // Extra bottom padding to prevent content from being hidden
                            SizedBox(height: Spacing.lg),
                          ],
                        ),
                      ),
                    ),
                    // Buttons Section - Hide when keyboard is open
                    KeyboardVisibilityBuilder(
                      builder: (context, isKeyboardVisible) {
                        if (isKeyboardVisible) {
                          return const SizedBox.shrink();
                        }
                        return SafeArea(
                          top: false,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: Spacing.md,
                              vertical: Spacing.sm,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.whiteColor,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColor.greyColor.withOpacity(0.1),
                                  blurRadius: 4,
                                  spreadRadius: 0,
                                  offset: const Offset(0, -2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Update Group Button
                                _buildUpdateGroupButton(controller),
                                SizedBox(height: Spacing.xs),
                                // Delete Group Button (Admin only)
                                Obx(
                                  () => controller.isCurrentUserAdmin.value ? _buildDeleteGroupButton(controller) : const SizedBox.shrink(),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColor.whiteColor,
      elevation: 0,
      leadingWidth: 0.sp,
      leading: const SizedBox.shrink(),
      title: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: AppColor.darkGrey,
              size: 20.sp,
            ),
            onPressed: () => Get.back(),
          ),
          AppText(
            text: AppString.editMembers,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppColor.darkGrey,
          ),
        ],
      ),
      centerTitle: false,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1.h),
        child: Container(
          color: AppColor.lightGrey.withOpacity(0.5),
          height: 1.h,
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryColor.withOpacity(0.08),
            blurRadius: 15,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80.w,
            height: 80.h,
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
              boxShadow: [
                BoxShadow(
                  color: AppColor.primaryColor.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.group_rounded,
              color: AppColor.whiteColor,
              size: 40.sp,
            ),
          ),
          SizedBox(height: Spacing.md),
          AppText(
            text: AppString.editGroupMembers,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColor.darkGrey,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: Spacing.sm),
          AppText(
            text: AppString.editGroupMembersSubtitle,
            fontSize: 14.sp,
            color: AppColor.greyColor,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGroupNameSection(EditMembersController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryColor.withOpacity(0.08),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: AppString.groupName,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: AppColor.darkGrey,
          ),
          SizedBox(height: Spacing.xs),
          AppTextField(
            controller: controller.groupNameController,
            hintText: AppString.groupNameHint,
            prefixIcon: Icon(
              Icons.group_outlined,
              color: AppColor.primaryColor,
              size: 18.sp,
            ),
            validator: controller.validateGroupName,
            focusNode: controller.groupNameFocusNode,
            textStyle: TextStyle(
              fontSize: 14.sp,
              color: AppColor.darkGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersSection(EditMembersController controller) {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: AppColor.primaryColor.withOpacity(0.08),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(Spacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    text: 'Group Members (${controller.groupMembers.length})',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColor.darkGrey,
                  ),
                  if (controller.isCurrentUserAdmin.value && controller.selectedMemberIds.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: AppText(
                        text: '${controller.selectedMemberIds.length} ${AppString.selected}',
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColor.primaryColor,
                      ),
                    ),
                ],
              ),
            ),
            // Search field (only for admins who can add members)
            if (controller.isCurrentUserAdmin.value)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Spacing.md),
                child: AppTextField(
                  controller: controller.searchController,
                  hintText: 'Search members...',
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColor.primaryColor,
                    size: 18.sp,
                  ),
                  textStyle: TextStyle(
                    fontSize: 13.sp,
                    color: AppColor.darkGrey,
                  ),
                ),
              ),
            SizedBox(height: Spacing.sm),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 300.h,
              ),
              child: Obx(() {
                // Show group members list (all members can see this)
                if (controller.groupMembers.isEmpty) {
                  return _buildEmptyContactsState();
                }
                return _buildGroupMembersList(controller);
              }),
            ),
            // For admins: show contacts section to add new members
            if (controller.isCurrentUserAdmin.value) ...[
              SizedBox(height: Spacing.md),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Spacing.md),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColor.lightGrey.withOpacity(0.5),
                ),
              ),
              SizedBox(height: Spacing.sm),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Spacing.md),
                child: AppText(
                  text: 'Add New Members',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColor.darkGrey,
                ),
              ),
              SizedBox(height: Spacing.sm),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 300.h,
                ),
                child: controller.filteredContacts.isEmpty ? _buildEmptyContactsState() : _buildContactsList(controller),
              ),
            ],
            SizedBox(height: Spacing.sm),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyContactsState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.person_outline,
            size: 40.sp,
            color: AppColor.greyColor.withOpacity(0.5),
          ),
          SizedBox(height: Spacing.sm),
          AppText(
            text: AppString.noContactsToAdd,
            fontSize: 12.sp,
            color: AppColor.greyColor,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGroupMembersList(EditMembersController controller) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: Spacing.md),
      itemCount: controller.groupMembers.length,
      separatorBuilder: (context, index) => SizedBox(height: Spacing.xs),
      itemBuilder: (context, index) {
        final member = controller.groupMembers[index];
        final isAdmin = controller.memberAdminStatus[member.id] ?? false;
        final currentUserId = FirebaseService.getCurrentUserId();
        final isCurrentUser = member.id == currentUserId;
        // Admins cannot be selected for removal, and current user cannot select themselves
        final canSelect = controller.isCurrentUserAdmin.value && !isAdmin && !isCurrentUser;
        final isSelected = canSelect && controller.isMemberSelected(member.id);

        return _buildGroupMemberItem(controller, member, isAdmin, isSelected, isCurrentUser);
      },
    );
  }

  Widget _buildContactsList(EditMembersController controller) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: Spacing.md),
      itemCount: controller.filteredContacts.length,
      separatorBuilder: (context, index) => SizedBox(height: Spacing.xs),
      itemBuilder: (context, index) {
        final contact = controller.filteredContacts[index];
        // Don't show contacts that are already group members
        final isAlreadyMember = controller.groupMembers.any((m) => m.id == contact.id);
        if (isAlreadyMember) {
          return const SizedBox.shrink();
        }
        final isSelected = controller.isMemberSelected(contact.id) && controller.isCurrentUserAdmin.value;

        return _buildContactItem(controller, contact, isSelected, isAdmin: false);
      },
    );
  }

  Widget _buildGroupMemberItem(
    EditMembersController controller,
    UserModel member,
    bool isAdmin,
    bool isSelected,
    bool isCurrentUser,
  ) {
    // Admins and current user cannot be selected
    final canSelect = controller.isCurrentUserAdmin.value && !isAdmin && !isCurrentUser;

    return InkWell(
        onTap: canSelect ? () => controller.toggleMemberSelection(member.id) : null,
        borderRadius: BorderRadius.circular(6.r),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.sm,
            vertical: Spacing.xs,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColor.primaryColor.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(6.r),
            border: Border.all(
              color: isSelected ? AppColor.primaryColor : AppColor.lightGrey.withOpacity(0.5),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              // Checkbox (only for non-admin, non-current-user members when current user is admin)
              if (canSelect) ...[
                Container(
                  width: 20.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColor.primaryColor : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? AppColor.primaryColor : AppColor.greyColor.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          color: AppColor.whiteColor,
                          size: 14.sp,
                        )
                      : null,
                ),
                SizedBox(width: Spacing.sm),
              ],

              // Profile Picture
              _buildContactAvatar(member),
              SizedBox(width: Spacing.sm),
              // Contact Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AppText(
                            text: isCurrentUser ? '${member.name} (You)' : member.name,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColor.darkGrey,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isAdmin)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.primaryColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: AppText(
                              text: 'Admin',
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColor.primaryColor,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    AppText(
                      text: member.email,
                      fontSize: 11.sp,
                      color: AppColor.greyColor,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildContactItem(
    EditMembersController controller,
    UserModel contact,
    bool isSelected, {
    bool isAdmin = false,
  }) {
    return InkWell(
      onTap: () => controller.toggleMemberSelection(contact.id),
      borderRadius: BorderRadius.circular(6.r),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Spacing.sm,
          vertical: Spacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(
            color: isSelected ? AppColor.primaryColor : AppColor.lightGrey.withOpacity(0.5),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Checkbox
            if (controller.isCurrentUserAdmin.value) ...[
              Container(
                width: 20.w,
                height: 20.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppColor.primaryColor : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? AppColor.primaryColor : AppColor.greyColor.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        color: AppColor.whiteColor,
                        size: 14.sp,
                      )
                    : null,
              ),
              SizedBox(width: Spacing.sm),
            ],

            // Profile Picture
            _buildContactAvatar(contact),
            SizedBox(width: Spacing.sm),
            // Contact Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppText(
                          text: contact.name,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColor.darkGrey,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isAdmin)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.primaryColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: AppText(
                            text: 'Admin',
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColor.primaryColor,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  AppText(
                    text: contact.email,
                    fontSize: 11.sp,
                    color: AppColor.greyColor,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactAvatar(UserModel contact) {
    return Container(
      width: 36.w,
      height: 36.h,
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
      child: contact.profileImage != null && contact.profileImage!.startsWith('http')
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: contact.profileImage!,
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
                      text: contact.name.isNotEmpty ? contact.name[0].toUpperCase() : 'U',
                      fontSize: 14.sp,
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
                      text: contact.name.isNotEmpty ? contact.name[0].toUpperCase() : 'U',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColor.whiteColor,
                    ),
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
                  text: contact.name.isNotEmpty ? contact.name[0].toUpperCase() : 'U',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColor.whiteColor,
                ),
              ),
            ),
    );
  }

  Widget _buildCallHistorySection(EditMembersController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryColor.withOpacity(0.08),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(
                  text: AppString.callHistory,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColor.darkGrey,
                ),
                Obx(() => controller.isCurrentUserAdmin.value
                    ? TextButton(
                        onPressed: () async {
                          final ok = await FirebaseService.clearGroupCallHistory(
                            groupId: group.id,
                          );
                          if (!ok) {
                            // silently ignore; snackbars are global
                          }
                        },
                        child: AppText(
                          text: 'Clear',
                          fontSize: 12.sp,
                          color: AppColor.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : const SizedBox.shrink()),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: AppColor.lightGrey.withOpacity(0.5),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseService.streamGroupCallHistory(
              groupId: group.id,
              limit: 25,
            ),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Padding(
                  padding: EdgeInsets.all(Spacing.sm),
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColor.primaryColor),
                  ),
                );
              }
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) {
                return _buildEmptyCallList();
              }
              return ListView.separated(
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
                      width: 28.w,
                      height: 28.h,
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
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColor.darkGrey,
                    ),
                    subtitle: AppText(
                      text: '${_formatTime(dt)}${duration != null ? ' • $duration' : ''}',
                      fontSize: 11.sp,
                      color: AppColor.greyColor,
                    ),
                    trailing: Obx(
                      () => controller.isCurrentUserAdmin.value
                          ? IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                size: 18.sp,
                                color: AppColor.lightRedColor,
                              ),
                              onPressed: () async {
                                await FirebaseService.deleteGroupCallHistoryEntry(
                                  groupId: group.id,
                                  entryId: docs[index].id,
                                );
                              },
                            )
                          : const SizedBox.shrink(),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCallList() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.call_outlined,
            size: 20.sp,
            color: AppColor.greyColor.withOpacity(0.5),
          ),
          SizedBox(width: Spacing.xs),
          AppText(
            text: AppString.noCallHistory,
            fontSize: 11.sp,
            color: AppColor.greyColor,
          ),
        ],
      ),
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

  Widget _buildUpdateGroupButton(EditMembersController controller) {
    return Obx(
      () => CustomButton(
        text: AppString.updateGroup,
        onPressed: controller.isUpdating.value ? () {} : () => controller.updateGroup(),
        isLoading: controller.isUpdating.value,
        backgroundColor: AppColor.primaryColor,
        borderRadius: 8,
        height: 38.h,
      ),
    );
  }

  Widget _buildDeleteGroupButton(EditMembersController controller) {
    return Obx(
      () => CustomButton(
        text: AppString.deleteGroup,
        onPressed: controller.isDeletingGroup.value || controller.isUpdating.value ? () {} : controller.showDeleteGroupConfirmation,
        isLoading: controller.isDeletingGroup.value,
        backgroundColor: AppColor.lightRedColor,
        borderRadius: 8,
        height: 38.h,
        prefixIcon: Icon(
          Icons.delete_outline,
          color: AppColor.whiteColor,
          size: 18.sp,
        ),
        enableAnimation: false,
      ),
    );
  }

  Widget _buildShimmerLoader() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: Spacing.lg),
          // Header Shimmer
          ShimmerSkeleton(
            isLoading: true,
            child: Container(
              width: double.infinity,
              height: 200.h,
              decoration: BoxDecoration(
                color: AppColor.lightGrey,
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
          SizedBox(height: Spacing.xl),
          // Group Name Shimmer
          ShimmerSkeleton(
            isLoading: true,
            child: Container(
              width: double.infinity,
              height: 100.h,
              decoration: BoxDecoration(
                color: AppColor.lightGrey,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
          SizedBox(height: Spacing.xl),
          // Members Shimmer
          ShimmerSkeleton(
            isLoading: true,
            child: Container(
              width: double.infinity,
              height: 300.h,
              decoration: BoxDecoration(
                color: AppColor.lightGrey,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
          SizedBox(height: Spacing.xl),
          // Button Shimmer
          ShimmerSkeleton(
            isLoading: true,
            child: Container(
              width: double.infinity,
              height: 44.h,
              decoration: BoxDecoration(
                color: AppColor.lightGrey,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
