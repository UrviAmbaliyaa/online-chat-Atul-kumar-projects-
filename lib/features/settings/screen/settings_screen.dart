import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:online_chat/features/settings/controller/settings_controller.dart';
import 'package:online_chat/utils/app_color.dart';
import 'package:online_chat/utils/app_spacing.dart';
import 'package:online_chat/utils/app_string.dart';
import 'package:online_chat/utils/app_text.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());

    return Scaffold(
      backgroundColor: AppColor.ScaffoldColor,
      appBar: _buildAppBar(),
      body: Obx(
        () => controller.isLoading.value
            ? Center(
                child: CircularProgressIndicator(
                  color: AppColor.primaryColor,
                ),
              )
            : RefreshIndicator(
                onRefresh: () async {
                  controller.loadUserData();
                  controller.loadSettings();
                },
                color: AppColor.primaryColor,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: Spacing.md,
                    vertical: Spacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Section
                      _buildProfileSection(controller),
                      SizedBox(height: Spacing.lg),

                      // Account Section
                      _buildSectionTitle(AppString.account),
                      SizedBox(height: Spacing.sm),
                      _buildAccountSection(controller),
                      SizedBox(height: Spacing.lg),

                      // Notifications Section
                      _buildSectionTitle(AppString.notifications),
                      SizedBox(height: Spacing.sm),
                      _buildNotificationsSection(controller),
                      SizedBox(height: Spacing.lg),

                      // App Settings Section
                      _buildSectionTitle(AppString.appSettings),
                      SizedBox(height: Spacing.sm),
                      _buildAppSettingsSection(controller),
                      SizedBox(height: Spacing.lg),

                      // About Section
                      _buildSectionTitle(AppString.about),
                      SizedBox(height: Spacing.sm),
                      _buildAboutSection(controller),
                      SizedBox(height: Spacing.lg),

                      // Delete Account Button
                      _buildDeleteAccountButton(controller),
                      SizedBox(height: Spacing.xl),
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
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: AppColor.darkGrey,
          size: 20.sp,
        ),
        onPressed: () => Get.back(),
      ),
      title: AppText(
        text: AppString.settings,
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        color: AppColor.darkGrey,
      ),
      centerTitle: false,
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
      () => Container(
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.circular(16.r),
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
        child: Row(
          children: [
            // Profile Picture
            Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColor.primaryColor,
                  width: 3,
                ),
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
                child: controller.userProfileImage.value.isNotEmpty &&
                        !controller.userProfileImage.value.startsWith('http')
                    ? Image.file(
                        File(controller.userProfileImage.value),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildProfilePlaceholder(controller);
                        },
                      )
                    : _buildProfilePlaceholder(controller),
              ),
            ),
            SizedBox(width: Spacing.md),
            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: controller.userName.value.isNotEmpty
                        ? controller.userName.value
                        : 'User',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColor.darkGrey,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  AppText(
                    text: controller.userEmail.value.isNotEmpty
                        ? controller.userEmail.value
                        : 'email@example.com',
                    fontSize: 14.sp,
                    color: AppColor.greyColor,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (controller.userPhone.value.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    AppText(
                      text: controller.userPhone.value,
                      fontSize: 14.sp,
                      color: AppColor.greyColor,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            // Edit Button
            IconButton(
              onPressed: controller.navigateToEditProfile,
              icon: Icon(
                Icons.edit_outlined,
                color: AppColor.primaryColor,
                size: 24.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePlaceholder(SettingsController controller) {
    return Container(
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
          text: controller.userName.value.isNotEmpty
              ? controller.userName.value[0].toUpperCase()
              : 'U',
          fontSize: 32.sp,
          fontWeight: FontWeight.w600,
          color: AppColor.whiteColor,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Spacing.xs),
      child: AppText(
        text: title,
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: AppColor.darkGrey,
      ),
    );
  }

  Widget _buildAccountSection(SettingsController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(16.r),
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
        borderRadius: BorderRadius.circular(16.r),
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

  Widget _buildAppSettingsSection(SettingsController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(16.r),
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
        () => _buildSelectionTile(
          icon: Icons.palette_outlined,
          title: AppString.theme,
          value: _getThemeDisplayName(controller.selectedTheme.value),
          onTap: () => _showThemeDialog(controller),
        ),
      ),
    );
  }

  Widget _buildAboutSection(SettingsController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(16.r),
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

  Widget _buildDeleteAccountButton(SettingsController controller) {
    return Obx(
      () => Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColor.redColor.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: AppColor.redColor,
          borderRadius: BorderRadius.circular(16.r),
          child: InkWell(
            onTap: controller.isLoading.value
                ? null
                : controller.showDeleteAccountConfirmation,
            borderRadius: BorderRadius.circular(16.r),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.delete_outline,
                    color: AppColor.whiteColor,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  AppText(
                    text: AppString.deleteAccount,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColor.whiteColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
        horizontal: Spacing.md,
        vertical: 4.h,
      ),
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: (iconColor ?? AppColor.primaryColor).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(
          icon,
          color: iconColor ?? AppColor.primaryColor,
          size: 20.sp,
        ),
      ),
      title: AppText(
        text: title,
        fontSize: 15.sp,
        fontWeight: FontWeight.w500,
        color: titleColor ?? AppColor.darkGrey,
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppColor.greyColor,
        size: 20.sp,
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
        horizontal: Spacing.md,
        vertical: 4.h,
      ),
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: AppColor.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(
          icon,
          color: AppColor.primaryColor,
          size: 20.sp,
        ),
      ),
      title: AppText(
        text: title,
        fontSize: 15.sp,
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
        horizontal: Spacing.md,
        vertical: 4.h,
      ),
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: AppColor.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(
          icon,
          color: AppColor.primaryColor,
          size: 20.sp,
        ),
      ),
      title: AppText(
        text: title,
        fontSize: 15.sp,
        fontWeight: FontWeight.w500,
        color: AppColor.darkGrey,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(
            text: value,
            fontSize: 14.sp,
            color: AppColor.greyColor,
          ),
          SizedBox(width: 4.w),
          Icon(
            Icons.chevron_right,
            color: AppColor.greyColor,
            size: 20.sp,
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
        horizontal: Spacing.md,
        vertical: 4.h,
      ),
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: AppColor.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(
          icon,
          color: AppColor.primaryColor,
          size: 20.sp,
        ),
      ),
      title: AppText(
        text: title,
        fontSize: 15.sp,
        fontWeight: FontWeight.w500,
        color: AppColor.darkGrey,
      ),
      trailing: AppText(
        text: value,
        fontSize: 14.sp,
        color: AppColor.greyColor,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 60.w,
      color: AppColor.lightGrey,
    );
  }

  String _getThemeDisplayName(String theme) {
    switch (theme) {
      case 'light':
        return AppString.light;
      case 'dark':
        return AppString.dark;
      default:
        return AppString.light;
    }
  }

  void _showThemeDialog(SettingsController controller) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Container(
          padding: EdgeInsets.all(Spacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText(
                text: AppString.theme,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.darkGrey,
              ),
              SizedBox(height: Spacing.md),
              Obx(
                () => Column(
                  children: [
                    _buildThemeOption(
                      controller,
                      'light',
                      AppString.light,
                      Icons.light_mode_outlined,
                    ),
                    SizedBox(height: Spacing.sm),
                    _buildThemeOption(
                      controller,
                      'dark',
                      AppString.dark,
                      Icons.dark_mode_outlined,
                    ),
                  ],
                ),
              ),
              SizedBox(height: Spacing.md),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    SettingsController controller,
    String value,
    String label,
    IconData icon,
  ) {
    final isSelected = controller.selectedTheme.value == value;
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(
          color: isSelected
              ? AppColor.primaryColor
              : AppColor.lightGrey,
          width: isSelected ? 2 : 1,
        ),
      ),
      leading: Icon(
        icon,
        color: isSelected ? AppColor.primaryColor : AppColor.greyColor,
      ),
      title: AppText(
        text: label,
        fontSize: 15.sp,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        color: isSelected ? AppColor.primaryColor : AppColor.darkGrey,
      ),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: AppColor.primaryColor,
            )
          : null,
      onTap: () {
        controller.changeTheme(value);
        Get.back();
      },
    );
  }
}
