import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:online_chat/utils/app_color.dart';
import 'package:online_chat/utils/app_string.dart';
import 'package:online_chat/utils/app_text.dart';

enum SnackbarType {
  success,
  error,
  info,
  warning,
}

class AppSnackbar {
  /// Show success snackbar with green background
  static void showSuccess({
    required String title,
    String? message,
    Duration duration = const Duration(seconds: 3),
    SnackPosition position = SnackPosition.BOTTOM,
  }) {
    _showSnackbar(
      title: title,
      message: message,
      type: SnackbarType.success,
      duration: duration,
      position: position,
    );
  }

  /// Show error snackbar with red background
  static void showError({
    required String title,
    String? message,
    Duration duration = const Duration(seconds: 3),
    SnackPosition position = SnackPosition.BOTTOM,
  }) {
    _showSnackbar(
      title: title,
      message: message,
      type: SnackbarType.error,
      duration: duration,
      position: position,
    );
  }

  /// Show info snackbar with blue background
  static void showInfo({
    required String title,
    String? message,
    Duration duration = const Duration(seconds: 3),
    SnackPosition position = SnackPosition.BOTTOM,
  }) {
    _showSnackbar(
      title: title,
      message: message,
      type: SnackbarType.info,
      duration: duration,
      position: position,
    );
  }

  /// Show warning snackbar with orange/yellow background
  static void showWarning({
    required String title,
    String? message,
    Duration duration = const Duration(seconds: 3),
    SnackPosition position = SnackPosition.BOTTOM,
  }) {
    _showSnackbar(
      title: title,
      message: message,
      type: SnackbarType.warning,
      duration: duration,
      position: position,
    );
  }

  // Convenience methods using AppString

  /// Show success snackbar with default title from AppString
  static void success({
    String? message,
    Duration duration = const Duration(seconds: 3),
    SnackPosition position = SnackPosition.BOTTOM,
  }) {
    showSuccess(
      title: AppString.successTitle,
      message: message,
      duration: duration,
      position: position,
    );
  }

  /// Show error snackbar with default title from AppString
  static void error({
    String? message,
    Duration duration = const Duration(seconds: 3),
    SnackPosition position = SnackPosition.BOTTOM,
  }) {
    showError(
      title: AppString.errorTitle,
      message: message,
      duration: duration,
      position: position,
    );
  }

  /// Show info snackbar with default title from AppString
  static void info({
    String? message,
    Duration duration = const Duration(seconds: 3),
    SnackPosition position = SnackPosition.BOTTOM,
  }) {
    showInfo(
      title: AppString.infoTitle,
      message: message,
      duration: duration,
      position: position,
    );
  }

  /// Show warning snackbar with default title from AppString
  static void warning({
    String? message,
    Duration duration = const Duration(seconds: 3),
    SnackPosition position = SnackPosition.BOTTOM,
  }) {
    showWarning(
      title: AppString.warningTitle,
      message: message,
      duration: duration,
      position: position,
    );
  }

  /// Internal method to show snackbar
  static void _showSnackbar({
    required String title,
    String? message,
    required SnackbarType type,
    required Duration duration,
    required SnackPosition position,
  }) {
    final color = _getColorForType(type);
    final icon = _getIconForType(type);

    Get.snackbar(
      '',
      '',
      titleText: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColor.whiteColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              icon,
              color: AppColor.whiteColor,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(
                  text: title,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColor.whiteColor,
                ),
                if (message != null && message.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  AppText(
                    text: message,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColor.whiteColor.withOpacity(0.9),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      messageText: const SizedBox.shrink(),
      backgroundColor: color,
      colorText: AppColor.whiteColor,
      snackPosition: position,
      duration: duration,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      borderRadius: 12.r,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      boxShadows: [
        BoxShadow(
          color: color.withOpacity(0.3),
          blurRadius: 10,
          spreadRadius: 2,
          offset: const Offset(0, 4),
        ),
      ],
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
      animationDuration: const Duration(milliseconds: 400),
    );
  }

  /// Get color based on snackbar type
  static Color _getColorForType(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return AppColor.accentColor; // Green color
      case SnackbarType.error:
        return AppColor.redColor; // Red color
      case SnackbarType.info:
        return AppColor.blueColor; // Blue color
      case SnackbarType.warning:
        return Colors.orange; // Orange color
    }
  }

  /// Get icon based on snackbar type
  static IconData _getIconForType(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return Icons.check_circle;
      case SnackbarType.error:
        return Icons.error;
      case SnackbarType.info:
        return Icons.info;
      case SnackbarType.warning:
        return Icons.warning;
    }
  }
}

