import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';
import 'onboarding.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
  });

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    goNext();
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

    bool isLoggedIn =
        prefs.getBool(
          "isLoggedIn",
        ) ??
            false;

    Widget nextPage;

    if (isLoggedIn) {

      nextPage =
      const HomePage();

    } else {

      nextPage =
      const OnboardingPage();
    }

    Navigator.pushReplacement(

      context,

      MaterialPageRoute(
        builder:
            (_) => nextPage,
      ),
    );
  }

  @override
  Widget build(
      BuildContext context,
      ) {

    return Scaffold(

      backgroundColor:
      Colors.white,

      body:

      Center(

        child:

        Column(

          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [

            FittedBox(

              fit: BoxFit.contain,

              child: Image.asset(

                "assets/logo.png",

                width: 220,

              ),
            ),

            const SizedBox(
              height: 40,
            ),

            const SizedBox(

              width: 34,
              height: 34,

              child:
              CircularProgressIndicator(

                color:
                Color(
                  0xFFEF4138,
                ),

                strokeWidth:
                3,

              ),

            ),

          ],
        ),
      ),
    );
  }
}