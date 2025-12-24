import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:online_chat/features/settings/controller/settings_controller.dart';
import 'package:online_chat/navigations/app_navigation.dart';
import 'package:online_chat/utils/app_button.dart';
import 'package:online_chat/utils/app_color.dart';
import 'package:online_chat/utils/app_preference.dart';
import 'package:online_chat/utils/app_profile_image.dart';
import 'package:online_chat/utils/app_spacing.dart';
import 'package:online_chat/utils/app_string.dart';
import 'package:online_chat/utils/app_text.dart';
import 'package:shimmer_skeleton/shimmer_skeleton.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  final controller = Get.put(SettingsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.ScaffoldColor,
      appBar: _buildAppBar(),
      body: Obx(
        () => controller.isLoading.value
            ? _buildShimmerLoader()
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: Spacing.sm,
                  vertical: Spacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Section
                    _buildProfileSection(controller),
                    SizedBox(height: Spacing.md),

                    // Account Section
                    _buildSectionTitle(AppString.account),
                    SizedBox(height: Spacing.xs),
                    _buildAccountSection(controller),
                    SizedBox(height: Spacing.md),

                    // // Notifications Section
                    // _buildSectionTitle(AppString.notifications),
                    // SizedBox(height: Spacing.sm),
                    // _buildNotificationsSection(controller),
                    // SizedBox(height: Spacing.lg),
                    //
                    // // About Section
                    // _buildSectionTitle(AppString.about),
                    // SizedBox(height: Spacing.sm),
                    // _buildAboutSection(controller),
                    // SizedBox(height: Spacing.lg),

                    // Logout Button
                    _buildLogoutButton(controller),
                    SizedBox(height: Spacing.xl),
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
      leadingWidth: 0,
      automaticallyImplyLeading: false,
      leading: const SizedBox.shrink(),
      title: Row(
        children: [
          // Profile Picture
          GestureDetector(
            onTap: () => AppNavigation.back(),
            child: SizedBox(
              width: 40.r,
              height: 40.r,
              child: Icon(Icons.arrow_back_ios, size: 18.r),
            ),
          ),

          AppText(
            text: AppString.settings,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColor.darkGrey,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1.h),
        child: Container(
          color: AppColor.lightGrey,
          height: 1.h,
        ),
      ),
    );
  }

  Widget _buildProfileSection(SettingsController controller) {
    return Obx(
      () {
        final currentUser = AppPreference.currentUser.value;
        final userName = currentUser?.name ?? controller.userName.value;
        final userEmail = currentUser?.email ?? controller.userEmail.value;
        final userPhone = currentUser?.phone ?? (controller.userPhone.value.isNotEmpty ? controller.userPhone.value : null);
        final userProfileImage =
            currentUser?.profileImage ?? (controller.userProfileImage.value.isNotEmpty ? controller.userProfileImage.value : null);

        return Container(
          decoration: BoxDecoration(
            color: AppColor.whiteColor,
            borderRadius: BorderRadius.circular(6.r),
            boxShadow: [
              BoxShadow(
                color: AppColor.primaryColor.withOpacity(0.08),
                blurRadius: 6,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.all(Spacing.sm),
          child: Row(
            children: [
              // Profile Picture
              _displaing_profile_image(userProfileImage, userName),
              SizedBox(width: Spacing.sm),
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _userName(userName),
                    SizedBox(height: 2.h),
                    _userEmail(userEmail),
                    // if (userPhone != null && userPhone.isNotEmpty) ...[
                    //   SizedBox(height: 2.h),
                    //   _contactInfo(userPhone),
                    // ],
                  ],
                ),
              ),
              // Edit Button
              // IconButton(
              //   onPressed: controller.navigateToEditProfile,
              //   icon: Icon(
              //     Icons.edit_outlined,
              //     color: AppColor.primaryColor,
              //     size: 24.sp,
              //   ),
              // ),
            ],
          ),
        );
      },
    );
  }

  AppText _contactInfo(String userPhone) {
    return AppText(
      text: userPhone,
      fontSize: 12.sp,
      color: AppColor.greyColor,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  AppText _userEmail(String userEmail) {
    return AppText(
      text: userEmail.isNotEmpty ? userEmail : 'email@example.com',
      fontSize: 12.sp,
      color: AppColor.greyColor,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  AppText _userName(String userName) {
    return AppText(
      text: userName.isNotEmpty ? userName : 'User',
      fontSize: 15.sp,
      fontWeight: FontWeight.w600,
      color: AppColor.darkGrey,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _displaing_profile_image(String? userProfileImage, String userName) {
    return AppProfileImage(
      width: 48.w,
      height: 48.h,
      username: userName,
      imageUrl: userProfileImage,
      borderWidth: 2,
      borderColor: AppColor.primaryColor,
      fontSize: 24.sp,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Spacing.xs),
      child: AppText(
        text: title,
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: AppColor.darkGrey,
      ),
    );
  }

  Widget _buildAccountSection(SettingsController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(6.r),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryColor.withOpacity(0.08),
            blurRadius: 6,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.person_outline,
            title: AppString.editProfile,
            onTap: controller.navigateToEditProfile,
          ),
          _buildDivider(),
          _buildSettingsTile(
            icon: Icons.lock_outline,
            title: AppString.changePassword,
            onTap: controller.navigateToChangePassword,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection(SettingsController controller) {
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
      child: Obx(
        () => _buildSwitchTile(
          icon: Icons.notifications_outlined,
          title: AppString.enableNotifications,
          value: controller.notificationsEnabled.value,
          onChanged: controller.toggleNotifications,
        ),
      ),
    );
  }

  Widget _buildAboutSection(SettingsController controller) {
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
      child: _buildInfoTile(
        icon: Icons.info_outline,
        title: AppString.version,
        value: AppString.appVersion,
      ),
    );
  }

  Widget _buildLogoutButton(SettingsController controller) {
    return Obx(() => CustomButton(
          text: AppString.logout,
          onPressed: controller.isLoading.value ? () {} : controller.showLogoutConfirmation,
          isLoading: controller.isLoading.value,
          backgroundColor: AppColor.lightRedColor,
          borderRadius: 8,
          height: 44.h,
          prefixIcon: Icon(
            Icons.logout,
            color: AppColor.whiteColor,
            size: 20.sp,
          ),
          enableAnimation: false,
        ));
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Color? iconColor,
    Color? titleColor,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: 2.h,
      ),
      leading: Container(
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: (iconColor ?? AppColor.primaryColor).withOpacity(0.1),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Icon(
          icon,
          color: iconColor ?? AppColor.primaryColor,
          size: 18.sp,
        ),
      ),
      title: AppText(
        text: title,
        fontSize: 13.sp,
        fontWeight: FontWeight.w500,
        color: titleColor ?? AppColor.darkGrey,
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppColor.greyColor,
        size: 18.sp,
      ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: 2.h,
      ),
      leading: Container(
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: AppColor.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Icon(
          icon,
          color: AppColor.primaryColor,
          size: 18.sp,
        ),
      ),
      title: AppText(
        text: title,
        fontSize: 13.sp,
        fontWeight: FontWeight.w500,
        color: AppColor.darkGrey,
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColor.primaryColor,
        inactiveThumbColor: AppColor.lightGrey,
        inactiveTrackColor: AppColor.lightGrey.withOpacity(0.5),
      ),
    );
  }

  Widget _buildSelectionTile({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: 2.h,
      ),
      leading: Container(
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: AppColor.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Icon(
          icon,
          color: AppColor.primaryColor,
          size: 18.sp,
        ),
      ),
      title: AppText(
        text: title,
        fontSize: 13.sp,
        fontWeight: FontWeight.w500,
        color: AppColor.darkGrey,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(
            text: value,
            fontSize: 12.sp,
            color: AppColor.greyColor,
          ),
          SizedBox(width: 4.w),
          Icon(
            Icons.chevron_right,
            color: AppColor.greyColor,
            size: 18.sp,
          ),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: 2.h,
      ),
      leading: Container(
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: AppColor.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Icon(
          icon,
          color: AppColor.primaryColor,
          size: 18.sp,
        ),
      ),
      title: AppText(
        text: title,
        fontSize: 13.sp,
        fontWeight: FontWeight.w500,
        color: AppColor.darkGrey,
      ),
      trailing: AppText(
        text: value,
        fontSize: 12.sp,
        color: AppColor.greyColor,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 48.w,
      color: AppColor.lightGrey,
    );
  }

  Widget _buildShimmerLoader() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Section Shimmer
          ShimmerSkeleton(
            isLoading: true,
            child: Container(
              width: double.infinity,
              height: 100.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                color: AppColor.lightGrey,
              ),
            ),
          ),
          SizedBox(height: Spacing.lg),
          // Account Section Shimmer
          ShimmerSkeleton(
            isLoading: true,
            child: Container(
              width: double.infinity,
              height: 120.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                color: AppColor.lightGrey,
              ),
            ),
          ),
          SizedBox(height: Spacing.lg),
          // Notifications Section Shimmer
          ShimmerSkeleton(
            isLoading: true,
            child: Container(
              width: double.infinity,
              height: 80.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                color: AppColor.lightGrey,
              ),
            ),
          ),
          SizedBox(height: Spacing.lg),
          // About Section Shimmer
          ShimmerSkeleton(
            isLoading: true,
            child: Container(
              width: double.infinity,
              height: 80.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                color: AppColor.lightGrey,
              ),
            ),
          ),
          SizedBox(height: Spacing.lg),
          // Delete Button Shimmer
          ShimmerSkeleton(
            isLoading: true,
            child: Container(
              width: double.infinity,
              height: 56.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                color: AppColor.lightGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
