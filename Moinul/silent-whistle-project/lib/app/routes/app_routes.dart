import 'package:flutter/cupertino.dart';
import 'package:jwells/features/auth/presentation/views/screens/forgot_password_otp_screen.dart';
import 'package:jwells/features/auth/presentation/views/screens/forgot_password_screen.dart';
import 'package:jwells/features/auth/presentation/views/screens/login_screen.dart';
import 'package:jwells/features/auth/presentation/views/screens/otp_screen.dart';
import 'package:jwells/features/auth/presentation/views/screens/set_new_password_screen.dart';
import 'package:jwells/features/auth/presentation/views/screens/signup_screen.dart';
import 'package:jwells/features/onboarding/presentation/view/screens/onboarding_screen.dart';
import 'package:jwells/features/profile/presentation/view/screens/profile_screen.dart';
import 'package:jwells/features/profile/presentation/view/screens/personal_info.dart';

import '../../core/constant/route_names.dart';
import '../../features/auth/presentation/views/screens/edit_profile_screen.dart';
import '../../features/home/presentation/view/screen/home_screen.dart';
import '../../features/parent/screen/parent_screen.dart';
import '../../features/profile/presentation/view/screens/other_user_profile.dart';
import '../../features/profile/presentation/view/screens/setting_screen.dart';
import '../../features/splash/splash_screen.dart';

class AppRoutes {
  static const String initialRoute = RouteNames.splashScreen;

  static final Map<String, WidgetBuilder> routes = {
    RouteNames.splashScreen: (context) => const SplashScreen(),
    RouteNames.home: (context) => const HomeScreen(),
    RouteNames.parentScreen: (context) => const ParentScreen(),
    // RouteNames.otpScreen: (context) => const OTPScreen(),
    RouteNames.forgotPasswordScreen: (context) => const ForgotPasswordScreen(),
    RouteNames.setPasswordScreen: (context) => const SetNewPasswordScreen(),
    RouteNames.forgotPasswordOtpScreen: (context) =>
        const ForgotPasswordOtpScreen(),
    RouteNames.settingScreen: (context) => const SettingScreen(),
    RouteNames.otherUserProfile: (context) => const OtherUserProfile(),

    RouteNames.loginScreen: (context) => const LoginScreen(),
    RouteNames.onboardingScreen: (context) => const OnboardingScreen(),
    RouteNames.signUpScreen: (context) => const SignUpScreen(),
    RouteNames.editProfileScreen: (context) => const EditProfileScreen(),
    RouteNames.personalInfo: (context) => const PersonalInfo(),
  };
}
