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

            const _PulsingDotsLoader(
              color: Color(0xFFEF4138),
            ),

          ],
        ),
      ),
    );
  }
}

class _PulsingDotsLoader extends StatefulWidget {

  final Color color;

  const _PulsingDotsLoader({
    required this.color,
  });

  @override
  State<_PulsingDotsLoader> createState() =>
      _PulsingDotsLoaderState();
}

class _PulsingDotsLoaderState
    extends State<_PulsingDotsLoader>
    with SingleTickerProviderStateMixin {

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _scaleFor(int index) {

    final t = (_controller.value - (index * 0.2)) % 1.0;

    final bump = (1 - (t - 0.5).abs() * 2).clamp(0.0, 1.0);

    return 0.6 + (bump * 0.6);
  }

  @override
  Widget build(BuildContext context) {

    return AnimatedBuilder(
      animation: _controller,

      builder: (_, __) {

        return Row(
          mainAxisSize: MainAxisSize.min,

          children: List.generate(3, (index) {

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),

              child: Transform.scale(
                scale: _scaleFor(index),

                child: Container(
                  width: 10,
                  height: 10,

                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}