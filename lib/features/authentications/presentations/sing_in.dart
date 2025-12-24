import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:online_chat/features/authentications/controller/sign_in_controller.dart';
import 'package:online_chat/utils/app_button.dart';
import 'package:online_chat/utils/app_color.dart';
import 'package:online_chat/utils/app_spacing.dart';
import 'package:online_chat/utils/app_string.dart';
import 'package:online_chat/utils/app_text.dart';
import 'package:online_chat/utils/app_textfield.dart';
import 'package:online_chat/utils/logo.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignInController());

    return Scaffold(
      backgroundColor: AppColor.ScaffoldColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.lg),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Animated Logo/Icon
                AppLogo(),

                SizedBox(height: 40.h),

                // Welcome Text
                _buildWelcomeSection().animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: -0.1, end: 0, duration: 600.ms, delay: 200.ms),

                SizedBox(height: 40.h),

                // Email Field
                _buildEmailField(controller)
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 300.ms)
                    .slideX(begin: -0.1, end: 0, duration: 600.ms, delay: 300.ms),

                SizedBox(height: 20.h),

                // Password Field
                _buildPasswordField(controller)
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 400.ms)
                    .slideX(begin: -0.1, end: 0, duration: 600.ms, delay: 400.ms),

                SizedBox(height: 12.h),

                // Remember Me & Forgot Password
                _buildRememberAndForgot(controller).animate().fadeIn(duration: 600.ms, delay: 500.ms),

                SizedBox(height: 32.h),

                // Sign In Button
                _buildSignInButton(controller)
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 600.ms)
                    .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 600.ms, delay: 600.ms),

                SizedBox(height: 32.h),

                // Sign Up Link
                _buildSignUpLink(controller).animate().fadeIn(duration: 600.ms, delay: 700.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: AppString.welcomeBack,
          fontSize: 32.sp,
          fontWeight: FontWeight.bold,
          color: AppColor.primaryColor,
        ),
        SizedBox(height: 8.h),
        AppText(
          text: AppString.signInSubtitle,
          fontSize: 16.sp,
          color: AppColor.greyColor,
        ),
      ],
    );
  }

  Widget _buildEmailField(SignInController controller) {
    return AppTextField(
      controller: controller.emailController,
      labelText: AppString.email,
      hintText: AppString.emailHint,
      keyboardType: TextInputType.emailAddress,
      prefixIcon: Icon(
        Icons.email_outlined,
        color: AppColor.primaryColor,
        size: 18.sp,
      ),
      validator: controller.validateEmail,
      focusNode: controller.emailFocusNode,
      textCapitalization: TextCapitalization.none,
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      onSubmitted: (_) {
        controller.passwordFocusNode.requestFocus();
      },
    );
  }

  Widget _buildPasswordField(SignInController controller) {
    return Obx(
      () => AppTextField(
        controller: controller.passwordController,
        labelText: AppString.password,
        hintText: AppString.passwordHint,
        obscureText: !controller.isPasswordVisible.value,
        prefixIcon: Icon(
          Icons.lock_outlined,
          color: AppColor.primaryColor,
          size: 18.sp,
        ),
        suffixIcon: Icon(
          controller.isPasswordVisible.value ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: AppColor.greyColor,
          size: 18.sp,
        ),
        onSuffixIconTap: controller.togglePasswordVisibility,
        validator: controller.validatePassword,
        focusNode: controller.passwordFocusNode,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        onSubmitted: (_) {
          controller.signIn();
        },
      ),
    );
  }

  Widget _buildRememberAndForgot(SignInController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        /*Obx(
          () => GestureDetector(
            onTap: controller.toggleRememberMe,
            child: Row(
              children: [
                Container(
                  width: 16.w,
                  height: 16.h,
                  decoration: BoxDecoration(
                    color: controller.rememberMe.value
                        ? AppColor.primaryColor
                        : Colors.transparent,
                    border: Border.all(
                      color: controller.rememberMe.value
                          ? AppColor.primaryColor
                          : AppColor.greyColor,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                  child: controller.rememberMe.value
                      ? Icon(
                          Icons.check,
                          size: 12.sp,
                          color: AppColor.whiteColor,
                        )
                      : null,
                )
                    .animate(target: controller.rememberMe.value ? 1 : 0)
                    .scale(duration: 200.ms),
                SizedBox(width: 6.w),
                AppText(
                  text: "Remember me",
                  fontSize: 12.sp,
                  color: AppColor.darkGrey,
                ),
              ],
            ),
          ),
        ),*/
        GestureDetector(
          onTap: controller.navigateToForgotPassword,
          child: AppText(
            text: AppString.forgotPassword,
            fontSize: 12.sp,
            color: AppColor.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSignInButton(SignInController controller) {
    return Obx(
      () => CustomButton(
        text: AppString.signIn,
        onPressed: controller.signIn,
        isLoading: controller.isLoading.value,
        backgroundColor: AppColor.primaryColor,
        borderRadius: 12,
        height: 44.h,
      ),
    );
  }

  Widget _buildSignUpLink(SignInController controller) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppText(
            text: AppString.dontHaveAccount,
            fontSize: 14.sp,
            color: AppColor.greyColor,
          ),
          GestureDetector(
            onTap: controller.navigateToSignUp,
            child: AppText(
              text: AppString.signUp,
              fontSize: 14.sp,
              color: AppColor.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
