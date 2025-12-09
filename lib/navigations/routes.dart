import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:online_chat/features/home/screen/home_screen.dart';

import '../features/authentications/presentations/sign_up.dart';
import '../features/authentications/presentations/sing_in.dart';
import '../features/authentications/presentations/forgot_password.dart';
import '../features/splash_screen.dart';

class AppRoutes {
  static String splashScreen = "/splashScreen";
  static String signIn = "/signIn";
  static String signUp = "/signUp";
  static String forgotPassword = "/forgotPassword";
  static String homeScreen = "/homeScreen";

  static List<GetPage> routes = [
    GetPage(name: splashScreen, page: () => SplashScreen()),
    GetPage(name: signIn, page: () => AuthScreen()),
    GetPage(name: signUp, page: () => SignUpScreen()),
    GetPage(name: forgotPassword, page: () => const ForgotPasswordScreen()),
    GetPage(name: homeScreen, page: () => HomeScreen()),
  ];
}
