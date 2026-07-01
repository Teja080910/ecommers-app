import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

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
          "About App",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🔥 APP CARD
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                children: [

                  // 🔥 LOGO
                  Container(
                    width: 64,
                    height: 64,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FB),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Image.asset(
                      "assets/logo.png",
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(width: 14),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "ZIPZAPCART",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),

                        SizedBox(height: 4),

                        Text(
                          "Shop Smarter. Smile From A to Z.",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            _sectionTitle("About Us"),
            _sectionText(
              "ZIPZAPCART is your all-in-one online shopping destination for fashion, electronics, beauty, home essentials, accessories, and more. We focus on delivering quality products, trusted shopping, and a premium customer experience.",
            ),

            const SizedBox(height: 18),

            _sectionTitle("Our Mission"),
            _sectionText(
              "To make online shopping smarter, faster, and more reliable by offering quality products with seamless delivery and excellent customer support.",
            ),

            const SizedBox(height: 18),

            _sectionTitle("Why Choose ZIPZAPCART"),
            _sectionText(
              "• Wide range of quality products\n"
                  "• Fast and secure delivery\n"
                  "• Trusted and safe payments\n"
                  "• Easy shopping experience\n"
                  "• 24/7 customer support\n"
                  "• Best deals and discounts",
            ),

            const SizedBox(height: 18),

            _sectionTitle("Our Promise"),
            _sectionText(
              "At ZIPZAPCART, customer satisfaction comes first. We continuously work to provide a smooth, secure, and enjoyable shopping experience for every user.",
            ),

            const SizedBox(height: 18),

            _sectionTitle("App Version"),
            _sectionText("Version 1.0.0"),

            const SizedBox(height: 24),

            const Center(
              child: Text(
                "© 2026 ZIPZAPCART. All rights reserved.",
                style: TextStyle(
                  fontSize: 11.5,
                  color: Colors.black45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 TITLE
  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: Color(0xFF111111),
      ),
    );
  }

  // 🔥 BODY TEXT
  Widget _sectionText(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12.8,
          color: Colors.black87,
          height: 1.55,
        ),
      ),
    );
  }
}