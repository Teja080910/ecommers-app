import 'package:flutter/material.dart';

class AboutAppPage
    extends StatelessWidget {

  const AboutAppPage({
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

          "About App",

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

            // 🔥 APP LOGO
            Center(

              child: Container(

                height: 110,
                width: 110,

                decoration:
                BoxDecoration(

                  color:
                  const Color(
                    0xFF151515,
                  ),

                  borderRadius:
                  BorderRadius.circular(
                    28,
                  ),
                ),

                child: Padding(

                  padding:
                  const EdgeInsets.all(
                    18,
                  ),

                  child: Image.asset(
                    "assets/images/logo-white.png",
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            const Center(

              child: Text(

                "Zenvora OTT",

                style: TextStyle(

                  color:
                  Colors.white,

                  fontSize: 28,

                  fontWeight:
                  FontWeight.w800,
                ),
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            const Center(

              child: Text(

                "Entertainment • Movies • Shorts • Web Series",

                textAlign:
                TextAlign.center,

                style: TextStyle(

                  color:
                  Colors.white60,

                  fontSize: 13,
                ),
              ),
            ),

            const SizedBox(
              height: 34,
            ),

            sectionTitle(
              "About Zenvora OTT",
            ),

            sectionText(

              "Zenvora OTT is an all-in-one entertainment platform designed for streaming movies, web series, shorts, and exclusive digital content. The platform also includes casting opportunities, creator features, and premium OTT experiences.",
            ),

            sectionTitle(
              "Features",
            ),

            featureTile(
              Icons.movie_creation_outlined,
              "Watch Movies & Web Series",
            ),

            featureTile(
              Icons.smart_display_outlined,
              "Short Videos & Reels",
            ),

            featureTile(
              Icons.workspace_premium_outlined,
              "Premium OTT Membership",
            ),

            featureTile(
              Icons.live_tv_outlined,
              "Exclusive OTT Originals",
            ),

            featureTile(
              Icons.person_search_outlined,
              "Casting & Talent Auditions",
            ),

            featureTile(
              Icons.favorite_border,
              "Wishlist & Watch History",
            ),

            const SizedBox(
              height: 24,
            ),

            sectionTitle(
              "Our Mission",
            ),

            sectionText(

              "Our mission is to create a modern entertainment ecosystem where viewers, creators, actors, and filmmakers can connect through one powerful digital platform.",
            ),

            sectionTitle(
              "Technology",
            ),

            sectionText(

              "Zenvora OTT is built using Flutter, PHP APIs, cloud streaming technology, Razorpay payment integration, and modern OTT architecture for smooth and secure entertainment experiences.",
            ),

            sectionTitle(
              "Version",
            ),

            const Text(

              "Version 1.0.0",

              style: TextStyle(

                color:
                Color(0xFF0A84FF),

                fontSize: 15,

                fontWeight:
                FontWeight.w700,
              ),
            ),

            const SizedBox(
              height: 30,
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

                    Icons.verified,

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

                    "Made With ❤️ For Entertainment",

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

                    "Thank you for choosing Zenvora OTT.",

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
        bottom: 12,
        top: 18,
      ),

      child: Text(

        title,

        style: const TextStyle(

          color:
          Colors.white,

          fontSize: 18,

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

  Widget featureTile(
      IconData icon,
      String title,
      ) {

    return Container(

      margin:
      const EdgeInsets.only(
        bottom: 12,
      ),

      padding:
      const EdgeInsets.all(14),

      decoration:
      BoxDecoration(

        color:
        const Color(
          0xFF141414,
        ),

        borderRadius:
        BorderRadius.circular(
          16,
        ),
      ),

      child: Row(
        children: [

          Container(

            height: 42,
            width: 42,

            decoration:
            BoxDecoration(

              color:
              const Color(
                0x220A84FF,
              ),

              borderRadius:
              BorderRadius.circular(
                12,
              ),
            ),

            child: Icon(

              icon,

              color:
              const Color(
                0xFF0A84FF,
              ),
            ),
          ),

          const SizedBox(
            width: 14,
          ),

          Expanded(

            child: Text(

              title,

              style:
              const TextStyle(

                color:
                Colors.white,

                fontSize: 14,

                fontWeight:
                FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}