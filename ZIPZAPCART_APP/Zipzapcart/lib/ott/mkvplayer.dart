import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import '../api_service.dart';
import '../constants.dart';
import 'upgrade.dart';

class MkvPlayerPage extends StatefulWidget {

  final String movieId;

  const MkvPlayerPage({
    super.key,
    required this.movieId,
  });

  @override
  State<MkvPlayerPage> createState() =>
      _MkvPlayerPageState();
}

class _MkvPlayerPageState
    extends State<MkvPlayerPage> {

  late VideoPlayerController
  _controller;

  bool _isLoading = true;

  bool _isPlaying = false;

  bool _showControls = true;

  bool _isInWatchlist = false;

  Map movie = {};

  List cast = [];

  String movieTitle = "";

  String aboutMovie = "";

  String videoUrl = "";

  String userId = "";

  int views = 0;

  bool isPremium = false;

  Duration watchedPosition =
      Duration.zero;

  @override
  void initState() {
    super.initState();

    loadMovie();
  }

  Future<void> loadMovie() async {

    final prefs =
    await SharedPreferences
        .getInstance();

    userId =
        prefs
            .getInt("user_id")
            .toString();

    final data =
    await ApiService.viewMovie(
      widget.movieId,
      userId,
    );

    if (data["status"] == true) {

      movie =
      data["movie"];

      cast =
      data["cast"];

      movieTitle =
          movie["title"] ?? "";

      aboutMovie =
          movie["about_html"] ?? "";

      videoUrl =
          movie["file"] ?? "";

      views = int.tryParse(
        movie["views"].toString(),
      ) ??
          0;

      isPremium =
          movie["isfree"] != "yes";

      _isInWatchlist =
          data["is_watchlist"] ?? false;

      await _initVideo();
    }

    setState(() {});
  }

  Future<void> _initVideo() async {

    try {

      _controller =
          VideoPlayerController
              .networkUrl(
            Uri.parse(videoUrl),
          );

      await _controller.initialize();

      await _controller.setLooping(
        false,
      );

      if (!isPremium) {

        await _controller.play();
      }

      _controller.addListener(
        _videoListener,
      );

      if (mounted) {

        setState(() {

          _isLoading = false;

          _isPlaying =
              _controller
                  .value
                  .isPlaying;
        });
      }

    } catch (e) {

      if (mounted) {

        setState(() {

          _isLoading = false;
        });
      }
    }
  }

  void _videoListener() {

    if (!mounted) return;

    final playing =
        _controller
            .value
            .isPlaying;

    watchedPosition =
        _controller
            .value
            .position;

    ApiService.saveWatchProgress(

      userId: userId,

      movieId:
      widget.movieId,

      watchedSeconds:
      watchedPosition
          .inSeconds,
    );

    if (playing != _isPlaying) {

      setState(() {

        _isPlaying = playing;
      });
    }
  }

  Future<void>
  _togglePlayPause() async {

    if (!_controller
        .value
        .isInitialized) return;

    if (_controller
        .value
        .isPlaying) {

      await _controller.pause();

    } else {

      await _controller.play();
    }

    if (mounted) {

      setState(() {

        _isPlaying =
            _controller
                .value
                .isPlaying;
      });
    }
  }

  Future<void>
  seekForward() async {

    final current =
        _controller
            .value
            .position;

    await _controller.seekTo(

      current +
          const Duration(
            seconds: 10,
          ),
    );
  }

  Future<void>
  seekBackward() async {

    final current =
        _controller
            .value
            .position;

    await _controller.seekTo(

      current -
          const Duration(
            seconds: 10,
          ),
    );
  }

  Future<void>
  _openFullscreen() async {

    if (!_controller
        .value
        .isInitialized) return;

    await Navigator.push(

      context,

      MaterialPageRoute(

        builder:
            (_) =>
            FullScreenVideoPage(

              controller:
              _controller,

              title:
              movieTitle,
            ),
      ),
    );

    if (mounted) {

      setState(() {});
    }
  }

  String _formatViews(
      int views,
      ) {

    if (views >= 1000000) {

      return
        "${(views / 1000000).toStringAsFixed(1)}M";
    }

    if (views >= 1000) {

      return
        "${(views / 1000).toStringAsFixed(1)}K";
    }

    return views.toString();
  }

  @override
  void dispose() {

    if (!_isLoading) {

      _controller.removeListener(
        _videoListener,
      );

      _controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(
      BuildContext context,
      ) {

    final playerHeight =
        MediaQuery.of(context)
            .size
            .width *
            9 /
            16;

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

        title: Text(

          movieTitle,

          style: const TextStyle(

            color:
            Colors.white,

            fontSize: 17,

            fontWeight:
            FontWeight.w800,
          ),
        ),
      ),

      body: _isLoading

          ? const Center(

        child:
        CircularProgressIndicator(
          color: Color(
            0xFFE8C37A,
          ),
        ),
      )

          : ListView(

        padding:
        const EdgeInsets.only(
          bottom: 28,
        ),

        children: [

          // 🔥 PLAYER
          Container(

            height:
            playerHeight,

            width:
            double.infinity,

            color:
            Colors.black,

            child:
            !_controller
                .value
                .isInitialized

                ? const Center(
              child: Text(

                "Video failed to load",

                style: TextStyle(
                  color:
                  Colors.white70,
                ),
              ),
            )

                : GestureDetector(

              onTap: () {

                setState(() {

                  _showControls =
                  !_showControls;
                });
              },

              child: Stack(
                fit:
                StackFit.expand,

                children: [

                  AspectRatio(

                    aspectRatio:
                    _controller
                        .value
                        .aspectRatio,

                    child:
                    VideoPlayer(
                      _controller,
                    ),
                  ),

                  AnimatedOpacity(

                    opacity:
                    _showControls
                        ? 1
                        : 0,

                    duration:
                    const Duration(
                      milliseconds:
                      220,
                    ),

                    child:
                    Container(

                      decoration:
                      BoxDecoration(

                        gradient:
                        LinearGradient(

                          begin:
                          Alignment.topCenter,

                          end:
                          Alignment.bottomCenter,

                          colors: [

                            Colors.black
                                .withOpacity(
                              0.55,
                            ),

                            Colors
                                .transparent,

                            Colors.black
                                .withOpacity(
                              0.75,
                            ),
                          ],
                        ),
                      ),

                      child: Stack(
                        children: [

                          // 🔥 PLAYER CONTROLS
                          Center(

                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,

                              children: [

                                GestureDetector(

                                  onTap:
                                  seekBackward,

                                  child:
                                  Container(

                                    width:
                                    58,

                                    height:
                                    58,

                                    decoration:
                                    BoxDecoration(

                                      shape:
                                      BoxShape.circle,

                                      color:
                                      Colors.black
                                          .withOpacity(
                                        0.45,
                                      ),
                                    ),

                                    child:
                                    const Icon(

                                      Icons.replay_10_rounded,

                                      color:
                                      Colors.white,

                                      size:
                                      34,
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  width:
                                  18,
                                ),

                                GestureDetector(

                                  onTap: () {

                                    if (isPremium) {

                                      Navigator.push(

                                        context,

                                        MaterialPageRoute(
                                          builder:
                                              (_) =>
                                          const UpgradePage(),
                                        ),
                                      );

                                    } else {

                                      _togglePlayPause();
                                    }
                                  },

                                  child:
                                  Container(

                                    width:
                                    82,

                                    height:
                                    82,

                                    decoration:
                                    BoxDecoration(

                                      shape:
                                      BoxShape.circle,

                                      color:
                                      Colors.black
                                          .withOpacity(
                                        0.45,
                                      ),

                                      border:
                                      Border.all(
                                        color:
                                        Colors.white24,
                                      ),
                                    ),

                                    child:
                                    Icon(

                                      _isPlaying

                                          ? Icons.pause_rounded

                                          : Icons.play_arrow_rounded,

                                      color:
                                      Colors.white,

                                      size:
                                      46,
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  width:
                                  18,
                                ),

                                GestureDetector(

                                  onTap:
                                  seekForward,

                                  child:
                                  Container(

                                    width:
                                    58,

                                    height:
                                    58,

                                    decoration:
                                    BoxDecoration(

                                      shape:
                                      BoxShape.circle,

                                      color:
                                      Colors.black
                                          .withOpacity(
                                        0.45,
                                      ),
                                    ),

                                    child:
                                    const Icon(

                                      Icons.forward_10_rounded,

                                      color:
                                      Colors.white,

                                      size:
                                      34,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Positioned(

                            right: 14,
                            bottom: 14,

                            child:
                            GestureDetector(

                              onTap:
                              _openFullscreen,

                              child:
                              Container(

                                padding:
                                const EdgeInsets.all(
                                  10,
                                ),

                                decoration:
                                BoxDecoration(

                                  color:
                                  Colors.black
                                      .withOpacity(
                                    0.45,
                                  ),

                                  borderRadius:
                                  BorderRadius.circular(
                                    12,
                                  ),
                                ),

                                child:
                                const Icon(

                                  Icons.fullscreen_rounded,

                                  color:
                                  Colors.white,

                                  size:
                                  28,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (!isPremium)

                    Positioned(

                      left: 0,
                      right: 0,
                      bottom: 0,

                      child:
                      VideoProgressIndicator(

                        _controller,

                        allowScrubbing:
                        true,

                        padding:
                        EdgeInsets.zero,

                        colors:
                        const VideoProgressColors(

                          playedColor:
                          Color(
                            0xFFE8C37A,
                          ),

                          bufferedColor:
                          Colors.white38,

                          backgroundColor:
                          Colors.white12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // 🔥 PREMIUM BOX
          if (isPremium)

            Container(

              margin:
              const EdgeInsets.all(
                16,
              ),

              padding:
              const EdgeInsets.all(
                18,
              ),

              decoration:
              BoxDecoration(

                borderRadius:
                BorderRadius.circular(
                  18,
                ),

                gradient:
                const LinearGradient(
                  colors: [

                    Color(
                      0xFF232526,
                    ),

                    Color(
                      0xFF414345,
                    ),
                  ],
                ),
              ),

              child: Column(
                children: [

                  const Icon(

                    Icons.workspace_premium,

                    color:
                    Color(
                      0xFFE8C37A,
                    ),

                    size: 44,
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  const Text(

                    "Premium Movie",

                    style: TextStyle(

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

                  const Text(

                    "Upgrade your membership to watch this movie in HD quality without ads.",

                    textAlign:
                    TextAlign.center,

                    style: TextStyle(

                      color:
                      Colors.white70,

                      height: 1.5,
                    ),
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  GestureDetector(

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

                    child:
                    Container(

                      height: 52,

                      decoration:
                      BoxDecoration(

                        borderRadius:
                        BorderRadius.circular(
                          14,
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
                      const Center(

                        child: Text(

                          "Upgrade Now",

                          style: TextStyle(

                            color:
                            Colors.black,

                            fontWeight:
                            FontWeight.w800,

                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 18),

          // 🔥 TITLE
          Padding(

            padding:
            const EdgeInsets.symmetric(
              horizontal: 16,
            ),

            child: Text(

              movieTitle,

              style:
              const TextStyle(

                color:
                Colors.white,

                fontSize:
                21,

                fontWeight:
                FontWeight.w800,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 🔥 INFO CARDS
          Padding(

            padding:
            const EdgeInsets.symmetric(
              horizontal: 16,
            ),

            child: Row(
              children: [

                Expanded(

                  child: _InfoCard(

                    title:
                    "Watchlist",

                    value:
                    _isInWatchlist

                        ? "Saved"

                        : "Add",

                    icon:
                    _isInWatchlist

                        ? Icons.bookmark

                        : Icons.bookmark_border,

                    onTap: () async {

                      bool status =
                      await ApiService
                          .toggleWatchlist(
                        userId,
                        widget.movieId,
                      );

                      setState(() {

                        _isInWatchlist =
                            status;
                      });
                    },
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                Expanded(

                  child: _InfoCard(

                    title:
                    "Views",

                    value:
                    _formatViews(
                      views,
                    ),

                    icon:
                    Icons.visibility_outlined,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 🔥 CAST
          const Padding(

            padding:
            EdgeInsets.symmetric(
              horizontal: 16,
            ),

            child: Text(

              "Cast",

              style: TextStyle(

                color:
                Colors.white,

                fontSize:
                17,

                fontWeight:
                FontWeight.w800,
              ),
            ),
          ),

          const SizedBox(height: 14),

          SizedBox(

            height: 160,

            child:
            ListView.separated(

              padding:
              const EdgeInsets.symmetric(
                horizontal: 16,
              ),

              scrollDirection:
              Axis.horizontal,

              itemCount:
              cast.length,

              separatorBuilder:
                  (_, __) =>
              const SizedBox(
                width: 18,
              ),

              itemBuilder:
                  (_, index) {

                final item =
                cast[index];

                return _CastCircleItem(

                  name:
                  item["name"],

                  imageUrl:
                  AppConstants.imageUrl +
                      item["imagelink"],
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // 🔥 ABOUT
          const Padding(

            padding:
            EdgeInsets.symmetric(
              horizontal: 16,
            ),

            child: Text(

              "About Movie",

              style: TextStyle(

                color:
                Colors.white,

                fontSize:
                17,

                fontWeight:
                FontWeight.w800,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Padding(

            padding:
            const EdgeInsets.symmetric(
              horizontal: 12,
            ),

            child: Html(

              data: aboutMovie,

              style: {

                "body": Style(

                  color:
                  Colors.white,

                  fontSize:
                  FontSize(15),

                  lineHeight:
                  LineHeight(
                    1.6,
                  ),

                  margin:
                  Margins.zero,

                  padding:
                  HtmlPaddings.zero,
                ),

                "p": Style(
                  color:
                  Colors.white,
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard
    extends StatelessWidget {

  final String title;

  final String value;

  final IconData icon;

  final VoidCallback? onTap;

  const _InfoCard({

    required this.title,

    required this.value,

    required this.icon,

    this.onTap,
  });

  @override
  Widget build(
      BuildContext context,
      ) {

    final card = Container(

      padding:
      const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 16,
      ),

      decoration: BoxDecoration(

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

            width: 44,
            height: 44,

            decoration:
            BoxDecoration(

              color:
              Colors.white
                  .withOpacity(
                0.08,
              ),

              borderRadius:
              BorderRadius.circular(
                12,
              ),
            ),

            child: Icon(

              icon,

              color:
              Colors.white,

              size: 24,
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(

            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,

              children: [

                Text(

                  title,

                  style: TextStyle(

                    color:
                    Colors.white
                        .withOpacity(
                      0.72,
                    ),

                    fontSize: 12,

                    fontWeight:
                    FontWeight.w500,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(

                  value,

                  style:
                  const TextStyle(

                    color:
                    Colors.white,

                    fontSize:
                    15,

                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return card;
    }

    return GestureDetector(
      onTap: onTap,
      child: card,
    );
  }
}

class _CastCircleItem
    extends StatelessWidget {

  final String name;

  final String imageUrl;

  const _CastCircleItem({

    required this.name,

    required this.imageUrl,
  });

  @override
  Widget build(
      BuildContext context,
      ) {

    return SizedBox(

      width: 96,

      child: Column(
        children: [

          Container(

            width: 82,
            height: 82,

            decoration:
            BoxDecoration(

              shape:
              BoxShape.circle,

              border:
              Border.all(
                color:
                Colors.white12,
                width: 2,
              ),
            ),

            child: ClipOval(

              child:
              CachedNetworkImage(

                imageUrl:
                imageUrl,

                fit:
                BoxFit.cover,

                placeholder:
                    (_, __) =>
                    Container(
                      color:
                      const Color(
                        0xFF1A1A1A,
                      ),
                    ),

                errorWidget:
                    (_, __, ___) =>
                    Container(

                      color:
                      const Color(
                        0xFF1A1A1A,
                      ),

                      child:
                      const Icon(

                        Icons.person,

                        color:
                        Colors.white38,

                        size: 34,
                      ),
                    ),
              ),
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          Text(

            name,

            maxLines: 2,

            overflow:
            TextOverflow.ellipsis,

            textAlign:
            TextAlign.center,

            style:
            const TextStyle(

              color:
              Colors.white,

              fontSize:
              12.5,

              fontWeight:
              FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class FullScreenVideoPage
    extends StatefulWidget {

  final VideoPlayerController
  controller;

  final String title;

  const FullScreenVideoPage({

    super.key,

    required this.controller,

    required this.title,
  });

  @override
  State<FullScreenVideoPage>
  createState() =>
      _FullScreenVideoPageState();
}

class _FullScreenVideoPageState
    extends State<FullScreenVideoPage> {

  bool _showControls = true;

  @override
  void initState() {
    super.initState();

    _enterLandscape();
  }

  Future<void>
  _enterLandscape() async {

    await SystemChrome
        .setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );

    await SystemChrome
        .setPreferredOrientations([

      DeviceOrientation
          .landscapeLeft,

      DeviceOrientation
          .landscapeRight,
    ]);
  }

  Future<void>
  _restorePortraitOnly() async {

    await SystemChrome
        .setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );

    await SystemChrome
        .setPreferredOrientations([

      DeviceOrientation
          .portraitUp,
    ]);
  }

  @override
  void dispose() {

    _restorePortraitOnly();

    super.dispose();
  }

  @override
  Widget build(
      BuildContext context,
      ) {

    return Scaffold(

      backgroundColor:
      Colors.black,

      body: GestureDetector(

        onTap: () {

          setState(() {

            _showControls =
            !_showControls;
          });
        },

        child: Stack(
          fit: StackFit.expand,

          children: [

            Center(

              child: AspectRatio(

                aspectRatio:
                widget
                    .controller
                    .value
                    .aspectRatio,

                child:
                VideoPlayer(
                  widget.controller,
                ),
              ),
            ),

            if (_showControls)

              Positioned(

                top: 24,
                left: 16,

                child:
                GestureDetector(

                  onTap: () {

                    Navigator.pop(
                      context,
                    );
                  },

                  child: Container(

                    padding:
                    const EdgeInsets.all(
                      10,
                    ),

                    decoration:
                    BoxDecoration(

                      color:
                      Colors.black
                          .withOpacity(
                        0.5,
                      ),

                      shape:
                      BoxShape.circle,
                    ),

                    child:
                    const Icon(

                      Icons.arrow_back,

                      color:
                      Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}