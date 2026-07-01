import 'package:flutter/material.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

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
          "Terms & Policies",
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

            _sectionTitle("Welcome to ZIPZAPCART"),

            _sectionText(
              "ZIPZAPCART is an online shopping platform offering fashion, electronics, beauty, accessories, home essentials, and more. By using our app, you agree to the following terms and conditions.",
            ),

            const SizedBox(height: 16),

            _sectionTitle("1. Orders & Delivery"),

            _sectionText(
              "• Orders are delivered based on serviceable locations.\n"
                  "• Delivery time may vary depending on product availability and logistics.\n"
                  "• Users must provide accurate address and contact details.\n"
                  "• Delays may occur due to weather, traffic, or operational issues.",
            ),

            const SizedBox(height: 16),

            _sectionTitle("2. Products & Quality"),

            _sectionText(
              "• We strive to provide high-quality and genuine products.\n"
                  "• Product colors and appearance may slightly vary from images.\n"
                  "• Product availability may change without prior notice.",
            ),

            const SizedBox(height: 16),

            _sectionTitle("3. Pricing & Payments"),

            _sectionText(
              "• Prices may change without prior notice.\n"
                  "• Payments can be made using UPI, debit/credit cards, net banking, or wallets.\n"
                  "• Orders will be confirmed only after successful payment verification.",
            ),

            const SizedBox(height: 16),

            _sectionTitle("4. Cancellation & Refund"),

            _sectionText(
              "• Orders can be cancelled before shipment.\n"
                  "• Refunds (if applicable) will be processed within 3–7 working days.\n"
                  "• Some products may not be eligible for return or refund.",
            ),

            const SizedBox(height: 16),

            _sectionTitle("5. User Responsibility"),

            _sectionText(
              "• Users must not misuse the platform.\n"
                  "• Providing false information may result in account suspension.\n"
                  "• Users are responsible for maintaining account confidentiality.",
            ),

            const SizedBox(height: 16),

            _sectionTitle("6. Privacy Policy"),

            _sectionText(
              "• Your personal information is kept secure and used only for order processing and service improvement.\n"
                  "• We do not share personal data with third parties without user consent.",
            ),

            const SizedBox(height: 16),

            _sectionTitle("7. Changes to Terms"),

            _sectionText(
              "ZIPZAPCART reserves the right to modify or update these terms and policies at any time without prior notice.",
            ),

            const SizedBox(height: 24),

            const Center(
              child: Text(
                "© 2026 ZIPZAPCART. All rights reserved.",
                style: TextStyle(
                  color: Colors.black45,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 TITLE STYLE
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

  // 🔥 BODY TEXT STYLE
  Widget _sectionText(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12.8,
          color: Colors.black87,
          height: 1.5,
        ),
      ),
    );
  }
}