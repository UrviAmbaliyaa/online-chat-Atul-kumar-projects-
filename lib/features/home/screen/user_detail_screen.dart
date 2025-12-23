import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:online_chat/features/home/models/user_model.dart';
import 'package:online_chat/utils/app_color.dart';
import 'package:online_chat/utils/app_profile_image.dart';
import 'package:online_chat/utils/app_spacing.dart';
import 'package:online_chat/utils/app_string.dart';
import 'package:online_chat/utils/app_text.dart';

class UserDetailScreen extends StatelessWidget {
  final UserModel user;

  const UserDetailScreen({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.ScaffoldColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Spacing.sm),
        child: Column(
          children: [
            // Profile Section
            _buildProfileSection(),

            // User Info Section
            _buildUserInfoSection(),
            SizedBox(height: Spacing.md),
            // Call List Section
            _buildCallListSection(),
          ],
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
            text: AppString.userDetails,
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

  Widget _buildProfileSection() {
    return Container(
      padding: EdgeInsets.only(bottom: Spacing.lg, top: Spacing.xs),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: AppProfileImage(
        width: 90.w,
        height: 90.h,
        username: user.name,
        imageUrl: user.profileImage,
        fontSize: 36.sp,
        borderWidth: 3,
        borderColor: AppColor.primaryColor,
      ),
    );
  }

  Widget _buildUserInfoSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryColor.withOpacity(0.08),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoItem(
            icon: Icons.person_outline,
            label: AppString.fullName,
            value: user.name,
          ),
          _buildDivider(),
          _buildInfoItem(
            icon: Icons.email_outlined,
            label: AppString.email,
            value: user.email,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.all(Spacing.md),
      child: Row(
        children: [
          Container(
            width: 32.w,
            height: 32.h,
            decoration: BoxDecoration(
              color: AppColor.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              icon,
              color: AppColor.primaryColor,
              size: 16.sp,
            ),
          ),
          SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: label,
                  fontSize: 11.sp,
                  color: AppColor.greyColor,
                ),
                SizedBox(height: 3.h),
                AppText(
                  text: value,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColor.darkGrey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColor.lightGrey.withOpacity(0.5),
      indent: Spacing.md + 32.w + Spacing.sm,
    );
  }

  Widget _buildCallListSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: AppColor.primaryColor.withOpacity(0.08),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(Spacing.md),
            child: AppText(
              text: AppString.callHistory,
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColor.darkGrey,
            ),
          ),
          _buildDivider(),
          _buildEmptyCallList(),
        ],
      ),
    );
  }

  Widget _buildEmptyCallList() {
    return Padding(
      padding: EdgeInsets.all(Spacing.lg),
      child: Column(
        children: [
          Icon(
            Icons.call_outlined,
            size: 36.sp,
            color: AppColor.greyColor.withOpacity(0.5),
          ),
          SizedBox(height: Spacing.md),
          AppText(
            text: AppString.noCallHistory,
            fontSize: 12.sp,
            color: AppColor.greyColor,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatLastSeen(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    // Format time as HH:MM AM/PM
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final timeString =
        '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';

    if (messageDate == today) {
      return 'today at $timeString';
    } else if (messageDate == yesterday) {
      return 'yesterday at $timeString';
    } else {
      // Format as "MMM d at HH:MM AM/PM" for older dates
      final dateString = DateFormat('MMM d').format(dateTime);
      return '$dateString at $timeString';
    }
  }
}
