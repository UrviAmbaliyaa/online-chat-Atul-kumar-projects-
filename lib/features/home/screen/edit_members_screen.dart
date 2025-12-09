import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:online_chat/features/home/controller/edit_members_controller.dart';
import 'package:online_chat/features/home/controller/home_controller.dart';
import 'package:online_chat/features/home/models/group_chat_model.dart';
import 'package:online_chat/features/home/models/user_model.dart';
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
      appBar: _buildAppBar(),
      body: Obx(
        () => controller.isLoading.value
            ? _buildShimmerLoader()
            : SingleChildScrollView(
                padding: EdgeInsets.all(Spacing.md),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      _buildHeaderSection(),
                      SizedBox(height: Spacing.md),
                      // Group Name Input
                      _buildGroupNameSection(controller),
                      SizedBox(height: Spacing.md),
                      // Members Selection Section
                      _buildMembersSection(controller),
                      SizedBox(height: Spacing.md),
                      // Update Group Button
                      _buildUpdateGroupButton(controller),
                      SizedBox(height: Spacing.lg),
                      // Delete Group Button (Admin only)
                      Obx(
                        () => controller.isCurrentUserAdmin.value
                            ? _buildDeleteGroupButton(controller)
                            : const SizedBox.shrink(),
                      ),
                      SizedBox(height: Spacing.md),
                    ],
                  ),
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
      leading: SizedBox.shrink(),
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
              gradient: LinearGradient(
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
            blurRadius: 15,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: AppString.groupName,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColor.darkGrey,
          ),
          SizedBox(height: Spacing.sm),
          AppTextField(
            controller: controller.groupNameController,
            hintText: AppString.groupNameHint,
            prefixIcon: Icon(
              Icons.group_outlined,
              color: AppColor.primaryColor,
              size: 20.sp,
            ),
            validator: controller.validateGroupName,
            focusNode: controller.groupNameFocusNode,
            textStyle: TextStyle(
              fontSize: 15.sp,
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
              blurRadius: 15,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(
                  text: AppString.selectMembers,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColor.darkGrey,
                ),
                if (controller.selectedMemberIds.isNotEmpty)
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
                      text:
                          '${controller.selectedMemberIds.length} ${AppString.selected}',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColor.primaryColor,
                    ),
                  ),
              ],
            ),
            SizedBox(height: Spacing.md),
            if (controller.availableContacts.isEmpty)
              _buildEmptyContactsState()
            else
              _buildContactsList(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyContactsState() {
    return Container(
      padding: EdgeInsets.all(Spacing.xl),
      child: Column(
        children: [
          Icon(
            Icons.person_outline,
            size: 48.sp,
            color: AppColor.greyColor.withOpacity(0.5),
          ),
          SizedBox(height: Spacing.md),
          AppText(
            text: AppString.noContactsToAdd,
            fontSize: 14.sp,
            color: AppColor.greyColor,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContactsList(EditMembersController controller) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.availableContacts.length,
      separatorBuilder: (context, index) => SizedBox(height: Spacing.sm),
      itemBuilder: (context, index) {
        final contact = controller.availableContacts[index];
        final isSelected = controller.isMemberSelected(contact.id);

        return _buildContactItem(controller, contact, isSelected);
      },
    );
  }

  Widget _buildContactItem(
    EditMembersController controller,
    UserModel contact,
    bool isSelected,
  ) {
    return InkWell(
      onTap: () => controller.toggleMemberSelection(contact.id),
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.all(Spacing.sm),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColor.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected
                ? AppColor.primaryColor
                : AppColor.lightGrey.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Checkbox
            Container(
              width: 24.w,
              height: 24.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColor.primaryColor : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppColor.primaryColor
                      : AppColor.greyColor.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      color: AppColor.whiteColor,
                      size: 16.sp,
                    )
                  : null,
            ),
            SizedBox(width: Spacing.md),
            // Profile Picture
            _buildContactAvatar(contact),
            SizedBox(width: Spacing.md),
            // Contact Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: contact.name,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColor.darkGrey,
                  ),
                  SizedBox(height: 2.h),
                  AppText(
                    text: contact.email,
                    fontSize: 13.sp,
                    color: AppColor.greyColor,
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
      width: 48.w,
      height: 48.h,
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
      child: contact.profileImage != null &&
              contact.profileImage!.startsWith('http')
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
                      text: contact.name.isNotEmpty
                          ? contact.name[0].toUpperCase()
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
                      text: contact.name.isNotEmpty
                          ? contact.name[0].toUpperCase()
                          : 'U',
                      fontSize: 18.sp,
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
                  text: contact.name.isNotEmpty
                      ? contact.name[0].toUpperCase()
                      : 'U',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColor.whiteColor,
                ),
              ),
            ),
    );
  }

  Widget _buildUpdateGroupButton(EditMembersController controller) {
    return Obx(
      () => CustomButton(
        text: AppString.updateGroup,
        onPressed: controller.isUpdating.value
            ? () {}
            : () => controller.updateGroup(),
        isLoading: controller.isUpdating.value,
        backgroundColor: AppColor.primaryColor,
        borderRadius: 8,
        height: 44.h,
      ),
    );
  }

  Widget _buildDeleteGroupButton(EditMembersController controller) {
    return Obx(
      () => CustomButton(
        text: AppString.deleteGroup,
        onPressed:
            controller.isDeletingGroup.value || controller.isUpdating.value
                ? () {}
                : controller.showDeleteGroupConfirmation,
        isLoading: controller.isDeletingGroup.value,
        backgroundColor: AppColor.lightRedColor,
        borderRadius: 8,
        height: 44.h,
        prefixIcon: Icon(
          Icons.delete_outline,
          color: AppColor.whiteColor,
          size: 20.sp,
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
            child: Container(
              width: double.infinity,
              height: 200.h,
              decoration: BoxDecoration(
                color: AppColor.lightGrey,
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            isLoading: true,
          ),
          SizedBox(height: Spacing.xl),
          // Group Name Shimmer
          ShimmerSkeleton(
            child: Container(
              width: double.infinity,
              height: 100.h,
              decoration: BoxDecoration(
                color: AppColor.lightGrey,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            isLoading: true,
          ),
          SizedBox(height: Spacing.xl),
          // Members Shimmer
          ShimmerSkeleton(
            child: Container(
              width: double.infinity,
              height: 300.h,
              decoration: BoxDecoration(
                color: AppColor.lightGrey,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            isLoading: true,
          ),
          SizedBox(height: Spacing.xl),
          // Button Shimmer
          ShimmerSkeleton(
            child: Container(
              width: double.infinity,
              height: 44.h,
              decoration: BoxDecoration(
                color: AppColor.lightGrey,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            isLoading: true,
          ),
        ],
      ),
    );
  }
}
