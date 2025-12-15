class AppString {
  static const String appName = "Online Chat";

  // Sign In Screen
  static const String signIn = "Sign In";
  static const String welcomeBack = "Welcome Back!";
  static const String signInSubtitle = "Sign in to continue to Chat Connect";
  static const String email = "Email";
  static const String emailHint = "Enter your email";
  static const String password = "Password";
  static const String passwordHint = "Enter your password";
  static const String forgotPassword = "Forgot Password?";
  static const String dontHaveAccount = "Don't have an account? ";
  static const String signUp = "Sign Up";
  static const String orContinueWith = "Or continue with";

  // Sign Up Screen
  static const String createAccount = "Create Account";
  static const String joinUs = "Join Us!";
  static const String signUpSubtitle = "Create your account to start chatting";
  static const String fullName = "Full Name";
  static const String fullNameHint = "Enter your full name";
  static const String phoneNumber = "Phone Number";
  static const String phoneNumberHint = "Enter your phone number";
  static const String profilePicture = "Profile Picture";
  static const String addProfilePicture = "Add Profile Picture";
  static const String changeProfilePicture = "Change Profile Picture";
  static const String removeProfilePicture = "Remove";
  static const String confirmPassword = "Confirm Password";
  static const String confirmPasswordHint = "Re-enter your password";
  static const String confirmPasswordHintChangePassword =
      "Confirm your new password";
  static const String alreadyHaveAccount = "Already have an account? ";
  static const String agreeToTerms = "I agree to the ";
  static const String termsAndConditions = "Terms & Conditions";
  static const String and = " and ";
  static const String privacyPolicy = "Privacy Policy";

  // Validation Messages
  static const String emailRequired = "Email is required";
  static const String emailInvalid = "Please enter a valid email";
  static const String passwordRequired = "Password is required";
  static const String passwordMinLength =
      "Password must be at least 6 characters";
  static const String nameRequired = "Name is required";
  static const String nameMinLength = "Name must be at least 3 characters";
  static const String confirmPasswordRequired = "Please confirm your password";
  static const String passwordsDoNotMatch = "Passwords do not match";
  static const String termsRequired = "Please accept the terms and conditions";
  static const String phoneRequired = "Phone number is required";
  static const String phoneInvalid = "Please enter a valid phone number";
  static const String phone = "Phone";

  // Success/Error Messages
  static const String signInSuccess = "Signed in successfully";
  static const String signInError = "Failed to sign in. Please try again.";
  static const String signUpSuccess = "Account created successfully";
  static const String signUpError =
      "Failed to create account. Please try again.";

  // Snackbar Titles
  static const String successTitle = "Success";
  static const String errorTitle = "Error";
  static const String infoTitle = "Info";
  static const String warningTitle = "Warning";

  // Image Picker Messages
  static const String imagePickGalleryError =
      "Failed to pick image from gallery. Please try again.";
  static const String imagePickCameraError =
      "Failed to capture image. Please try again.";
  static const String imagePickMultipleError =
      "Failed to pick images. Please try again.";
  static const String videoPickGalleryError =
      "Failed to pick video. Please try again.";
  static const String videoPickCameraError =
      "Failed to record video. Please try again.";
  static const String selectImageSource = "Select Image Source";
  static const String selectVideoSource = "Select Video Source";
  static const String selectMultipleImages = "Select Multiple Images";
  static const String gallery = "Gallery";
  static const String camera = "Camera";

  // File Picker Messages
  static const String filePickPDFError =
      "Failed to pick PDF file. Please try again.";
  static const String filePickZIPError =
      "Failed to pick ZIP file. Please try again.";
  static const String filePickError = "Failed to pick file. Please try again.";
  static const String filePickMultipleError =
      "Failed to pick files. Please try again.";

  // Forgot Password Screen
  static const String forgotPasswordTitle = "Forgot Password?";
  static const String forgotPasswordSubtitle =
      "Don't worry! Enter your email and we'll send you a link to reset your password.";
  static const String sendResetLink = "Send Reset Link";
  static const String backToSignIn = "Back to Sign In";
  static const String emailSentTitle = "Check Your Email";

  static String emailSentDescription(String email) =>
      "We've sent a password reset link to $email. Please check your inbox and follow the instructions.";
  static const String resendEmail = "Resend Email";

  // Feature Coming Soon Messages
  static const String forgotPasswordComingSoon =
      "Forgot password screen coming soon";
  static const String signUpComingSoon = "Sign up screen coming soon";
  static const String featureComingSoon = "Feature coming soon";

  // General Messages
  static const String somethingWentWrong =
      "Something went wrong. Please try again.";
  static const String operationSuccess = "Operation completed successfully";
  static const String operationFailed = "Operation failed. Please try again.";
  static const String pleaseTryAgain = "Please try again";

  // Home Screen
  static const String home = "Home";
  static const String myContacts = "My Contacts";
  static const String myGroups = "My Groups";
  static const String addedUsers = "Added Users";
  static const String createdGroups = "Created Groups";
  static const String addContact = "Add Contact";
  static const String addGroup = "Add Group";
  static const String createNewGroup = "Create New Group";
  static const String createGroupSubtitle =
      "Add a group name and select members from your contacts";
  static const String groupName = "Group Name";
  static const String groupNameHint = "Enter group name";
  static const String groupNameRequired = "Group name is required";
  static const String groupNameMinLength =
      "Group name must be at least 3 characters";
  static const String selectMembers = "Select Members";
  static const String selected = "selected";
  static const String noContactsToAdd = "No contacts available";
  static const String addContactsFirst = "Add contacts first to create a group";
  static const String selectAtLeastOneMember =
      "Please select at least one member";
  static const String createGroup = "Create Group";
  static const String groupCreatedSuccessfully = "Group created successfully";
  static const String groupCreateError =
      "Failed to create group. Please try again.";
  static const String groupUpdateError =
      "Failed to update group. Please try again.";
  static const String groupNotFound = "Group not found";
  static const String onlyAdminCanAddMembers =
      "Only group admin can add members";
  static const String allMembersAlreadyAdded =
      "All selected members are already in the group";
  static const String exitFromGroup = "Exit from Group";
  static const String exitGroupConfirmation =
      "Are you sure you want to exit from this group?";
  static const String exitGroup = "Exit Group";
  static const String groupExitedSuccessfully =
      "You have exited from the group";
  static const String exitGroupError =
      "Failed to exit from group. Please try again.";
  static const String groupMembers = "Group Members";
  static const String admin = "Admin";
  static const String member = "Member";
  static const String adminCannotExitGroup =
      "Group admin cannot exit from the group";
  static const String userNotInGroup = "You are not a member of this group";
  static const String errorLoadingMembers = "Error loading members";
  static const String groupDetails = "Group Details";
  static const String update = "Update";
  static const String groupNameUpdated = "Group name updated successfully";
  static const String addMember = "Add Member";
  static const String noMembersFound = "No members found";
  static const String removeMember = "Remove Member";
  static const String removeMemberConfirmation =
      "Are you sure you want to remove {name} from this group?";
  static const String remove = "Remove";
  static const String memberRemovedSuccessfully = "Member removed successfully";
  static const String removeMemberError =
      "Failed to remove member. Please try again.";
  static const String onlyAdminCanRemoveMembers =
      "Only group admin can remove members";
  static const String cannotRemoveAdmin = "Cannot remove admin from the group";
  static const String editMembers = "Edit Members";
  static const String editGroupMembers = "Edit Group Members";
  static const String editGroupMembersSubtitle =
      "Update group name and manage members";
  static const String updateGroup = "Update Group";
  static const String groupUpdatedSuccessfully = "Group updated successfully";
  static const String deleteGroup = "Delete Group";
  static const String deleteGroupConfirmation =
      "Are you sure you want to delete this group? This action cannot be undone.";
  static const String groupDeletedSuccessfully = "Group deleted successfully";
  static const String deleteGroupError =
      "Failed to delete group. Please try again.";
  static const String onlyAdminCanDeleteGroup =
      "Only group admin can delete the group";
  static const String addContactTitle = "Add New Contact";
  static const String addContactSubtitle =
      "Enter the email address of the person you want to add as a contact";
  static const String addContactEmailHint = "Enter contact email address";
  static const String contactAddedSuccessfully = "Contact added successfully";
  static const String contactAddError =
      "Failed to add contact. Please try again.";
  static const String contactAlreadyExists =
      "This contact is already in your list";
  static const String cannotAddYourself =
      "You cannot add yourself as a contact";
  static const String noUsersFound = "No users found";
  static const String noGroupsFound = "No groups found";
  static const String online = "Online";
  static const String offline = "Offline";
  static const String lastSeen = "Last seen";
  static const String members = "Members";
  static const String created = "Created";
  static const String pullToRefresh = "Pull to refresh";

  // Settings Screen
  static const String settings = "Settings";
  static const String profile = "Profile";
  static const String account = "Account";
  static const String notifications = "Notifications";
  static const String privacy = "Privacy";
  static const String appSettings = "App Settings";
  static const String about = "About";
  static const String logout = "Logout";
  static const String editProfile = "Edit Profile";
  static const String changePassword = "Change Password";
  static const String deleteAccount = "Delete Account";
  static const String notificationSettings = "Notification Settings";
  static const String enableNotifications = "Enable Notifications";
  static const String enableSound = "Enable Sound";
  static const String enableVibration = "Enable Vibration";
  static const String privacySettings = "Privacy Settings";
  static const String lastSeenPrivacy = "Last Seen";
  static const String readReceipts = "Read Receipts";
  static const String typingIndicator = "Typing Indicator";
  static const String onlineStatus = "Online Status";
  static const String everyone = "Everyone";
  static const String contactsOnly = "Contacts Only";
  static const String nobody = "Nobody";
  static const String theme = "Theme";
  static const String language = "Language";
  static const String light = "Light";
  static const String dark = "Dark";
  static const String system = "System";
  static const String english = "English";
  static const String version = "Version";
  static const String appVersion = "1.0.0";
  static const String buildNumber = "Build Number";
  static const String termsOfService = "Terms of Service";
  static const String privacyPolicyTitle = "Privacy Policy";
  static const String helpAndSupport = "Help & Support";
  static const String reportABug = "Report a Bug";
  static const String logoutConfirmation = "Are you sure you want to logout?";
  static const String yes = "Yes";
  static const String no = "No";
  static const String logoutSuccess = "Logged out successfully";
  static const String logoutError = "Failed to logout. Please try again.";
  static const String settingsSaved = "Settings saved successfully";
  static const String settingsSaveError =
      "Failed to save settings. Please try again.";
  static const String profileUpdated = "Profile updated successfully";
  static const String profileUpdateError =
      "Failed to update profile. Please try again.";
  static const String deleteAccountConfirmation =
      "Are you sure you want to delete your account? This action cannot be undone.";
  static const String cancel = "Cancel";
  static const String delete = "Delete";

  // Edit Profile Messages
  static const String userNotLoggedIn =
      "User not logged in. Please sign in again.";
  static const String profileImageUploadError =
      "Failed to upload profile image. Please try again.";
  static const String userEmailNotFound =
      "User email not found. Please sign in again.";
  static const String networkError =
      "Network error. Please check your internet connection.";
  static const String permissionDenied = "Permission denied. Please try again.";

  // Firebase Service Messages
  static const String signOutError = "Failed to sign out. Please try again.";
  static const String passwordResetEmailSent =
      "Password reset email sent. Please check your inbox.";
  static const String passwordResetEmailError =
      "Failed to send password reset email. Please try again.";
  static const String createDocumentError =
      "Failed to create document. Please try again.";
  static const String getDocumentError =
      "Failed to get document. Please try again.";
  static const String updateDocumentError =
      "Failed to update document. Please try again.";
  static const String deleteDocumentError =
      "Failed to delete document. Please try again.";
  static const String getDocumentsError =
      "Failed to get documents. Please try again.";
  static const String createUserDocumentError =
      "Failed to create user profile. Please try again.";
  static const String updateProfilePermissionDenied =
      "Permission denied. You do not have access to update this profile.";
  static const String updateProfileNotFound =
      "User document not found. Please try again.";
  static const String updateProfileUnavailable =
      "Service unavailable. Please try again later.";
  static const String updateProfileTimeout =
      "Request timeout. Please check your internet connection and try again.";
  static const String uploadFileError =
      "Failed to upload file. Please try again.";
  static const String deleteFileError =
      "Failed to delete file. Please try again.";
  static const String batchOperationError =
      "Failed to perform batch operation. Please try again.";

  // Firebase Auth Exception Messages
  static const String userNotFound = "No user found with this email.";
  static const String wrongPassword = "Wrong password provided.";
  static const String emailAlreadyInUse =
      "An account already exists with this email.";
  static const String weakPassword = "The password provided is too weak.";
  static const String invalidEmail = "The email address is invalid.";
  static const String userDisabled = "This user account has been disabled.";
  static const String tooManyRequests =
      "Too many requests. Please try again later.";
  static const String operationNotAllowed = "This operation is not allowed.";
  static const String authErrorDefault = "An error occurred. Please try again.";

  static const String currentPassword = "Current Password";
  static const String newPassword = "New Password";
  static const String currentPasswordHint = "Enter your current password";
  static const String newPasswordHint = "Enter your new password";
  static const String passwordChanged = "Password changed successfully";
  static const String passwordChangeError =
      "Failed to change password. Please try again.";
  static const String currentPasswordRequired = "Current password is required";
  static const String newPasswordRequired = "New password is required";
  static const String samePasswordError =
      "New password must be different from current password";
  static const String weakPasswordError =
      "Password must be at least 6 characters long";
  static const String reauthenticationRequired =
      "Please enter your current password to continue";
  static const String reauthenticationFailed = "Current password is incorrect";

  // Chat Screen
  static const String typeMessage = "Type a message";
  static const String send = "Send";
  static const String hello = "Hello";
  static const String noMessagesYet = "No messages yet";
  static const String startConversation = "Start a conversation";
  static const String sending = "Sending...";
  static const String sendingDots = "Sending";
  static const String sendMessageError =
      "Failed to send message. Please try again.";
  static const String uploadImageError =
      "Failed to upload image. Please try again.";
  static const String selectImage = "Select Image";
  static const String selectAttachment = "Select Attachment";
  static const String attachFile = "Attach File";
  static const String selectFile = "Select File";
  static const String pdf = "PDF";
  static const String zip = "ZIP";
  static const String reply = "Reply";
  static const String replyingTo = "Replying to";
  static const String today = "Today";
  static const String yesterday = "Yesterday";
  static const String image = "Image";
  static const String file = "File";
  static const String download = "Download";
  static const String open = "Open";
  static const String message = "Message";
  static const String messages = "Messages";
  static const String at = "at";
  static const String copy = "Copy";
  static const String messageCopied = "Message copied to clipboard";
  static const String deleteMessage = "Delete Message";
  static const String deleteMessageConfirmation =
      "Are you sure you want to delete this message? This action cannot be undone.";
  static const String chatNotFound = "Chat not found";
  static const String messageNotFound = "Message not found";
  static const String onlySenderCanDeleteMessage =
      "You can only delete your own messages";
  static const String deleteMessageError = "Failed to delete message";
  static const String messageDeletedSuccessfully =
      "Message deleted successfully";
  static const String imageMessage = "[Image]";
  static const String fileMessage = "[File]";
  static const String forward = "Forward";
  static const String info = "Info";

  // User Detail Screen
  static const String userDetails = "User Details";
  static const String callHistory = "Call History";
  static const String noCallHistory = "No call history available";

  // Calling Screen
  static const String calling = "Calling...";
  static const String incomingCall = "Incoming Call";
  static const String ringing = "Ringing...";
  static const String connected = "Connected";
  static const String callEnded = "Call Ended";
  static const String callRejected = "Call Rejected";
  static const String userBusy = "User Busy";
  static const String callFailed = "Call Failed";
  static const String groupCall = "Group Call";
  static const String participants = "participants";
  static const String accept = "Accept";
  static const String reject = "Reject";
  static const String endCall = "End Call";
  static const String mute = "Mute";
  static const String unmute = "Unmute";
  static const String speaker = "Speaker";
  static const String video = "Video";
  static const String audio = "Audio";
  static const String callPermissionDenied =
      "Microphone permission is required for calls";
  static const String cameraPermissionDenied =
      "Camera permission is required for video calls";
  static const String you = "You";
  static const String callConnectionError =
      "Failed to connect to call. Please check your internet connection.";
  static const String callInitializationError =
      "Failed to start call. Please try again.";
  static const String callNetworkError =
      "Network error. Please check your internet connection.";
  static const String callServiceError =
      "Call service error. Please try again.";
}
