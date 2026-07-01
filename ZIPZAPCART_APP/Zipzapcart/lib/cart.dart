import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'checkout.dart';
import 'constants.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() =>
      _CartPageState();
}

class _CartPageState
    extends State<CartPage> {

  List items = [];
  int userId = 0;
  bool loading = true;

  double total = 0;

  final Color primaryColor =
  const Color(0xFFECA202);

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

    loadCart();
  }
  Future<void> loadCart() async {

    items = await ApiService.getCart(userId);

    total = 0;

    for (var item in items) {

      total +=
      (double.parse(
        item["saleprice"]
            .toString(),
      ) *
          int.parse(
            item["quantity"]
                .toString(),
          ));
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      const Color(0xFFF5F5F5),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,

        centerTitle: true,

        title: Text(
          "My Cart",

          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),

      bottomNavigationBar:
      items.isEmpty
          ? null
          : Container(
        padding:
        const EdgeInsets.all(18),

        decoration:
        const BoxDecoration(
          color: Colors.white,
        ),

        child: SafeArea(
          child: Row(
            children: [

              Expanded(
                child: Column(
                  mainAxisSize:
                  MainAxisSize.min,

                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

                  children: [

                    Text(
                      "Total Amount",

                      style:
                      GoogleFonts.poppins(
                        fontSize: 13,
                        color:
                        Colors.grey,
                      ),
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      "₹$total",

                      style:
                      GoogleFonts.poppins(
                        fontSize: 28,

                        fontWeight:
                        FontWeight.w700,

                        color:
                        primaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SizedBox(
                  height: 58,

                  child:
                  ElevatedButton(

                    onPressed: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                          const CheckoutPage(),
                        ),
                      );
                    },

                    style:
                    ElevatedButton.styleFrom(
                      backgroundColor:
                      primaryColor,

                      elevation: 0,

                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                          18,
                        ),
                      ),
                    ),

                    child: Text(
                      "Checkout",

                      style:
                      GoogleFonts.poppins(
                        color:
                        Colors.white,

                        fontSize: 15,

                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      body: loading

          ? Center(
        child:
        CircularProgressIndicator(
          color: primaryColor,
        ),
      )
          : items.isEmpty

          ? Center(
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [

            Lottie.asset(
              "assets/images/empty-cart.json",
              height: 240,
            ),

            const SizedBox(
              height: 20,
            ),

            Text(
              "Your Cart is Empty",

              style:
              GoogleFonts.poppins(
                fontSize: 22,

                fontWeight:
                FontWeight.w700,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            Text(
              "Looks like you haven’t\nadded anything yet.",

              textAlign:
              TextAlign.center,

              style:
              GoogleFonts.poppins(
                color:
                Colors.grey,

                height: 1.7,

                fontSize: 14,
              ),
            ),

            const SizedBox(
              height: 28,
            ),

            SizedBox(
              width: 220,
              height: 56,

              child:
              ElevatedButton(

                onPressed: () {

                  Navigator.pop(
                    context,
                  );
                },

                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  primaryColor,

                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(
                      18,
                    ),
                  ),
                ),

                child: Text(
                  "Start Shopping",

                  style:
                  GoogleFonts.poppins(
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
      )

          : ListView.builder(
        padding:
        const EdgeInsets.all(
          14,
        ),

        itemCount:
        items.length,

        itemBuilder:
            (_, index) {

          final item =
          items[index];

          return Container(

            margin:
            const EdgeInsets.only(
              bottom: 14,
            ),

            padding:
            const EdgeInsets.all(
              14,
            ),

            decoration:
            BoxDecoration(
              color:
              Colors.white,

              borderRadius:
              BorderRadius.circular(
                22,
              ),

              boxShadow: [
                BoxShadow(
                  color: Colors.black
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
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,

              children: [

                Container(
                  height: 110,
                  width: 110,

                  padding:
                  const EdgeInsets.all(
                    12,
                  ),

                  decoration:
                  BoxDecoration(
                    color:
                    const Color(
                      0xFFF7F7F7,
                    ),

                    borderRadius:
                    BorderRadius.circular(
                      18,
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
                  width: 14,
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
                          fontSize:
                          15,

                          fontWeight:
                          FontWeight
                              .w600,
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      Text(
                        "₹${item["saleprice"]}",

                        style:
                        GoogleFonts.poppins(
                          fontSize:
                          22,

                          fontWeight:
                          FontWeight
                              .w700,

                          color:
                          primaryColor,
                        ),
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      Row(
                        children: [

                          // 🔥 MINUS
                          GestureDetector(

                            onTap:
                                () async {

                              await ApiService
                                  .updateCartQuantity(
                                int.parse(
                                  item["id"]
                                      .toString(),
                                ),
                                "minus",
                              );

                              loadCart();
                            },

                            child:
                            Container(
                              height:
                              36,

                              width:
                              36,

                              decoration:
                              BoxDecoration(
                                color:
                                const Color(
                                  0xFFF3F3F3,
                                ),

                                borderRadius:
                                BorderRadius.circular(
                                  12,
                                ),
                              ),

                              child:
                              const Icon(
                                Icons
                                    .remove,
                                size:
                                18,
                              ),
                            ),
                          ),

                          Container(
                            margin:
                            const EdgeInsets.symmetric(
                              horizontal:
                              14,
                            ),

                            child:
                            Text(
                              item[
                              "quantity"]
                                  .toString(),

                              style:
                              GoogleFonts.poppins(
                                fontSize:
                                16,

                                fontWeight:
                                FontWeight
                                    .w700,
                              ),
                            ),
                          ),

                          // 🔥 PLUS
                          GestureDetector(

                            onTap:
                                () async {

                              await ApiService
                                  .updateCartQuantity(
                                int.parse(
                                  item["id"]
                                      .toString(),
                                ),
                                "plus",
                              );

                              loadCart();
                            },

                            child:
                            Container(
                              height:
                              36,

                              width:
                              36,

                              decoration:
                              BoxDecoration(
                                color:
                                primaryColor,

                                borderRadius:
                                BorderRadius.circular(
                                  12,
                                ),
                              ),

                              child:
                              const Icon(
                                Icons.add,
                                size:
                                18,

                                color: Colors
                                    .white,
                              ),
                            ),
                          ),

                          const Spacer(),

                          // 🔥 DELETE
                          GestureDetector(

                            onTap:
                                () async {

                              await ApiService
                                  .removeCartItem(
                                int.parse(
                                  item["id"]
                                      .toString(),
                                ),
                              );

                              loadCart();
                            },

                            child:
                            Container(
                              padding:
                              const EdgeInsets.all(
                                10,
                              ),

                              decoration:
                              BoxDecoration(
                                color: Colors
                                    .red
                                    .withOpacity(
                                  0.10,
                                ),

                                borderRadius:
                                BorderRadius.circular(
                                  12,
                                ),
                              ),

                              child:
                              const Icon(
                                Icons
                                    .delete_outline,

                                color:
                                Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}