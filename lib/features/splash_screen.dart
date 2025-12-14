import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:online_chat/navigations/app_navigation.dart';
import 'package:online_chat/navigations/routes.dart';
import 'package:online_chat/services/firebase_service.dart';
import 'package:online_chat/utils/app_color.dart';
import 'package:online_chat/utils/app_local_storage.dart';
import 'package:online_chat/utils/app_string.dart';
import 'package:online_chat/utils/logo.dart';

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
        const Duration(seconds: 3),
        () => AppNavigation.offNamed(
              FirebaseService.isUserLoggedIn() ||
                      AppLocalStorage.isUserLoggedIn()
                  ? AppRoutes.homeScreen
                  : AppRoutes.signIn, // This will replace splash screen
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppLogo(),
            30.r.verticalSpace,
            AppText(
              text: AppString.appName,
              color: AppColor.primaryColor,
              fontWeight: FontWeight.w800,
              fontSize: 30.r,
            ),
          ],
        ),
      ),
    );
  }


}
