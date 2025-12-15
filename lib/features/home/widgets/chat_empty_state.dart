import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:online_chat/utils/app_color.dart';
import 'package:online_chat/utils/app_spacing.dart';
import 'package:online_chat/utils/app_string.dart';
import 'package:online_chat/utils/app_text.dart';

class ChatEmptyState extends StatelessWidget {
  const ChatEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(Spacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Hello Icon with gradient and floating animation
              Container(
                width: 140.w,
                height: 140.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColor.primaryColor.withOpacity(0.2),
                      AppColor.primaryColor.withOpacity(0.1),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.primaryColor.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 100.w,
                    height: 100.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColor.primaryColor.withOpacity(0.15),
                    ),
                    child: Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 56.sp,
                      color: AppColor.primaryColor,
                    ),
                  ),
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .fadeIn(duration: 800.ms, delay: 200.ms)
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1, 1),
                    duration: 800.ms,
                    delay: 200.ms,
                    curve: Curves.easeOutBack,
                  )
                  .then()
                  .moveY(
                    begin: 0,
                    end: -10,
                    duration: 2000.ms,
                    curve: Curves.easeInOut,
                  )
                  .then()
                  .moveY(
                    begin: -10,
                    end: 0,
                    duration: 2000.ms,
                    curve: Curves.easeInOut,
                  ),
              SizedBox(height: Spacing.xl + Spacing.md),
              // Hello Text with gradient effect and fade animation
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    AppColor.primaryColor,
                    AppColor.primaryColor.withOpacity(0.8),
                  ],
                ).createShader(bounds),
                child: AppText(
                  text: AppString.hello,
                  fontSize: 42.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 400.ms)
                  .slideY(
                    begin: 0.2,
                    end: 0,
                    duration: 600.ms,
                    delay: 400.ms,
                    curve: Curves.easeOut,
                  )
                  .shimmer(
                    duration: 2000.ms,
                    delay: 1000.ms,
                    color: Colors.white.withOpacity(0.3),
                  ),
              SizedBox(height: Spacing.md),
              // Subtitle with fade animation
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Spacing.xl * 2),
                child: AppText(
                  text: AppString.noMessagesYet,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColor.darkGrey,
                  textAlign: TextAlign.center,
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 600.ms).slideY(
                    begin: 0.2,
                    end: 0,
                    duration: 600.ms,
                    delay: 600.ms,
                    curve: Curves.easeOut,
                  ),
              SizedBox(height: Spacing.sm),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Spacing.xl * 2),
                child: AppText(
                  text: AppString.startConversation,
                  fontSize: 14.sp,
                  color: AppColor.greyColor,
                  textAlign: TextAlign.center,
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 800.ms).slideY(
                    begin: 0.2,
                    end: 0,
                    duration: 600.ms,
                    delay: 800.ms,
                    curve: Curves.easeOut,
                  ),
              SizedBox(height: Spacing.xl * 2),
              // Animated decorative dots with pulse effect
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (index) => Container(
                    width: 8.w,
                    height: 8.h,
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColor.primaryColor.withOpacity(0.3),
                    ),
                  )
                      .animate(onPlay: (controller) => controller.repeat())
                      .fadeIn(
                        duration: 400.ms,
                        delay: (1000 + index * 200).ms,
                      )
                      .scale(
                        begin: const Offset(0, 0),
                        end: const Offset(1, 1),
                        duration: 400.ms,
                        delay: (1000 + index * 200).ms,
                        curve: Curves.easeOutBack,
                      )
                      .then()
                      .scale(
                        begin: const Offset(1, 1),
                        end: const Offset(1.3, 1.3),
                        duration: 1000.ms,
                        delay: (1400 + index * 200).ms,
                        curve: Curves.easeInOut,
                      )
                      .then()
                      .scale(
                        begin: const Offset(1.3, 1.3),
                        end: const Offset(1, 1),
                        duration: 1000.ms,
                        curve: Curves.easeInOut,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
