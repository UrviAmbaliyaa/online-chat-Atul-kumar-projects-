import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:online_chat/features/home/controller/home_controller.dart';
import 'package:online_chat/features/home/widgets/groups_tab_widget.dart';
import 'package:online_chat/features/home/widgets/users_tab_widget.dart';
import 'package:online_chat/navigations/app_navigation.dart';
import 'package:online_chat/navigations/routes.dart';
import 'package:online_chat/utils/app_color.dart';
import 'package:online_chat/utils/app_local_storage.dart';
import 'package:online_chat/utils/app_preference.dart';
import 'package:online_chat/utils/app_spacing.dart';
import 'package:online_chat/utils/app_string.dart';
import 'package:online_chat/utils/app_text.dart';
import 'package:shimmer_skeleton/shimmer_skeleton.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Scaffold(
      backgroundColor: AppColor.ScaffoldColor,
      appBar: _buildCustomAppBar(context, controller),
      body: Obx(
        () => controller.isLoading.value
            ? _buildShimmerLoader()
            : Column(
                children: [
                  // Tab Bar
                  _buildTabBar(controller),

                  // Content
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: controller.refresh,
                      color: AppColor.primaryColor,
                      child: Obx(
                        () => controller.selectedTab.value == 0
                            ? UsersTabWidget(controller: controller)
                            : GroupsTabWidget(controller: controller),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTabBar(HomeController controller) {
    return Container(
      color: AppColor.whiteColor,
      child: Row(
        children: [
          Expanded(
            child: _buildTabItem(
              controller: controller,
              index: 0,
              title: AppString.addedUsers,
              icon: Icons.person_outline,
            ),
          ),
          Expanded(
            child: _buildTabItem(
              controller: controller,
              index: 1,
              title: AppString.createdGroups,
              icon: Icons.group_outlined,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required HomeController controller,
    required int index,
    required String title,
    required IconData icon,
  }) {
    final isSelected = controller.selectedTab.value == index;

    return GestureDetector(
      onTap: () => controller.switchTab(index),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColor.primaryColor : AppColor.lightGrey,
              width: isSelected ? 3 : 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20.sp,
              color: isSelected ? AppColor.primaryColor : AppColor.greyColor,
            ),
            SizedBox(width: 8.w),
            AppText(
              text: title,
              fontSize: 14.sp,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? AppColor.primaryColor : AppColor.greyColor,
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildCustomAppBar(
      BuildContext context, HomeController controller) {
    return AppBar(
      backgroundColor: AppColor.whiteColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Obx(
        () {
          final currentUser = AppPreference.currentUser.value;
          final userName = currentUser?.name ?? AppLocalStorage.getUserName();
          final userEmail =
              currentUser?.email ?? AppLocalStorage.getUserEmail();
          final userProfileImage = currentUser?.profileImage ??
              (AppLocalStorage.getUserProfileImage().isNotEmpty
                  ? AppLocalStorage.getUserProfileImage()
                  : null);

          return Row(
            children: [
              // Profile Picture
              GestureDetector(
                onTap: () {
                  // TODO: Navigate to profile screen
                },
                child: Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColor.primaryColor,
                      width: 2,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: userProfileImage != null &&
                          userProfileImage.isNotEmpty &&
                          userProfileImage.startsWith('http')
                      ? CachedNetworkImage(
                          imageUrl: userProfileImage,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              _buildProfilePlaceholder(userName),
                          errorWidget: (context, url, error) =>
                              _buildProfilePlaceholder(userName),
                        )
                      : userProfileImage != null &&
                              userProfileImage.isNotEmpty &&
                              !userProfileImage.startsWith('http')
                          ? Image.file(
                              File(userProfileImage),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildProfilePlaceholder(userName);
                              },
                            )
                          : _buildProfilePlaceholder(userName),
                ),
              ),
              SizedBox(width: 12.w),
              // Name and Email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText(
                      text: userName.isNotEmpty ? userName : 'User',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColor.darkGrey,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    AppText(
                      text: userEmail.isNotEmpty
                          ? userEmail
                          : 'email@example.com',
                      fontSize: 12.sp,
                      color: AppColor.greyColor,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.settings_outlined,
            size: 24.sp,
            color: AppColor.darkGrey,
          ),
          onPressed: () {
            AppNavigation.toNamed(AppRoutes.settingsScreen);
          },
        ),
        SizedBox(width: 8.w),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1.h),
        child: Container(
          color: AppColor.lightGrey,
          height: 1.h,
        ),
      ),
    );
  }

  Widget _buildProfilePlaceholder(String userName) {
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
          text: userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: AppColor.whiteColor,
        ),
      ),
    );
  }

  Widget _buildShimmerLoader() {
    return Column(
      children: [
        // Tab Bar Shimmer
        Container(
          color: AppColor.whiteColor,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Row(
            children: [
              Expanded(
                child: ShimmerSkeleton(
                  child: Container(
                    width: double.infinity,
                    height: 20.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.r),
                      color: AppColor.lightGrey,
                    ),
                  ),
                  isLoading: true,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: ShimmerSkeleton(
                  child: Container(
                    width: double.infinity,
                    height: 20.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.r),
                      color: AppColor.lightGrey,
                    ),
                  ),
                  isLoading: true,
                ),
              ),
            ],
          ),
        ),
        // Content Shimmer
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(Spacing.md),
            itemCount: 5,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.only(bottom: Spacing.sm),
                padding: EdgeInsets.all(Spacing.md),
                decoration: BoxDecoration(
                  color: AppColor.whiteColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    ShimmerSkeleton(
                      child: Container(
                        width: 50.w,
                        height: 50.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColor.lightGrey,
                        ),
                      ),
                      isLoading: true,
                    ),
                    SizedBox(width: Spacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerSkeleton(
                            child: Container(
                              width: double.infinity,
                              height: 16.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4.r),
                                color: AppColor.lightGrey,
                              ),
                            ),
                            isLoading: true,
                          ),
                          SizedBox(height: 8.h),
                          ShimmerSkeleton(
                            child: Container(
                              width: 150.w,
                              height: 12.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4.r),
                                color: AppColor.lightGrey,
                              ),
                            ),
                            isLoading: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
