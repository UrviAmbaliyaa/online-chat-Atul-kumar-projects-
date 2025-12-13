import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:online_chat/utils/app_color.dart';
import 'package:online_chat/utils/app_string.dart';
import 'package:online_chat/utils/app_text.dart';

class DeleteMessageConfirmationDialog extends StatelessWidget {
  final VoidCallback onDelete;

  const DeleteMessageConfirmationDialog({
    super.key,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
            // Warning Icon
            Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColor.lightRedColor.withOpacity(0.1),
              ),
              child: Icon(
                Icons.warning_rounded,
                color: AppColor.lightRedColor,
                size: 48.sp,
              ),
            ),
            SizedBox(height: 18.h),
            // Title
            AppText(
              text: AppString.deleteMessage,
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: AppColor.darkGrey,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            // Message
            AppText(
              text: AppString.deleteMessageConfirmation,
              fontSize: 14.sp,
              color: AppColor.greyColor,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            // Buttons
            Row(
              children: [
                // Cancel Button
                Expanded(
                  child: Container(
                    height: 44.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: AppColor.greyColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Get.back(),
                        borderRadius: BorderRadius.circular(8.r),
                        child: Center(
                          child: AppText(
                            text: AppString.cancel,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColor.darkGrey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                // Delete Button
                Expanded(
                  child: Container(
                    height: 44.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      color: AppColor.lightRedColor,
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.lightRedColor.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Get.back();
                          onDelete();
                        },
                        borderRadius: BorderRadius.circular(8.r),
                        child: Center(
                          child: AppText(
                            text: AppString.delete,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColor.whiteColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

