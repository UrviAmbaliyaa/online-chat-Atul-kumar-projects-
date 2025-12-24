import 'dart:io';
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:http/http.dart' as http;
import 'package:online_chat/utils/app_snackbar.dart';
import 'package:online_chat/utils/app_string.dart';
import 'package:permission_handler/permission_handler.dart';

class AppDownloader {
  static const String _androidDownloads = '/storage/emulated/0/Download';
  static const String _folderName = 'OnlineChat';

  static Future<bool> _ensurePermissions() async {
    if (Platform.isAndroid) {
      // Storage permission required on Android <= 12 for saving to Downloads
      final status = await Permission.storage.request();
      if (!status.isGranted && !status.isLimited) {
        return false;
      }
    }
    return true;
  }

  /// Download a URL with progress callback (0.0 - 1.0) and save to Downloads
  static Future<String?> saveFromUrlWithProgress(
    String url, {
    String? fileName,
    void Function(double progress)? onProgress,
  }) async {
    final ok = await _ensurePermissions();
    if (!ok) {
      AppSnackbar.error(message: AppString.permissionDenied);
      return null;
    }
    try {
      final request = http.Request('GET', Uri.parse(url));
      final streamed = await request.send();
      if (streamed.statusCode != 200) {
        return null;
      }
      final contentLength = streamed.contentLength ?? 0;
      final builder = BytesBuilder(copy: false);
      int received = 0;
      await for (final chunk in streamed.stream) {
        builder.add(chunk);
        received += chunk.length;
        if (contentLength > 0 && onProgress != null) {
          onProgress(received / contentLength);
        }
      }
      final inferredName = fileName ?? url.split('/').last.split('?').first.split('#').first;
      final ext = inferredName.contains('.') ? inferredName.split('.').last : '';
      return saveBytes(
        bytes: builder.toBytes(),
        fileName: inferredName,
        ext: ext,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<String?> saveBytes({
    required Uint8List bytes,
    required String fileName,
    required String ext,
    // MimeType? mimeType,
  }) async {
    final ok = await _ensurePermissions();
    if (!ok) return null;
    try {
      if (Platform.isAndroid) {
        final dir = Directory('$_androidDownloads/$_folderName');
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
        final sanitizedName = fileName.endsWith('.$ext') ? fileName : '$fileName.$ext';
        final fullPath = '${dir.path}/$sanitizedName';
        final outFile = File(fullPath);
        await outFile.writeAsBytes(bytes, flush: true);
        return fullPath;
      }
      // Fallback (iOS and others): use FileSaver to default destination
      await FileSaver.instance.saveFile(
        name: fileName,
        bytes: bytes,
        ext: ext,
        // mimeType: mimeType,
      );
      return fileName;
    } catch (_) {
      try {
        // Final fallback using FileSaver on Android if direct save failed
        await FileSaver.instance.saveFile(
          name: fileName,
          bytes: bytes,
          ext: ext,
        );
        return fileName;
      } catch (_) {
        return null;
      }
    }
  }

  static Future<String?> saveFromFile(File file, {String? fileName}) async {
    final name = fileName ?? file.path.split(Platform.pathSeparator).last;
    final ext = name.split('.').length > 1 ? name.split('.').last : '';
    final bytes = await file.readAsBytes();
    return saveBytes(bytes: bytes, fileName: name, ext: ext);
  }

  static Future<String?> saveFromUrl(String url, {String? fileName}) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final inferredName = fileName ?? url.split('/').last.split('?').first.split('#').first;
        final ext = inferredName.contains('.') ? inferredName.split('.').last : '';
        return saveBytes(
          bytes: response.bodyBytes,
          fileName: inferredName,
          ext: ext,
        );
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
