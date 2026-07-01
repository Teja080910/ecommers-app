import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

class NotAvailablePage extends StatelessWidget {
  const NotAvailablePage({super.key});

  Future<bool> _onBackPressed(BuildContext context) async {
    final shouldExit = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text("Exit App"),
        content: const Text("Are you sure you want to exit?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0A7A40),
            ),
            child: const Text("Exit"),
          ),
        ],
      ),
    );

    if (shouldExit == true) {
      SystemNavigator.pop();
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onBackPressed(context),
      child: Scaffold(
        body: Stack(
          children: [
            // 🔥 Gradient Background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFE8F5E9),
                    Color(0xFFF1F8F4),
                    Colors.white,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // 🔥 Center Content
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 🎯 Lottie Animation
                    SizedBox(
                      height: 220,
                      child: Lottie.asset(
                        "assets/images/location.json",
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // 🔥 Title
                    const Text(
                      "Service Not Available",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF101828),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // 🔥 Subtitle
                    const Text(
                      "We currently don’t deliver to your area.\nBut we’re expanding fast 🚀",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Color(0xFF667085),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // 🔥 Button Row
                    Row(
                      children: [
                        // Retry




                        // Exit
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              SystemNavigator.pop();
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(
                                color: Color(0xFF0A7A40),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              "Exit",
                              style: TextStyle(
                                color: Color(0xFF0A7A40),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // 🔥 Small hint
                    const Text(
                      "Available only in selected pincodes",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}