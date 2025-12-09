import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:online_chat/utils/app_color.dart';

class SpeedDialOption {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const SpeedDialOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class CustomSpeedDial extends StatelessWidget {
  final List<SpeedDialOption> options;
  final Color? backgroundColor;
  final Color? iconColor;
  final SpeedDialDirection direction;
  final double? buttonSize;
  final double? childrenButtonSize;
  final double spacing;
  final double spaceBetweenChildren;

  const CustomSpeedDial({
    super.key,
    required this.options,
    this.backgroundColor,
    this.iconColor,
    this.direction = SpeedDialDirection.up,
    this.buttonSize,
    this.childrenButtonSize,
    this.spacing = 16.0,
    this.spaceBetweenChildren = 14.0,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColor.primaryColor;
    final iconClr = iconColor ?? AppColor.whiteColor;

    return SpeedDial(
      icon: Icons.add,
      animatedIconTheme: IconThemeData(
        size: 24.sp,
        color: iconClr,
      ),
      backgroundColor: bgColor,
      foregroundColor: iconClr,
      overlayColor: AppColor.whiteColor,
      overlayOpacity: 0.5,
      spacing: spacing.h,
      spaceBetweenChildren: spaceBetweenChildren.h,
      direction: direction,
      elevation: 8,
      buttonSize: buttonSize != null
          ? Size(buttonSize!, buttonSize!)
          : Size(56.w, 56.h),
      childrenButtonSize: childrenButtonSize != null
          ? Size(childrenButtonSize!, childrenButtonSize!)
          : Size(50.w, 50.h),
      activeChild: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColor.primaryColor.withOpacity(0.3),
              blurRadius: 12,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.close,
          color: iconClr,
          size: 24.sp,
        ),
      ),
      children: options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;

        return SpeedDialChild(
          child: Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: AppColor.primaryColor,
              // gradient: LinearGradient(
              //   begin: Alignment.topLeft,
              //   end: Alignment.bottomRight,
              //   colors: [
              //     AppColor.primaryColor,
              //     AppColor.secondaryColor,
              //     AppColor.accentColor,
              //   ],
              // ),
              // boxShadow: [
              //   BoxShadow(
              //     color: AppColor.primaryColor.withOpacity(0.3),
              //     blurRadius: 12,
              //     spreadRadius: 0,
              //     offset: const Offset(0, 4),
              //   ),
              // ],
              // boxShadow: [
              //   BoxShadow(
              //     color: bgColor.withOpacity(0.4),
              //     blurRadius: 12,
              //     spreadRadius: 0,
              //     offset: const Offset(0, 4),
              //   ),
              //   BoxShadow(
              //     color: bgColor.withOpacity(0.2),
              //     blurRadius: 6,
              //     spreadRadius: 0,
              //     offset: const Offset(0, 2),
              //   ),
              // ],
            ),
            child: Icon(
              option.icon,
              color: iconClr,
              size: 24.sp,
            ),
          )
              .animate()
              .fadeIn(
                duration: 300.ms,
                delay: (index * 100).ms,
              )
              .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1, 1),
                duration: 300.ms,
                delay: (index * 100).ms,
                curve: Curves.easeOutBack,
              ),
          backgroundColor: Colors.transparent,
          label: option.label,
          labelStyle: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: AppColor.darkGrey,
            letterSpacing: 0.3,
          ),
          labelBackgroundColor: AppColor.whiteColor,
          elevation: 0,
          onTap: option.onTap,
        );
      }).toList(),
    );
  }
}
