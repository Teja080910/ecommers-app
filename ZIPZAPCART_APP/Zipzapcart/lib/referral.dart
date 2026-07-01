import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'constants.dart';
import 'home.dart';

class ReferralPage extends StatefulWidget {

  final int userId;

  const ReferralPage({
    super.key,
    required this.userId,
  });

  @override
  State<ReferralPage> createState() =>
      _ReferralPageState();
}

class _ReferralPageState
    extends State<ReferralPage> {

  TextEditingController nameController =
  TextEditingController();

  TextEditingController codeController =
  TextEditingController();

  bool loading = false;

  Future<void> saveData() async {

    setState(() => loading = true);

    var response = await http.post(
      Uri.parse(AppConstants.baseUrl),

      body: {

        "action":
        "save_profile_referral",

        "user_id":
        widget.userId.toString(),

        "name":
        nameController.text,

        "sponsor_code":
        codeController.text,
      },
    );

    var data =
    jsonDecode(response.body);

    setState(() => loading = false);

    if (data["status"] == true) {

      Navigator.pushReplacement(
        context,

        MaterialPageRoute(
          builder:
              (_) => const HomePage(),
        ),
      );

    } else {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          backgroundColor: Colors.red,

          content:
          Text(data["message"]),
        ),
      );
    }
  }

  Widget glassInput({

    required TextEditingController
    controller,

    required String hint,

    IconData? icon,

  }) {

    return Container(

      height: 64,

      padding:
      const EdgeInsets.symmetric(
        horizontal: 18,
      ),

      decoration: BoxDecoration(

        borderRadius:
        BorderRadius.circular(22),

        gradient: LinearGradient(
          colors: [

            Colors.white
                .withOpacity(0.18),

            Colors.white
                .withOpacity(0.08),
          ],
        ),

        border: Border.all(
          color:
          Colors.white.withOpacity(
            0.25,
          ),

          width: 1.2,
        ),

        boxShadow: [

          BoxShadow(
            color:
            Colors.black.withOpacity(
              0.18,
            ),

            blurRadius: 18,

            offset:
            const Offset(0, 8),
          ),
        ],
      ),

      child: Row(
        children: [

          Icon(
            icon,
            color: Colors.white,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: TextField(

              controller: controller,

              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight:
                FontWeight.w600,
              ),

              decoration:
              InputDecoration(
                border:
                InputBorder.none,

                hintText: hint,

                hintStyle:
                const TextStyle(
                  color:
                  Colors.white70,

                  fontWeight:
                  FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      resizeToAvoidBottomInset:
      true,

      body: Stack(
        children: [

          // 🔥 BACKGROUND
          Positioned.fill(
            child: Image.asset(
              "assets/images/back.png",

              fit: BoxFit.cover,
            ),
          ),

          // 🔥 OVERLAY
          Positioned.fill(
            child: Container(

              decoration: BoxDecoration(
                gradient: LinearGradient(

                  begin:
                  Alignment.topCenter,

                  end:
                  Alignment.bottomCenter,

                  colors: [

                    Colors.black
                        .withOpacity(
                      0.15,
                    ),

                    Colors.black
                        .withOpacity(
                      0.55,
                    ),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(

            child:
            SingleChildScrollView(

              physics:
              const BouncingScrollPhysics(),

              padding: EdgeInsets.only(

                left: 22,
                right: 22,
                top: 22,

                bottom:
                MediaQuery.of(context)
                    .viewInsets
                    .bottom +
                    22,
              ),

              child: ConstrainedBox(

                constraints: BoxConstraints(
                  minHeight:
                  MediaQuery.of(context)
                      .size
                      .height -
                      60,
                ),

                child: IntrinsicHeight(

                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                    children: [

                      Align(
                        alignment:
                        Alignment.topRight,

                        child: TextButton(

                          onPressed: () {

                            Navigator.pushReplacement(

                              context,

                              MaterialPageRoute(
                                builder:
                                    (_) =>
                                const HomePage(),
                              ),
                            );
                          },

                          child: const Text(
                            "Skip",

                            style: TextStyle(
                              color:
                              Colors.white,

                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const Spacer(),

                      // 🔥 GLASS CARD
                      Container(

                        padding:
                        const EdgeInsets.all(
                          24,
                        ),

                        decoration:
                        BoxDecoration(

                          borderRadius:
                          BorderRadius.circular(
                            34,
                          ),

                          gradient:
                          LinearGradient(

                            begin:
                            Alignment.topLeft,

                            end:
                            Alignment.bottomRight,

                            colors: [

                              Colors.white
                                  .withOpacity(
                                0.18,
                              ),

                              Colors.white
                                  .withOpacity(
                                0.08,
                              ),
                            ],
                          ),

                          border: Border.all(
                            color:
                            Colors.white
                                .withOpacity(
                              0.18,
                            ),
                          ),
                        ),

                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                          children: [

                            const Text(
                              "Complete Profile",

                              style: TextStyle(
                                color:
                                Colors.white,

                                fontSize: 22,

                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),

                            const SizedBox(
                              height: 10,
                            ),

                            Text(
                              "Enter your name and referral code",

                              style: TextStyle(
                                color:
                                Colors.white
                                    .withOpacity(
                                  0.75,
                                ),

                                fontSize: 13,
                              ),
                            ),

                            const SizedBox(
                              height: 30,
                            ),

                            // 🔥 NAME
                            glassInput(
                              controller:
                              nameController,

                              hint:
                              "Enter Full Name",

                              icon:
                              Icons.person,
                            ),

                            const SizedBox(
                              height: 20,
                            ),

                            // 🔥 REFERRAL
                            glassInput(
                              controller:
                              codeController,

                              hint:
                              "Referral Code (Optional)",

                              icon: Icons
                                  .card_giftcard,
                            ),

                            const SizedBox(
                              height: 28,
                            ),

                            SizedBox(
                              width:
                              double.infinity,

                              height: 60,

                              child:
                              ElevatedButton(

                                onPressed: () {

                                  if (nameController
                                      .text
                                      .trim()
                                      .isEmpty) {

                                    ScaffoldMessenger
                                        .of(
                                      context,
                                    )
                                        .showSnackBar(

                                      const SnackBar(
                                        content:
                                        Text(
                                          "Enter your name",
                                        ),
                                      ),
                                    );

                                    return;
                                  }

                                  saveData();
                                },

                                style:
                                ElevatedButton.styleFrom(

                                  elevation: 10,

                                  backgroundColor:
                                  const Color(
                                    0xFFFFB800,
                                  ),

                                  foregroundColor:
                                  const Color(
                                    0xFF0A2A75,
                                  ),

                                  shadowColor:
                                  const Color(
                                    0xFFFFB800,
                                  ).withOpacity(
                                    0.5,
                                  ),

                                  shape:
                                  RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(
                                      22,
                                    ),
                                  ),
                                ),

                                child: loading

                                    ? const SizedBox(
                                  height: 22,
                                  width: 22,

                                  child:
                                  CircularProgressIndicator(
                                    color:
                                    Colors.white,

                                    strokeWidth:
                                    2.5,
                                  ),
                                )

                                    : const Text(
                                  "Continue",

                                  style:
                                  TextStyle(
                                    fontSize:
                                    16,

                                    fontWeight:
                                    FontWeight
                                        .bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 🔥 LOADER
          if (loading)

            Container(
              color: Colors.black54,

              child: const Center(
                child:
                CircularProgressIndicator(
                  color:
                  Color(0xFFFFB800),
                ),
              ),
            ),
        ],
      ),
    );
  }
}