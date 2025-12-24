import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:online_chat/features/authentications/controller/sign_up_controller.dart';
import 'package:online_chat/utils/app_button.dart';
import 'package:online_chat/utils/app_color.dart';
import 'package:online_chat/utils/app_spacing.dart';
import 'package:online_chat/utils/app_string.dart';
import 'package:online_chat/utils/app_text.dart';
import 'package:online_chat/utils/app_textfield.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignUpController());

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
                // Welcome Text
                _buildWelcomeSection().animate().fadeIn(duration: 600.ms, delay: 100.ms).slideY(begin: -0.1, end: 0, duration: 600.ms, delay: 100.ms),

                SizedBox(height: 24.h),

                // Profile Picture
                // _buildProfilePicture(controller)
                //     .animate()
                //     .fadeIn(duration: 600.ms, delay: 200.ms)
                //     .scale(
                //         begin: const Offset(0.9, 0.9),
                //         end: const Offset(1, 1),
                //         duration: 600.ms,
                //         delay: 200.ms),
                //
                // SizedBox(height: 24.h),

                // Name Field
                _buildNameField(controller)
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 300.ms)
                    .slideX(begin: -0.1, end: 0, duration: 600.ms, delay: 300.ms),

                SizedBox(height: 16.h),

                // Email Field
                _buildEmailField(controller)
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 400.ms)
                    .slideX(begin: -0.1, end: 0, duration: 600.ms, delay: 400.ms),

                // SizedBox(height: 16.h),

                // Phone Number Field
                // _buildPhoneField(controller)
                //     .animate()
                //     .fadeIn(duration: 600.ms, delay: 500.ms)
                //     .slideX(
                //         begin: -0.1, end: 0, duration: 600.ms, delay: 500.ms),

                SizedBox(height: 16.h),

                // Password Field
                _buildPasswordField(controller)
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 600.ms)
                    .slideX(begin: -0.1, end: 0, duration: 600.ms, delay: 600.ms),

                SizedBox(height: 16.h),

                // Confirm Password Field
                _buildConfirmPasswordField(controller)
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 700.ms)
                    .slideX(begin: -0.1, end: 0, duration: 600.ms, delay: 700.ms),

                // SizedBox(height: 16.h),

                // Terms and Conditions
                // _buildTermsAndConditions(controller)
                //     .animate()
                //     .fadeIn(duration: 600.ms, delay: 800.ms),

                SizedBox(height: 24.h),

                // Sign Up Button
                _buildSignUpButton(controller)
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 900.ms)
                    .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 600.ms, delay: 900.ms),

                SizedBox(height: 24.h),

                // Sign In Link
                _buildSignInLink(controller).animate().fadeIn(duration: 600.ms, delay: 1000.ms),
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
          text: AppString.joinUs,
          fontSize: 28.sp,
          fontWeight: FontWeight.bold,
          color: AppColor.primaryColor,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.h),
        AppText(
          text: AppString.signUpSubtitle,
          fontSize: 14.sp,
          color: AppColor.greyColor,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProfilePicture(SignUpController controller) {
    return Obx(
      () => Center(
        child: Column(
          children: [
            Stack(
              children: [
                GestureDetector(
                  onTap: controller.showImageSourceDialog,
                  child: Container(
                    width: 100.w,
                    height: 100.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColor.primaryColor,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.primaryColor.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: controller.profileImage.value != null
                        ? ClipOval(
                            child: Image.file(
                              controller.profileImage.value!,
                              fit: BoxFit.cover,
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
                            child: Icon(
                              Icons.person,
                              size: 50.sp,
                              color: AppColor.whiteColor,
                            ),
                          ),
                  ),
                ),
                if (controller.profileImage.value != null)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: controller.removeProfileImage,
                      child: Container(
                        width: 32.w,
                        height: 32.h,
                        decoration: BoxDecoration(
                          color: AppColor.redColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColor.whiteColor,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.close,
                          size: 16.sp,
                          color: AppColor.whiteColor,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8.h),
            GestureDetector(
              onTap: controller.showImageSourceDialog,
              child: AppText(
                text: controller.profileImage.value != null ? AppString.changeProfilePicture : AppString.addProfilePicture,
                fontSize: 12.sp,
                color: AppColor.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameField(SignUpController controller) {
    return AppTextField(
      controller: controller.nameController,
      labelText: AppString.fullName,
      hintText: AppString.fullNameHint,
      keyboardType: TextInputType.name,
      prefixIcon: Icon(
        Icons.person_outline,
        color: AppColor.primaryColor,
        size: 18.sp,
      ),
      validator: controller.validateName,
      focusNode: controller.nameFocusNode,
      textCapitalization: TextCapitalization.words,
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      onSubmitted: (_) {
        controller.emailFocusNode.requestFocus();
      },
    );
  }

  Widget _buildPhoneField(SignUpController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: AppString.phoneNumber,
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: AppColor.darkGrey,
        ),
        SizedBox(height: 6.h),

        /*Obx(
          () => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: CountryCodePicker(
                  selectedCountry: controller.selectedCountry.value,
                  onCountrySelected: controller.updateSelectedCountry,
                ),
              ),
              SizedBox(width: 12.w),
              // Expanded(
              //   child: AppTextField(
              //     controller: controller.phoneController,
              //     hintText: AppString.phoneNumberHint,
              //     keyboardType: TextInputType.phone,
              //     prefixIcon: Icon(
              //       Icons.phone_outlined,
              //       color: AppColor.primaryColor,
              //       size: 18.sp,
              //     ),
              //     validator: controller.validatePhone,
              //     focusNode: controller.phoneFocusNode,
              //     contentPadding:
              //         EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              //     inputFormatters: controller.getPhoneFormatters(),
              //     maxLength: controller.getPhoneMaxLength(),
              //     onSubmitted: (_) {
              //       controller.passwordFocusNode.requestFocus();
              //     },
              //   ),
              // ),
            ],
          ),
        ),*/
      ],
    );
  }

  Widget _buildEmailField(SignUpController controller) {
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

  Widget _buildPasswordField(SignUpController controller) {
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
          controller.confirmPasswordFocusNode.requestFocus();
        },
      ),
    );
  }

  Widget _buildConfirmPasswordField(SignUpController controller) {
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
          controller.signUp();
        },
      ),
    );
  }

  Widget _buildTermsAndConditions(SignUpController controller) {
    return Obx(
      () => GestureDetector(
        onTap: controller.toggleAgreeToTerms,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 16.w,
              height: 16.h,
              margin: EdgeInsets.only(top: 2.h),
              decoration: BoxDecoration(
                color: controller.agreeToTerms.value ? AppColor.primaryColor : Colors.transparent,
                border: Border.all(
                  color: controller.agreeToTerms.value ? AppColor.primaryColor : AppColor.greyColor,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(3.r),
              ),
              child: controller.agreeToTerms.value
                  ? Icon(
                      Icons.check,
                      size: 12.sp,
                      color: AppColor.whiteColor,
                    )
                  : null,
            ).animate(target: controller.agreeToTerms.value ? 1 : 0).scale(duration: 200.ms),
            SizedBox(width: 8.w),
            Expanded(
              child: Wrap(
                children: [
                  AppText(
                    text: AppString.agreeToTerms,
                    fontSize: 12.sp,
                    color: AppColor.darkGrey,
                  ),
                  GestureDetector(
                    onTap: () {
                      // TODO: Navigate to terms and conditions
                    },
                    child: AppText(
                      text: AppString.termsAndConditions,
                      fontSize: 12.sp,
                      color: AppColor.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AppText(
                    text: AppString.and,
                    fontSize: 12.sp,
                    color: AppColor.darkGrey,
                  ),
                  GestureDetector(
                    onTap: () {
                      // TODO: Navigate to privacy policy
                    },
                    child: AppText(
                      text: AppString.privacyPolicy,
                      fontSize: 12.sp,
                      color: AppColor.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignUpButton(SignUpController controller) {
    return Obx(
      () => CustomButton(
        text: AppString.createAccount,
        onPressed: controller.signUp,
        isLoading: controller.isLoading.value,
        backgroundColor: AppColor.primaryColor,
        borderRadius: 12,
        height: 44.h,
      ),
    );
  }

  Widget _buildSignInLink(SignUpController controller) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppText(
            text: AppString.alreadyHaveAccount,
            fontSize: 14.sp,
            color: AppColor.greyColor,
          ),
          GestureDetector(
            onTap: controller.navigateToSignIn,
            child: AppText(
              text: AppString.signIn,
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
