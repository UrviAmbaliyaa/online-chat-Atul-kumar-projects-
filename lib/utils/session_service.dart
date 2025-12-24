import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:online_chat/features/home/widgets/force_logout_dialog.dart';
import 'package:online_chat/navigations/app_navigation.dart';
import 'package:online_chat/navigations/routes.dart';
import 'package:online_chat/services/firebase_service.dart';
import 'package:online_chat/utils/app_local_storage.dart';
import 'package:online_chat/utils/firebase_constants.dart';

class SessionService extends GetxService {
  Stream<DocumentSnapshot>? _userDocStream;
  StreamSubscription<DocumentSnapshot>? _sub;
  bool _dialogShown = false;

  static Future<SessionService> ensure() async {
    if (Get.isRegistered<SessionService>()) {
      return Get.find<SessionService>();
    }
    return await Get.putAsync<SessionService>(() async => SessionService().init());
  }

  Future<SessionService> init() async {
    await _startOrRefreshSession();
    return this;
  }

  Future<void> _startOrRefreshSession() async {
    final uid = FirebaseService.getCurrentUserId();
    if (uid == null) return;

    // Generate or reuse a session id
    String sessionId = AppLocalStorage.getSessionId();
    if (sessionId.isEmpty) {
      final rand = Random();
      sessionId = '${DateTime.now().millisecondsSinceEpoch}_${rand.nextInt(1 << 32)}';
      await AppLocalStorage.saveSessionId(sessionId);
    }

    // Write active session id to user doc
    await FirebaseService.updateUserDocument(userId: uid, userData: {
      'activeSessionId': sessionId,
      'lastLoginAt': FieldValue.serverTimestamp(),
      'isOnline': true,
    });

    // Listen for changes to detect if another device logs in
    _sub?.cancel();
    _userDocStream = FirebaseService.streamDocument(
      collection: FirebaseConstants.userCollection,
      docId: uid,
    );
    _sub = _userDocStream!.listen((snap) {
      final data = snap.data() as Map<String, dynamic>?;
      if (data == null) return;
      final current = AppLocalStorage.getSessionId();
      final remote = data['activeSessionId'] as String?;
      if (remote != null && current.isNotEmpty && remote != current) {
        _showForceLogoutDialog();
      }
    });
  }

  void _showForceLogoutDialog() {
    if (_dialogShown) return;
    _dialogShown = true;
    Get.dialog(
      ForceLogoutDialog(
        onLogout: () async {
          try {
            await FirebaseService.setUserOffline();
          } catch (_) {}
          await FirebaseService.signOut();
          await AppLocalStorage.logout();
          _dialogShown = false;
          Get.back(closeOverlays: true);
          AppNavigation.replaceAllNamed(AppRoutes.signIn);
        },
      ),
      barrierDismissible: false,
    );
  }

  Future<void> refreshSession() async {
    await _startOrRefreshSession();
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
