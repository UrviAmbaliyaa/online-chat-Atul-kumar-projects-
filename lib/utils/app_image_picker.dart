import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:online_chat/utils/app_color.dart';
import 'package:online_chat/utils/app_snackbar.dart';
import 'package:online_chat/utils/app_spacing.dart';
import 'package:online_chat/utils/app_string.dart';
import 'package:online_chat/utils/app_text.dart';

/// Common image picker utility class
/// Provides reusable image picking functionality throughout the app
class AppImagePicker {
  static final ImagePicker _imagePicker = ImagePicker();

  /// Pick image from gallery
  /// [maxWidth] - Maximum width for image (default: 800)
  /// [maxHeight] - Maximum height for image (default: 800)
  /// [imageQuality] - Image quality 0-100 (default: 80)
  /// Returns File if successful, null otherwise
  static Future<File?> pickImageFromGallery({
    double maxWidth = 800,
    double maxHeight = 800,
    int imageQuality = 80,
  }) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: imageQuality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      AppSnackbar.error(
        message: AppString.imagePickGalleryError,
      );
      return null;
    }
  }

  /// Pick image from camera
  /// [maxWidth] - Maximum width for image (default: 800)
  /// [maxHeight] - Maximum height for image (default: 800)
  /// [imageQuality] - Image quality 0-100 (default: 80)
  /// Returns File if successful, null otherwise
  static Future<File?> pickImageFromCamera({
    double maxWidth = 800,
    double maxHeight = 800,
    int imageQuality = 80,
  }) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: imageQuality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      AppSnackbar.error(
        message: AppString.imagePickCameraError,
      );
      return null;
    }
  }

  /// Pick multiple images from gallery
  /// [maxWidth] - Maximum width for images (default: 800)
  /// [maxHeight] - Maximum height for images (default: 800)
  /// [imageQuality] - Image quality 0-100 (default: 80)
  /// [limit] - Maximum number of images to pick (default: 10)
  /// Returns List of Files if successful, empty list otherwise
  static Future<List<File>> pickMultipleImages({
    double maxWidth = 800,
    double maxHeight = 800,
    int imageQuality = 80,
    int limit = 10,
  }) async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        imageQuality: imageQuality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );
      if (images.isNotEmpty) {
        final limitedImages = images.take(limit).toList();
        return limitedImages.map((xFile) => File(xFile.path)).toList();
      }
      return [];
    } catch (e) {
      AppSnackbar.error(
        message: AppString.imagePickMultipleError,
      );
      return [];
    }
  }

  /// Show image source selection dialog
  /// [onGallerySelected] - Callback when gallery is selected
  /// [onCameraSelected] - Callback when camera is selected
  /// [allowMultiple] - Whether to allow multiple image selection (default: false)
  /// [onMultipleSelected] - Callback when multiple images are selected (only if allowMultiple is true)
  /// [title] - Dialog title (optional)
  /// [maxWidth] - Maximum width for images (default: 800)
  /// [maxHeight] - Maximum height for images (default: 800)
  /// [imageQuality] - Image quality 0-100 (default: 80)
  /// [limit] - Maximum number of images for multiple selection (default: 10)
  static void showImageSourceDialog({
    required Function(File) onGallerySelected,
    required Function(File) onCameraSelected,
    bool allowMultiple = false,
    Function(List<File>)? onMultipleSelected,
    String? title,
    double maxWidth = 800,
    double maxHeight = 800,
    int imageQuality = 80,
    int limit = 10,
  }) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        backgroundColor: AppColor.whiteColor,
        child: Container(
          padding: EdgeInsets.all(Spacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    text: title ?? AppString.selectImageSource,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColor.darkGrey,
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      Icons.close,
                      color: AppColor.greyColor,
                      size: 20.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: Spacing.md),
              const Divider(color: AppColor.lightGrey, height: 1),
              SizedBox(height: Spacing.sm),
              // Options
              if (allowMultiple && onMultipleSelected != null)
                _buildDialogOption(
                  icon: Icons.photo_library_outlined,
                  title: AppString.selectMultipleImages,
                  onTap: () async {
                    Get.back();
                    final images = await pickMultipleImages(
                      maxWidth: maxWidth,
                      maxHeight: maxHeight,
                      imageQuality: imageQuality,
                      limit: limit,
                    );
                    if (images.isNotEmpty) {
                      onMultipleSelected(images);
                    }
                  },
                ),
              if (allowMultiple && onMultipleSelected != null)
                SizedBox(height: Spacing.xs),
              _buildDialogOption(
                icon: Icons.photo_library,
                title: AppString.gallery,
                onTap: () async {
                  Get.back();
                  final image = await pickImageFromGallery(
                    maxWidth: maxWidth,
                    maxHeight: maxHeight,
                    imageQuality: imageQuality,
                  );
                  if (image != null) {
                    onGallerySelected(image);
                  }
                },
              ),
              SizedBox(height: Spacing.xs),
              _buildDialogOption(
                icon: Icons.camera_alt,
                title: AppString.camera,
                onTap: () async {
                  Get.back();
                  final image = await pickImageFromCamera(
                    maxWidth: maxWidth,
                    maxHeight: maxHeight,
                    imageQuality: imageQuality,
                  );
                  if (image != null) {
                    onCameraSelected(image);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build dialog option item
  static Widget _buildDialogOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColor.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                icon,
                color: AppColor.primaryColor,
                size: 24.sp,
              ),
            ),
            SizedBox(width: Spacing.md),
            Expanded(
              child: AppText(
                text: title,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: AppColor.darkGrey,
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColor.greyColor,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  /// Pick image with source selection dialog
  /// [maxWidth] - Maximum width for image (default: 800)
  /// [maxHeight] - Maximum height for image (default: 800)
  /// [imageQuality] - Image quality 0-100 (default: 80)
  /// Returns File if single image selected, null otherwise
  /// Note: This method shows a dialog and returns the selected image via callback
  /// For direct picking, use pickImageFromGallery() or pickImageFromCamera()
  static void pickImageWithDialog({
    required Function(File?) onImageSelected,
    double maxWidth = 800,
    double maxHeight = 800,
    int imageQuality = 80,
  }) {
    showImageSourceDialog(
      onGallerySelected: (image) {
        onImageSelected(image);
      },
      onCameraSelected: (image) {
        onImageSelected(image);
      },
    );
  }

  /// Pick video from gallery
  /// Returns File if successful, null otherwise
  static Future<File?> pickVideoFromGallery() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
      );
      if (video != null) {
        return File(video.path);
      }
      return null;
    } catch (e) {
      AppSnackbar.error(
        message: AppString.videoPickGalleryError,
      );
      return null;
    }
  }

  /// Pick video from camera
  /// Returns File if successful, null otherwise
  static Future<File?> pickVideoFromCamera() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.camera,
      );
      if (video != null) {
        return File(video.path);
      }
      return null;
    } catch (e) {
      AppSnackbar.error(
        message: AppString.videoPickCameraError,
      );
      return null;
    }
  }

  /// Show video source selection dialog
  /// [onGallerySelected] - Callback when gallery video is selected
  /// [onCameraSelected] - Callback when camera video is selected
  /// [title] - Dialog title (optional)
  static void showVideoSourceDialog({
    required Function(File) onGallerySelected,
    required Function(File) onCameraSelected,
    String? title,
  }) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        backgroundColor: AppColor.whiteColor,
        child: Container(
          padding: EdgeInsets.all(Spacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    text: title ?? AppString.selectVideoSource,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColor.darkGrey,
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      Icons.close,
                      color: AppColor.greyColor,
                      size: 20.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: Spacing.md),
              const Divider(color: AppColor.lightGrey, height: 1),
              SizedBox(height: Spacing.sm),
              // Options
              _buildDialogOption(
                icon: Icons.video_library,
                title: AppString.gallery,
                onTap: () async {
                  Get.back();
                  final video = await pickVideoFromGallery();
                  if (video != null) {
                    onGallerySelected(video);
                  }
                },
              ),
              SizedBox(height: Spacing.xs),
              _buildDialogOption(
                icon: Icons.videocam,
                title: AppString.camera,
                onTap: () async {
                  Get.back();
                  final video = await pickVideoFromCamera();
                  if (video != null) {
                    onCameraSelected(video);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
