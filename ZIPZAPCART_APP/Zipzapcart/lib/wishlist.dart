import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';
import 'constants.dart';
import 'view_product.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() =>
      _WishlistPageState();
}

class _WishlistPageState
    extends State<WishlistPage> {

  bool loading = true;

  int userId = 0;

  List products = [];

  final Color primaryColor =
  const Color(0xFFDF6907);

  @override
  void initState() {
    super.initState();

    getUser();
  }

  Future<void> getUser() async {

    final prefs =
    await SharedPreferences.getInstance();

    userId =
        prefs.getInt("user_id") ?? 0;

    loadWishlist();
  }

  Future<void> loadWishlist() async {

    products =
    await ApiService.getWishlist(
      userId,
    );

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      const Color(0xFFF6F7F9),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,

        title: const Text(
          "Wishlist",

          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),

        centerTitle: true,
      ),

      body: loading

          ? const Center(
        child:
        CircularProgressIndicator(),
      )

          : products.isEmpty

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

              // 🔥 LOTTIE
              Lottie.asset(
                "assets/images/nodata.json",
                height: 220,
                repeat: true,
              ),

              const SizedBox(height: 20),

              const Text(
                "Your Wishlist is Empty",

                textAlign:
                TextAlign.center,

                style: TextStyle(
                  fontSize: 18,
                  fontWeight:
                  FontWeight.w800,

                  color:
                  Color(0xFF111111),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Save your favorite items here.\nYou can add products to wishlist and shop later.",

                textAlign:
                TextAlign.center,

                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 26),

              SizedBox(
                width: double.infinity,
                height: 52,

                child: ElevatedButton(

                  onPressed: () {

                    Navigator.pop(
                      context,
                    );
                  },

                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    primaryColor,

                    foregroundColor:
                    Colors.white,

                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        14,
                      ),
                    ),

                    elevation: 0,
                  ),

                  child: const Text(
                    "Start Shopping",

                    style: TextStyle(
                      fontWeight:
                      FontWeight.w700,

                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      )

          : RefreshIndicator(

        onRefresh: () async {

          loadWishlist();
        },

        child: ListView.builder(

          padding:
          const EdgeInsets.all(16),

          itemCount:
          products.length,

          itemBuilder:
              (_, index) {

            final item =
            products[index];

            return GestureDetector(

              onTap: () {

                Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder: (_) =>
                        ViewProductPage(
                          productId:
                          int.parse(
                            item["id"]
                                .toString(),
                          ),
                        ),
                  ),
                );
              },

              child: Container(

                margin:
                const EdgeInsets.only(
                  bottom: 16,
                ),

                padding:
                const EdgeInsets.all(
                  14,
                ),

                decoration:
                BoxDecoration(
                  color: Colors.white,

                  borderRadius:
                  BorderRadius.circular(
                    22,
                  ),

                  boxShadow: [

                    BoxShadow(
                      color:
                      Colors.black
                          .withOpacity(
                        0.03,
                      ),

                      blurRadius: 12,

                      offset:
                      const Offset(
                        0,
                        4,
                      ),
                    ),
                  ],
                ),

                child: Row(
                  children: [

                    Container(
                      height: 95,
                      width: 95,

                      padding:
                      const EdgeInsets.all(
                        10,
                      ),

                      decoration:
                      BoxDecoration(
                        color:
                        const Color(
                          0xFFF5F5F5,
                        ),

                        borderRadius:
                        BorderRadius.circular(
                          20,
                        ),
                      ),

                      child:
                      Image.network(
                        AppConstants
                            .imageUrl +
                            item["image"],

                        fit:
                        BoxFit.contain,
                      ),
                    ),

                    const SizedBox(
                      width: 16,
                    ),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                        children: [

                          Text(
                            item["name"],

                            maxLines: 2,

                            overflow:
                            TextOverflow
                                .ellipsis,

                            style:
                            GoogleFonts.poppins(
                              fontWeight:
                              FontWeight
                                  .w600,

                              fontSize:
                              15,
                            ),
                          ),

                          const SizedBox(
                            height: 12,
                          ),

                          Row(

                            children:[

                              Flexible(

                                flex:2,

                                child:

                                Text(

                                  "₹${item["saleprice"]}",

                                  maxLines:1,

                                  overflow:
                                  TextOverflow.ellipsis,

                                  style:

                                  GoogleFonts.poppins(

                                    color:
                                    primaryColor,

                                    fontSize:
                                    20,

                                    fontWeight:
                                    FontWeight.w700,

                                  ),

                                ),

                              ),

                              const SizedBox(
                                width:8,
                              ),

                              Expanded(

                                child:

                                Align(

                                  alignment:
                                  Alignment.centerRight,

                                  child:

                                  Text(

                                    "₹${item["rate"]}",

                                    maxLines:1,

                                    overflow:
                                    TextOverflow.ellipsis,

                                    style:

                                    GoogleFonts.poppins(

                                      fontSize:
                                      13,

                                      decoration:
                                      TextDecoration.lineThrough,

                                      color:
                                      Colors.grey,

                                    ),

                                  ),

                                ),

                              ),

                            ],

                          ),
                          const SizedBox(
                            height: 12,
                          ),

                          Container(
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal:
                              12,

                              vertical: 6,
                            ),

                            decoration:
                            BoxDecoration(
                              color:
                              Colors.green
                                  .withOpacity(
                                0.12,
                              ),

                              borderRadius:
                              BorderRadius.circular(
                                30,
                              ),
                            ),

                            child: Text(
                              "${item["stock"]} In Stock",

                              style:
                              GoogleFonts.poppins(
                                color:
                                Colors.green,

                                fontWeight:
                                FontWeight
                                    .w600,

                                fontSize:
                                12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    Icon(
                      Icons.favorite,

                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}