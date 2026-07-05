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
  const Color(0xFFEF4138);

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
        const EdgeInsets.fromLTRB(
          14, 12, 14, 12,
        ),

        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),

        child: SafeArea(
          top: false,
          child: Row(
            children: [

              Expanded(
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),

                  decoration: BoxDecoration(
                    color: const Color(
                      0xFFFDECEB,
                    ),

                    borderRadius:
                    BorderRadius.circular(16),
                  ),

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
                          fontSize: 11.5,
                          color:
                          Colors.grey.shade600,
                          fontWeight:
                          FontWeight.w500,
                        ),
                      ),

                      const SizedBox(
                        height: 2,
                      ),

                      Text(
                        AppConstants.formatPrice(total),

                        style:
                        GoogleFonts.poppins(
                          fontSize: 19,

                          fontWeight:
                          FontWeight.w800,

                          color:
                          primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              SizedBox(
                height: 48,

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

                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 22,
                    ),

                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        14,
                      ),
                    ),
                  ),

                  child: Row(
                    mainAxisSize:
                    MainAxisSize.min,

                    children: [

                      Text(
                        "Checkout",

                        style:
                        GoogleFonts.poppins(
                          color:
                          Colors.white,

                          fontSize: 14,

                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),

                      const SizedBox(width: 6),

                      const Icon(
                        Icons
                            .arrow_forward_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ],
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
              "Looks like you haven't\nadded anything yet.",

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
              bottom: 12,
            ),

            padding:
            const EdgeInsets.all(
              12,
            ),

            decoration:
            BoxDecoration(
              color:
              Colors.white,

              borderRadius:
              BorderRadius.circular(
                18,
              ),

              border: Border.all(
                color: const Color(0xFFF1F1F1),
              ),

              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withOpacity(
                    0.03,
                  ),

                  blurRadius: 10,

                  offset:
                  const Offset(
                    0,
                    3,
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
                  height: 78,
                  width: 78,

                  padding:
                  const EdgeInsets.all(
                    8,
                  ),

                  decoration:
                  BoxDecoration(
                    color:
                    const Color(
                      0xFFF7F7F7,
                    ),

                    borderRadius:
                    BorderRadius.circular(
                      14,
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
                  width: 12,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                    children: [

                      Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        children: [

                          Expanded(
                            child: Text(
                              item["name"],

                              maxLines: 1,

                              overflow:
                              TextOverflow
                                  .ellipsis,

                              style:
                              GoogleFonts.poppins(
                                fontSize:
                                12.5,

                                fontWeight:
                                FontWeight
                                    .w600,
                              ),
                            ),
                          ),

                          // 🔥 DELETE
                          GestureDetector(

                            onTap:
                                () async {

                              final res = await ApiService
                                  .removeCartItem(
                                int.parse(
                                  item["id"]
                                      .toString(),
                                ),
                              );

                              await loadCart();

                              if (!mounted) {
                                return;
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: res["status"] == true
                                      ? const Color(0xFF1F1F1F)
                                      : Colors.red,
                                  content: Text(
                                    res["status"] == true
                                        ? "Item removed from cart"
                                        : "Couldn't remove item. Please try again.",
                                  ),
                                ),
                              );
                            },

                            child:
                            Padding(
                              padding:
                              const EdgeInsets.only(
                                left: 8,
                              ),

                              child:
                              Icon(
                                Icons
                                    .delete_outline_rounded,

                                size: 18,

                                color:
                                Colors.grey.shade400,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 6,
                      ),

                      Text(
                        AppConstants.formatPrice(item["saleprice"]),

                        style:
                        GoogleFonts.poppins(
                          fontSize:
                          16,

                          fontWeight:
                          FontWeight
                              .w700,

                          color:
                          primaryColor,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      // 🔥 QUANTITY STEPPER
                      Container(
                        height: 30,

                        decoration:
                        BoxDecoration(
                          color: const Color(
                            0xFFF6F6F6,
                          ),

                          borderRadius:
                          BorderRadius.circular(
                            9,
                          ),
                        ),

                        child: Row(
                          mainAxisSize:
                          MainAxisSize.min,

                          children: [

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
                              const SizedBox(
                                height: 30,
                                width: 32,

                                child: Icon(
                                  Icons
                                      .remove,
                                  size:
                                  15,
                                ),
                              ),
                            ),

                            SizedBox(
                              width: 26,

                              child:
                              Text(
                                item[
                                "quantity"]
                                    .toString(),

                                textAlign:
                                TextAlign.center,

                                style:
                                GoogleFonts.poppins(
                                  fontSize:
                                  13,

                                  fontWeight:
                                  FontWeight
                                      .w700,
                                ),
                              ),
                            ),

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
                                30,

                                width:
                                32,

                                alignment:
                                Alignment.center,

                                decoration:
                                BoxDecoration(
                                  color:
                                  primaryColor,

                                  borderRadius:
                                  const BorderRadius.horizontal(
                                    right: Radius.circular(9),
                                  ),
                                ),

                                child:
                                const Icon(
                                  Icons.add,
                                  size:
                                  15,

                                  color: Colors
                                      .white,
                                ),
                              ),
                            ),
                          ],
                        ),
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