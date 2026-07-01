import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api_service.dart';
import '../constants.dart';
import 'mkvplayer.dart';

class WatchHistoryPage
    extends StatefulWidget {

  const WatchHistoryPage({
    super.key,
  });

  @override
  State<WatchHistoryPage>
  createState() =>
      _WatchHistoryPageState();
}

class _WatchHistoryPageState
    extends State<WatchHistoryPage> {

  bool loading = true;

  List movies = [];

  @override
  void initState() {
    super.initState();

    loadHistory();
  }

  Future<void>
  loadHistory() async {

    final prefs =
    await SharedPreferences
        .getInstance();

    int userId =
        prefs.getInt(
          "user_id",
        ) ??
            0;

    movies =
    await ApiService
        .getWatchHistory(
      userId.toString(),
    );

    loading = false;

    setState(() {});
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

        iconTheme:
        const IconThemeData(

          color: Colors.white,
        ),

        title: const Text(

          "Watch History",

          style: TextStyle(

            color:
            Colors.white,

            fontWeight:
            FontWeight.w700,
          ),
        ),
      ),
      body: loading

          ? const Center(

        child:
        CircularProgressIndicator(
          color:
          Color(
            0xFF0A84FF,
          ),
        ),
      )

          : movies.isEmpty

          ? Center(

        child: Padding(

          padding:
          const EdgeInsets.symmetric(
            horizontal: 28,
          ),

          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,

            children: [

              Lottie.asset(

                "assets/images/nodata.json",

                height: 220,
              ),

              const SizedBox(
                height: 20,
              ),

              const Text(

                "No Watch History",

                textAlign:
                TextAlign.center,

                style: TextStyle(

                  fontSize: 20,

                  fontWeight:
                  FontWeight.w800,

                  color:
                  Colors.white,
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              const Text(

                "Movies you watch will appear here.",

                textAlign:
                TextAlign.center,

                style: TextStyle(

                  fontSize: 13,

                  color:
                  Colors.white60,

                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      )

          : ListView.builder(

        padding:
        const EdgeInsets.all(
          14,
        ),

        itemCount:
        movies.length,

        itemBuilder:
            (context, index) {

          final item =
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
                        item["movie_id"]
                            .toString(),
                      ),
                ),
              );
            },

            child: Container(

              margin:
              const EdgeInsets.only(
                bottom: 14,
              ),

              decoration:
              BoxDecoration(

                color:
                const Color(
                  0xFF151515,
                ),

                borderRadius:
                BorderRadius.circular(
                  18,
                ),
              ),

              child: Row(
                children: [

                  ClipRRect(

                    borderRadius:
                    const BorderRadius.only(

                      topLeft:
                      Radius.circular(
                        18,
                      ),

                      bottomLeft:
                      Radius.circular(
                        18,
                      ),
                    ),

                    child:
                    CachedNetworkImage(

                      imageUrl:
                      AppConstants.imageUrl +
                          item[
                          "mainposter"],

                      height: 130,

                      width: 110,

                      fit:
                      BoxFit.cover,
                    ),
                  ),

                  Expanded(

                    child: Padding(

                      padding:
                      const EdgeInsets.all(
                        14,
                      ),

                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                        children: [

                          Text(

                            item["title"],

                            maxLines: 2,

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
                              FontWeight.w700,
                            ),
                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          Row(
                            children: [

                              Container(

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
                                  item["isfree"] ==
                                      "yes"

                                      ? Colors.green

                                      : Colors.orange,

                                  borderRadius:
                                  BorderRadius.circular(
                                    30,
                                  ),
                                ),

                                child: Text(

                                  item["isfree"] ==
                                      "yes"

                                      ? "FREE"

                                      : "PREMIUM",

                                  style:
                                  const TextStyle(

                                    color:
                                    Colors.white,

                                    fontSize:
                                    10,

                                    fontWeight:
                                    FontWeight.w700,
                                  ),
                                ),
                              ),

                              const SizedBox(
                                width: 10,
                              ),

                              const Icon(

                                Icons
                                    .visibility_outlined,

                                color:
                                Colors.white54,

                                size: 16,
                              ),

                              const SizedBox(
                                width: 4,
                              ),

                              Text(

                                "${item["views"]}",

                                style:
                                const TextStyle(

                                  color:
                                  Colors.white54,

                                  fontSize:
                                  12,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 14,
                          ),

                          Container(

                            padding:
                            const EdgeInsets.symmetric(

                              horizontal:
                              12,

                              vertical:
                              8,
                            ),

                            decoration:
                            BoxDecoration(

                              color:
                              const Color(
                                0x220A84FF,
                              ),

                              borderRadius:
                              BorderRadius.circular(
                                30,
                              ),
                            ),

                            child: const Row(
                              mainAxisSize:
                              MainAxisSize.min,

                              children: [

                                Icon(

                                  Icons.play_arrow,

                                  color:
                                  Color(
                                    0xFF0A84FF,
                                  ),

                                  size: 18,
                                ),

                                SizedBox(
                                  width: 4,
                                ),

                                Text(

                                  "Continue Watching",

                                  style: TextStyle(

                                    color:
                                    Color(
                                      0xFF0A84FF,
                                    ),

                                    fontWeight:
                                    FontWeight.w700,

                                    fontSize:
                                    12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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