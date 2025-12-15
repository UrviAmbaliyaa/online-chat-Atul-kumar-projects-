import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:online_chat/features/home/controller/calling_controller.dart';
import 'package:online_chat/features/home/models/group_chat_model.dart';
import 'package:online_chat/features/home/models/user_model.dart';
import 'package:online_chat/utils/app_color.dart';
import 'package:online_chat/utils/app_profile_image.dart';
import 'package:online_chat/utils/app_snackbar.dart';
import 'package:online_chat/utils/app_spacing.dart';
import 'package:online_chat/utils/app_string.dart';
import 'package:online_chat/utils/app_text.dart';

class CallingScreen extends StatelessWidget {
  final UserModel? user; // For one-to-one call
  final GroupChatModel? group; // For group call
  final bool isIncoming; // Whether it's an incoming call
  final String chatId; // Whether it's an incoming call
  final bool isVideoCall; // Whether it's a video call

  const CallingScreen({
    super.key,
    this.user,
    this.group,
    required this.chatId,
    this.isIncoming = false,
    this.isVideoCall = false,
  });

  @override
  Widget build(BuildContext context) {
    try {
      final controller = Get.put(CallingController(
        user: user,
        chatId: chatId,
        group: group,
        isIncoming: isIncoming,
        isVideoCall: isVideoCall,
      ));
      ever(controller.callState, (CallState state) {
        if (state == CallState.failed) {
          _handleCallFailure(controller);
        } else if (state == CallState.ended) {
          _handleCallEnded(controller);
        }
      });
      return PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: AppColor.blackColor,
          body: Stack(
            children: [
              // Background with gradient
              _buildBackground(),
              // Video grid for group calls or local video
              // Obx(
              //   () => controller.isVideoCall ? _buildVideoGrid(controller) : const SizedBox.shrink(),
              // ),
              // Main content overlay
              _buildMainContent(controller),
              // Control buttons at bottom
              _buildControlButtons(controller),
            ],
          ),
        ),
      );
    } catch (e, stackTrace) {
      developer.log(
        'Error building CallingScreen: $e',
        error: e,
        stackTrace: stackTrace,
      );

      // Show error and return error widget
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppSnackbar.error(
          message: 'Failed to load call screen. Please try again.',
        );
        Get.back();
      });

      return Scaffold(
        backgroundColor: AppColor.blackColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: AppColor.redColor,
                size: 64.sp,
              ),
              SizedBox(height: Spacing.lg),
              AppText(
                text: 'Unable to start call',
                fontSize: 18.sp,
                color: AppColor.whiteColor,
                fontWeight: FontWeight.w600,
              ),
              SizedBox(height: Spacing.sm),
              AppText(
                text: 'Please try again',
                fontSize: 14.sp,
                color: AppColor.whiteColor.withOpacity(0.7),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _handleCallFailure(CallingController controller) {
    developer.log(
      'Call failed',
      name: 'CallingScreen',
    );
    // Error message is already shown by controller
    // Auto-close after a delay
    Future.delayed(const Duration(seconds: 3), () {
      if (controller.callState.value == CallState.failed) {
        Get.back();
      }
    });
  }

  void _handleCallEnded(CallingController controller) {
    developer.log(
      'Call ended',
      name: 'CallingScreen',
    );
    // Auto-close when call ends
    Future.delayed(const Duration(seconds: 1), () {
      if (controller.callState.value == CallState.ended) {
        Get.back();
      }
    });
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColor.primaryColor.withOpacity(0.95),
            AppColor.secondaryColor.withOpacity(0.9),
            AppColor.blackColor.withOpacity(0.95),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Animated circles for visual effect
          Positioned(
            top: -100.h,
            right: -100.w,
            child: Container(
              width: 300.w,
              height: 300.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColor.whiteColor.withOpacity(0.05),
              ),
            )
                .animate(onPlay: (controller) => controller.repeat())
                .scale(
                    duration: 3000.ms,
                    begin: const Offset(1, 1),
                    end: const Offset(1.5, 1.5))
                .fade(duration: 3000.ms, begin: 0.1, end: 0.0),
          ),
          Positioned(
            bottom: -150.h,
            left: -150.w,
            child: Container(
              width: 400.w,
              height: 400.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColor.accentColor.withOpacity(0.05),
              ),
            )
                .animate(onPlay: (controller) => controller.repeat())
                .scale(
                    duration: 4000.ms,
                    begin: const Offset(1, 1),
                    end: const Offset(1.3, 1.3))
                .fade(duration: 4000.ms, begin: 0.1, end: 0.0),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoGrid(CallingController controller) {
    if (controller.group != null) {
      // Group call - show grid of participants
      return Obx(
        () {
          if (controller.remoteUsers.isEmpty && !controller.isConnected.value) {
            return const SizedBox.shrink();
          }

          final allUsers = [
            if (controller.isVideoCall &&
                controller.isVideoEnabled.value &&
                controller.localUid != null)
              controller.localUid!,
            ...controller.remoteUsers,
          ];

          if (allUsers.isEmpty) {
            return const SizedBox.shrink();
          }

          return GridView.builder(
            padding: EdgeInsets.all(Spacing.md),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: allUsers.length <= 2 ? 1 : 2,
              crossAxisSpacing: Spacing.sm,
              mainAxisSpacing: Spacing.sm,
              childAspectRatio: 1,
            ),
            itemCount: allUsers.length,
            itemBuilder: (context, index) {
              final uid = allUsers[index];
              final isLocal =
                  controller.localUid != null && uid == controller.localUid;

              return Container(
                decoration: BoxDecoration(
                  color: AppColor.darkGrey,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.blackColor.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: isLocal
                          ? controller.getLocalVideoView()
                          : controller.getRemoteVideoView(uid),
                    ),
                    if (isLocal)
                      Positioned(
                        top: Spacing.xs,
                        right: Spacing.xs,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Spacing.xs,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.blackColor.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: AppText(
                            text: AppString.you,
                            fontSize: 10.sp,
                            color: AppColor.whiteColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      );
    } else {
      // One-to-one call - show remote video with local video overlay
      return Obx(
        () {
          if (!controller.isVideoCall || !controller.isConnected.value) {
            return const SizedBox.shrink();
          }

          return Stack(
            children: [
              // Remote video (full screen)
              Positioned.fill(
                child: Container(
                  margin: EdgeInsets.all(Spacing.md),
                  decoration: BoxDecoration(
                    color: AppColor.darkGrey,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.blackColor.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: controller.remoteUsers.isNotEmpty
                        ? controller
                            .getRemoteVideoView(controller.remoteUsers.first)
                        : Container(
                            color: AppColor.darkGrey,
                            child: Center(
                              child: Icon(
                                Icons.person,
                                color: AppColor.whiteColor.withOpacity(0.5),
                                size: 80.sp,
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              // Local video (small overlay)
              if (controller.isVideoEnabled.value)
                Positioned(
                  top: Spacing.xl,
                  right: Spacing.xl,
                  child: Container(
                    width: 120.w,
                    height: 160.h,
                    decoration: BoxDecoration(
                      color: AppColor.darkGrey,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: AppColor.whiteColor,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.blackColor.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: controller.getLocalVideoView(),
                    ),
                  ),
                ),
            ],
          );
        },
      );
    }
  }

  Widget _buildMainContent(CallingController controller) {
    final isGroup = controller.group != null;
    final title = isGroup
        ? controller.group?.name ?? AppString.groupCall
        : controller.user?.name ?? AppString.calling;
    final image =
        isGroup ? controller.group?.groupImage : controller.user?.profileImage;

    return Obx(
      () {
        // Hide main content when video call is active and connected
        if (controller.isVideoCall &&
            controller.isConnected.value &&
            controller.remoteUsers.isNotEmpty) {
          return const SizedBox.shrink();
        }

        return SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                SizedBox(height: Spacing.xl * 2),
                // Status text with animation
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Spacing.md,
                    vertical: Spacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.whiteColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: AppColor.whiteColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: AppText(
                    text: controller.getCallStatus(),
                    fontSize: 14.sp,
                    color: AppColor.whiteColor.withOpacity(0.95),
                    fontWeight: FontWeight.w600,
                  ),
                )
                    .animate(onPlay: (controller) => controller.repeat())
                    .fade(duration: 1500.ms, begin: 0.7, end: 1.0)
                    .scale(
                        duration: 1500.ms,
                        begin: const Offset(0.98, 0.98),
                        end: const Offset(1, 1)),
                SizedBox(height: Spacing.xl * 2),
                // Profile image with pulsing animation
                _buildProfileImage(controller, title, image, isGroup)
                    .animate(onPlay: (controller) => controller.repeat())
                    .scale(
                      duration: 2000.ms,
                      begin: const Offset(1, 1),
                      end: const Offset(1.05, 1.05),
                      curve: Curves.easeInOut,
                    )
                    .then()
                    .scale(
                      duration: 2000.ms,
                      begin: const Offset(1.05, 1.05),
                      end: const Offset(1, 1),
                      curve: Curves.easeInOut,
                    ),
                SizedBox(height: Spacing.xl),
                // Name
                AppText(
                  text: title,
                  fontSize: 32.sp,
                  color: AppColor.whiteColor,
                  fontWeight: FontWeight.w700,
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideY(
                    begin: 0.2, end: 0, duration: 500.ms, delay: 200.ms),
                SizedBox(height: Spacing.sm),
                // Additional info
                if (isGroup)
                  Obx(
                    () => AppText(
                      text:
                          '${controller.remoteUsers.length + (controller.isVideoCall && controller.isVideoEnabled.value ? 1 : 0)} ${AppString.participants}',
                      fontSize: 16.sp,
                      color: AppColor.whiteColor.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else
                  AppText(
                    text: controller.user?.email ?? '',
                    fontSize: 16.sp,
                    color: AppColor.whiteColor.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                SizedBox(height: Spacing.xl * 1.5),
                // Call duration (when connected)
                Obx(
                  () => controller.isConnected.value
                      ? _buildCallDuration(controller)
                          .animate()
                          .fadeIn(duration: 300.ms)
                          .scale(
                              begin: const Offset(0.9, 0.9), duration: 300.ms)
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileImage(
    CallingController controller,
    String title,
    String? image,
    bool isGroup,
  ) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer pulsing ring
        Container(
          width: 220.w,
          height: 220.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColor.whiteColor.withOpacity(0.2),
              width: 2,
            ),
          ),
        )
            .animate(onPlay: (controller) => controller.repeat())
            .scale(
                duration: 2000.ms,
                begin: const Offset(1, 1),
                end: const Offset(1.15, 1.15))
            .fade(duration: 2000.ms, begin: 0.3, end: 0.0),
        // Middle ring
        Container(
          width: 210.w,
          height: 210.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColor.whiteColor.withOpacity(0.3),
              width: 2,
            ),
          ),
        )
            .animate(onPlay: (controller) => controller.repeat())
            .scale(
                duration: 2000.ms,
                begin: const Offset(1, 1),
                end: const Offset(1.1, 1.1),
                delay: 300.ms)
            .fade(duration: 2000.ms, begin: 0.4, end: 0.0, delay: 300.ms),
        // Profile image
        Container(
          width: 200.w,
          height: 200.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColor.whiteColor.withOpacity(0.4),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
          child: AppProfileImage(
            width: 200.w,
            height: 200.h,
            username: title,
            imageUrl: image,
            fallbackIcon: isGroup ? Icons.group : Icons.person,
            fontSize: 70.sp,
            borderWidth: 5,
            borderColor: AppColor.whiteColor,
          ),
        ),
      ],
    );
  }

  Widget _buildCallDuration(CallingController controller) {
    return Obx(
      () => Container(
        padding: EdgeInsets.symmetric(
          horizontal: Spacing.lg,
          vertical: Spacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColor.whiteColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(25.r),
          border: Border.all(
            color: AppColor.whiteColor.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColor.blackColor.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.call,
              color: AppColor.whiteColor,
              size: 16.sp,
            ),
            SizedBox(width: Spacing.xs),
            AppText(
              text: controller.getCallDuration(),
              fontSize: 18.sp,
              color: AppColor.whiteColor,
              fontWeight: FontWeight.w700,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButtons(CallingController controller) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.xl,
            vertical: Spacing.xl * 1.5,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                AppColor.blackColor.withOpacity(0.9),
              ],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Mute button
              Obx(
                () => _buildControlButton(
                  icon: controller.isMuted.value ? Icons.mic_off : Icons.mic,
                  onPressed: controller.toggleMute,
                  backgroundColor: controller.isMuted.value
                      ? AppColor.redColor.withOpacity(0.8)
                      : AppColor.whiteColor.withOpacity(0.2),
                  iconColor: AppColor.whiteColor,
                  isActive: controller.isMuted.value,
                ),
              ),
              // Speaker button
              Obx(
                () => _buildControlButton(
                  icon: controller.isSpeakerOn.value
                      ? Icons.volume_up
                      : Icons.volume_down,
                  onPressed: controller.toggleSpeaker,
                  backgroundColor: controller.isSpeakerOn.value
                      ? AppColor.accentColor.withOpacity(0.8)
                      : AppColor.whiteColor.withOpacity(0.2),
                  iconColor: AppColor.whiteColor,
                  isActive: controller.isSpeakerOn.value,
                ),
              ),
              // Video toggle (for video calls)
              // Obx(
              //   () => controller.isVideoCall
              //       ? _buildControlButton(
              //           icon: controller.isVideoEnabled.value
              //               ? Icons.videocam
              //               : Icons.videocam_off,
              //           onPressed: controller.toggleVideo,
              //           backgroundColor: controller.isVideoEnabled.value
              //               ? AppColor.blueColor.withOpacity(0.8)
              //               : AppColor.whiteColor.withOpacity(0.2),
              //           iconColor: AppColor.whiteColor,
              //           isActive: controller.isVideoEnabled.value,
              //         )
              //       : const SizedBox.shrink(),
              // ),
              // End call button
              _buildControlButton(
                icon: Icons.call_end,
                onPressed: controller.endCall,
                backgroundColor: AppColor.redColor,
                iconColor: AppColor.whiteColor,
                size: 70.w,
                isEndCall: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color iconColor,
    double? size,
    bool isActive = false,
    bool isEndCall = false,
  }) {
    final buttonSize = size ?? 60.w;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: isEndCall
                  ? AppColor.redColor.withOpacity(0.5)
                  : AppColor.blackColor.withOpacity(0.4),
              blurRadius: isEndCall ? 20 : 15,
              spreadRadius: isEndCall ? 5 : 3,
            ),
          ],
          border: isActive
              ? Border.all(
                  color: iconColor.withOpacity(0.5),
                  width: 2,
                )
              : null,
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: (buttonSize * 0.45).sp,
        ),
      ).animate().scale(duration: 100.ms).then().scale(
          duration: 100.ms,
          begin: const Offset(1.1, 1.1),
          end: const Offset(1, 1)),
    );
  }
}
