import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:online_chat/utils/app_color.dart';
import 'package:online_chat/utils/app_string.dart';
import 'package:online_chat/utils/app_text.dart';

class ForceLogoutDialog extends StatelessWidget {
  final VoidCallback onLogout;

  const ForceLogoutDialog({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 25.r),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 0.r),
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: AppColor.whiteColor,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Info Icon
              Container(
                width: 80.w,
                height: 80.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.primaryColor.withValues(alpha: 0.1),
                ),
                child: Icon(
                  Icons.login_rounded,
                  color: AppColor.primaryColor,
                  size: 48.sp,
                ),
              ),
              SizedBox(height: 18.h),
              // Title
              AppText(
                text: AppString.singleSessionTitle,
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: AppColor.darkGrey,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),
              // Message
              AppText(
                text: AppString.singleSessionMessage,
                fontSize: 14.sp,
                color: AppColor.greyColor,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),
              // Logout Button
              SizedBox(
                width: double.infinity,
                height: 44.h,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      onLogout();
                    },
                    borderRadius: BorderRadius.circular(8.r),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        color: AppColor.primaryColor,
                        boxShadow: [
                          BoxShadow(
                            color: AppColor.primaryColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            spreadRadius: 0,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: AppText(
                          text: AppString.forceLogout,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColor.whiteColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              // No cancel option; dialog is non-dismissable
            ],
          ),
        ),
      ),
    );
  }
}
