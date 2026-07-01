import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class RewardsPage
    extends StatelessWidget {

  const RewardsPage({
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

          "Rewards",

          style: TextStyle(

            color:
            Colors.white,

            fontWeight:
            FontWeight.w700,
          ),
        ),
      ),

      body: Center(

        child: Padding(

          padding:
          const EdgeInsets.symmetric(
            horizontal: 28,
          ),

          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,

            children: [

              // 🔥 LOTTIE
              Lottie.asset(

                "assets/images/nodata.json",

                height: 230,

                repeat: true,
              ),

              const SizedBox(
                height: 22,
              ),

              // 🔥 TITLE
              const Text(

                "No Rewards Yet",

                textAlign:
                TextAlign.center,

                style: TextStyle(

                  fontSize: 22,

                  fontWeight:
                  FontWeight.w800,

                  color:
                  Colors.white,
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              // 🔥 SUBTITLE
              const Text(

                "You currently don't have any rewards.\nWatch content, subscribe, and participate in activities to earn rewards.",

                textAlign:
                TextAlign.center,

                style: TextStyle(

                  fontSize: 13,

                  color:
                  Colors.white60,

                  height: 1.6,
                ),
              ),

              const SizedBox(
                height: 30,
              ),

              // 🔥 BUTTON
              SizedBox(

                width:
                double.infinity,

                height: 54,

                child:
                ElevatedButton(

                  onPressed: () {

                    Navigator.pop(
                      context,
                    );
                  },

                  style:
                  ElevatedButton.styleFrom(

                    backgroundColor:
                    const Color(
                      0xFF0A84FF,
                    ),

                    shape:
                    RoundedRectangleBorder(

                      borderRadius:
                      BorderRadius.circular(
                        16,
                      ),
                    ),
                  ),

                  child: const Text(

                    "Explore Content",

                    style: TextStyle(

                      color:
                      Colors.white,

                      fontWeight:
                      FontWeight.w700,

                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}