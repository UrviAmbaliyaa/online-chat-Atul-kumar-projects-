import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:online_chat/navigations/routes.dart';
import 'package:online_chat/utils/app_color.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);

    return GetMaterialApp(
      title: 'Apna Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: AppColor.ScaffoldColor,
        textTheme: GoogleFonts.interTextTheme(),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColor.whiteColor,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColor.darkGrey),
          titleTextStyle: TextStyle(
            color: AppColor.darkGrey,
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
