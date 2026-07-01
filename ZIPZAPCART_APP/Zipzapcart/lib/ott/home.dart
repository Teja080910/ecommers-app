import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../api_service.dart';
import '../constants.dart';
import 'profile.dart';

import 'cast.dart';
import 'mkvplayer.dart';
import 'shorts.dart';
import 'upgrade.dart';
import 'zhatpat.dart';

class HomePage extends StatefulWidget {

  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() =>
      _HomePageState();
}

class _HomePageState
    extends State<HomePage>
    with SingleTickerProviderStateMixin {

  List tabs = [];

  int selectedIndex = 0;

  int bottomIndex = 1;

  bool loading = true;

  bool showGold = false;

  Timer? _logoTimer;

  late final AnimationController
  _shimmerController;

  List banners = [];

  List castingBanner = [];

  List categories = [];

  @override
  void initState() {
    super.initState();

    loadCategories();

    _logoTimer = Timer.periodic(
      const Duration(seconds: 5),

          (timer) {

        if (!mounted) return;

        setState(() {
          showGold = !showGold;
        });
      },
    );

    _shimmerController =
    AnimationController(

      vsync: this,

      duration:
      const Duration(
        milliseconds: 1400,
      ),
    )..repeat();
  }

  Future<void> loadCategories() async {

    List cats =
    await ApiService
        .getOttCategories();

    tabs.addAll(cats);

    setState(() {});

    loadHomeData("0");
  }

  Future<void> loadHomeData(
      String catId,
      ) async {

    setState(() {
      loading = true;
    });

    final data =
    await ApiService
        .getOttHome(catId);

    banners =
        data["banners"] ?? [];

    castingBanner =
        data["casting_banner"] ?? [];

    categories =
        data["categories"] ?? [];

    loading = false;

    setState(() {});
  }

  @override
  void dispose() {

    _logoTimer?.cancel();

    _shimmerController.dispose();

    super.dispose();
  }

  @override
  Widget build(
      BuildContext context,
      ) {

    final bottomSafe =
        MediaQuery.of(context)
            .padding
            .bottom;

    return Scaffold(

      backgroundColor:
      Colors.black,

      body: SafeArea(

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            const SizedBox(
              height: 10,
            ),

            // 🔥 TOP BAR
            Padding(

              padding:
              const EdgeInsets.symmetric(
                horizontal: 18,
              ),

              child: Row(
                children: [

                  Expanded(

                    child:
                    AnimatedSwitcher(

                      duration:
                      const Duration(
                        milliseconds: 600,
                      ),

                      child: showGold

                          ? const _JoinGoldWidget(
                        key:
                        ValueKey(
                          "gold",
                        ),
                      )

                          : SizedBox(

                        key:
                        const ValueKey(
                          "logo",
                        ),

                        height: 42,

                        child: Align(
                          alignment:
                          Alignment.centerLeft,

                          child:
                          Image.asset(

                            "assets/images/logo-white.png",

                            fit:
                            BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),

                  IconButton(

                    onPressed: () {},

                    icon: const Icon(

                      Icons
                          .notifications_none_rounded,

                      color:
                      Colors.white,
                    ),
                  ),

                  GestureDetector(

                    onTap: () {

                      Navigator.push(

                        context,

                        MaterialPageRoute(
                          builder:
                              (_) =>
                          const ProfilePage(),
                        ),
                      );
                    },

                    child: Container(

                      width: 40,
                      height: 40,

                      decoration:
                      const BoxDecoration(

                        shape:
                        BoxShape.circle,

                        color:
                        Color(
                          0xFFD8E5FF,
                        ),
                      ),

                      child: const Icon(

                        Icons.account_circle,

                        color:
                        Color(
                          0xFF9EB9F3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 18,
            ),


            Expanded(

              child: loading

                  ? SingleChildScrollView(

                child: Column(
                  children: [

                    _shimmerBanner(),

                    const SizedBox(
                      height: 20,
                    ),

                    _horizontalCardShimmer(),

                    const SizedBox(
                      height: 20,
                    ),

                    _verticalPosterRowShimmer(),
                  ],
                ),
              )

                  : SingleChildScrollView(

                padding:
                EdgeInsets.only(
                  bottom:
                  100 +
                      bottomSafe,
                ),

                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

                  children: [

                    // 🔥 MAIN SLIDER
                    SizedBox(

                      height: 420,

                      child:
                      PageView.builder(

                        itemCount:
                        banners.length,

                        controller:
                        PageController(
                          viewportFraction:
                          0.92,
                        ),

                        itemBuilder:
                            (_, index) {

                          final movie =
                          banners[index];

                          return GestureDetector(

                            onTap: () {

                              Navigator.push(

                                context,

                                MaterialPageRoute(
                                  builder:
                                      (_) =>
                                      MkvPlayerPage(
                                        movieId:
                                        movie["id"]
                                            .toString(),
                                      ),
                                ),
                              );
                            },

                            child:
                            Container(

                              margin:
                              const EdgeInsets.symmetric(
                                horizontal:
                                8,
                              ),

                              child:
                              ClipRRect(

                                borderRadius:
                                BorderRadius.circular(
                                  16,
                                ),

                                child:
                                Stack(
                                  fit:
                                  StackFit.expand,

                                  children: [

                                    CachedNetworkImage(

                                      imageUrl:
                                      AppConstants.imageUrl +
                                          movie[
                                          "verticalposter"],

                                      fit:
                                      BoxFit.cover,
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

                                            Colors.transparent,

                                            Colors.black87,
                                          ],
                                        ),
                                      ),
                                    ),

                                    Positioned(

                                      left: 18,
                                      right: 18,
                                      bottom: 24,

                                      child:
                                      Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                        children: [

                                          Text(

                                            movie[
                                            "title"],

                                            style:
                                            const TextStyle(

                                              color:
                                              Colors.white,

                                              fontSize:
                                              24,

                                              fontWeight:
                                              FontWeight.w800,
                                            ),
                                          ),

                                          const SizedBox(
                                            height:
                                            14,
                                          ),

                                          GestureDetector(

                                            onTap:
                                                () {

                                              Navigator.push(

                                                context,

                                                MaterialPageRoute(
                                                  builder:
                                                      (_) =>
                                                      MkvPlayerPage(
                                                        movieId:
                                                        movie["id"]
                                                            .toString(),
                                                      ),
                                                ),
                                              );
                                            },

                                            child:
                                            Container(

                                              padding:
                                              const EdgeInsets.symmetric(
                                                horizontal:
                                                18,

                                                vertical:
                                                10,
                                              ),

                                              decoration:
                                              BoxDecoration(

                                                color:
                                                Colors.white,

                                                borderRadius:
                                                BorderRadius.circular(
                                                  30,
                                                ),
                                              ),

                                              child:
                                              const Text(

                                                "Watch Now",

                                                style:
                                                TextStyle(
                                                  fontWeight:
                                                  FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(
                      height: 22,
                    ),

                    // 🔥 CASTING BANNER
                    SizedBox(

                      height: 180,

                      child:
                      ListView.builder(

                        scrollDirection:
                        Axis.horizontal,

                        itemCount:
                        castingBanner.length,

                        itemBuilder:
                            (_, index) {

                          final item =
                          castingBanner[index];

                          return Padding(

                            padding:
                            const EdgeInsets.only(
                              left: 16,
                            ),

                            child:
                            GestureDetector(

                              onTap: () {

                                Navigator.push(

                                  context,

                                  MaterialPageRoute(
                                    builder:
                                        (_) =>
                                    const CastPage(),
                                  ),
                                );
                              },

                              child:
                              ClipRRect(

                                borderRadius:
                                BorderRadius.circular(
                                  14,
                                ),

                                child:
                                CachedNetworkImage(

                                  imageUrl:
                                  AppConstants.imageUrl +
                                      item[
                                      "image"],

                                  width:
                                  MediaQuery.of(context)
                                      .size
                                      .width -
                                      32,

                                  fit:
                                  BoxFit.contain,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(
                      height: 26,
                    ),

                    // 🔥 MOVIES LIST
                    ...categories.map((cat) {

                      List movies =
                      cat["movies"];

                      if (movies.isEmpty) {
                        return const SizedBox();
                      }

                      return Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        children: [

                          if (selectedIndex == 0)

                            Padding(

                              padding:
                              const EdgeInsets.symmetric(
                                horizontal:
                                18,
                              ),

                              child: Text(

                                cat["name"],

                                style:
                                const TextStyle(

                                  color:
                                  Colors.white,

                                  fontSize:
                                  20,

                                  fontWeight:
                                  FontWeight.w700,
                                ),
                              ),
                            ),

                          if (selectedIndex == 0)

                            const SizedBox(
                              height: 14,
                            ),

                          SizedBox(

                            height: 165,

                            child:
                            ListView.builder(

                              padding:
                              const EdgeInsets.symmetric(
                                horizontal:
                                18,
                              ),

                              scrollDirection:
                              Axis.horizontal,

                              itemCount:
                              movies.length,

                              itemBuilder:
                                  (_, index) {

                                final movie =
                                movies[index];

                                return GestureDetector(

                                  onTap: () {

                                    Navigator.push(

                                      context,

                                      MaterialPageRoute(
                                        builder:
                                            (_) =>
                                            MkvPlayerPage(
                                              movieId:
                                              movie["id"]
                                                  .toString(),
                                            ),
                                      ),
                                    );
                                  },

                                  child:
                                  Container(

                                    width:
                                    240,

                                    margin:
                                    const EdgeInsets.only(
                                      right:
                                      14,
                                    ),

                                    child:
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,

                                      children: [

                                        Expanded(

                                          child:
                                          Stack(
                                            children: [

                                              ClipRRect(

                                                borderRadius:
                                                BorderRadius.circular(
                                                  14,
                                                ),

                                                child:
                                                CachedNetworkImage(

                                                  imageUrl:
                                                  AppConstants.imageUrl +
                                                      movie[
                                                      "mainposter"],

                                                  width:
                                                  double.infinity,

                                                  fit:
                                                  BoxFit.cover,
                                                ),
                                              ),

                                              if (movie[
                                              "isfree"] !=
                                                  "yes")

                                                Positioned(

                                                  top: 10,
                                                  right: 10,

                                                  child:
                                                  Container(

                                                    padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal:
                                                      10,

                                                      vertical:
                                                      5,
                                                    ),

                                                    decoration:
                                                    BoxDecoration(

                                                      borderRadius:
                                                      BorderRadius.circular(
                                                        30,
                                                      ),

                                                      gradient:
                                                      const LinearGradient(
                                                        colors: [

                                                          Color(
                                                            0xFFE8C37A,
                                                          ),

                                                          Color(
                                                            0xFFC58D36,
                                                          ),
                                                        ],
                                                      ),
                                                    ),

                                                    child:
                                                    const Text(

                                                      "PREMIUM",

                                                      style:
                                                      TextStyle(

                                                        color:
                                                        Colors.black,

                                                        fontSize:
                                                        10,

                                                        fontWeight:
                                                        FontWeight.w800,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),

                                        const SizedBox(
                                          height:
                                          8,
                                        ),

                                        Text(

                                          movie[
                                          "title"],

                                          maxLines:
                                          1,

                                          overflow:
                                          TextOverflow.ellipsis,

                                          style:
                                          const TextStyle(

                                            color:
                                            Colors.white,

                                            fontWeight:
                                            FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(
                            height: 24,
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // 🔥 BOTTOM NAV
      bottomNavigationBar:
      Container(

        padding:
        EdgeInsets.only(
          bottom: bottomSafe,
          top: 8,
        ),

        decoration:
        const BoxDecoration(

          color:
          Color(0xFF101010),

          border: Border(
            top: BorderSide(
              color:
              Color(0xFF1E1E1E),
            ),
          ),
        ),

        child: Row(
          mainAxisAlignment:
          MainAxisAlignment.spaceAround,

          children: [

            _bottomItem(
              icon:
              Icons.home_filled,

              label:
              "Home",

              index: 0,
            ),

            _bottomItem(
              icon:
              Icons.flash_on_rounded,

              label:
              "Zhatpat",

              index: 1,
            ),

            _bottomItem(
              icon:
              Icons.play_circle_fill_rounded,

              label:
              "Shorts",

              index: 2,
            ),

            _bottomItem(
              icon:
              Icons.person,

              label:
              "Profile",

              index: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomItem({

    required IconData icon,

    required String label,

    required int index,

  }) {

    final selected =
        bottomIndex == index;

    return GestureDetector(

      onTap: () {

        setState(() {
          bottomIndex = index;
        });

        if (index == 1) {

          Navigator.push(

            context,

            MaterialPageRoute(
              builder:
                  (_) =>
              const ZhatpatPage(),
            ),
          );
        }

        if (index == 2) {

          Navigator.push(

            context,

            MaterialPageRoute(
              builder:
                  (_) =>
              const ShortsPage(),
            ),
          );
        }

        if (index == 3) {

          Navigator.push(

            context,

            MaterialPageRoute(
              builder:
                  (_) =>
              const ProfilePage(),
            ),
          );
        }
      },

      child: Column(
        mainAxisSize:
        MainAxisSize.min,

        children: [

          Icon(

            icon,

            color:
            selected

                ? Colors.white

                : Colors.white54,
          ),

          const SizedBox(
            height: 4,
          ),

          Text(

            label,

            style: TextStyle(

              color:
              selected

                  ? Colors.white

                  : Colors.white54,

              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerBanner() {

    return Padding(

      padding:
      const EdgeInsets.symmetric(
        horizontal: 16,
      ),

      child: _ShimmerBox(

        controller:
        _shimmerController,

        height: 400,

        width: double.infinity,

        radius: 16,
      ),
    );
  }

  Widget _horizontalCardShimmer() {

    return SizedBox(

      height: 166,

      child:
      ListView.separated(

        padding:
        const EdgeInsets.symmetric(
          horizontal: 18,
        ),

        scrollDirection:
        Axis.horizontal,

        itemCount: 3,

        separatorBuilder:
            (_, __) =>
        const SizedBox(
          width: 14,
        ),

        itemBuilder:
            (_, index) {

          return _ShimmerBox(

            controller:
            _shimmerController,

            height: 140,

            width: 240,

            radius: 14,
          );
        },
      ),
    );
  }

  Widget _verticalPosterRowShimmer() {

    return SizedBox(

      height: 250,

      child:
      ListView.separated(

        padding:
        const EdgeInsets.symmetric(
          horizontal: 18,
        ),

        scrollDirection:
        Axis.horizontal,

        itemCount: 4,

        separatorBuilder:
            (_, __) =>
        const SizedBox(
          width: 14,
        ),

        itemBuilder:
            (_, index) {

          return _ShimmerBox(

            controller:
            _shimmerController,

            height: 240,

            width: 150,

            radius: 12,
          );
        },
      ),
    );
  }
}

class _JoinGoldWidget
    extends StatelessWidget {

  const _JoinGoldWidget({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      ) {

    return GestureDetector(

      onTap: () {

        Navigator.push(

          context,

          MaterialPageRoute(
            builder:
                (_) =>
            const UpgradePage(),
          ),
        );
      },

      child: SizedBox(

        height: 42,

        child: Align(
          alignment:
          Alignment.centerLeft,

          child: Container(

            padding:
            const EdgeInsets.symmetric(
              horizontal: 6,
            ),

            decoration:
            BoxDecoration(

              borderRadius:
              BorderRadius.circular(
                22,
              ),

              gradient:
              const LinearGradient(
                colors: [

                  Color(0xFFE8C37A),

                  Color(0xFFA9CAFF),

                  Color(0xFF8AB6FF),
                ],
              ),
            ),

            child: Row(
              mainAxisSize:
              MainAxisSize.min,

              children: [

                Container(

                  width: 34,
                  height: 34,

                  decoration:
                  const BoxDecoration(

                    shape:
                    BoxShape.circle,

                    gradient:
                    LinearGradient(
                      colors: [

                        Color(
                          0xFFF6DEAE,
                        ),

                        Color(
                          0xFFC58D36,
                        ),
                      ],
                    ),
                  ),

                  child: const Icon(
                    Icons.play_arrow_rounded,

                    color:
                    Colors.black87,
                  ),
                ),

                const SizedBox(
                  width: 10,
                ),

                const Text(

                  "Join Gold",

                  style: TextStyle(

                    color:
                    Colors.white,

                    fontWeight:
                    FontWeight.w700,
                  ),
                ),

                const Icon(
                  Icons.chevron_right_rounded,

                  color:
                  Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShimmerBox
    extends StatelessWidget {

  final AnimationController
  controller;

  final double height;

  final double width;

  final double radius;

  const _ShimmerBox({

    required this.controller,

    required this.height,

    required this.width,

    this.radius = 10,
  });

  @override
  Widget build(
      BuildContext context,
      ) {

    return AnimatedBuilder(

      animation: controller,

      builder: (_, __) {

        return Container(

          height: height,

          width: width,

          decoration: BoxDecoration(

            borderRadius:
            BorderRadius.circular(
              radius,
            ),

            gradient:
            LinearGradient(

              begin: Alignment(
                -1.0 +
                    (controller.value * 2),
                0,
              ),

              end: Alignment(
                1.0 +
                    (controller.value * 2),
                0,
              ),

              colors: const [

                Color(0xFF141414),

                Color(0xFF222222),

                Color(0xFF141414),
              ],

              stops: const [
                0.15,
                0.5,
                0.85,
              ],
            ),
          ),
        );
      },
    );
  }
}