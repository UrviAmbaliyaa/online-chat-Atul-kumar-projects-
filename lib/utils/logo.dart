import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:online_chat/utils/app_color.dart';

class AppLogo extends StatefulWidget {
  const AppLogo({super.key});

  @override
  State<AppLogo> createState() => _AppLogoState();
}

class _AppLogoState extends State<AppLogo> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 120.w,
        height: 120.h,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColor.primaryColor,
              AppColor.secondaryColor,
              AppColor.accentColor,
            ],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColor.primaryColor.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Icon(
          Icons.chat_bubble_outline,
          size: 60.sp,
          color: AppColor.whiteColor,
        ),
      )
          .animate(onPlay: (controller) => controller.repeat())
          .shimmer(
              duration: 2000.ms, color: AppColor.whiteColor.withOpacity(0.3))
          .then()
          .scale(
              duration: 1000.ms,
              begin: const Offset(1, 1),
              end: const Offset(1.05, 1.05))
          .then()
          .scale(
              duration: 1000.ms,
              begin: const Offset(1.05, 1.05),
              end: const Offset(1, 1)),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: 100.ms)
        .slideY(begin: -0.2, end: 0, duration: 600.ms, delay: 100.ms);
  }
}
