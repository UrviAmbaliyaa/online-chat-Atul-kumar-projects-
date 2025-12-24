import 'package:get/get.dart';
import 'package:online_chat/utils/app_downloader.dart';
import 'package:online_chat/utils/app_snackbar.dart';
import 'package:online_chat/utils/app_string.dart';

class DownloadTask {
  final String url;
  final String? fileName;

  DownloadTask(this.url, {this.fileName});
}

class DownloadManager extends GetxController {
  final RxBool isDownloading = false.obs;
  final RxString currentUrl = ''.obs;
  final List<DownloadTask> _queue = <DownloadTask>[];

  void enqueue(String url, {String? fileName}) {
    // If this URL is already current or queued, ignore
    if (currentUrl.value == url || _queue.any((t) => t.url == url)) {
      return;
    }
    _queue.add(DownloadTask(url, fileName: fileName));
    if (!isDownloading.value) {
      _startNext();
    } else {
      AppSnackbar.warning(message: AppString.downloading);
    }
  }

  Future<void> _startNext() async {
    if (_queue.isEmpty) {
      isDownloading.value = false;
      currentUrl.value = '';
      return;
    }
    final task = _queue.removeAt(0);
    isDownloading.value = true;
    currentUrl.value = task.url;

    final savedPath = await AppDownloader.saveFromUrlWithProgress(
      task.url,
      fileName: task.fileName,
    );

    if (savedPath != null) {
      final fileName = task.fileName ?? _extractFileName(savedPath);
      final folder = _extractFolderDisplay(savedPath);
      AppSnackbar.success(message: '$fileName saved to $folder');
    } else {
      AppSnackbar.error(message: AppString.downloadFailed);
    }

    isDownloading.value = false;
    currentUrl.value = '';
    // Start next if queued
    if (_queue.isNotEmpty) {
      _startNext();
    }
  }

  String _extractFileName(String path) {
    final normalized = path.replaceAll('\\', '/');
    if (normalized.contains('/')) {
      final parts = normalized.split('/');
      return parts.isNotEmpty ? parts.last : path;
    }
    return path;
  }

  String _extractFolderDisplay(String path) {
    final normalized = path.replaceAll('\\', '/');
    if (normalized.contains('/Download/OnlineChat')) {
      return 'Downloads/OnlineChat';
    }
    if (normalized.contains('/Download/')) {
      return 'Downloads';
    }
    if (normalized.contains('/')) {
      final parts = normalized.split('/');
      if (parts.length >= 2) {
        return parts[parts.length - 2];
      }
    }
    return 'device storage';
  }
}
