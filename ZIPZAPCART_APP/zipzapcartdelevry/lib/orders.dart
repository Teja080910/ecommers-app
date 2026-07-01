import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';

import 'vieworder.dart';

class OrdersPage
    extends StatefulWidget{

  const OrdersPage({
    super.key,
  });

  @override
  State<OrdersPage>
  createState()=>

      _OrdersPageState();

}

class _OrdersPageState
    extends State<OrdersPage>{

  List orders=[];

  bool loading=true;

  final primary=

  const Color(
    0xFFECA202,
  );

  Future load()
  async{

    loading=true;

    setState((){});

    final prefs=

    await SharedPreferences
        .getInstance();

    final id=

        prefs.getInt(
          "delivery_id",
        )

            ??

            0;

    final data=

    await ApiService
        .orders(
      id,
    );

    orders=

        data["orders"]

            ??

            [];

    loading=false;

    setState((){});

  }

  @override
  void initState(){

    super.initState();

    load();

  }

  Color statusColor(
      String s,
      ){

    s=
        s.toLowerCase();

    if(
    s=="placed"
    ){

      return Colors.orange;

    }

    if(
    s=="on the way"
    ){

      return Colors.blue;

    }

    if(
    s=="delivered"
    ){

      return Colors.green;

    }

    return Colors.grey;

  }

  Widget item(
      Map o,
      ){

    return GestureDetector(

      onTap:(){

        Navigator.push(

          context,

          MaterialPageRoute(

            builder:
                (_)=>

                ViewOrderPage(

                  orderId:

                  int.parse(

                    o["id"]
                        .toString(),

                  ),

                ),

          ),

        );

      },

      child:

      Container(

        margin:

        const EdgeInsets.only(
          bottom:16,
        ),

        padding:

        const EdgeInsets.all(
          18,
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

              blurRadius:12,

              color:

              Colors.black
                  .withOpacity(
                0.04,
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

                Expanded(

                  child:

                  Text(

                    o["order_no"],

                    style:

                    GoogleFonts.poppins(

                      fontWeight:
                      FontWeight.w700,

                      fontSize:17,

                    ),

                  ),

                ),

                Container(

                  padding:

                  const EdgeInsets.symmetric(

                    horizontal:14,

                    vertical:7,

                  ),

                  decoration:

                  BoxDecoration(

                    color:

                    statusColor(

                      o["order_status"],

                    )

                        .withOpacity(
                      0.12,
                    ),

                    borderRadius:

                    BorderRadius.circular(
                      40,
                    ),

                  ),

                  child:

                  Text(

                    o["order_status"],

                    style:

                    GoogleFonts.poppins(

                      fontSize:12,

                      fontWeight:
                      FontWeight.w700,

                      color:

                      statusColor(

                        o["order_status"],

                      ),

                    ),

                  ),

                ),

              ],

            ),

            const SizedBox(
              height:14,
            ),

            Text(

              "₹${o["total_amount"]}",

              style:

              GoogleFonts.poppins(

                fontWeight:
                FontWeight.w800,

                fontSize:28,

                color:
                primary,

              ),

            ),

            const SizedBox(
              height:10,
            ),

            Text(

              "Payment : ${o["payment_method"]}",

              style:

              GoogleFonts.poppins(

                color:
                Colors.grey.shade700,

              ),

            ),

            const SizedBox(
              height:4,
            ),

            Text(

              "Date : ${o["created_at"]}",

              style:

              GoogleFonts.poppins(

                fontSize:12,

                color:
                Colors.grey,

              ),

            ),

            if(

            o["order_status"]
                .toString()
                .toLowerCase()

                !=

                "delivered"

            )...[

              const SizedBox(
                height:18,
              ),

              Container(

                height:50,

                alignment:
                Alignment.center,

                decoration:

                BoxDecoration(

                  color:
                  primary,

                  borderRadius:

                  BorderRadius.circular(
                    16,
                  ),

                ),

                child:

                Text(

                  "View Order",

                  style:

                  GoogleFonts.poppins(

                    color:
                    Colors.white,

                    fontWeight:
                    FontWeight.w700,

                  ),

                ),

              ),

            ],

          ],

        ),

      ),

    );

  }

  @override
  Widget build(
      context,
      ){

    return Scaffold(

      backgroundColor:

      const Color(
        0xFFF7F7F7,
      ),

      appBar:

      AppBar(

        backgroundColor:
        Colors.white,

        elevation:0,

        title:

        Text(

          "All Orders",

          style:

          GoogleFonts.poppins(

            fontWeight:
            FontWeight.w700,

            color:
            Colors.black,

          ),

        ),

      ),

      body:

      loading

          ?

      Center(

        child:

        CircularProgressIndicator(

          color:
          primary,

        ),

      )

          :

      orders.isEmpty

          ?

      Center(

        child:

        Column(

          mainAxisAlignment:
          MainAxisAlignment.center,

          children:[

            Icon(

              Icons.receipt_long,

              size:90,

              color:
              Colors.grey.shade400,

            ),

            const SizedBox(
              height:16,
            ),

            Text(

              "No Orders Found",

              style:

              GoogleFonts.poppins(

                fontSize:18,

              ),

            ),

          ],

        ),

      )

          :

      RefreshIndicator(

        color:
        primary,

        onRefresh:
        load,

        child:

        ListView.builder(

          padding:

          const EdgeInsets.all(
            18,
          ),

          itemCount:
          orders.length,

          itemBuilder:
              (_,i){

            return item(

              orders[i],

            );

          },

        ),

      ),

    );

  }

}
