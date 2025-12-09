import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:online_chat/features/home/controller/home_controller.dart';
import 'package:online_chat/features/home/widgets/groups_tab_widget.dart';
import 'package:online_chat/features/home/widgets/users_tab_widget.dart';
import 'package:online_chat/navigations/app_navigation.dart';
import 'package:online_chat/navigations/routes.dart';
import 'package:online_chat/utils/app_color.dart';
import 'package:online_chat/utils/app_spacing.dart';
import 'package:online_chat/utils/app_string.dart';
import 'package:online_chat/utils/app_text.dart';
import 'package:online_chat/utils/app_local_storage.dart';

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
            ? Center(
                child: CircularProgressIndicator(
                  color: AppColor.primaryColor,
                ),
              )
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

  PreferredSizeWidget _buildCustomAppBar(BuildContext context, HomeController controller) {
    final userName = AppLocalStorage.getUserName();
    final userEmail = AppLocalStorage.getUserEmail();
    final userProfileImage = AppLocalStorage.getUserProfileImage();

    return AppBar(
      backgroundColor: AppColor.whiteColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
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
              child: ClipOval(
                child: userProfileImage.isNotEmpty && !userProfileImage.startsWith('http')
                    ? Image.file(
                        File(userProfileImage),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
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
                        },
                      )
                    : Container(
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
                        ),
                        child: Center(
                          child: AppText(
                            text: userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColor.whiteColor,
                          ),
                        ),
                      ),
              ),
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
                  text: userEmail.isNotEmpty ? userEmail : 'email@example.com',
                  fontSize: 12.sp,
                  color: AppColor.greyColor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
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

}
