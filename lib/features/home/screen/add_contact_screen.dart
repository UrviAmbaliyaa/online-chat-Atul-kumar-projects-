import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:online_chat/features/home/controller/add_contact_controller.dart';
import 'package:online_chat/features/home/models/user_model.dart';
import 'package:online_chat/utils/app_button.dart';
import 'package:online_chat/utils/app_color.dart';
import 'package:online_chat/utils/app_spacing.dart';
import 'package:online_chat/utils/app_string.dart';
import 'package:online_chat/utils/app_text.dart';
import 'package:online_chat/utils/app_textfield.dart';

class AddContactScreen extends StatelessWidget {
  const AddContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddContactController());

    return Scaffold(
      backgroundColor: AppColor.ScaffoldColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Spacing.md),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: Spacing.lg),
              // Header Section
              _buildHeaderSection(),
              SizedBox(height: Spacing.xl),
              // Email Input Section + Suggestions
              _buildEmailInputSection(controller),
              SizedBox(height: Spacing.xl),
              // Add Contact Button
              _buildAddContactButton(controller),
              SizedBox(height: Spacing.lg),
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
            text: AppString.addContact,
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
              Icons.person_add_rounded,
              color: AppColor.whiteColor,
              size: 40.sp,
            ),
          ),
          SizedBox(height: Spacing.md),
          AppText(
            text: AppString.addContactTitle,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColor.darkGrey,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: Spacing.sm),
          AppText(
            text: AppString.addContactSubtitle,
            fontSize: 14.sp,
            color: AppColor.greyColor,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmailInputSection(AddContactController controller) {
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
            text: AppString.email,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColor.darkGrey,
          ),
          SizedBox(height: Spacing.sm),
          AppTextField(
            controller: controller.emailController,
            hintText: AppString.addContactEmailHint,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icon(
              Icons.email_outlined,
              color: AppColor.primaryColor,
              size: 20.sp,
            ),
            validator: controller.validateEmail,
            focusNode: controller.emailFocusNode,
            textStyle: TextStyle(
              fontSize: 15.sp,
              color: AppColor.darkGrey,
              fontWeight: FontWeight.w500,
            ),
            onSubmitted: (_) => controller.addContact(),
          ),
          SizedBox(height: Spacing.md),
          _buildSuggestionSection(controller),
        ],
      ),
    );
  }

  Widget _buildSuggestionSection(AddContactController controller) {
    return Obx(
      () {
        final hasData = controller.suggestions.isNotEmpty;
        final loading = controller.isSearching.value;
        if (!hasData && !loading) return const SizedBox.shrink();

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
            children: [
              Padding(
                padding: EdgeInsets.all(Spacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText(
                      text: 'Matching users',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColor.darkGrey,
                    ),
                    if (loading)
                      SizedBox(
                        width: 16.w,
                        height: 16.h,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColor.primaryColor,
                        ),
                      ),
                  ],
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 300.h),
                child: hasData ? _buildSuggestionList(controller) : _buildEmptySuggestionsState(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptySuggestionsState() {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.xl,
      ),
      child: Column(
        children: [
          Icon(
            Icons.person_search_outlined,
            size: 40.sp,
            color: AppColor.greyColor.withOpacity(0.5),
          ),
          SizedBox(height: Spacing.sm),
          AppText(
            text: AppString.noUsersFound,
            fontSize: 12.sp,
            color: AppColor.greyColor,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionList(AddContactController controller) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: Spacing.md),
      itemCount: controller.suggestions.length,
      separatorBuilder: (context, index) => SizedBox(height: Spacing.xs),
      itemBuilder: (context, index) {
        final user = controller.suggestions[index];
        return _buildSuggestionItem(controller, user);
      },
    );
  }

  Widget _buildSuggestionItem(AddContactController controller, UserModel user) {
    return InkWell(
      onTap: () => controller.selectSuggestion(user),
      borderRadius: BorderRadius.circular(6.r),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Spacing.sm,
          vertical: Spacing.xs,
        ),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(
            color: AppColor.lightGrey.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            _buildContactAvatar(user),
            SizedBox(width: Spacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText(
                    text: user.name,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColor.darkGrey,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 1.h),
                  AppText(
                    text: user.email,
                    fontSize: 11.sp,
                    color: AppColor.greyColor,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: Spacing.sm),
            Icon(
              Icons.north_west,
              size: 16.sp,
              color: AppColor.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactAvatar(UserModel user) {
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
      child: user.profileImage != null && user.profileImage!.startsWith('http')
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: user.profileImage!,
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
                      text: user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
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
                      text: user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColor.whiteColor,
                    ),
                  ),
                ),
              ),
            )
          : Center(
              child: AppText(
                text: user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.whiteColor,
              ),
            ),
    );
  }

  Widget _buildAddContactButton(AddContactController controller) {
    return Obx(
      () => CustomButton(
        text: AppString.addContact,
        onPressed: controller.isAdding.value ? () {} : () => controller.addContact(),
        isLoading: controller.isAdding.value,
        backgroundColor: AppColor.primaryColor,
        borderRadius: 8,
        height: 44.h,
      ),
    );
  }
}
