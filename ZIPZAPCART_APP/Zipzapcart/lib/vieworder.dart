import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'api_service.dart';
import 'constants.dart';
import 'package:url_launcher/url_launcher.dart';
class ViewOrderPage extends StatefulWidget {

  final int orderId;

  const ViewOrderPage({
    super.key,
    required this.orderId,
  });

  @override
  State<ViewOrderPage> createState() =>
      _ViewOrderPageState();
}

class _ViewOrderPageState
    extends State<ViewOrderPage> {

  bool loading = true;

  Map order = {};

  List items = [];

  final Color primaryColor =
  const Color(0xFFEF4138);

  @override
  void initState() {

    super.initState();

    loadOrder();

  }
  Future<void> loadOrder() async {

    var data =
    await ApiService.viewOrder(
      widget.orderId,
    );

    if (data["status"] == true) {

      order = data["order"];

      items = data["items"];
    }

    setState(() {
      loading = false;
    });
  }

  int currentStep() {

    String status =

    (
        order["order_status"]
            ??
            ""
    )

        .toString()

        .toLowerCase()

        .trim();

    if(
    status==
        "cancelled"
    ){

      return -1;

    }

    if(
    status==
        "placed"
    ){

      return 0;

    }

    if(
    status==
        "shipped"
    ){

      return 1;

    }

    if(
    status==
        "on the way"
    ){

      return 2;

    }

    if(
    status==
        "delivered"
    ){

      return 3;

    }

    return 0;

  }
  Future<void> showCancelBottomSheet() async {

    showModalBottomSheet(

      context: context,

      backgroundColor:
      Colors.white,

      shape:

      const RoundedRectangleBorder(

        borderRadius:

        BorderRadius.vertical(

          top:
          Radius.circular(
            28,
          ),

        ),

      ),

      builder:
          (_){

        return Padding(

          padding:
          const EdgeInsets.all(
            22,
          ),

          child:

          Column(

            mainAxisSize:
            MainAxisSize.min,

            children:[

              Container(

                height:5,

                width:60,

                decoration:

                BoxDecoration(

                  color:
                  Colors.grey.shade300,

                  borderRadius:
                  BorderRadius.circular(
                    100,
                  ),

                ),

              ),

              const SizedBox(
                height:22,
              ),

              const Icon(

                Icons.cancel,

                color:
                Colors.red,

                size:60,

              ),

              const SizedBox(
                height:18,
              ),

              Text(

                "Cancel Order?",

                style:
                GoogleFonts.poppins(

                  fontSize:22,

                  fontWeight:
                  FontWeight.w700,

                ),

              ),

              const SizedBox(
                height:10,
              ),

              Text(

                "Are you sure you want to cancel this order?",

                textAlign:
                TextAlign.center,

                style:
                GoogleFonts.poppins(

                  color:
                  Colors.grey,

                ),

              ),

              const SizedBox(
                height:26,
              ),

              Row(

                children:[

                  Expanded(

                    child:

                    OutlinedButton(

                      onPressed:(){

                        Navigator.pop(
                          context,
                        );

                      },

                      style:

                      OutlinedButton.styleFrom(

                        minimumSize:
                        const Size(
                          0,
                          56,
                        ),

                        shape:

                        RoundedRectangleBorder(

                          borderRadius:
                          BorderRadius.circular(
                            18,
                          ),

                        ),

                      ),

                      child:

                      Text(

                        "No",

                        style:
                        GoogleFonts.poppins(),

                      ),

                    ),

                  ),

                  const SizedBox(
                    width:12,
                  ),

                  Expanded(

                    child:

                    ElevatedButton(

                      onPressed:() async {

                        Navigator.pop(
                          context,
                        );

                        await cancelOrder();

                      },

                      style:

                      ElevatedButton.styleFrom(

                        backgroundColor:
                        Colors.red,

                        minimumSize:
                        const Size(
                          0,
                          56,
                        ),

                        shape:

                        RoundedRectangleBorder(

                          borderRadius:
                          BorderRadius.circular(
                            18,
                          ),

                        ),

                      ),

                      child:

                      Text(

                        "Yes Cancel",

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

              const SizedBox(
                height:10,
              ),

            ],

          ),

        );

      },

    );

  }
  Future<void> cancelOrder() async {

    bool success =

    await ApiService
        .cancelOrder(
      widget.orderId,
    );

    if(success){

      setState((){

        order[
        "order_status"
        ]=
        "cancelled";

      });

      ScaffoldMessenger.of(
        context,
      )

          .showSnackBar(

        const SnackBar(

          content:

          Text(
            "Order Cancelled",
          ),

        ),

      );

      await loadOrder();

    }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      const Color(0xFFF6F7F9),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        title: Text(
          "Order Details",

          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w700,
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

          : SingleChildScrollView(
        padding:
        const EdgeInsets.all(16),

        child: Column(
          children: [

            // 🔥 AMAZON STYLE STATUS
            Container(
              width: double.infinity,

              padding:
              const EdgeInsets.all(22),

              decoration:
              BoxDecoration(
                color: Colors.white,

                borderRadius:
                BorderRadius.circular(
                  26,
                ),

                boxShadow: [

                  BoxShadow(
                    color:
                    Colors.black.withOpacity(
                      0.03,
                    ),

                    blurRadius: 12,

                    offset:
                    const Offset(0, 4),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

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
                              order["order_no"],

                              style:
                              GoogleFonts.poppins(
                                fontSize: 15,

                                fontWeight:
                                FontWeight.w700,
                              ),
                            ),

                            const SizedBox(
                              height: 6,
                            ),

                            Text(
                              order["created_at"],

                              style:
                              GoogleFonts.poppins(
                                color:
                                Colors.grey,

                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Text(
                        AppConstants.formatPrice(order["total_amount"]),

                        style:
                        GoogleFonts.poppins(
                          color:
                          primaryColor,

                          fontSize: 22,

                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 30,
                  ),

// 🔥 ORDER STATUS

                  if(
                  order["order_status"]
                      .toString()
                      .toLowerCase()
                      .trim()

                      ==

                      "cancelled"
                  )

                    Container(

                      width:
                      double.infinity,

                      padding:
                      const EdgeInsets.all(
                        22,
                      ),

                      decoration:
                      BoxDecoration(

                        color:
                        Colors.red.withOpacity(
                          0.08,
                        ),

                        borderRadius:
                        BorderRadius.circular(
                          18,
                        ),

                      ),

                      child:

                      Row(

                        children:[

                          const Icon(

                            Icons.cancel,

                            color:
                            Colors.red,

                            size:
                            34,

                          ),

                          const SizedBox(
                            width:14,
                          ),

                          Expanded(

                            child:

                            Column(

                              crossAxisAlignment:
                              CrossAxisAlignment.start,

                              children:[

                                Text(

                                  "Order Cancelled",

                                  style:
                                  GoogleFonts.poppins(

                                    fontSize:18,

                                    fontWeight:
                                    FontWeight.w700,

                                    color:
                                    Colors.red,

                                  ),

                                ),

                                const SizedBox(
                                  height:6,
                                ),

                                Text(

                                  "This order has been cancelled",

                                  style:
                                  GoogleFonts.poppins(),

                                ),

                              ],

                            ),

                          ),

                        ],

                      ),

                    )

                  else

                    Column(

                      children:[

                        statusTile(

                          title:
                          "Order Placed",

                          subtitle:
                          "Your order has been placed",

                          active:
                          currentStep()>=0,

                          isLast:false,

                        ),

                        statusTile(

                          title:
                          "Shipped",

                          subtitle:
                          "Seller shipped your order",

                          active:
                          currentStep()>=1,

                          isLast:false,

                        ),

                        statusTile(

                          title:
                          "On The Way",

                          subtitle:
                          "Delivery partner is coming",

                          active:
                          currentStep()>=2,

                          isLast:false,

                        ),

                        statusTile(

                          title:
                          "Delivered",

                          subtitle:
                          "Order delivered successfully",

                          active:
                          currentStep()>=3,

                          isLast:true,

                        ),

                      ],

                    ),

                  if(
                  order["order_status"]
                      .toString()
                      .toLowerCase()
                      .trim()

                      ==

                      "placed"
                  )

                    Column(

                      children:[

                        const SizedBox(
                          height:22,
                        ),

                        SizedBox(

                          width:
                          double.infinity,

                          height:
                          54,

                          child:

                          ElevatedButton(

                            onPressed:
                            showCancelBottomSheet,
                            style:
                            ElevatedButton.styleFrom(

                              backgroundColor:
                              Colors.red,

                              shape:
                              RoundedRectangleBorder(

                                borderRadius:
                                BorderRadius.circular(
                                  18,
                                ),

                              ),

                            ),

                            child:

                            Text(

                              "Cancel Order",

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

                ],
              ),
            ),
// 🔥 DELIVERY OTP
            // 🔥 DELIVERY OTP PROFESSIONAL

            if(
            order["delivery_otp"] != null &&
                order["delivery_otp"]
                    .toString()
                    .isNotEmpty &&
                order["order_status"]
                    .toString()
                    .toLowerCase()
                    .trim()
                    !=
                    "delivered"
            )

              Column(

                children:[

                  const SizedBox(
                    height:18,
                  ),

                  Container(

                    width:
                    double.infinity,

                    padding:
                    const EdgeInsets.all(
                      20,
                    ),

                    decoration:

                    BoxDecoration(

                      color:
                      Colors.white,

                      borderRadius:
                      BorderRadius.circular(
                        24,
                      ),

                      boxShadow:[

                        BoxShadow(

                          color:
                          Colors.black.withOpacity(
                            0.03,
                          ),

                          blurRadius:
                          14,

                          offset:
                          const Offset(
                            0,
                            5,
                          ),

                        ),

                      ],

                    ),

                    child:

                    Column(

                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children:[

                        Row(

                          children:[

                            Container(

                              height:42,
                              width:42,

                              decoration:

                              BoxDecoration(

                                color:
                                primaryColor.withOpacity(
                                  0.08,
                                ),

                                shape:
                                BoxShape.circle,

                              ),

                              child:

                              Icon(

                                Icons.local_shipping_outlined,

                                size:22,

                                color:
                                primaryColor,

                              ),

                            ),

                            const SizedBox(
                              width:12,
                            ),

                            Expanded(

                              child:

                              Column(

                                crossAxisAlignment:
                                CrossAxisAlignment.start,

                                children:[

                                  Text(

                                    "Delivery Verification",

                                    style:
                                    GoogleFonts.poppins(

                                      fontSize:16,

                                      fontWeight:
                                      FontWeight.w700,

                                    ),

                                  ),

                                  Text(

                                    "Provide OTP after receiving order",

                                    style:
                                    GoogleFonts.poppins(

                                      fontSize:12,

                                      color:
                                      Colors.grey,

                                    ),

                                  ),

                                ],

                              ),

                            ),

                          ],

                        ),

                        const SizedBox(
                          height:18,
                        ),

                        Container(

                          width:
                          double.infinity,

                          padding:
                          const EdgeInsets.symmetric(

                            vertical:18,

                            horizontal:18,

                          ),

                          decoration:

                          BoxDecoration(

                            color:
                            Colors.white,

                            border:

                            Border.all(

                              color:
                              primaryColor,

                              width:
                              1.5,

                            ),

                            borderRadius:
                            BorderRadius.circular(
                              18,
                            ),

                          ),

                          child:

                          Row(

                            mainAxisAlignment:
                            MainAxisAlignment.center,

                            children:[

                              for(
                              int i=0;
                              i<
                                  order["delivery_otp"]
                                      .toString()
                                      .length;
                              i++
                              )...[

                                Container(

                                  height:54,
                                  width:48,

                                  alignment:
                                  Alignment.center,

                                  decoration:

                                  BoxDecoration(

                                    color:
                                    const Color(
                                      0xFFFFF7EF,
                                    ),

                                    borderRadius:
                                    BorderRadius.circular(
                                      14,
                                    ),

                                  ),

                                  child:

                                  Text(

                                    order[
                                    "delivery_otp"
                                    ]
                                        .toString()[i],

                                    style:
                                    GoogleFonts.poppins(

                                      fontSize:24,

                                      fontWeight:
                                      FontWeight.w700,

                                      color:
                                      primaryColor,

                                    ),

                                  ),

                                ),

                                if(i<3)

                                  const SizedBox(
                                    width:10,
                                  ),

                              ]

                            ],

                          ),

                        ),

                        const SizedBox(
                          height:10,
                        ),

                        Center(

                          child:

                          Text(

                            "Only share with delivery partner",

                            style:
                            GoogleFonts.poppins(

                              fontSize:11,

                              color:
                              Colors.orange,

                              fontWeight:
                              FontWeight.w600,

                            ),

                          ),

                        ),

                      ],

                    ),

                  ),

                ],
              ),
            // 🔥 DELIVERY PARTNER
            if (order["delivery_boy_name"] != null &&
                order["delivery_boy_name"]
                    .toString()
                    .isNotEmpty)

              Column(
                children: [

                  const SizedBox(
                    height: 18,
                  ),

                  Container(
                    width: double.infinity,

                    padding:
                    const EdgeInsets.all(
                      22,
                    ),

                    decoration:
                    BoxDecoration(
                      color:
                      Colors.white,

                      borderRadius:
                      BorderRadius.circular(
                        26,
                      ),

                      boxShadow: [

                        BoxShadow(
                          color:
                          Colors.black
                              .withOpacity(
                            0.03,
                          ),

                          blurRadius:
                          12,

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
                          height: 72,
                          width: 72,

                          decoration:
                          BoxDecoration(
                            color:
                            primaryColor
                                .withOpacity(
                              0.12,
                            ),

                            shape:
                            BoxShape.circle,
                          ),

                          child: Icon(
                            Icons
                                .delivery_dining,

                            color:
                            primaryColor,

                            size: 36,
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
                                "Delivery Partner",

                                style:
                                GoogleFonts.poppins(
                                  color:
                                  Colors.grey,

                                  fontSize:
                                  12,
                                ),
                              ),

                              const SizedBox(
                                height:
                                6,
                              ),

                              Text(
                                order[
                                "delivery_boy_name"]
                                    .toString(),

                                style:
                                GoogleFonts.poppins(
                                  fontSize:
                                  18,

                                  fontWeight:
                                  FontWeight
                                      .w700,
                                ),
                              ),

                              const SizedBox(
                                height:
                                6,
                              ),

                              Text(
                                order[
                                "delivery_boy_phone"]
                                    .toString(),

                                style:
                                GoogleFonts.poppins(
                                  color:
                                  Colors.grey
                                      .shade700,
                                ),
                              ),
                            ],
                          ),
                        ),

                        GestureDetector(

                          onTap: () async {

                            final phone =
                            order["delivery_boy_phone"]
                                .toString();

                            final Uri url = Uri(
                              scheme: 'tel',
                              path: phone,
                            );

                            if (await canLaunchUrl(url)) {

                              await launchUrl(url);
                            }
                          },

                          child: Container(
                            height: 52,
                            width: 52,

                            decoration:
                            const BoxDecoration(
                              color:
                              Colors.black,

                              shape:
                              BoxShape.circle,
                            ),

                            child: const Icon(
                              Icons.call,

                              color:
                              Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 18),

            // 🔥 ADDRESS
            Container(
              width: double.infinity,

              padding:
              const EdgeInsets.all(20),

              decoration:
              BoxDecoration(
                color: Colors.white,

                borderRadius:
                BorderRadius.circular(
                  26,
                ),

                boxShadow: [

                  BoxShadow(
                    color:
                    Colors.black.withOpacity(
                      0.03,
                    ),

                    blurRadius: 12,

                    offset:
                    const Offset(0, 4),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  Text(
                    "Delivery Address",

                    style:
                    GoogleFonts.poppins(
                      fontWeight:
                      FontWeight.w700,

                      fontSize: 17,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    order["full_name"],

                    style:
                    GoogleFonts.poppins(
                      fontWeight:
                      FontWeight.w700,

                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "${order["address"]}, ${order["city"]}, ${order["state"]} - ${order["pincode"]}",

                    style:
                    GoogleFonts.poppins(
                      height: 1.7,

                      color:
                      Colors.grey.shade700,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    order["mobile"],

                    style:
                    GoogleFonts.poppins(
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 🔥 ITEMS
            Container(
              width: double.infinity,

              padding:
              const EdgeInsets.all(20),

              decoration:
              BoxDecoration(
                color: Colors.white,

                borderRadius:
                BorderRadius.circular(
                  26,
                ),

                boxShadow: [

                  BoxShadow(
                    color:
                    Colors.black.withOpacity(
                      0.03,
                    ),

                    blurRadius: 12,

                    offset:
                    const Offset(0, 4),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  Text(
                    "Order Items",

                    style:
                    GoogleFonts.poppins(
                      fontWeight:
                      FontWeight.w700,

                      fontSize: 17,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Column(
                    children: List.generate(
                      items.length,

                          (index) {

                        final item =
                        items[index];

                        return Container(
                          margin:
                          const EdgeInsets.only(
                            bottom: 16,
                          ),

                          child: Row(
                            children: [

                              Container(
                                height: 84,
                                width: 84,

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
                                      item[
                                      "image"],

                                  fit:
                                  BoxFit.contain,

                                  errorBuilder:
                                      (_, e, s) => Icon(
                                    Icons.shopping_bag_outlined,
                                    color: Colors.grey.shade400,
                                    size: 28,
                                  ),
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
                                        14,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 10,
                                    ),

                                    Text(
                                      "Qty : ${item["quantity"]}  •  ${AppConstants.formatPrice(item["price"])} each",

                                      style:
                                      GoogleFonts.poppins(
                                        fontSize: 12,
                                        color:
                                        Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Text(
                                AppConstants.formatPrice(item["total"]),

                                style:
                                GoogleFonts.poppins(
                                  fontWeight:
                                  FontWeight.w700,

                                  color:
                                  primaryColor,

                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget statusTile({

    required String title,

    required String subtitle,

    required bool active,

    required bool isLast,

  }) {

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Column(
            children: [

              AnimatedContainer(
                duration:
                const Duration(
                  milliseconds: 400,
                ),

                height: 34,
                width: 34,

                decoration:
                BoxDecoration(
                  color:
                  active
                      ? primaryColor
                      : Colors
                      .grey
                      .shade300,

                  shape:
                  BoxShape.circle,
                ),

                child: const Icon(
                  Icons.check,

                  color: Colors.white,
                  size: 18,
                ),
              ),

              if (!isLast)

                Expanded(
                  child: Container(
                    width: 3,

                    margin:
                    const EdgeInsets.symmetric(
                      vertical: 4,
                    ),

                    decoration:
                    BoxDecoration(
                      color:
                      active
                          ? primaryColor
                          : Colors.grey
                          .shade300,

                      borderRadius:
                      BorderRadius.circular(
                        20,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Padding(
              padding:
              const EdgeInsets.only(
                top: 2,
                bottom: 26,
              ),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  Text(
                    title,

                    style:
                    GoogleFonts.poppins(
                      fontWeight:
                      FontWeight.w700,

                      fontSize: 15,

                      color:
                      active
                          ? Colors.black
                          : Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    subtitle,

                    style:
                    GoogleFonts.poppins(
                      fontSize: 12,

                      height: 1.5,

                      color:
                      Colors.grey
                          .shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}