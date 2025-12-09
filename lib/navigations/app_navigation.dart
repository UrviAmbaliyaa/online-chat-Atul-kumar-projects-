import 'package:get/get.dart';

class AppNavigation {
  // Basic navigation
  static Future<T?>? push<T>(
    dynamic page, {
    dynamic arguments,
    Transition? transition,
    Duration? duration,
    bool? opaque,
    bool? popGesture,
  }) {
    return Get.to<T>(
      page,
      arguments: arguments,
      transition: transition ?? Transition.rightToLeft,
      duration: duration ?? const Duration(milliseconds: 300),
      opaque: opaque ?? true,
      popGesture: popGesture ?? true,
    );
  }

  // Replace current screen
  static Future<T?>? namePushed<T>(
    dynamic page, {
    dynamic arguments,
    Transition? transition,
    bool? opaque,
  }) {
    return Get.off<T>(
      page,
      arguments: arguments,
      transition: transition ?? Transition.rightToLeft,
      opaque: opaque ?? true,
    );
  }

  // Replace all screens
  static Future<T?>? replaceAll<T>(
    dynamic page, {
    dynamic arguments,
    Transition? transition,
    bool? opaque,
  }) {
    return Get.offAll<T>(
      page,
      arguments: arguments,
      transition: transition ?? Transition.rightToLeft,
      opaque: opaque ?? true,
    );
  }

  // Go back with optional result
  static void back<T>({T? result}) {
    Get.back(result: result);
  }

  // Go back to specific screen
  static void until(String routeName) {
    Get.until((route) => Get.currentRoute == routeName);
  }

  // Navigate with named routes
  static Future<T?>? toNamed<T>(
    String routeName, {
    dynamic arguments,
    Map<String, String>? parameters,
  }) {
    return Get.toNamed<T>(
      routeName,
      arguments: arguments,
      parameters: parameters,
    );
  }

  // Replace current screen with named route
  static Future<T?>? offNamed<T>(
    String routeName, {
    dynamic arguments,
    Map<String, String>? parameters,
  }) {
    return Get.offNamed<T>(
      routeName,
      arguments: arguments,
      parameters: parameters,
    );
  }

  // Replace all screens with named route
  static Future<T?>? replaceAllNamed<T>(
    String routeName, {
    dynamic arguments,
    Map<String, String>? parameters,
  }) {
    return Get.offAllNamed<T>(
      routeName,
      arguments: arguments,
      parameters: parameters,
    );
  }

  // Check if can pop
  static bool get canPop => Get.key.currentState?.canPop() ?? false;

  // Get current route
  static String get currentRoute => Get.currentRoute;

  // Get previous route
  static String? get previousRoute => Get.previousRoute;
}
