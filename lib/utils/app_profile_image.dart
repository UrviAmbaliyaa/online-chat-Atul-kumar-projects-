import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:online_chat/utils/app_color.dart';
import 'package:online_chat/utils/app_text.dart';

/// Common profile image widget
/// Displays user profile image with fallback to initials
class AppProfileImage extends StatelessWidget {
  final double width;
  final double height;
  final String username;
  final String? imageUrl;
  final File? imageFile;
  final double? borderWidth;
  final Color? borderColor;
  final IconData? fallbackIcon;
  final double? fontSize;

  const AppProfileImage({
    super.key,
    required this.width,
    required this.height,
    required this.username,
    this.imageUrl,
    this.imageFile,
    this.borderWidth,
    this.borderColor,
    this.fallbackIcon,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.antiAlias,
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
        border: borderWidth != null
            ? Border.all(
                color: borderColor ?? AppColor.primaryColor,
                width: borderWidth!,
              )
            : null,
      ),
      child: _buildImageContent(),
    );
  }

  Widget _buildImageContent() {
    // Priority: imageFile > imageUrl (network) > placeholder
    if (imageFile != null) {
      return Image.file(
        imageFile!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      );
    }

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      if (imageUrl!.startsWith('http')) {
        // Network image
        return CachedNetworkImage(
          imageUrl: imageUrl!,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildPlaceholder(),
          errorWidget: (context, url, error) => _buildPlaceholder(),
        );
      } else {
        // Local file path
        try {
          return Image.file(
            File(imageUrl!),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholder();
            },
          );
        } catch (e) {
          return _buildPlaceholder();
        }
      }
    }

    // Placeholder with initials or icon
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
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
        child: fallbackIcon != null
            ? Icon(
                fallbackIcon,
                size: (fontSize ?? (width * 0.5)).sp,
                color: AppColor.whiteColor,
              )
            : AppText(
                text: username.isNotEmpty ? username[0].toUpperCase() : 'U',
                fontSize: fontSize ?? (width * 0.35).sp,
                fontWeight: FontWeight.w600,
                color: AppColor.whiteColor,
              ),
      ),
    );
  }
}
