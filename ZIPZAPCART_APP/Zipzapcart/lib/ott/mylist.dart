import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api_service.dart';
import '../constants.dart';
import 'mkvplayer.dart';

class MyListPage
    extends StatefulWidget {

  const MyListPage({
    super.key,
  });

  @override
  State<MyListPage>
  createState() =>
      _MyListPageState();
}

class _MyListPageState
    extends State<MyListPage> {

  bool loading = true;

  List movies = [];

  @override
  void initState() {
    super.initState();

    loadWatchlist();
  }

  Future<void>
  loadWatchlist() async {

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
        .getWatchlistMovies(
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

          "My List",

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

                "Your List is Empty",

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

                "Movies you add to watchlist will appear here.",

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

          : GridView.builder(

        padding:
        const EdgeInsets.all(
          14,
        ),

        itemCount:
        movies.length,

        gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(

          crossAxisCount: 2,

          childAspectRatio:
          0.63,

          crossAxisSpacing:
          12,

          mainAxisSpacing:
          16,
        ),

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
                        item["movieid"]
                            .toString(),
                      ),
                ),
              );
            },

            child: Container(

              decoration:
              BoxDecoration(

                color:
                const Color(
                  0xFF141414,
                ),

                borderRadius:
                BorderRadius.circular(
                  18,
                ),
              ),

              clipBehavior:
              Clip.antiAlias,

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  Expanded(

                    child: Stack(
                      children: [

                        Positioned.fill(

                          child:
                          CachedNetworkImage(

                            imageUrl:
                            AppConstants.imageUrl +
                                item[
                                "mainposter"],

                            fit:
                            BoxFit.cover,
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
                        ),
                      ],
                    ),
                  ),

                  Padding(

                    padding:
                    const EdgeInsets.all(
                      12,
                    ),

                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                      children: [

                        Text(

                          item["title"],

                          maxLines: 1,

                          overflow:
                          TextOverflow
                              .ellipsis,

                          style:
                          const TextStyle(

                            color:
                            Colors.white,

                            fontSize:
                            14,

                            fontWeight:
                            FontWeight.w700,
                          ),
                        ),

                        const SizedBox(
                          height: 6,
                        ),

                        Row(
                          children: [

                            const Icon(

                              Icons
                                  .visibility_outlined,

                              color:
                              Colors.white54,

                              size: 15,
                            ),

                            const SizedBox(
                              width: 5,
                            ),

                            Text(

                              "${item["views"]} Views",

                              style:
                              const TextStyle(

                                color:
                                Colors.white54,

                                fontSize:
                                11,
                              ),
                            ),
                          ],
                        ),
                      ],
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