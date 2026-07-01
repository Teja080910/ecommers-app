import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../api_service.dart';
import '../constants.dart';
import 'playzhaphat.dart';

class ZhatpatPage extends StatefulWidget {

  const ZhatpatPage({super.key});

  @override
  State<ZhatpatPage> createState() =>
      _ZhatpatPageState();
}

class _ZhatpatPageState
    extends State<ZhatpatPage>
    with SingleTickerProviderStateMixin {

  late final AnimationController
  _shimmerController;

  bool loading = true;

  List series = [];

  @override
  void initState() {
    super.initState();

    _shimmerController =
    AnimationController(

      vsync: this,

      duration:
      const Duration(
        milliseconds: 1400,
      ),
    )..repeat();

    loadSeries();
  }

  Future<void> loadSeries() async {

    final data =
    await ApiService
        .getZhatpatSeries();

    series =
        data["series"] ?? [];

    loading = false;

    setState(() {});
  }

  @override
  void dispose() {

    _shimmerController.dispose();

    super.dispose();
  }

  @override
  Widget build(
      BuildContext context,
      ) {

    return Scaffold(

      backgroundColor:
      Colors.black,

      appBar: AppBar(

        backgroundColor:
        Colors.black,

        elevation: 0,

        automaticallyImplyLeading:
        false,

        titleSpacing: 16,

        title: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            ShaderMask(

              shaderCallback:
                  (bounds) =>
                  const LinearGradient(

                    colors: [

                      Color(
                        0xFFFF3D68,
                      ),

                      Color(
                        0xFFFFC107,
                      ),
                    ],
                  ).createShader(
                    bounds,
                  ),

              child:
              const Text(

                "Zenvora Short Webseries",

                style: TextStyle(

                  fontSize: 20,

                  fontWeight:
                  FontWeight.w800,

                  color:
                  Colors.white,
                ),
              ),
            ),

            const SizedBox(
              height: 2,
            ),

            const Text(

              "Trending Now 🔥",

              style: TextStyle(

                color:
                Colors.white70,

                fontSize:
                12.5,

                fontWeight:
                FontWeight.w500,
              ),
            ),
          ],
        ),
      ),

      body: loading

          ? GridView.builder(

        padding:
        const EdgeInsets.fromLTRB(
          14,
          8,
          14,
          20,
        ),

        itemCount: 8,

        gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(

          crossAxisCount: 2,

          crossAxisSpacing: 12,

          mainAxisSpacing: 16,

          childAspectRatio: 0.62,
        ),

        itemBuilder:
            (_, __) =>
            _ShimmerCard(
              controller:
              _shimmerController,
            ),
      )

          : GridView.builder(

        padding:
        const EdgeInsets.fromLTRB(
          14,
          8,
          14,
          20,
        ),

        itemCount:
        series.length,

        gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(

          crossAxisCount: 2,

          crossAxisSpacing: 12,

          mainAxisSpacing: 16,

          childAspectRatio: 0.62,
        ),

        itemBuilder:
            (context, index) {

          final item =
          series[index];

          return GestureDetector(

            onTap: () {

              Navigator.push(

                context,

                MaterialPageRoute(

                  builder:
                      (_) =>
                      PlayZhatphatPage(

                        zhatpatId:
                        item["id"]
                            .toString(),

                        title:
                        item["title"],
                      ),
                ),
              );
            },

            child: Container(

              decoration:
              BoxDecoration(

                borderRadius:
                BorderRadius.circular(
                  16,
                ),

                color:
                const Color(
                  0xFF101010,
                ),
              ),

              clipBehavior:
              Clip.antiAlias,

              child: Stack(
                fit:
                StackFit.expand,

                children: [

                  CachedNetworkImage(

                    imageUrl:
                    AppConstants.imageUrl +
                        item[
                        "verticalposter"],

                    fit:
                    BoxFit.cover,

                    placeholder:
                        (_, __) =>
                        _ShimmerCard(
                          controller:
                          _shimmerController,
                        ),

                    errorWidget:
                        (_, __, ___) =>
                        Container(
                          color:
                          Colors.black26,
                        ),
                  ),

                  Container(

                    decoration:
                    const BoxDecoration(

                      gradient:
                      LinearGradient(

                        begin:
                        Alignment.topCenter,

                        end:
                        Alignment.bottomCenter,

                        colors: [

                          Color(
                            0x22000000,
                          ),

                          Colors.transparent,

                          Color(
                            0xDD000000,
                          ),
                        ],
                      ),
                    ),
                  ),

                  Positioned(

                    top: 10,
                    right: 10,

                    child: Container(

                      padding:
                      const EdgeInsets.symmetric(

                        horizontal:
                        10,

                        vertical:
                        6,
                      ),

                      decoration:
                      BoxDecoration(

                        color:
                        Colors.black
                            .withOpacity(
                          0.75,
                        ),

                        borderRadius:
                        BorderRadius.circular(
                          30,
                        ),
                      ),

                      child: Text(

                        "${item["no_of_episode"]} Episodes",

                        style:
                        const TextStyle(

                          color:
                          Colors.white,

                          fontSize:
                          11,

                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  Positioned(

                    left: 12,
                    bottom: 12,
                    right: 12,

                    child: Text(

                      item["title"],

                      style:
                      const TextStyle(

                        color:
                        Colors.white,

                        fontSize:
                        18,

                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ShimmerCard
    extends StatelessWidget {

  final AnimationController
  controller;

  const _ShimmerCard({
    required this.controller,
  });

  @override
  Widget build(
      BuildContext context,
      ) {

    return AnimatedBuilder(

      animation: controller,

      builder:
          (context, child) {

        return Container(

          decoration:
          BoxDecoration(

            borderRadius:
            BorderRadius.circular(
              16,
            ),

            gradient:
            LinearGradient(

              begin:
              Alignment(
                -1 +
                    controller.value *
                        2,
                0,
              ),

              end:
              Alignment(
                1 +
                    controller.value *
                        2,
                0,
              ),

              colors: const [

                Color(
                  0xFF141414,
                ),

                Color(
                  0xFF2A2A2A,
                ),

                Color(
                  0xFF141414,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}