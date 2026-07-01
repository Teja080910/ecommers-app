import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../api_service.dart';
import '../constants.dart';
import 'applycasting.dart';

class CastingListPage extends StatefulWidget {

  const CastingListPage({super.key});

  @override
  State<CastingListPage> createState() =>
      _CastingListPageState();
}

class _CastingListPageState
    extends State<CastingListPage> {

  bool loading = true;

  List casting = [];

  @override
  void initState() {
    super.initState();

    loadCasting();
  }

  Future<void> loadCasting() async {

    final data =
    await ApiService.getCasting();

    casting =
        data["casting"] ?? [];

    loading = false;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.black,


      appBar: AppBar(

        backgroundColor:
        Colors.black,

        elevation: 0,

        iconTheme:
        const IconThemeData(

          color: Colors.white,
        ),

        title: const Text(

          "Casting Opportunities",

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
          Color(0xFF0A84FF),
        ),
      )

          : ListView.builder(

        padding:
        const EdgeInsets.all(14),

        itemCount:
        casting.length,

        itemBuilder:
            (context, index) {

          final item =
          casting[index];

          return GestureDetector(

            onTap: () {

              Navigator.push(

                context,

                MaterialPageRoute(

                  builder:
                      (_) =>
                      ApplyCastingPage(
                        casting:
                        item,
                      ),
                ),
              );
            },

            child: Container(

              margin:
              const EdgeInsets.only(
                bottom: 16,
              ),

              decoration:
              BoxDecoration(

                color:
                const Color(
                  0xFF161616,
                ),

                borderRadius:
                BorderRadius.circular(
                  18,
                ),
              ),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  ClipRRect(

                    borderRadius:
                    const BorderRadius.only(

                      topLeft:
                      Radius.circular(
                        18,
                      ),

                      topRight:
                      Radius.circular(
                        18,
                      ),
                    ),

                    child:
                    CachedNetworkImage(

                      imageUrl:
                      AppConstants.imageUrl +
                          item["image"],

                      height: 210,

                      width:
                      double.infinity,

                      fit:
                      BoxFit.cover,
                    ),
                  ),

                  Padding(

                    padding:
                    const EdgeInsets.all(
                      14,
                    ),

                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                      children: [

                        Row(
                          children: [

                            Expanded(

                              child: Text(

                                item["title"],

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

                                    : "₹${item["amount"]}",

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
                          ],
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        Text(

                          item["category"],

                          style:
                          const TextStyle(

                            color:
                            Color(0xFF0A84FF),

                            fontWeight:
                            FontWeight.w600,
                          ),
                        ),

                        const SizedBox(
                          height: 14,
                        ),

                        SizedBox(

                          width:
                          double.infinity,

                          height: 50,

                          child:
                          ElevatedButton(

                            onPressed: () {

                              Navigator.push(

                                context,

                                MaterialPageRoute(

                                  builder:
                                      (_) =>
                                      ApplyCastingPage(
                                        casting:
                                        item,
                                      ),
                                ),
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
                                  14,
                                ),
                              ),
                            ),

                            child:
                            const Text(

                              "Apply Now",

                              style: TextStyle(

                                color:
                                Colors.white,

                                fontWeight:
                                FontWeight.w700,
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
          );
        },
      ),
    );
  }
}