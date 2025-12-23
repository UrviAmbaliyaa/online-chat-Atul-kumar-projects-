import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:online_chat/features/home/controller/chat_controller.dart';
import 'package:online_chat/utils/app_color.dart';
import 'package:online_chat/utils/app_spacing.dart';
import 'package:online_chat/utils/app_string.dart';
import 'package:online_chat/utils/app_text.dart';
import 'package:online_chat/utils/app_file_picker.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:online_chat/utils/app_downloader.dart';
import 'package:online_chat/utils/app_snackbar.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MediaPreviewScreen extends StatefulWidget {
  final File? file;
  final String? networkUrl;
  final bool isImage;
  final bool enableSend;
  final String? fileName;
  final String? fileExtension;

  const MediaPreviewScreen({
    super.key,
    this.file,
    this.networkUrl,
    required this.isImage,
    this.enableSend = true,
    this.fileName,
    this.fileExtension,
  });

  @override
  State<MediaPreviewScreen> createState() => _MediaPreviewScreenState();
}

class _MediaPreviewScreenState extends State<MediaPreviewScreen> {
  double _downloadProgress = 0.0;
  bool _isDownloading = false;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatController>();
    return Scaffold(
      backgroundColor: Colors.black,
      body: _buildBody(controller),
      floatingActionButton:
          widget.enableSend ? _buildSendFab(controller) : _buildDownloadFab(),
    );
  }

  Widget _buildBody(ChatController controller) {
    return Stack(
      children: [
        _buildPreviewContent(),
        _buildCancelButton(),
        if (_isDownloading) _buildDownloadProgressOverlay(),
      ],
    );
  }

  Widget _buildPreviewContent() {
    return Positioned.fill(
      child: widget.isImage ? _buildImagePreview() : SafeArea(child: _buildFilePreview()),
    );
  }

  Widget _buildCancelButton() {
    return SafeArea(
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: EdgeInsets.all(Spacing.sm),
          child: InkWell(
            onTap: () => Get.back(),
            borderRadius: BorderRadius.circular(24.r),
            child: Container(
              width: 40.w,
              height: 40.h,
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close_rounded,
                color: AppColor.whiteColor,
                size: 20.sp,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSendFab(ChatController controller) {
    return Obx(() {
      final isUploading =
          controller.isUploadingImage.value || controller.isUploadingFile.value;
      if (isUploading) {
        return Container(
          width: 44.w,
          height: 44.h,
          decoration: BoxDecoration(
            color: AppColor.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: SizedBox(
              width: 20.w,
              height: 20.h,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColor.primaryColor,
              ),
            ),
          ),
        );
      }
      return GestureDetector(
        onTap: () async {
          // Start upload and immediately navigate back to chat.
          // Chat screen send button will show loading until upload completes.
          if (widget.file == null) {
            Get.snackbar(
              AppString.errorTitle,
              AppString.operationFailed,
              snackPosition: SnackPosition.BOTTOM,
              colorText: AppColor.whiteColor,
              backgroundColor: Colors.black87,
            );
            return;
          }
          if (widget.isImage) {
            // ignore: unawaited_futures
            controller.sendImageMessage(widget.file!);
          } else {
            // ignore: unawaited_futures
            controller.sendFileMessage(widget.file!);
          }
          Get.back();
        },
        child: Container(
          width: 44.w,
          height: 44.h,
          decoration: BoxDecoration(
            color: AppColor.primaryColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColor.primaryColor.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.send_rounded,
            color: AppColor.whiteColor,
            size: 20.sp,
          ),
        ),
      );
    });
  }

  Widget _buildImagePreview() {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4.0,
      child: Center(
        child: widget.file != null
            ? Image.file(
                widget.file!,
                fit: BoxFit.contain,
              )
            : (widget.networkUrl != null
                ? CachedNetworkImage(
                    imageUrl: widget.networkUrl!,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(
                        color: AppColor.primaryColor,
                      ),
                    ),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.broken_image_outlined,
                      color: Colors.white70,
                    ),
                  )
                : const SizedBox.shrink()),
      ),
    );
  }

  Widget _buildFilePreview() {
    final localName =
        widget.file != null ? widget.file!.path.split(Platform.pathSeparator).last : null;
    final networkName = widget.networkUrl != null
        ? widget.networkUrl!
            .split('/')
            .last
            .split('?')
            .first
            .split('#')
            .first
        : null;
    final displayName = widget.fileName ?? localName ?? networkName ?? 'File';
    final isPdfLocal = widget.file != null && AppFilePicker.isPDF(widget.file!);
    final isPdfNetwork = widget.file == null &&
        ((widget.fileExtension?.toLowerCase() == 'pdf') ||
            (displayName.toLowerCase().endsWith('.pdf')));
    if (isPdfLocal) {
      return SizedBox.expand(
        child: SfPdfViewer.file(
          widget.file!,
          canShowScrollHead: true,
          canShowScrollStatus: true,
        ),
      );
    }
    if (isPdfNetwork && widget.networkUrl != null) {
      return SizedBox.expand(
        child: SfPdfViewer.network(
          widget.networkUrl!,
          canShowScrollHead: true,
          canShowScrollStatus: true,
        ),
      );
    }
    final fileSize = widget.file != null ? AppFilePicker.getFileSize(widget.file!) : null;
    return Container(
      padding: EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.insert_drive_file_rounded,
            color: AppColor.whiteColor,
            size: 64.sp,
          ),
          SizedBox(height: Spacing.sm),
          AppText(
            text: displayName,
            fontSize: 14.sp,
            color: AppColor.whiteColor,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: Spacing.xs),
          if (fileSize != null)
            AppText(
              text: fileSize,
              fontSize: 12.sp,
              color: AppColor.whiteColor.withOpacity(0.8),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  Widget _buildDownloadFab() {
    return GestureDetector(
      onTap: () async {
        setState(() {
          _isDownloading = true;
          _downloadProgress = 0.0;
        });
        // AppSnackbar.info(message: AppString.downloadingToDownloads);
        String? savedPath;
        if (widget.file != null) {
          savedPath = await AppDownloader.saveFromFile(
            widget.file!,
            fileName: widget.fileName,
          );
        } else if (widget.networkUrl != null) {
          savedPath = await AppDownloader.saveFromUrlWithProgress(
            widget.networkUrl!,
            fileName: widget.fileName,
            onProgress: (p) {
              setState(() {
                _downloadProgress = p.clamp(0.0, 1.0);
              });
            },
          );
        }
        setState(() {
          _isDownloading = false;
        });
        if (savedPath != null) {
          final pathHint = Platform.isAndroid
              ? 'Downloads/OnlineChat'
              : 'Files app';
          AppSnackbar.success(
              message: '${AppString.savedToDownloads} ($pathHint)');
        } else {
          AppSnackbar.error(message: AppString.downloadFailed);
        }
      },
      child: Container(
        width: 44.w,
        height: 44.h,
        decoration: BoxDecoration(
          color: AppColor.primaryColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColor.primaryColor.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.download_rounded,
          color: AppColor.whiteColor,
          size: 20.sp,
        ),
      ),
    );
  }

  Widget _buildDownloadProgressOverlay() {
    return Positioned(
      bottom: 90.h,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.sm),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 20.w,
                height: 20.h,
                child: CircularProgressIndicator(
                  value: _downloadProgress > 0 && _downloadProgress < 1 ? _downloadProgress : null,
                  strokeWidth: 2,
                  color: AppColor.whiteColor,
                  backgroundColor: AppColor.whiteColor.withOpacity(0.2),
                ),
              ),
              SizedBox(width: Spacing.sm),
              AppText(
                text: AppString.downloading,
                fontSize: 12.sp,
                color: AppColor.whiteColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


