class AppString {
  static const String appName = "Apna Chat";
  
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
  static const String alreadyHaveAccount = "Already have an account? ";
  static const String agreeToTerms = "I agree to the ";
  static const String termsAndConditions = "Terms & Conditions";
  static const String and = " and ";
  static const String privacyPolicy = "Privacy Policy";
  
  // Validation Messages
  static const String emailRequired = "Email is required";
  static const String emailInvalid = "Please enter a valid email";
  static const String passwordRequired = "Password is required";
  static const String passwordMinLength = "Password must be at least 6 characters";
  static const String nameRequired = "Name is required";
  static const String nameMinLength = "Name must be at least 3 characters";
  static const String confirmPasswordRequired = "Please confirm your password";
  static const String passwordsDoNotMatch = "Passwords do not match";
  static const String termsRequired = "Please accept the terms and conditions";
  static const String phoneRequired = "Phone number is required";
  static const String phoneInvalid = "Please enter a valid phone number";
  
  // Success/Error Messages
  static const String signInSuccess = "Signed in successfully";
  static const String signInError = "Failed to sign in. Please try again.";
  static const String signUpSuccess = "Account created successfully";
  static const String signUpError = "Failed to create account. Please try again.";
  
  // Snackbar Titles
  static const String successTitle = "Success";
  static const String errorTitle = "Error";
  static const String infoTitle = "Info";
  static const String warningTitle = "Warning";
  
  // Image Picker Messages
  static const String imagePickGalleryError = "Failed to pick image from gallery. Please try again.";
  static const String imagePickCameraError = "Failed to capture image. Please try again.";
  static const String imagePickMultipleError = "Failed to pick images. Please try again.";
  static const String videoPickGalleryError = "Failed to pick video. Please try again.";
  static const String videoPickCameraError = "Failed to record video. Please try again.";
  static const String selectImageSource = "Select Image Source";
  static const String selectVideoSource = "Select Video Source";
  static const String selectMultipleImages = "Select Multiple Images";
  static const String gallery = "Gallery";
  static const String camera = "Camera";
  
  // File Picker Messages
  static const String filePickPDFError = "Failed to pick PDF file. Please try again.";
  static const String filePickZIPError = "Failed to pick ZIP file. Please try again.";
  static const String filePickError = "Failed to pick file. Please try again.";
  static const String filePickMultipleError = "Failed to pick files. Please try again.";
  
  // Forgot Password Screen
  static const String forgotPasswordTitle = "Forgot Password?";
  static const String forgotPasswordSubtitle = "Don't worry! Enter your email and we'll send you a link to reset your password.";
  static const String sendResetLink = "Send Reset Link";
  static const String backToSignIn = "Back to Sign In";
  static const String emailSentTitle = "Check Your Email";
  static String emailSentDescription(String email) => "We've sent a password reset link to $email. Please check your inbox and follow the instructions.";
  static const String resendEmail = "Resend Email";
  
  // Feature Coming Soon Messages
  static const String forgotPasswordComingSoon = "Forgot password screen coming soon";
  static const String signUpComingSoon = "Sign up screen coming soon";
  static const String featureComingSoon = "Feature coming soon";
  
  // General Messages
  static const String somethingWentWrong = "Something went wrong. Please try again.";
  static const String operationSuccess = "Operation completed successfully";
  static const String operationFailed = "Operation failed. Please try again.";
  static const String pleaseTryAgain = "Please try again";
  
  // Home Screen
  static const String home = "Home";
  static const String myContacts = "My Contacts";
  static const String myGroups = "My Groups";
  static const String addedUsers = "Added Users";
  static const String createdGroups = "Created Groups";
  static const String noUsersFound = "No users found";
  static const String noGroupsFound = "No groups found";
  static const String online = "Online";
  static const String offline = "Offline";
  static const String lastSeen = "Last seen";
  static const String members = "Members";
  static const String created = "Created";
  static const String pullToRefresh = "Pull to refresh";
}