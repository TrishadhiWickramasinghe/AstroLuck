import 'package:flutter/material.dart';
import '../features/splash/splash_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/auth/profile_setup_screen.dart';
import '../features/home/home_screen.dart';
import '../features/lottery/lottery_generator_screen.dart';
import '../features/history/history_screen.dart';
import '../features/settings/settings_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String profileSetup = '/profile-setup';
  static const String home = '/';
  static const String lotteryGenerator = '/lottery-generator';
  static const String history = '/history';
  static const String settings = '/settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final name = settings.name ?? splash;
    if (name == splash) {
      return MaterialPageRoute(builder: (_) => const SplashScreen());
    } else if (name == onboarding) {
      return MaterialPageRoute(builder: (_) => const OnboardingScreen());
    } else if (name == profileSetup) {
      return MaterialPageRoute(
        builder: (_) => const ProfileSetupScreen(isEditing: false),
      );
    } else if (name == home) {
      return MaterialPageRoute(builder: (_) => const HomeScreen());
    } else if (name == lotteryGenerator) {
      return MaterialPageRoute(builder: (_) => const LotteryGeneratorScreen());
    } else if (name == history) {
      return MaterialPageRoute(builder: (_) => const HistoryScreen());
    } else if (name == settings) {
      return MaterialPageRoute(builder: (_) => const SettingsScreen());
    } else {
      return MaterialPageRoute(
        builder: (_) => Scaffold(
          body: Center(
            child: Text('No route defined for ${settings.name}'),
          ),
        ),
      );
    }
  }
}
