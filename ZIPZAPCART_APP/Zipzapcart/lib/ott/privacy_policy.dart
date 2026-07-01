import 'package:flutter/material.dart';

class PrivacyPolicyPage
    extends StatelessWidget {

  const PrivacyPolicyPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      Colors.black,

      appBar: AppBar(

        backgroundColor:
        Colors.black,

        elevation: 0,

        iconTheme:
        const IconThemeData(

          color: Colors.white,
        ),

        title: const Text(

          "Privacy Policy",

          style: TextStyle(

            color:
            Colors.white,

            fontWeight:
            FontWeight.w700,
          ),
        ),
      ),

      body: SingleChildScrollView(

        padding:
        const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            const Text(

              "Zenvora OTT Privacy Policy",

              style: TextStyle(

                color:
                Colors.white,

                fontSize: 22,

                fontWeight:
                FontWeight.w800,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            const Text(

              "Last Updated: May 2026",

              style: TextStyle(
                color:
                Colors.white54,
              ),
            ),

            const SizedBox(
              height: 28,
            ),

            sectionTitle(
              "1. Introduction",
            ),

            sectionText(

              "Zenvora OTT values your privacy and is committed to protecting your personal information. This Privacy Policy explains how we collect, use, and safeguard your data.",
            ),

            sectionTitle(
              "2. Information We Collect",
            ),

            sectionText(

              "We may collect information such as your name, phone number, email address, profile photo, subscription details, watch history, and device information when you use Zenvora OTT.",
            ),

            sectionTitle(
              "3. How We Use Your Information",
            ),

            sectionText(

              "Your information is used to provide streaming services, improve app performance, personalize content recommendations, process payments, and enhance user experience.",
            ),

            sectionTitle(
              "4. Payment Security",
            ),

            sectionText(

              "Payments are securely processed using trusted payment gateways like Razorpay. Zenvora OTT does not store your card or banking information on its servers.",
            ),

            sectionTitle(
              "5. OTT Viewing Data",
            ),

            sectionText(

              "We may store your watch history, watch progress, likes, wishlist, and subscription activity to improve recommendations and continue playback features.",
            ),

            sectionTitle(
              "6. Casting Applications",
            ),

            sectionText(

              "Information submitted for casting applications, including photos and videos, is used only for audition and talent evaluation purposes.",
            ),

            sectionTitle(
              "7. Data Protection",
            ),

            sectionText(

              "We implement appropriate security measures to protect your information from unauthorized access, misuse, or disclosure.",
            ),

            sectionTitle(
              "8. Third-Party Services",
            ),

            sectionText(

              "Zenvora OTT may use third-party services such as Firebase, Razorpay, analytics providers, and cloud hosting services to operate the platform efficiently.",
            ),

            sectionTitle(
              "9. Cookies & Analytics",
            ),

            sectionText(

              "We may use cookies, analytics, and device identifiers to understand user behavior and improve platform performance and recommendations.",
            ),

            sectionTitle(
              "10. Account Deletion",
            ),

            sectionText(

              "Users may request account deletion by contacting support. Certain transaction or legal records may be retained as required by law.",
            ),

            sectionTitle(
              "11. Children's Privacy",
            ),

            sectionText(

              "Zenvora OTT is not intended for children under 13 years of age without parental supervision.",
            ),

            sectionTitle(
              "12. Changes to Privacy Policy",
            ),

            sectionText(

              "We reserve the right to update this Privacy Policy at any time. Continued use of the platform after updates indicates acceptance of revised policies.",
            ),

            sectionTitle(
              "13. Contact Us",
            ),

            sectionText(

              "For privacy-related concerns or support, users can contact the Zenvora OTT support team through the application.",
            ),

            const SizedBox(
              height: 40,
            ),

            Container(

              width: double.infinity,

              padding:
              const EdgeInsets.all(18),

              decoration:
              BoxDecoration(

                color:
                const Color(
                  0xFF111111,
                ),

                borderRadius:
                BorderRadius.circular(
                  18,
                ),

                border:
                Border.all(
                  color:
                  Colors.white10,
                ),
              ),

              child: const Column(
                children: [

                  Icon(

                    Icons.lock,

                    color:
                    Color(
                      0xFF0A84FF,
                    ),

                    size: 42,
                  ),

                  SizedBox(
                    height: 14,
                  ),

                  Text(

                    "Your Privacy Matters",

                    textAlign:
                    TextAlign.center,

                    style: TextStyle(

                      color:
                      Colors.white,

                      fontSize: 16,

                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),

                  SizedBox(
                    height: 8,
                  ),

                  Text(

                    "Zenvora OTT is committed to keeping your data secure and protected.",

                    textAlign:
                    TextAlign.center,

                    style: TextStyle(

                      color:
                      Colors.white60,

                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }

  Widget sectionTitle(
      String title,
      ) {

    return Padding(

      padding:
      const EdgeInsets.only(
        bottom: 10,
        top: 14,
      ),

      child: Text(

        title,

        style: const TextStyle(

          color:
          Colors.white,

          fontSize: 17,

          fontWeight:
          FontWeight.w700,
        ),
      ),
    );
  }

  Widget sectionText(
      String text,
      ) {

    return Text(

      text,

      style: const TextStyle(

        color:
        Colors.white70,

        fontSize: 14,

        height: 1.7,
      ),
    );
  }
}