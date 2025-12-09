import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:online_chat/utils/app_color.dart';

import 'app_text.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isLoading;
  final double? width;
  final double? height;
  final double borderRadius;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enableAnimation;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.isLoading = false,
    this.width,
    this.height,
    this.borderRadius = 12,
    this.prefixIcon,
    this.suffixIcon,
    this.enableAnimation = true,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = backgroundColor ?? AppColor.primaryColor;

    Widget buttonContent = Container(
      width: width ?? double.infinity,
      height: height ?? 50.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius.r),
        gradient: enableAnimation && !isLoading
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColor.primaryColor,
                  AppColor.secondaryColor,
                  AppColor.accentColor,
                ],
              )
            : null,
        color: enableAnimation && !isLoading ? null : baseColor,
        boxShadow: [
          BoxShadow(
            color: baseColor.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius.r),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius.r),
            ),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(
                          textColor ?? AppColor.whiteColor,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (prefixIcon != null) ...[
                          prefixIcon!,
                          SizedBox(width: 8.w),
                        ],
                        AppText(
                          text: text,
                          color: textColor ?? AppColor.whiteColor,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        if (suffixIcon != null) ...[
                          SizedBox(width: 8.w),
                          suffixIcon!,
                        ],
                      ],
                    ),
            ),
          ),
        ),
      ),
    );

    // Apply animations matching the logo
    if (enableAnimation && !isLoading) {
      return buttonContent
          .animate(onPlay: (controller) => controller.repeat())
          .shimmer(
            duration: 2000.ms,
            color: AppColor.whiteColor.withOpacity(0.3),
          )
          .then()
          .scale(
            duration: 1000.ms,
            begin: const Offset(1, 1),
            end: const Offset(1.02, 1.02),
          )
          .then()
          .scale(
            duration: 1000.ms,
            begin: const Offset(1.02, 1.02),
            end: const Offset(1, 1),
          );
    }

    return buttonContent;
  }
}
