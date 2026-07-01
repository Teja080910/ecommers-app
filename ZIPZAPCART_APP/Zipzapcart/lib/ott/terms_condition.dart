import 'package:flutter/material.dart';

class TermsConditionPage
    extends StatelessWidget {

  const TermsConditionPage({
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

          "Terms and Conditions",

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

              "Zenvora OTT Terms & Conditions",

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
              "1. Acceptance of Terms",
            ),

            sectionText(

              "By accessing or using Zenvora OTT, you agree to comply with these Terms & Conditions. If you do not agree, please discontinue using the platform immediately.",
            ),

            sectionTitle(
              "2. Subscription & Payments",
            ),

            sectionText(

              "Some content on Zenvora OTT requires a premium subscription. Payments made through Razorpay are secure and non-refundable unless required by law.",
            ),

            sectionTitle(
              "3. User Accounts",
            ),

            sectionText(

              "Users are responsible for maintaining the confidentiality of their account credentials. Sharing accounts or unauthorized access may result in suspension.",
            ),

            sectionTitle(
              "4. Content Usage",
            ),

            sectionText(

              "All movies, web series, shorts, graphics, logos, and content available on Zenvora OTT are protected under copyright laws. Downloading, recording, or redistributing content without permission is prohibited.",
            ),

            sectionTitle(
              "5. OTT Streaming",
            ),

            sectionText(

              "Streaming quality may vary depending on your internet speed and device compatibility. Zenvora OTT is not responsible for interruptions caused by network issues.",
            ),

            sectionTitle(
              "6. Casting & Applications",
            ),

            sectionText(

              "Users applying for casting opportunities must provide authentic information. Fake applications, impersonation, or misleading submissions may lead to permanent bans.",
            ),

            sectionTitle(
              "7. Community Guidelines",
            ),

            sectionText(

              "Users must not upload harmful, offensive, abusive, or illegal content on the platform. Violation may result in legal action and account termination.",
            ),

            sectionTitle(
              "8. Privacy Policy",
            ),

            sectionText(

              "Your personal information is securely stored and used only for service-related purposes. Zenvora OTT does not sell user data to third parties.",
            ),

            sectionTitle(
              "9. Refund Policy",
            ),

            sectionText(

              "Subscription plans and digital purchases are generally non-refundable. Refund requests are reviewed only under exceptional circumstances.",
            ),

            sectionTitle(
              "10. Changes to Terms",
            ),

            sectionText(

              "Zenvora OTT reserves the right to modify these Terms & Conditions at any time. Continued usage of the platform after updates implies acceptance of revised terms.",
            ),

            sectionTitle(
              "11. Contact Information",
            ),

            sectionText(

              "For support, queries, or legal concerns regarding Zenvora OTT, users may contact the official support team through the app.",
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

                    Icons.verified_user,

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

                    "Thank You For Using Zenvora OTT",

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

                    "Enjoy premium entertainment securely with Zenvora OTT.",

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