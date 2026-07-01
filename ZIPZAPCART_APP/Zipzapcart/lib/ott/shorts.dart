import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:video_player/video_player.dart';

import '../api_service.dart';

class ShortsPage extends StatefulWidget {

  const ShortsPage({
    super.key,
  });

  @override
  State<ShortsPage> createState() =>
      _ShortsPageState();
}

class _ShortsPageState
    extends State<ShortsPage> {

  final PageController
  _pageController =
  PageController();

  List<String> videos = [];

  final Map<int,
      VideoPlayerController>
  _controllers = {};

  int _currentIndex = 0;

  bool _loading = true;

  List<Map<String, dynamic>>
  reelMeta = [];

  @override
  void initState() {
    super.initState();

    loadShorts();
  }

  Future<void> loadShorts() async {

    final data =
    await ApiService.getShorts();

    final shorts =
        data["shorts"] ?? [];

    videos =
        shorts.map<String>((e) {

          String url =
          e["video"]
              .toString();

          if (!url.startsWith(
              "http")) {

            url =
                "https://zenvorashops.in/app/" +
                    url;
          }

          return url;

        }).toList();

    reelMeta =
    List<Map<String, dynamic>>.from(

      shorts
          .asMap()
          .entries
          .map((e) {

        return <String, dynamic>{

          "title":
          "Zenvora Shorts ${e.key + 1}",

          "caption":
          "Trending viral short videos 🔥",

          "music":
          "Original Audio",

          "likes":
          120 +
              (e.key * 14),

          "comments":
          20 + e.key,
        };
      }),
    );
    await _setupInitialVideo();
  }

  Future<void>
  _setupInitialVideo() async {

    if (videos.isEmpty) {

      setState(() {

        _loading = false;
      });

      return;
    }

    await _initializeController(
      _currentIndex,
    );

    await _controllers[
    _currentIndex]
        ?.play();

    if (mounted) {

      setState(() {

        _loading = false;
      });
    }
  }

  Future<void>
  _initializeController(
      int index,
      ) async {

    index =
        index %
            videos.length;

    if (_controllers
        .containsKey(index)) {
      return;
    }

    try {

      print(videos[index]);

      final controller =
      VideoPlayerController
          .networkUrl(

        Uri.parse(
          videos[index],
        ),
      );

      await controller
          .initialize();

      await controller
          .setLooping(true);

      await controller
          .setVolume(1);

      _controllers[index] =
          controller;

      if (mounted) {

        setState(() {});
      }

    } catch (e) {

      print(e.toString());
    }
  }

  Future<void>
  _onPageChanged(
      int index,
      ) async {

    final previousRealIndex =
        _currentIndex %
            videos.length;

    final newRealIndex =
        index %
            videos.length;

    _currentIndex = index;

    await _controllers[
    previousRealIndex]
        ?.pause();

    await _initializeController(
      newRealIndex,
    );

    await _controllers[
    newRealIndex]
        ?.play();

    final nextIndex =
        (newRealIndex + 1) %
            videos.length;

    await _initializeController(
      nextIndex,
    );

    if (mounted) {

      setState(() {});
    }
  }

  @override
  void dispose() {

    for (final controller
    in _controllers.values) {

      controller.dispose();
    }

    _pageController.dispose();

    super.dispose();
  }

  @override
  Widget build(
      BuildContext context,
      ) {

    if (_loading) {

      return const Scaffold(

        backgroundColor:
        Colors.black,

        body: Center(

          child:
          InstaGradientSpinner(
            size: 56,
          ),
        ),
      );
    }

    if (videos.isEmpty) {

      return Scaffold(

        backgroundColor:
        Colors.black,

        body: const Center(

          child: Text(

            "No Shorts Found",

            style: TextStyle(
              color:
              Colors.white,
            ),
          ),
        ),
      );
    }

    return Scaffold(

      backgroundColor:
      Colors.black,

      body: PageView.builder(

        controller:
        _pageController,

        scrollDirection:
        Axis.vertical,

        itemCount: 100000,

        onPageChanged:
        _onPageChanged,

        itemBuilder:
            (context, index) {

          final realIndex =
              index %
                  videos.length;

          return ReelVideoItem(

            key: ValueKey(
              'reel_$realIndex',
            ),

            controller:
            _controllers[
            realIndex],

            title:
            reelMeta[
            realIndex]["title"],

            caption:
            reelMeta[
            realIndex]["caption"],

            music:
            reelMeta[
            realIndex]["music"],

            initialLikes:
            reelMeta[
            realIndex]["likes"],

            initialComments:
            reelMeta[
            realIndex]
            ["comments"],
          );
        },
      ),
    );
  }
}

class ReelVideoItem
    extends StatefulWidget {

  final VideoPlayerController?
  controller;

  final String title;

  final String caption;

  final String music;

  final int initialLikes;

  final int initialComments;

  const ReelVideoItem({

    super.key,

    required this.controller,

    required this.title,

    required this.caption,

    required this.music,

    required this.initialLikes,

    required this.initialComments,
  });

  @override
  State<ReelVideoItem>
  createState() =>
      _ReelVideoItemState();
}

class _ReelVideoItemState
    extends State<
        ReelVideoItem>
    with
        SingleTickerProviderStateMixin {

  late bool liked;

  late int likes;

  late int comments;

  bool showHeart = false;

  late final AnimationController
  _heartController;

  late final Animation<double>
  _scaleAnimation;

  @override
  void initState() {
    super.initState();

    liked = false;

    likes =
        widget.initialLikes;

    comments =
        widget.initialComments;

    _heartController =
        AnimationController(

          vsync: this,

          duration:
          const Duration(
            milliseconds: 450,
          ),
        );

    _scaleAnimation =
        CurvedAnimation(

          parent:
          _heartController,

          curve:
          Curves.elasticOut,
        );
  }

  @override
  void dispose() {

    _heartController.dispose();

    super.dispose();
  }

  void _handleDoubleTap() {

    if (!liked) {

      setState(() {

        liked = true;

        likes++;
      });
    }

    setState(() {

      showHeart = true;
    });

    _heartController.forward(
      from: 0,
    );

    Future.delayed(

      const Duration(
        milliseconds: 700,
      ),

          () {

        if (mounted) {

          setState(() {

            showHeart = false;
          });
        }
      },
    );
  }

  @override
  Widget build(
      BuildContext context,
      ) {

    final controller =
        widget.controller;

    final paused =
        controller != null &&
            controller
                .value
                .isInitialized &&
            !controller
                .value
                .isPlaying;

    return Stack(

      fit: StackFit.expand,

      children: [

        GestureDetector(

          onTap: () async {

            if (controller ==
                null ||
                !controller
                    .value
                    .isInitialized) {
              return;
            }

            if (controller
                .value
                .isPlaying) {

              await controller
                  .pause();

            } else {

              await controller
                  .play();
            }

            if (mounted) {

              setState(() {});
            }
          },

          onDoubleTap:
          _handleDoubleTap,

          child:
          controller != null &&
              controller
                  .value
                  .isInitialized

              ? Stack(

            fit:
            StackFit.expand,

            children: [

              FittedBox(

                fit:
                BoxFit.cover,

                child:
                SizedBox(

                  width:
                  controller
                      .value
                      .size
                      .width,

                  height:
                  controller
                      .value
                      .size
                      .height,

                  child:
                  VideoPlayer(
                    controller,
                  ),
                ),
              ),

              const DecoratedBox(

                decoration:
                BoxDecoration(

                  gradient:
                  LinearGradient(

                    begin:
                    Alignment
                        .topCenter,

                    end:
                    Alignment
                        .center,

                    colors: [

                      Color(
                        0x66000000,
                      ),

                      Color(
                        0x22000000,
                      ),

                      Colors
                          .transparent,
                    ],
                  ),
                ),
              ),

              const DecoratedBox(

                decoration:
                BoxDecoration(

                  gradient:
                  LinearGradient(

                    begin:
                    Alignment
                        .bottomCenter,

                    end:
                    Alignment
                        .center,

                    colors: [

                      Color(
                        0xAA000000,
                      ),

                      Color(
                        0x44000000,
                      ),

                      Colors
                          .transparent,
                    ],
                  ),
                ),
              ),
            ],
          )

              : const Center(

            child:
            InstaGradientSpinner(
              size: 52,
            ),
          ),
        ),

        if (showHeart)

          Center(

            child:
            ScaleTransition(

              scale:
              _scaleAnimation,

              child:
              Container(

                width: 110,
                height: 110,

                decoration:
                BoxDecoration(

                  shape:
                  BoxShape.circle,

                  color:
                  Colors.black
                      .withOpacity(
                    0.18,
                  ),
                ),

                child:
                const Icon(

                  Icons.favorite,

                  color:
                  Colors.white,

                  size: 74,
                ),
              ),
            ),
          ),

        Positioned(

          right: 8,
          bottom: 108,

          child: SafeArea(

            child: Column(
              mainAxisSize:
              MainAxisSize.min,

              children: [

                _LikeActionButton(

                  liked: liked,

                  likes: likes,

                  onTap:
                      (isLiked) async {

                    setState(() {

                      liked =
                      !isLiked;

                      likes += liked

                          ? 1

                          : -1;
                    });

                    return !isLiked;
                  },
                ),

                const SizedBox(
                  height: 12,
                ),

                _SmallActionButton(

                  icon:
                  Icons
                      .mode_comment_outlined,

                  label:
                  "$comments",
                ),

                const SizedBox(
                  height: 12,
                ),

                const _SmallActionButton(

                  icon:
                  Icons
                      .send_rounded,

                  label: "",
                ),

                const SizedBox(
                  height: 12,
                ),

                const _SmallActionButton(

                  icon:
                  Icons
                      .more_vert_rounded,

                  label: "",
                ),
              ],
            ),
          ),
        ),

        Positioned(

          left: 14,
          right: 76,
          bottom: 40,

          child: SafeArea(

            top: false,

            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,

              mainAxisSize:
              MainAxisSize.min,

              children: [

                Text(

                  widget.title,

                  maxLines: 1,

                  overflow:
                  TextOverflow
                      .ellipsis,

                  style:
                  const TextStyle(

                    color:
                    Colors.white,

                    fontSize:
                    16,

                    fontWeight:
                    FontWeight.w800,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                Text(

                  widget.caption,

                  maxLines: 2,

                  overflow:
                  TextOverflow
                      .ellipsis,

                  style:
                  const TextStyle(

                    color:
                    Colors.white70,

                    fontSize:
                    12.5,

                    height: 1.35,

                    fontWeight:
                    FontWeight.w500,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                Row(
                  children: [

                    const Icon(

                      Icons
                          .graphic_eq_rounded,

                      color:
                      Colors.white70,

                      size: 15,
                    ),

                    const SizedBox(
                      width: 6,
                    ),

                    Expanded(

                      child: Text(

                        widget.music,

                        maxLines: 1,

                        overflow:
                        TextOverflow
                            .ellipsis,

                        style:
                        const TextStyle(

                          color:
                          Colors.white70,

                          fontSize:
                          11.5,

                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        Positioned(

          left: 0,
          right: 0,
          bottom: 0,

          child:
          controller != null &&
              controller
                  .value
                  .isInitialized

              ? _BottomVideoProgressBar(
            controller:
            controller,
          )

              : const SizedBox
              .shrink(),
        ),

        if (paused)

          Center(

            child:
            Container(

              width: 84,
              height: 84,

              decoration:
              BoxDecoration(

                shape:
                BoxShape.circle,

                color:
                Colors.black
                    .withOpacity(
                  0.25,
                ),

                border:
                Border.all(
                  color:
                  Colors.white24,
                ),
              ),

              child:
              const Icon(

                Icons
                    .play_arrow_rounded,

                size: 48,

                color:
                Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}

class _LikeActionButton
    extends StatelessWidget {

  final bool liked;

  final int likes;

  final Future<bool>
  Function(bool)
  onTap;

  const _LikeActionButton({

    required this.liked,

    required this.likes,

    required this.onTap,
  });

  @override
  Widget build(
      BuildContext context,
      ) {

    return SizedBox(

      width: 44,

      child: Column(
        mainAxisSize:
        MainAxisSize.min,

        children: [

          Opacity(

            opacity: 0.82,

            child: LikeButton(

              size: 26,

              isLiked: liked,

              likeCount: null,

              padding:
              EdgeInsets.zero,

              circleColor:
              const CircleColor(

                start:
                Color(
                  0xFFFF5B7F,
                ),

                end:
                Color(
                  0xFFFF2D55,
                ),
              ),

              bubblesColor:
              const BubblesColor(

                dotPrimaryColor:
                Color(
                  0xFFFF5B7F,
                ),

                dotSecondaryColor:
                Color(
                  0xFFFFC107,
                ),
              ),

              onTap: onTap,

              likeBuilder:
                  (isLiked) =>
                  Icon(

                    Icons
                        .favorite_rounded,

                    color:
                    isLiked

                        ? Colors
                        .redAccent

                        : Colors
                        .white,

                    size: 26,
                  ),
            ),
          ),

          const SizedBox(
            height: 4,
          ),

          Text(

            "$likes",

            maxLines: 1,

            overflow:
            TextOverflow
                .ellipsis,

            textAlign:
            TextAlign.center,

            style: TextStyle(

              color:
              liked

                  ? Colors
                  .redAccent

                  : Colors
                  .white,

              fontSize: 9.5,

              fontWeight:
              FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallActionButton
    extends StatelessWidget {

  final IconData icon;

  final String label;

  const _SmallActionButton({

    required this.icon,

    required this.label,
  });

  @override
  Widget build(
      BuildContext context,
      ) {

    return SizedBox(

      width: 40,

      child: Opacity(

        opacity: 0.68,

        child: Column(
          mainAxisSize:
          MainAxisSize.min,

          children: [

            Icon(

              icon,

              color:
              Colors.white,

              size: 22,
            ),

            if (label.isNotEmpty)
              ...[

                const SizedBox(
                  height: 3,
                ),

                Text(

                  label,

                  maxLines: 1,

                  overflow:
                  TextOverflow
                      .ellipsis,

                  textAlign:
                  TextAlign.center,

                  style:
                  const TextStyle(

                    color:
                    Colors.white,

                    fontSize:
                    9.5,

                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ],
          ],
        ),
      ),
    );
  }
}

class _BottomVideoProgressBar
    extends StatefulWidget {

  final VideoPlayerController
  controller;

  const _BottomVideoProgressBar({

    required this.controller,
  });

  @override
  State<_BottomVideoProgressBar>
  createState() =>
      _BottomVideoProgressBarState();
}

class _BottomVideoProgressBarState
    extends State<
        _BottomVideoProgressBar> {

  @override
  void initState() {
    super.initState();

    widget.controller
        .addListener(
      _listener,
    );
  }

  @override
  void dispose() {

    widget.controller
        .removeListener(
      _listener,
    );

    super.dispose();
  }

  void _listener() {

    if (mounted) {

      setState(() {});
    }
  }

  @override
  Widget build(
      BuildContext context,
      ) {

    final value =
        widget.controller.value;

    if (!value.isInitialized ||
        value
            .duration
            .inMilliseconds ==
            0) {

      return const SizedBox(
        height: 3,
      );
    }

    final progress =
    (value.position
        .inMilliseconds /
        value.duration
            .inMilliseconds)
        .clamp(0.0, 1.0);

    return Stack(
      children: [

        Container(

          height: 3,

          width:
          double.infinity,

          color:
          Colors.white24,
        ),

        FractionallySizedBox(

          widthFactor: progress,

          child: Container(

            height: 3,

            decoration:
            const BoxDecoration(

              gradient:
              LinearGradient(

                colors: [

                  Color(
                    0xFFFEDA75,
                  ),

                  Color(
                    0xFFFA7E1E,
                  ),

                  Color(
                    0xFFD62976,
                  ),

                  Color(
                    0xFF962FBF,
                  ),

                  Color(
                    0xFF4F5BD5,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class InstaGradientSpinner
    extends StatefulWidget {

  final double size;

  const InstaGradientSpinner({

    super.key,

    this.size = 48,
  });

  @override
  State<InstaGradientSpinner>
  createState() =>
      _InstaGradientSpinnerState();
}

class _InstaGradientSpinnerState
    extends State<
        InstaGradientSpinner>
    with
        SingleTickerProviderStateMixin {

  late final AnimationController
  _controller;

  @override
  void initState() {
    super.initState();

    _controller =
    AnimationController(

      vsync: this,

      duration:
      const Duration(
        milliseconds: 1100,
      ),
    )..repeat();
  }

  @override
  void dispose() {

    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(
      BuildContext context,
      ) {

    return RotationTransition(

      turns: _controller,

      child: CustomPaint(

        size: Size(
          widget.size,
          widget.size,
        ),

        painter:
        _InstaSpinnerPainter(),
      ),
    );
  }
}

class _InstaSpinnerPainter
    extends CustomPainter {

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {

    final stroke =
        size.width * 0.10;

    final rect =
    Offset.zero & size;

    final paintBg = Paint()

      ..style =
          PaintingStyle.stroke

      ..strokeWidth = stroke

      ..color = Colors.white
          .withOpacity(0.10)

      ..strokeCap =
          StrokeCap.round;

    canvas.drawArc(

      rect.deflate(
        stroke / 2,
      ),

      0,

      math.pi * 2,

      false,

      paintBg,
    );

    final gradient =
    SweepGradient(

      colors: const [

        Color(0xFFFEDA75),

        Color(0xFFFA7E1E),

        Color(0xFFD62976),

        Color(0xFF962FBF),

        Color(0xFF4F5BD5),

        Color(0xFFFEDA75),
      ],
    );

    final paintFg = Paint()

      ..style =
          PaintingStyle.stroke

      ..strokeWidth = stroke

      ..strokeCap =
          StrokeCap.round

      ..shader =
      gradient
          .createShader(rect);

    canvas.drawArc(

      rect.deflate(
        stroke / 2,
      ),

      -math.pi / 2,

      math.pi * 1.35,

      false,

      paintFg,
    );
  }

  @override
  bool shouldRepaint(
      covariant CustomPainter
      oldDelegate,
      ) =>
      true;
}