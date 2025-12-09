import 'package:flutter/material.dart';
import 'package:online_chat/navigations/app_navigation.dart';
import 'package:online_chat/navigations/routes.dart';
import 'package:online_chat/services/firebase_service.dart';
import 'package:online_chat/utils/app_local_storage.dart';
import 'package:online_chat/utils/app_string.dart';

import '../utils/app_text.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _inItFunction();
  }

  void _inItFunction() {
    Future.delayed(
        Duration(seconds: 1),
        () => AppNavigation.offNamed(
              FirebaseService.isUserLoggedIn() ||
                      AppLocalStorage.isUserLoggedIn()
                  ? AppRoutes.homeScreen
                  : AppRoutes.signIn, // This will replace splash screen
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppText(
          text: AppString.appName,
        )
      ],
    );
  }
}
