import 'dart:async';

import 'package:flutter/material.dart';

import 'api_service.dart';
import 'constants.dart';
import 'login.dart';

class OnboardingPage
    extends StatefulWidget {

  const OnboardingPage({
    super.key,
  });

  @override
  State<OnboardingPage> createState() =>
      _OnboardingPageState();
}

class _OnboardingPageState
    extends State<OnboardingPage> {

  final PageController
  _pageController =
  PageController();

  int currentIndex = 0;

  Timer? _timer;

  bool loading = true;

  List banners = [];

  @override
  void initState() {
    super.initState();

    loadBanners();
  }

  Future<void> loadBanners() async {

    banners =
    await ApiService
        .getOnboardingBanners();

    loading = false;

    setState(() {});

    if (banners.isNotEmpty) {

      _startAutoSlide();
    }
  }

  void _startAutoSlide() {

    _timer = Timer.periodic(
      const Duration(seconds: 3),

          (timer) {

        if (currentIndex <
            banners.length - 1) {

          currentIndex++;

        } else {

          currentIndex = 0;
        }

        _pageController
            .animateToPage(

          currentIndex,

          duration:
          const Duration(
            milliseconds: 600,
          ),

          curve:
          Curves.easeInOut,
        );
      },
    );
  }

  void _stopAutoSlide() {

    _timer?.cancel();
  }

  @override
  void dispose() {

    _timer?.cancel();

    _pageController.dispose();

    super.dispose();
  }

  @override
  Widget build(
      BuildContext context,
      ) {

    return Scaffold(

      backgroundColor:
      Colors.black,

      body: loading

          ? const Center(
        child:
        CircularProgressIndicator(),
      )

          : GestureDetector(

        onPanDown:
            (_) =>
            _stopAutoSlide(),

        onPanCancel:
        _startAutoSlide,

        onPanEnd:
            (_) =>
            _startAutoSlide(),

        child:
        PageView.builder(

          controller:
          _pageController,

          itemCount:
          banners.length,

          onPageChanged:
              (index) {

            setState(() {

              currentIndex =
                  index;
            });
          },

          itemBuilder:
              (context, index) {

            final item =
            banners[index];

            return Stack(
              children: [

                // 🔥 IMAGE
                AnimatedScale(
                  scale:
                  currentIndex ==
                      index
                      ? 1.0
                      : 1.08,

                  duration:
                  const Duration(
                    milliseconds:
                    800,
                  ),

                  curve:
                  Curves.easeOut,

                  child:
                  SizedBox.expand(

                    child:
                    Image.network(

                      AppConstants
                          .imageUrl +
                          item[
                          "image"],

                      fit:
                      BoxFit.cover,
                    ),
                  ),
                ),

                // 🔥 OVERLAY
                Positioned.fill(
                  child: Container(
                    decoration:
                    BoxDecoration(
                      gradient:
                      LinearGradient(
                        colors: [

                          Colors.black
                              .withOpacity(
                            0.45,
                          ),

                          Colors
                              .transparent,

                          const Color(
                            0xFFEF4138,
                          ).withOpacity(
                            0.20,
                          ),

                          Colors.black
                              .withOpacity(
                            0.55,
                          ),
                        ],

                        begin:
                        Alignment
                            .topCenter,

                        end:
                        Alignment
                            .bottomCenter,
                      ),
                    ),
                  ),
                ),

                // 🔥 INDICATOR
                Positioned(
                  bottom: 90,
                  left: 0,
                  right: 0,

                  child: Center(
                    child: Container(
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal:
                        14,

                        vertical:
                        8,
                      ),

                      decoration:
                      BoxDecoration(
                        color: Colors
                            .white
                            .withOpacity(
                          0.12,
                        ),

                        borderRadius:
                        BorderRadius.circular(
                          30,
                        ),

                        border:
                        Border.all(
                          color:
                          Colors.white24,
                        ),
                      ),

                      child: Row(
                        mainAxisSize:
                        MainAxisSize.min,

                        children:
                        List.generate(

                          banners.length,

                              (i) => AnimatedContainer(

                            duration:
                            const Duration(
                              milliseconds:
                              300,
                            ),

                            margin:
                            const EdgeInsets.symmetric(
                              horizontal:
                              4,
                            ),

                            width:
                            currentIndex ==
                                i
                                ? 18
                                : 8,

                            height: 8,

                            decoration:
                            BoxDecoration(
                              color:
                              currentIndex ==
                                  i

                                  ? const Color(
                                0xFFEF4138,
                              )
                                  : Colors
                                  .white54,

                              borderRadius:
                              BorderRadius.circular(
                                20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // 🔥 BUTTON
                AnimatedPositioned(

                  duration:
                  const Duration(
                    milliseconds:
                    500,
                  ),

                  curve:
                  Curves.easeOut,

                  bottom:
                  currentIndex ==
                      banners.length -
                          1

                      ? 30
                      : -80,

                  left: 20,
                  right: 20,

                  child:
                  AnimatedOpacity(

                    duration:
                    const Duration(
                      milliseconds:
                      400,
                    ),

                    opacity:
                    currentIndex ==
                        banners.length -
                            1

                        ? 1
                        : 0,

                    child:
                    SizedBox(

                      height: 55,

                      child:
                      ElevatedButton(

                        onPressed: () {

                          Navigator.pushReplacement(
                            context,

                            MaterialPageRoute(
                              builder:
                                  (_) =>
                              const LoginPage(),
                            ),
                          );
                        },

                        style:
                        ElevatedButton.styleFrom(
                          backgroundColor:
                          const Color(
                            0xFFEF4138,
                          ),

                          elevation:
                          8,

                          shadowColor:
                          const Color(
                            0xFFEF4138,
                          ),


                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(
                              18,
                            ),
                          ),
                        ),

                        child:
                        const Text(
                          "Continue",

                          style:
                          TextStyle(
                            fontSize:
                            16,

                            fontWeight:
                            FontWeight.w700,

                            color:
                            Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}