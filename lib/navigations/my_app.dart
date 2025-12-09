import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_chat/navigations/routes.dart';
import 'package:online_chat/utils/app_color.dart';
import 'package:online_chat/utils/app_local_storage.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);
    
    // Load saved theme mode
    final savedTheme = AppLocalStorage.getThemeMode();
    final themeMode = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
    
    return GetMaterialApp(
      title: 'Apna Chat',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: AppColor.ScaffoldColor,
        textTheme: GoogleFonts.interTextTheme(),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColor.whiteColor,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColor.darkGrey),
          titleTextStyle: TextStyle(
            color: AppColor.darkGrey,
            fontSize: 20.r,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColor.darkGrey,
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColor.darkGrey,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColor.whiteColor),
          titleTextStyle: TextStyle(
            color: AppColor.whiteColor,
            fontSize: 20.r,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      initialRoute: AppRoutes.splashScreen,
      getPages: AppRoutes.routes,
      defaultTransition: Transition.fadeIn,
    );
  }
}