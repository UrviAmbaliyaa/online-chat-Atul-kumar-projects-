import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:online_chat/features/settings/controller/edit_profile_controller.dart';
import 'package:online_chat/utils/app_button.dart';
import 'package:online_chat/utils/app_color.dart';
import 'package:online_chat/utils/app_preference.dart';
import 'package:online_chat/utils/app_spacing.dart';
import 'package:online_chat/utils/app_string.dart';
import 'package:online_chat/utils/app_text.dart';
import 'package:online_chat/utils/app_textfield.dart';
import 'package:online_chat/utils/country_code_picker.dart';
import 'package:shimmer_skeleton/shimmer_skeleton.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final controller = Get.put(EditProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.ScaffoldColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Spacing.md),
        child: Obx(() {
          return ShimmerSkeleton(
            isLoading: controller.isLoading.value,
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: Spacing.md),
                  // Profile Picture Section
                  _buildProfilePictureSection(controller),

                  // Form Fields
                  _buildFormFields(controller),
                  SizedBox(height: Spacing.xl),
                  // Update Button
                  _buildUpdateButton(controller),
                  SizedBox(height: Spacing.lg),
                  // Delete Account Button
                  _buildDeleteAccountButton(controller),
                  SizedBox(height: Spacing.lg),
                ],
              ),
            ),
          );
        }),
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
            text: AppString.editProfile,
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

  Widget _buildProfilePictureSection(EditProfileController controller) {
    return Obx(
      () => Column(
        children: [
          // Profile Picture
          Stack(
            children: [
              Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColor.primaryColor,
                      width: 4,
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
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.primaryColor.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _buildProfilePlaceholder(controller)
                  /*controller.profileImage.value != null
                    ? Image.file(
                        controller.profileImage.value!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildProfilePlaceholder(controller);
                        },
                      )
                    : controller.currentProfileImageUrl != null &&
                            controller.currentProfileImageUrl!.isNotEmpty &&
                            controller.currentProfileImageUrl!
                                .startsWith('http')
                        ? CachedNetworkImage(
                            imageUrl: controller.currentProfileImageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                _buildProfilePlaceholder(controller),
                            errorWidget: (context, url, error) =>
                                _buildProfilePlaceholder(controller),
                          )
                        : _buildProfilePlaceholder(controller),*/
                  ),
              // Edit Icon Button
              // Positioned(
              //   bottom: 0,
              //   right: 0,
              //   child: Container(
              //     width: 36.w,
              //     height: 36.h,
              //     decoration: BoxDecoration(
              //       shape: BoxShape.circle,
              //       color: AppColor.primaryColor,
              //       border: Border.all(
              //         color: AppColor.whiteColor,
              //         width: 3,
              //       ),
              //       boxShadow: [
              //         BoxShadow(
              //           color: AppColor.blackColor.withOpacity(0.2),
              //           blurRadius: 8,
              //           spreadRadius: 0,
              //           offset: const Offset(0, 2),
              //         ),
              //       ],
              //     ),
              //     child: Material(
              //       color: Colors.transparent,
              //       child: InkWell(
              //         onTap: controller.showImageSourceDialog,
              //         borderRadius: BorderRadius.circular(8.r),
              //         child: Icon(
              //           Icons.camera_alt_rounded,
              //           color: AppColor.whiteColor,
              //           size: 18.sp,
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
          // SizedBox(height: Spacing.md),
          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              controller.profileImage.value != null
                  ? TextButton.icon(
                      onPressed: controller.removeProfileImage,
                      icon: Icon(
                        Icons.delete_outline,
                        color: AppColor.lightRedColor,
                        size: 18.sp,
                      ),
                      label: AppText(
                        text: AppString.removeProfilePicture,
                        fontSize: 14.sp,
                        color: AppColor.lightRedColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ).paddingOnly(bottom: Spacing.sm)
                  : SizedBox(height: Spacing.xl),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePlaceholder(EditProfileController controller) {
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
          text: controller.nameController.text.isNotEmpty
              ? controller.nameController.text[0].toUpperCase()
              : 'U',
          fontSize: 48.sp,
          fontWeight: FontWeight.w700,
          color: AppColor.whiteColor,
        ),
      ),
    );
  }

  Widget _buildFormFields(EditProfileController controller) {
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
        children: [
          // Full Name Field
          AppTextField(
            controller: controller.nameController,
            labelText: AppString.fullName,
            hintText: AppString.fullNameHint,
            prefixIcon: Icon(
              Icons.person_outline,
              color: AppColor.primaryColor,
              size: 20.sp,
            ),
            onChanged: (p0) {
              if (p0.trim().isNotEmpty &&
                  AppPreference.currentUser.value?.name[0] != p0.trim()[0]) {
                setState(() {});
              }
            },
            textCapitalization: TextCapitalization.words,
            validator: controller.validateName,
            focusNode: controller.nameFocusNode,
            textStyle: TextStyle(
              fontSize: 15.sp,
              color: AppColor.darkGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: Spacing.md),
          // Email Field
          AppTextField(
            controller: controller.emailController,
            labelText: AppString.email,
            hintText: AppString.emailHint,
            prefixIcon: Icon(
              Icons.email_outlined,
              color: AppColor.primaryColor,
              size: 20.sp,
            ),
            keyboardType: TextInputType.emailAddress,
            validator: controller.validateEmail,
            focusNode: controller.emailFocusNode,
            enabled: false,
            // Email is usually not editable
            fillColor: AppColor.lightGrey.withOpacity(0.3),
            textStyle: TextStyle(
              fontSize: 15.sp,
              color: AppColor.greyColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: Spacing.md),
          // Phone Number Field
          _buildPhoneField(controller),
        ],
      ),
    );
  }

  Widget _buildPhoneField(EditProfileController controller) {
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
        Obx(
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
              Expanded(
                child: AppTextField(
                  controller: controller.phoneController,
                  hintText: AppString.phoneNumberHint,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icon(
                    Icons.phone_outlined,
                    color: AppColor.primaryColor,
                    size: 18.sp,
                  ),
                  validator: controller.validatePhone,
                  focusNode: controller.phoneFocusNode,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                  inputFormatters: controller.getPhoneFormatters(),
                  maxLength: controller.getPhoneMaxLength(),
                  textStyle: TextStyle(
                    fontSize: 15.sp,
                    color: AppColor.darkGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUpdateButton(EditProfileController controller) {
    return Obx(
      () => CustomButton(
        text: AppString.editProfile,
        onPressed: controller.isSaving.value
            ? () {}
            : () => controller.updateProfile(),
        isLoading: controller.isSaving.value,
        backgroundColor: AppColor.primaryColor,
        borderRadius: 8,
        height: 44.h,
      ),
    );
  }

  Widget _buildDeleteAccountButton(EditProfileController controller) {
    return Obx(
      () => CustomButton(
        text: AppString.deleteAccount,
        onPressed:
            controller.isDeletingAccount.value || controller.isSaving.value
                ? () {}
                : controller.showDeleteAccountConfirmation,
        isLoading: controller.isDeletingAccount.value,
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
}
