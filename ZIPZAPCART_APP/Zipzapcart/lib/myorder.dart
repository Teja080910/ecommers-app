import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';
import 'vieworder.dart';

class MyOrderPage extends StatefulWidget {
  const MyOrderPage({super.key});

  @override
  State<MyOrderPage> createState() =>
      _MyOrderPageState();
}

class _MyOrderPageState
    extends State<MyOrderPage> {

  bool loading = true;

  int userId = 0;

  List orders = [];

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

    loadOrders();
  }

  Future<void> loadOrders() async {

    orders =
    await ApiService.getMyOrders(
      userId,
    );

    setState(() {
      loading = false;
    });
  }

  Color statusColor(String status) {

    switch (status.toLowerCase()) {

      case "placed":
        return Colors.orange;

      case "accepted":
        return Colors.blue;

      case "on the way":
        return Colors.purple;

      case "delivered":
        return Colors.green;

      case "cancelled":
        return Colors.red;

      default:
        return Colors.black;
    }
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
          "My Orders",

          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),

        centerTitle: true,
      ),

      body: loading

          ? Center(
        child:
        CircularProgressIndicator(
          color: primaryColor,
        ),
      )
          : orders.isEmpty

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
                height: 230,
              ),

              const SizedBox(height: 20),

              const Text(
                "No Orders Yet",

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
                "Looks like you haven't placed any orders yet.\nStart shopping to see your orders here.",

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

          loadOrders();
        },

        child: ListView.builder(

          padding:
          const EdgeInsets.all(16),

          itemCount: orders.length,

          itemBuilder: (_, index) {

            final order =
            orders[index];

            return GestureDetector(

              onTap: () {

                Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder: (_) =>
                        ViewOrderPage(
                          orderId:
                          int.parse(
                            order["id"]
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
                  18,
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

                child: Column(
                  children: [

                    Row(
                      children: [

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                            children: [

                              Text(
                                order[
                                "order_no"],

                                style:
                                GoogleFonts.poppins(
                                  fontSize:
                                  16,

                                  fontWeight:
                                  FontWeight
                                      .w700,
                                ),
                              ),

                              const SizedBox(
                                height: 6,
                              ),

                              Text(
                                order[
                                "created_at"],

                                style:
                                GoogleFonts.poppins(
                                  fontSize:
                                  12,

                                  color:
                                  Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          padding:
                          const EdgeInsets.symmetric(
                            horizontal:
                            14,

                            vertical:
                            7,
                          ),

                          decoration:
                          BoxDecoration(
                            color:
                            statusColor(
                              order[
                              "order_status"],
                            ).withOpacity(
                              0.12,
                            ),

                            borderRadius:
                            BorderRadius.circular(
                              30,
                            ),
                          ),

                          child: Text(
                            order[
                            "order_status"],

                            style:
                            GoogleFonts.poppins(
                              color:
                              statusColor(
                                order[
                                "order_status"],
                              ),

                              fontWeight:
                              FontWeight
                                  .w700,

                              fontSize:
                              12,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: [

                        Expanded(
                          child: infoBox(
                            "Items",
                            order[
                            "items_count"]
                                .toString(),
                          ),
                        ),

                        const SizedBox(
                          width: 12,
                        ),

                        Expanded(
                          child: infoBox(
                            "Payment",
                            order[
                            "payment_method"]
                                .toUpperCase(),
                          ),
                        ),

                        const SizedBox(
                          width: 12,
                        ),

                        Expanded(
                          child: infoBox(
                            "Total",
                            "₹${order["total_amount"]}",
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [

                        Expanded(
                          child: Container(
                            height: 48,

                            decoration:
                            BoxDecoration(
                              color:
                              primaryColor,

                              borderRadius:
                              BorderRadius.circular(
                                16,
                              ),
                            ),

                            child: Center(
                              child: Text(
                                "View Details",

                                style:
                                GoogleFonts.poppins(
                                  color:
                                  Colors.white,

                                  fontWeight:
                                  FontWeight
                                      .w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Widget infoBox(
      String title,
      String value,
      ) {

    return Container(

      padding:
      const EdgeInsets.symmetric(
        vertical: 14,
      ),

      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),

        borderRadius:
        BorderRadius.circular(
          18,
        ),
      ),

      child: Column(
        children: [

          Text(
            title,

            style:
            GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            value,

            textAlign:
            TextAlign.center,

            style:
            GoogleFonts.poppins(
              fontWeight:
              FontWeight.w700,

              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}