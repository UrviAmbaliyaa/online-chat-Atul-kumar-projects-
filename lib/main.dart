import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:online_chat/utils/app_local_storage.dart';

import 'navigations/my_app.dart';
import 'package:get/get.dart';
import 'services/presence_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Local Storage
  await AppLocalStorage.init();

  await ScreenUtil.ensureScreenSize();
  // Initialize presence tracking
  Get.put(PresenceService(), permanent: true);
  runApp(const MyApp());
}
