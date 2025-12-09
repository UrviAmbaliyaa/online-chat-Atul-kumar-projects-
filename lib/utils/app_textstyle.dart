import 'dart:ui';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:online_chat/utils/app_color.dart';

class AppTextStyle{
  static TextStyle headingStyle = TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.bold,
    color:AppColor.primaryColor,
  );

  static TextStyle titleStyle = TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
    color: AppColor.darkGrey,
  );

  static TextStyle bodyStyle = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.normal,
    color:AppColor.darkGrey,
  );

  static TextStyle captionStyle = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.normal,
    color: AppColor.greyColor,
  );

  static TextStyle smallStyle = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.normal,
    color: AppColor.greyColor,
  );

}