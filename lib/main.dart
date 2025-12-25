import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:online_chat/utils/app_local_storage.dart';

import 'navigations/my_app.dart';
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

/*
The FCM HTTP v1 API's platform override feature enables a message send request to have different behaviors on different platforms. One use case of this feature is to display different notification message content based on the platform. The feature is most fully used when targeting multiple devices (which might span multiple platforms) with topic messaging. This section walks you through the steps to make your app receive a topic message customized for each platform.

Subscribe to a topic from the client
To subscribe to a topic, copy this code to the main function below the comment TODO: Subscribe to a topic:


// subscribe to a topic.
const topic = 'app_promotion';
await messaging.subscribeToTopic(topic);
[Optional] Subscribe to a topic from the server for web
You can skip this section if you are not developing on the web platform.

The FCM JS SDK currently does not support client-side topic subscription. Instead, you can subscribe using the Admin SDK's server-side topic management API. This code in the FcmSubscriptionManager.java file illustrates server-side topic subscription with the Java Admin SDK. Make sure to add your FCM Registration Token before running it:


 private static void subscribeFcmRegistrationTokensToTopic() throws Exception {
   List<String> registrationTokens =
       Arrays.asList(
           "REPLACE_WITH_FCM_REGISTRATION_TOKEN"); // TODO: add FCM Registration Tokens to
   // subscribe String topicName = "app_promotion";

   TopicManagementResponse response =     FirebaseMessaging.getInstance().subscribeToTopic(registrationTokens, topicName);
   System.out.printf("Num tokens successfully subscribed %d", response.getSuccessCount());
 }
Note: Every time the Web application is closed and reopened, the registration token may be updated. Make sure to adjust the token in your code if the notification is not delivered correctly.

Open the app server and click Run The run button in Android Studio to run the main function in FcmSubscriptionManager.java file:

A cropped screenshot of the Run icon shown next to the FcmSubscriptionManager.java main function in Android Studio

Send a message with platform overrides to a topic
Now you're ready to send a topic platform override message. In the following code snippet:

You construct a send request with a base message and title "A new app is available".
The message generates a display notification with the title "A new app is available" on iOS and web platforms.
The message generates a display notification with title "A new Android app is available" on Android devices.

private static void sendMessageToFcmTopic() throws Exception {
   String topicName = "app_promotion";

   Message message =
       Message.builder()
           .setNotification(
               Notification.builder()
                   .setTitle("A new app is available")
                   .setBody("Check out our latest app in the app store.")
                   .build())
           .setAndroidConfig(
               AndroidConfig.builder()
                   .setNotification(
                       AndroidNotification.builder()
                           .setTitle("A new Android app is available")
                           .setBody("Our latest app is available on Google Play store")
                           .build())
                   .build())
           .setTopic("app_promotion")
           .build();

   FirebaseMessaging.getInstance().send(message);

   System.out.println("Message to topic sent successfully!!");
 }*/
