import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:online_chat/features/settings/controller/change_password_controller.dart';
import 'package:online_chat/utils/app_button.dart';
import 'package:online_chat/utils/app_color.dart';
import 'package:online_chat/utils/app_spacing.dart';
import 'package:online_chat/utils/app_string.dart';
import 'package:online_chat/utils/app_text.dart';
import 'package:online_chat/utils/app_textfield.dart';
import 'package:shimmer_skeleton/shimmer_skeleton.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChangePasswordController());

    return Scaffold(
      backgroundColor: AppColor.ScaffoldColor,
      appBar: _buildAppBar(),
      body: Obx(
        () => controller.isChanging.value && !controller.formKey.currentState!.validate()
            ? _buildShimmerLoader()
            : SingleChildScrollView(
                padding: EdgeInsets.all(Spacing.md),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: Spacing.lg),
                      // Info Card
                      _buildInfoCard(),
                      SizedBox(height: Spacing.xl),
                      // Current Password Field
                      _buildCurrentPasswordField(controller),
                      SizedBox(height: Spacing.md),
                      // New Password Field
                      _buildNewPasswordField(controller),
                      SizedBox(height: Spacing.md),
                      // Confirm Password Field
                      _buildConfirmPasswordField(controller),
                      SizedBox(height: Spacing.xl),
                      // Change Password Button
                      _buildChangePasswordButton(controller),
                      SizedBox(height: Spacing.lg),
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
      leadingWidth: 0,
      automaticallyImplyLeading: false,
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
            text: AppString.changePassword,
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

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: AppColor.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: AppColor.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColor.primaryColor,
            size: 24.sp,
          ),
          SizedBox(width: Spacing.md),
          Expanded(
            child: AppText(
              text: AppString.reauthenticationRequired,
              fontSize: 14.sp,
              color: AppColor.darkGrey,
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPasswordField(ChangePasswordController controller) {
    return Obx(
      () => AppTextField(
        controller: controller.currentPasswordController,
        labelText: AppString.currentPassword,
        hintText: AppString.currentPasswordHint,
        obscureText: !controller.isCurrentPasswordVisible.value,
        prefixIcon: Icon(
          Icons.lock_outlined,
          color: AppColor.primaryColor,
          size: 18.sp,
        ),
        suffixIcon: Icon(
          controller.isCurrentPasswordVisible.value ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: AppColor.greyColor,
          size: 18.sp,
        ),
        onSuffixIconTap: controller.toggleCurrentPasswordVisibility,
        validator: controller.validateCurrentPassword,
        focusNode: controller.currentPasswordFocusNode,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        onSubmitted: (_) {
          controller.newPasswordFocusNode.requestFocus();
        },
      ),
    );
  }

  Widget _buildNewPasswordField(ChangePasswordController controller) {
    return Obx(
      () => AppTextField(
        controller: controller.newPasswordController,
        labelText: AppString.newPassword,
        hintText: AppString.newPasswordHint,
        obscureText: !controller.isNewPasswordVisible.value,
        prefixIcon: Icon(
          Icons.lock_outlined,
          color: AppColor.primaryColor,
          size: 18.sp,
        ),
        suffixIcon: Icon(
          controller.isNewPasswordVisible.value ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: AppColor.greyColor,
          size: 18.sp,
        ),
        onSuffixIconTap: controller.toggleNewPasswordVisibility,
        validator: controller.validateNewPassword,
        focusNode: controller.newPasswordFocusNode,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        onSubmitted: (_) {
          controller.confirmPasswordFocusNode.requestFocus();
        },
      ),
    );
  }

  Widget _buildConfirmPasswordField(ChangePasswordController controller) {
    return Obx(
      () => AppTextField(
        controller: controller.confirmPasswordController,
        labelText: AppString.confirmPassword,
        hintText: AppString.confirmPasswordHint,
        obscureText: !controller.isConfirmPasswordVisible.value,
        prefixIcon: Icon(
          Icons.lock_outlined,
          color: AppColor.primaryColor,
          size: 18.sp,
        ),
        suffixIcon: Icon(
          controller.isConfirmPasswordVisible.value ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: AppColor.greyColor,
          size: 18.sp,
        ),
        onSuffixIconTap: controller.toggleConfirmPasswordVisibility,
        validator: controller.validateConfirmPassword,
        focusNode: controller.confirmPasswordFocusNode,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        onSubmitted: (_) {
          controller.changePassword();
        },
      ),
    );
  }

  Widget _buildChangePasswordButton(ChangePasswordController controller) {
    return Obx(
      () => CustomButton(
        text: AppString.changePassword,
        onPressed: controller.isChanging.value ? () {} : () => controller.changePassword(),
        isLoading: controller.isChanging.value,
        backgroundColor: AppColor.primaryColor,
        borderRadius: 8,
        height: 44.h,
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
          // Info Card Shimmer
          ShimmerSkeleton(
            isLoading: true,
            child: Container(
              width: double.infinity,
              height: 80.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                color: AppColor.lightGrey,
              ),
            ),
          ),
          SizedBox(height: Spacing.xl),
          // Password Fields Shimmer
          ShimmerSkeleton(
            isLoading: true,
            child: Container(
              width: double.infinity,
              height: 56.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                color: AppColor.lightGrey,
              ),
            ),
          ),
          SizedBox(height: Spacing.md),
          ShimmerSkeleton(
            isLoading: true,
            child: Container(
              width: double.infinity,
              height: 56.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                color: AppColor.lightGrey,
              ),
            ),
          ),
          SizedBox(height: Spacing.md),
          ShimmerSkeleton(
            isLoading: true,
            child: Container(
              width: double.infinity,
              height: 56.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                color: AppColor.lightGrey,
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
                borderRadius: BorderRadius.circular(8.r),
                color: AppColor.lightGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
