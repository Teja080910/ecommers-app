import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import '../constants.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:video_player/video_player.dart';

import '../api_service.dart';

class PlayZhatphatPage extends StatefulWidget {

  final String zhatpatId;

  final String title;

  const PlayZhatphatPage({

    super.key,

    required this.zhatpatId,

    required this.title,
  });

  @override
  State<PlayZhatphatPage> createState() =>
      _PlayZhatphatPageState();
}

class _PlayZhatphatPageState
    extends State<PlayZhatphatPage> {

  final PageController
  _pageController =
  PageController();

  List videos = [];

  final Map<int,
      VideoPlayerController>
  _controllers = {};

  int _currentIndex = 0;

  bool _loading = true;

  bool apiLoading = true;

  List<Map<String, dynamic>>
  episodeMeta = [];

  @override
  void initState() {
    super.initState();

    loadVideos();
  }

  Future<void> loadVideos() async {

    final data =
    await ApiService
        .getZhatpatVideos(
      widget.zhatpatId,
    );

    final responseVideos =
        data["videos"] ?? [];

    videos =
        responseVideos
            .map((e) =>
        e["videolink"])
            .toList();

    episodeMeta =
    List<Map<String, dynamic>>.from(

      responseVideos
          .asMap()
          .entries
          .map((e) {

        return <String, dynamic>{

          "title":
          "${widget.title} Episode ${e.key + 1}",

          "subtitle":
          "Watch Episode ${e.key + 1}",

          "likes":
          int.tryParse(
            e.value["likes_count"]
                .toString(),
          ) ??
              0,
        };
      }),
    );
    await _setupInitialVideo();

    apiLoading = false;

    setState(() {});
  }

  Future<void>
  _setupInitialVideo() async {

    if (videos.isEmpty) return;

    await _initializeController(
      _currentIndex,
    );

    await _controllers[
    _currentIndex]
        ?.play();

    if (_currentIndex + 1 <
        videos.length) {

      await _initializeController(
        _currentIndex + 1,
      );
    }

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

    if (index < 0 ||
        index >= videos.length) {
      return;
    }

    if (_controllers
        .containsKey(index)) {
      return;
    }

    String videoUrl =
    videos[index]
        .toString();

    // 🔥 FIX URL
    if (!videoUrl.startsWith("http")) {

      videoUrl =
          AppConstants.imageUrl +
              videoUrl;
    }

    print("VIDEO URL:");
    print(videoUrl);

    try {

      final controller =
      VideoPlayerController
          .networkUrl(

        Uri.parse(videoUrl),
      );

      await controller
          .initialize();

      await controller
          .setLooping(true);

      await controller
          .setVolume(1);

      _controllers[index] =
          controller;

      print(
        "VIDEO INITIALIZED SUCCESS",
      );

      if (mounted) {

        setState(() {});
      }

    } catch (e) {

      print(
        "VIDEO ERROR:",
      );

      print(e.toString());
    }
  }
  Future<void>
  _onPageChanged(
      int index,
      ) async {

    final previous =
        _currentIndex;

    _currentIndex = index;

    await _controllers[
    previous]
        ?.pause();

    await _initializeController(
      index,
    );

    await _controllers[index]
        ?.play();

    if (index - 1 >= 0) {

      await _initializeController(
        index - 1,
      );
    }

    if (index + 1 <
        videos.length) {

      await _initializeController(
        index + 1,
      );
    }

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

    if (_loading ||
        apiLoading) {

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

        appBar: AppBar(

          backgroundColor:
          Colors.black,
        ),

        body: const Center(

          child: Text(

            "No Episodes Found",

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

        itemCount:
        videos.length,

        onPageChanged:
        _onPageChanged,

        itemBuilder:
            (context, index) {

          return _EpisodePlayerItem(

            key:
            ValueKey(index),

            controller:
            _controllers[index],

            title:
            episodeMeta[index]
            ["title"],

            subtitle:
            episodeMeta[index]
            ["subtitle"],

            initialLikes:
            episodeMeta[index]
            ["likes"],

            currentEpisode:
            index + 1,

            totalEpisodes:
            videos.length,

            seriesTitle:
            widget.title,

            onEpisodeSwitch:
                () {

              final target =
              index ==
                  videos.length -
                      1

                  ? 0

                  : index + 1;

              _pageController
                  .animateToPage(

                target,

                duration:
                const Duration(
                  milliseconds:
                  420,
                ),

                curve:
                Curves
                    .easeInOutCubic,
              );
            },
          );
        },
      ),
    );
  }
}

class _EpisodePlayerItem
    extends StatefulWidget {

  final VideoPlayerController?
  controller;

  final String title;

  final String subtitle;

  final int initialLikes;

  final int currentEpisode;

  final int totalEpisodes;

  final String seriesTitle;

  final VoidCallback
  onEpisodeSwitch;

  const _EpisodePlayerItem({

    super.key,

    required this.controller,

    required this.title,

    required this.subtitle,

    required this.initialLikes,

    required this.currentEpisode,

    required this.totalEpisodes,

    required this.seriesTitle,

    required this.onEpisodeSwitch,
  });

  @override
  State<_EpisodePlayerItem>
  createState() =>
      _EpisodePlayerItemState();
}

class _EpisodePlayerItemState
    extends State<
        _EpisodePlayerItem>
    with
        SingleTickerProviderStateMixin {

  late bool liked;

  late int likes;

  bool showHeart = false;

  bool showPausePlayIcon =
  false;

  IconData pausePlayIcon =
      Icons.pause_rounded;

  bool showSeekText = false;

  String seekText = "";

  late final AnimationController
  _heartController;

  late final Animation<double>
  _heartScale;

  Timer? _pausePlayTimer;

  Timer? _seekTimer;

  @override
  void initState() {
    super.initState();

    liked = false;

    likes =
        widget.initialLikes;

    _heartController =
        AnimationController(

          vsync: this,

          duration:
          const Duration(
            milliseconds: 450,
          ),
        );

    _heartScale =
        CurvedAnimation(

          parent:
          _heartController,

          curve:
          Curves.elasticOut,
        );
  }

  @override
  void dispose() {

    _pausePlayTimer?.cancel();

    _seekTimer?.cancel();

    _heartController.dispose();

    super.dispose();
  }

  void _showCenterIcon(
      IconData icon,
      ) {

    _pausePlayTimer?.cancel();

    setState(() {

      pausePlayIcon = icon;

      showPausePlayIcon =
      true;
    });

    _pausePlayTimer = Timer(

      const Duration(
        milliseconds: 550,
      ),

          () {

        if (!mounted) return;

        setState(() {

          showPausePlayIcon =
          false;
        });
      },
    );
  }

  void _showSeekOverlay(
      String text,
      ) {

    _seekTimer?.cancel();

    setState(() {

      seekText = text;

      showSeekText = true;
    });

    _seekTimer = Timer(

      const Duration(
        milliseconds: 700,
      ),

          () {

        if (!mounted) return;

        setState(() {

          showSeekText = false;
        });
      },
    );
  }

  Future<void>
  _togglePlayPause() async {

    final controller =
        widget.controller;

    if (controller == null ||
        !controller
            .value
            .isInitialized) {
      return;
    }

    if (controller
        .value
        .isPlaying) {

      await controller.pause();

      _showCenterIcon(
        Icons.play_arrow_rounded,
      );

    } else {

      await controller.play();

      _showCenterIcon(
        Icons.pause_rounded,
      );
    }

    if (mounted) {

      setState(() {});
    }
  }

  void _handleDoubleTapLike() {

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

        if (!mounted) return;

        setState(() {

          showHeart = false;
        });
      },
    );
  }

  Future<void> _seekBy(
      int seconds,
      ) async {

    final controller =
        widget.controller;

    if (controller == null ||
        !controller
            .value
            .isInitialized) {
      return;
    }

    final current =
        controller
            .value
            .position;

    final duration =
        controller
            .value
            .duration;

    var target =
        current +
            Duration(
              seconds: seconds,
            );

    if (target <
        Duration.zero) {

      target = Duration.zero;
    }

    if (target > duration) {

      target = duration;
    }

    await controller.seekTo(
      target,
    );

    _showSeekOverlay(

      seconds > 0

          ? "+10 sec"

          : "-10 sec",
    );

    if (mounted) {

      setState(() {});
    }
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

        if (controller != null &&
            controller
                .value
                .isInitialized)

          Row(
            children: [

              Expanded(

                child:
                GestureDetector(

                  behavior:
                  HitTestBehavior
                      .opaque,

                  onDoubleTap:
                      () =>
                      _seekBy(
                        -10,
                      ),

                  child:
                  const SizedBox
                      .expand(),
                ),
              ),

              Expanded(

                child:
                GestureDetector(

                  behavior:
                  HitTestBehavior
                      .opaque,

                  onDoubleTap:
                      () =>
                      _seekBy(
                        10,
                      ),

                  child:
                  const SizedBox
                      .expand(),
                ),
              ),
            ],
          ),

        GestureDetector(

          onTap:
          _togglePlayPause,

          onDoubleTap:
          _handleDoubleTapLike,

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
                        0x99000000,
                      ),

                      Color(
                        0x33000000,
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
                        0xCC000000,
                      ),

                      Color(
                        0x66000000,
                      ),

                      Colors
                          .transparent,
                    ],
                  ),
                ),
              ),
            ],
          )

              : Container(

            color:
            Colors.black,

            child:
            const Center(

              child:
              InstaGradientSpinner(
                size: 52,
              ),
            ),
          ),
        ),

        Positioned(

          top:
          MediaQuery.of(context)
              .padding
              .top +
              10,

          left: 14,
          right: 14,

          child: Row(
            children: [

              Text(

                widget.seriesTitle,

                style:
                const TextStyle(

                  color:
                  Colors.white,

                  fontSize:
                  19,

                  fontWeight:
                  FontWeight.w800,
                ),
              ),

              const Spacer(),

              Container(

                padding:
                const EdgeInsets.symmetric(

                  horizontal:
                  12,

                  vertical:
                  7,
                ),

                decoration:
                BoxDecoration(

                  color:
                  Colors.black
                      .withOpacity(
                    0.35,
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

                child: Text(

                  "Episode ${widget.currentEpisode}",

                  style:
                  const TextStyle(

                    color:
                    Colors.white,

                    fontSize:
                    11.5,

                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),

        if (showHeart)

          Center(

            child:
            ScaleTransition(

              scale:
              _heartScale,

              child:
              Container(

                padding:
                const EdgeInsets.all(
                  18,
                ),

                decoration:
                BoxDecoration(

                  color:
                  Colors.white
                      .withOpacity(
                    0.12,
                  ),

                  shape:
                  BoxShape.circle,
                ),

                child:
                const Icon(

                  Icons.favorite,

                  color:
                  Colors.white,

                  size: 96,
                ),
              ),
            ),
          ),

        if (showPausePlayIcon)

          Center(

            child:
            AnimatedOpacity(

              opacity:
              showPausePlayIcon

                  ? 1

                  : 0,

              duration:
              const Duration(
                milliseconds:
                180,
              ),

              child:
              Container(

                width: 86,
                height: 86,

                decoration:
                BoxDecoration(

                  shape:
                  BoxShape.circle,

                  color:
                  Colors.black
                      .withOpacity(
                    0.34,
                  ),

                  border:
                  Border.all(
                    color:
                    Colors.white24,
                  ),
                ),

                child: Icon(

                  pausePlayIcon,

                  color:
                  Colors.white,

                  size: 52,
                ),
              ),
            ),
          ),

        if (showSeekText)

          Center(

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
                Colors.black
                    .withOpacity(
                  0.60,
                ),

                borderRadius:
                BorderRadius.circular(
                  28,
                ),
              ),

              child: Text(

                seekText,

                style:
                const TextStyle(

                  color:
                  Colors.white,

                  fontSize:
                  17,

                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ),
          ),

        Positioned(

          right: 10,
          bottom: 112,

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
                  height: 16,
                ),

                _EpisodeSwitchButton(

                  currentEpisode:
                  widget
                      .currentEpisode,

                  totalEpisodes:
                  widget
                      .totalEpisodes,

                  onTap:
                  widget
                      .onEpisodeSwitch,
                ),
              ],
            ),
          ),
        ),

        Positioned(

          left: 14,
          right: 86,
          bottom: 48,

          child: SafeArea(

            top: false,

            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,

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
                    18,

                    fontWeight:
                    FontWeight.w800,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                Text(

                  widget.subtitle,

                  maxLines: 2,

                  overflow:
                  TextOverflow
                      .ellipsis,

                  style:
                  const TextStyle(

                    color:
                    Colors.white70,

                    fontSize:
                    13,

                    height: 1.4,

                    fontWeight:
                    FontWeight.w500,
                  ),
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

              ? _BottomSeekBar(
            controller:
            controller,
          )

              : const SizedBox(
            height: 4,
          ),
        ),

        if (paused &&
            !showPausePlayIcon)

          Center(

            child:
            Container(

              width: 88,
              height: 88,

              decoration:
              BoxDecoration(

                shape:
                BoxShape.circle,

                color:
                Colors.black
                    .withOpacity(
                  0.28,
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

                size: 52,

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

      width: 52,

      child: Column(
        mainAxisSize:
        MainAxisSize.min,

        children: [

          Opacity(

            opacity: 0.95,

            child: LikeButton(

              size: 30,

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

                    size: 30,
                  ),
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          Text(

            "$likes",

            textAlign:
            TextAlign.center,

            style: TextStyle(

              color:
              liked

                  ? Colors
                  .redAccent

                  : Colors
                  .white,

              fontSize: 10,

              fontWeight:
              FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EpisodeSwitchButton
    extends StatelessWidget {

  final int currentEpisode;

  final int totalEpisodes;

  final VoidCallback onTap;

  const _EpisodeSwitchButton({

    required this.currentEpisode,

    required this.totalEpisodes,

    required this.onTap,
  });

  @override
  Widget build(
      BuildContext context,
      ) {

    final nextEpisode =
    currentEpisode ==
        totalEpisodes

        ? 1

        : currentEpisode +
        1;

    return GestureDetector(

      onTap: onTap,

      child: SizedBox(

        width: 62,

        child: Column(
          mainAxisSize:
          MainAxisSize.min,

          children: [

            ClipRRect(

              borderRadius:
              BorderRadius.circular(
                20,
              ),

              child:
              BackdropFilter(

                filter:
                ImageFilter.blur(

                  sigmaX: 8,

                  sigmaY: 8,
                ),

                child:
                Container(

                  width: 50,
                  height: 50,

                  decoration:
                  BoxDecoration(

                    color:
                    Colors.white
                        .withOpacity(
                      0.10,
                    ),

                    borderRadius:
                    BorderRadius.circular(
                      20,
                    ),

                    border:
                    Border.all(
                      color:
                      Colors.white24,
                    ),
                  ),

                  child: Stack(
                    alignment:
                    Alignment.center,

                    children: [

                      const Icon(

                        Icons
                            .swap_vert_rounded,

                        color:
                        Colors.white,

                        size: 22,
                      ),

                      Positioned(

                        top: 5,
                        right: 5,

                        child:
                        Container(

                          width: 16,
                          height: 16,

                          decoration:
                          const BoxDecoration(

                            color:
                            Colors.redAccent,

                            shape:
                            BoxShape.circle,
                          ),

                          alignment:
                          Alignment.center,

                          child: Text(

                            "$nextEpisode",

                            style:
                            const TextStyle(

                              color:
                              Colors.white,

                              fontSize:
                              9,

                              fontWeight:
                              FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 5,
            ),

            const Text(

              "Switch",

              style: TextStyle(

                color:
                Colors.white,

                fontSize: 10,

                fontWeight:
                FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomSeekBar
    extends StatefulWidget {

  final VideoPlayerController
  controller;

  const _BottomSeekBar({
    required this.controller,
  });

  @override
  State<_BottomSeekBar>
  createState() =>
      _BottomSeekBarState();
}

class _BottomSeekBarState
    extends State<
        _BottomSeekBar> {

  bool _dragging = false;

  double _dragValue = 0;

  @override
  void initState() {
    super.initState();

    widget.controller
        .addListener(
      _listener,
    );
  }

  @override
  void didUpdateWidget(
      covariant _BottomSeekBar
      oldWidget,
      ) {

    super.didUpdateWidget(
      oldWidget,
    );

    if (oldWidget.controller !=
        widget.controller) {

      oldWidget.controller
          .removeListener(
        _listener,
      );

      widget.controller
          .addListener(
        _listener,
      );
    }
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

    if (mounted &&
        !_dragging) {

      setState(() {});
    }
  }

  String _formatDuration(
      Duration d,
      ) {

    final minutes =
    d.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');

    final seconds =
    d.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');

    final hours = d.inHours;

    if (hours > 0) {

      return "$hours:$minutes:$seconds";
    }

    return "$minutes:$seconds";
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
        height: 20,
      );
    }

    final durationMs =
    value.duration
        .inMilliseconds
        .toDouble();

    final positionMs =
    value.position
        .inMilliseconds
        .clamp(
      0,
      value.duration
          .inMilliseconds,
    )
        .toDouble();

    final sliderValue =
    _dragging

        ? _dragValue

        : positionMs;

    return Container(

      padding:
      const EdgeInsets.fromLTRB(
        10,
        0,
        10,
        10,
      ),

      decoration:
      const BoxDecoration(

        gradient:
        LinearGradient(

          begin:
          Alignment.bottomCenter,

          end:
          Alignment.topCenter,

          colors: [

            Color(
              0xD9000000,
            ),

            Color(
              0x80000000,
            ),

            Colors.transparent,
          ],
        ),
      ),

      child: Column(
        mainAxisSize:
        MainAxisSize.min,

        children: [

          SliderTheme(

            data:
            SliderTheme.of(
              context,
            ).copyWith(

              trackHeight: 3.2,

              thumbShape:
              const RoundSliderThumbShape(
                enabledThumbRadius:
                6,
              ),

              overlayShape:
              const RoundSliderOverlayShape(
                overlayRadius:
                12,
              ),

              activeTrackColor:
              Colors.white,

              inactiveTrackColor:
              Colors.white24,

              thumbColor:
              Colors.white,

              overlayColor:
              Colors.white24,
            ),

            child: Slider(

              min: 0,

              max:
              durationMs <= 0

                  ? 1

                  : durationMs,

              value:
              sliderValue.clamp(

                0,

                durationMs <= 0

                    ? 1

                    : durationMs,
              ),

              onChanged: (v) {

                setState(() {

                  _dragging = true;

                  _dragValue = v;
                });
              },

              onChangeEnd:
                  (v) async {

                await widget
                    .controller
                    .seekTo(

                  Duration(
                    milliseconds:
                    v.toInt(),
                  ),
                );

                setState(() {

                  _dragging =
                  false;
                });
              },
            ),
          ),

          Padding(

            padding:
            const EdgeInsets.symmetric(
              horizontal: 6,
            ),

            child: Row(
              children: [

                Text(

                  _formatDuration(

                    Duration(
                      milliseconds:
                      sliderValue
                          .toInt(),
                    ),
                  ),

                  style:
                  const TextStyle(

                    color:
                    Colors.white70,

                    fontSize:
                    11,

                    fontWeight:
                    FontWeight.w600,
                  ),
                ),

                const Spacer(),

                Text(

                  _formatDuration(
                    value.duration,
                  ),

                  style:
                  const TextStyle(

                    color:
                    Colors.white70,

                    fontSize:
                    11,

                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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