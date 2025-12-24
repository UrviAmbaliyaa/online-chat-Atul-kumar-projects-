import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:online_chat/services/firebase_service.dart';

/// PresenceService keeps the user's online status in sync with app lifecycle.
class PresenceService extends GetxService with WidgetsBindingObserver {
  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    // Mark online on service init
    FirebaseService.setUserOnline();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    // Best-effort: mark offline when service is disposed
    FirebaseService.setUserOffline();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        FirebaseService.setUserOnline();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        FirebaseService.setUserOffline();
        break;
      case AppLifecycleState.hidden:
        // Treat hidden similar to paused on platforms that support it
        FirebaseService.setUserOffline();
        break;
    }
  }
}
