import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';
import 'home.dart';
import 'notification_service.dart';
import 'onboarding.dart';
import 'translator_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
  });

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _fadeController.forward();

    goNext();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> goNext() async {

    await Future.delayed(
      const Duration(
        seconds: 3,
      ),
    );

    if (!mounted) {
      return;
    }

    final prefs =
    await SharedPreferences
        .getInstance();

    // 🔥 pick up any previously-selected language before Home renders
    await TranslatorService().init();

    bool isLoggedIn =
        prefs.getBool(
          "isLoggedIn",
        ) ??
            false;

    Widget nextPage;

    if (isLoggedIn) {

      nextPage =
      const HomePage();

      // 🔥 refresh the saved FCM token on every startup, not just at login --
      // otherwise a token that changes after login (reinstall, OS-level
      // rotation) never reaches the server and push silently stops working
      final userId = prefs.getInt("user_id") ?? 0;

      if (userId != 0) {

        NotificationService.getToken().then((token) {

          if (token.isNotEmpty) {
            ApiService.saveFcmToken(userId, token);
          }
        });
      }

    } else {

      nextPage =
      const OnboardingPage();
    }

    Navigator.pushReplacement(

      context,

      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 550),

        pageBuilder: (_, animation, __) => nextPage,

        transitionsBuilder: (_, animation, __, child) {

          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(
      BuildContext context,
      ) {

    return Scaffold(

      backgroundColor:
      Colors.black,

      body: FadeTransition(

        opacity: _fadeAnimation,

        child: SizedBox.expand(

          child: Image.asset(

            "assets/images/intro.jpeg",

            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
