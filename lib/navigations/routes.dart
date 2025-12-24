import 'package:get/get.dart';
import 'package:online_chat/features/home/screen/home_screen.dart';

import '../features/authentications/presentations/forgot_password.dart';
import '../features/authentications/presentations/sign_up.dart';
import '../features/authentications/presentations/sing_in.dart';
import '../features/home/models/group_chat_model.dart';
import '../features/home/models/user_model.dart';
import '../features/home/screen/add_contact_screen.dart';
import '../features/home/screen/add_group_screen.dart';
import '../features/home/screen/calling_screen.dart';
import '../features/home/screen/edit_members_screen.dart';
import '../features/home/screen/user_detail_screen.dart';
import '../features/settings/screen/change_password_screen.dart';
import '../features/settings/screen/edit_profile_screen.dart';
import '../features/settings/screen/settings_screen.dart';
import '../features/splash_screen.dart';

class AppRoutes {
  static String splashScreen = "/splashScreen";
  static String signIn = "/signIn";
  static String signUp = "/signUp";
  static String forgotPassword = "/forgotPassword";
  static String homeScreen = "/homeScreen";
  static String settingsScreen = "/settingsScreen";
  static String editProfileScreen = "/editProfileScreen";
  static String changePasswordScreen = "/changePasswordScreen";
  static String addContactScreen = "/addContactScreen";
  static String addGroupScreen = "/addGroupScreen";
  static String editMembersScreen = "/editMembersScreen";
  static String userDetailScreen = "/userDetailScreen";
  static String callingScreen = "/callingScreen";

  static List<GetPage> routes = [
    GetPage(name: splashScreen, page: () => const SplashScreen()),
    GetPage(name: signIn, page: () => const AuthScreen()),
    GetPage(name: signUp, page: () => const SignUpScreen()),
    GetPage(name: forgotPassword, page: () => const ForgotPasswordScreen()),
    GetPage(name: homeScreen, page: () => HomeScreen()),
    GetPage(name: settingsScreen, page: () => SettingsScreen()),
    GetPage(name: editProfileScreen, page: () => const EditProfileScreen()),
    GetPage(name: changePasswordScreen, page: () => const ChangePasswordScreen()),
    GetPage(
      name: addContactScreen,
      page: () => const AddContactScreen(),
    ),
    GetPage(
      name: addGroupScreen,
      page: () => const AddGroupScreen(),
    ),
    GetPage(
      name: editMembersScreen,
      page: () {
        final group = Get.arguments as GroupChatModel;
        return EditMembersScreen(group: group);
      },
    ),
    GetPage(
      name: userDetailScreen,
      page: () {
        final user = Get.arguments as UserModel;
        return UserDetailScreen(user: user);
      },
    ),
    GetPage(
      name: callingScreen,
      page: () {
        final args = Get.arguments as Map<String, dynamic>;
        return CallingScreen(
          user: args['user'] as UserModel?,
          group: args['group'] as GroupChatModel?,
          chatId: args['chatId'] as String ?? "",
          isIncoming: args['isIncoming'] as bool? ?? false,
          isVideoCall: args['isVideoCall'] as bool? ?? false,
        );
      },
    ),
  ];
}
