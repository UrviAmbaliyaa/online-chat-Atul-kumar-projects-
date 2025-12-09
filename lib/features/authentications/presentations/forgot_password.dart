import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:online_chat/features/authentications/controller/forgot_password_controller.dart';
import 'package:online_chat/utils/app_button.dart';
import 'package:online_chat/utils/app_color.dart';
import 'package:online_chat/utils/app_spacing.dart';
import 'package:online_chat/utils/app_string.dart';
import 'package:online_chat/utils/app_text.dart';
import 'package:online_chat/utils/app_textfield.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgotPasswordController());

    return Scaffold(
      backgroundColor: AppColor.ScaffoldColor,
      appBar: _buildAppBar(controller),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.lg),
          child: Form(
            key: controller.formKey,
            child: Obx(
              () => controller.isEmailSent.value
                  ? _buildSuccessView(controller)
                  : _buildResetForm(controller),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ForgotPasswordController controller) {
    return AppBar(
      backgroundColor: AppColor.ScaffoldColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          size: 20.sp,
          color: AppColor.darkGrey,
        ),
        onPressed: controller.navigateToSignIn,
      ),
      title: AppText(
        text: AppString.forgotPassword,
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: AppColor.darkGrey,
      ),
      centerTitle: false,
    );
  }

  Widget _buildResetForm(ForgotPasswordController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Animated Icon
        _buildAnimatedIcon()
            .animate()
            .fadeIn(duration: 600.ms, delay: 100.ms)
            .slideY(begin: -0.2, end: 0, duration: 600.ms, delay: 100.ms),

        SizedBox(height: 40.h),

        // Title and Description
        _buildHeaderSection()
            .animate()
            .fadeIn(duration: 600.ms, delay: 200.ms)
            .slideY(begin: -0.1, end: 0, duration: 600.ms, delay: 200.ms),

        SizedBox(height: 40.h),

        // Email Field
        _buildEmailField(controller)
            .animate()
            .fadeIn(duration: 600.ms, delay: 300.ms)
            .slideX(begin: -0.1, end: 0, duration: 600.ms, delay: 300.ms),

        SizedBox(height: 32.h),

        // Send Reset Email Button
        _buildSendButton(controller)
            .animate()
            .fadeIn(duration: 600.ms, delay: 400.ms)
            .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 600.ms, delay: 400.ms),

        SizedBox(height: 24.h),

        // Back to Sign In Link
        _buildBackToSignInLink(controller)
            .animate()
            .fadeIn(duration: 600.ms, delay: 500.ms),
      ],
    );
  }

  Widget _buildSuccessView(ForgotPasswordController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 40.h),

        // Success Icon
        _buildSuccessIcon()
            .animate()
            .fadeIn(duration: 600.ms, delay: 100.ms)
            .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1), duration: 600.ms, delay: 100.ms),

        SizedBox(height: 40.h),

        // Success Title
        _buildSuccessTitle()
            .animate()
            .fadeIn(duration: 600.ms, delay: 200.ms)
            .slideY(begin: -0.1, end: 0, duration: 600.ms, delay: 200.ms),

        SizedBox(height: 16.h),

        // Success Description
        _buildSuccessDescription(controller)
            .animate()
            .fadeIn(duration: 600.ms, delay: 300.ms)
            .slideY(begin: 0.1, end: 0, duration: 600.ms, delay: 300.ms),

        SizedBox(height: 40.h),

        // Back to Sign In Button
        _buildBackToSignInButton(controller)
            .animate()
            .fadeIn(duration: 600.ms, delay: 400.ms)
            .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 600.ms, delay: 400.ms),

        SizedBox(height: 16.h),

        // Resend Email Link
        _buildResendEmailLink(controller)
            .animate()
            .fadeIn(duration: 600.ms, delay: 500.ms),
      ],
    );
  }

  Widget _buildAnimatedIcon() {
    return Center(
      child: Container(
        width: 120.w,
        height: 120.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColor.primaryColor,
              AppColor.secondaryColor,
              AppColor.accentColor,
            ],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColor.primaryColor.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Icon(
          Icons.lock_reset,
          size: 60.sp,
          color: AppColor.whiteColor,
        ),
      )
          .animate(onPlay: (controller) => controller.repeat())
          .shimmer(duration: 2000.ms, color: AppColor.whiteColor.withOpacity(0.3))
          .then()
          .scale(duration: 1000.ms, begin: const Offset(1, 1), end: const Offset(1.05, 1.05))
          .then()
          .scale(duration: 1000.ms, begin: const Offset(1.05, 1.05), end: const Offset(1, 1)),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: AppString.forgotPasswordTitle,
          fontSize: 32.sp,
          fontWeight: FontWeight.bold,
          color: AppColor.primaryColor,
        ),
        SizedBox(height: 8.h),
        AppText(
          text: AppString.forgotPasswordSubtitle,
          fontSize: 16.sp,
          color: AppColor.greyColor,
        ),
      ],
    );
  }

  Widget _buildEmailField(ForgotPasswordController controller) {
    return AppTextField(
      controller: controller.emailController,
      focusNode: controller.emailFocusNode,
      labelText: AppString.email,
      hintText: AppString.emailHint,
      keyboardType: TextInputType.emailAddress,
      prefixIcon: Icon(
        Icons.email_outlined,
        size: 20.sp,
        color: AppColor.greyColor,
      ),
      validator: controller.validateEmail,
      onSubmitted: (_) => controller.sendResetEmail(),
    );
  }

  Widget _buildSendButton(ForgotPasswordController controller) {
    return Obx(
      () => CustomButton(
        text: AppString.sendResetLink,
        onPressed: controller.sendResetEmail,
        isLoading: controller.isLoading.value,
        backgroundColor: AppColor.primaryColor,
        borderRadius: 12,
        height: 44.h,
      ),
    );
  }

  Widget _buildBackToSignInLink(ForgotPasswordController controller) {
    return Center(
      child: GestureDetector(
        onTap: controller.navigateToSignIn,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.arrow_back_ios,
              size: 14.sp,
              color: AppColor.primaryColor,
            ),
            SizedBox(width: 4.w),
            AppText(
              text: AppString.backToSignIn,
              fontSize: 14.sp,
              color: AppColor.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      width: 120.w,
      height: 120.h,
      decoration: BoxDecoration(
        color: AppColor.successColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.check_circle,
        size: 80.sp,
        color: AppColor.successColor,
      ),
    );
  }

  Widget _buildSuccessTitle() {
    return AppText(
      text: AppString.emailSentTitle,
      fontSize: 28.sp,
      fontWeight: FontWeight.bold,
      color: AppColor.primaryColor,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSuccessDescription(ForgotPasswordController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Spacing.sm),
      child: AppText(
        text: AppString.emailSentDescription(controller.emailController.text),
        fontSize: 16.sp,
        color: AppColor.greyColor,
        textAlign: TextAlign.center,
        maxLines: 3,
      ),
    );
  }

  Widget _buildBackToSignInButton(ForgotPasswordController controller) {
    return CustomButton(
      text: AppString.backToSignIn,
      onPressed: controller.navigateToSignIn,
      backgroundColor: AppColor.primaryColor,
      borderRadius: 12,
      height: 44.h,
    );
  }

  Widget _buildResendEmailLink(ForgotPasswordController controller) {
    return GestureDetector(
      onTap: controller.resendEmail,
      child: AppText(
        text: AppString.resendEmail,
        fontSize: 14.sp,
        color: AppColor.primaryColor,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

