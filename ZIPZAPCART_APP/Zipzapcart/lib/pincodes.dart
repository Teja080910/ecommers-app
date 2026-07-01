import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class PincodePage extends StatelessWidget {
  const PincodePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),

      // 🔥 PREMIUM APPBAR
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          "Delivery Area",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),

      // 🔥 EMPTY STATE (NO BUTTON)
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // 🔥 LOTTIE ANIMATION
              Lottie.asset(
                "assets/images/nodata.json",
                height: 230,
              ),

              const SizedBox(height: 20),

              // 🔥 TITLE
              const Text(
                "No Delivery Area Selected",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111111),
                ),
              ),

              const SizedBox(height: 8),

              // 🔥 SUBTITLE
              const Text(
                "Please select your pincode to check\navailability of services in your area.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}