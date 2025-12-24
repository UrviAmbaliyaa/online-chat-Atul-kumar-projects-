import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:online_chat/utils/app_snackbar.dart';
import 'package:online_chat/utils/app_string.dart';

/// Common file picker utility class
/// Provides reusable file picking functionality for PDFs, ZIP files, and other documents
class AppFilePicker {
  /// Pick a PDF file
  /// Returns File if successful, null otherwise
  static Future<File?> pickPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: false,
        withReadStream: false,
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
      return null;
    } catch (e) {
      AppSnackbar.error(
        message: AppString.filePickPDFError,
      );
      return null;
    }
  }

  /// Pick a ZIP file
  /// Returns File if successful, null otherwise
  static Future<File?> pickZIP() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
        withData: false,
        withReadStream: false,
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
      return null;
    } catch (e) {
      AppSnackbar.error(
        message: AppString.filePickZIPError,
      );
      return null;
    }
  }

  /// Pick any file (PDF, ZIP, or other documents)
  /// [allowedExtensions] - List of allowed file extensions (e.g., ['pdf', 'zip', 'doc', 'docx'])
  /// Returns File if successful, null otherwise
  static Future<File?> pickFile({
    List<String>? allowedExtensions,
  }) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions,
        withData: false,
        withReadStream: false,
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
      return null;
    } catch (e) {
      AppSnackbar.error(
        message: AppString.filePickError,
      );
      return null;
    }
  }

  /// Pick multiple files
  /// [allowedExtensions] - List of allowed file extensions (optional)
  /// Returns List of Files if successful, empty list otherwise
  static Future<List<File>> pickMultipleFiles({
    List<String>? allowedExtensions,
  }) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions,
        allowMultiple: true,
        withData: false,
        withReadStream: false,
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files.where((file) => file.path != null).map((file) => File(file.path!)).toList();
      }
      return [];
    } catch (e) {
      AppSnackbar.error(
        message: AppString.filePickMultipleError,
      );
      return [];
    }
  }

  /// Pick PDF or ZIP file
  /// Returns File if successful, null otherwise
  static Future<File?> pickPDFOrZIP() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'zip'],
        withData: false,
        withReadStream: false,
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
      return null;
    } catch (e) {
      AppSnackbar.error(
        message: AppString.filePickError,
      );
      return null;
    }
  }

  /// Get file size in human-readable format
  /// [file] - File to get size for
  /// Returns formatted string (e.g., "1.5 MB")
  static String getFileSize(File file) {
    final bytes = file.lengthSync();
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  /// Get file extension from file path
  /// [filePath] - Path of the file
  /// Returns file extension (e.g., "pdf", "zip")
  static String getFileExtension(String filePath) {
    return filePath.split('.').last.toLowerCase();
  }

  /// Check if file is PDF
  /// [file] - File to check
  /// Returns true if file is PDF, false otherwise
  static bool isPDF(File file) {
    return getFileExtension(file.path) == 'pdf';
  }

  /// Check if file is ZIP
  /// [file] - File to check
  /// Returns true if file is ZIP, false otherwise
  static bool isZIP(File file) {
    final ext = getFileExtension(file.path);
    return ext == 'zip' || ext == 'rar' || ext == '7z';
  }

  /// Check if file is an image
  /// [file] - File to check
  /// Returns true if file is an image, false otherwise
  static bool isImage(File file) {
    final ext = getFileExtension(file.path);
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext);
  }
}
