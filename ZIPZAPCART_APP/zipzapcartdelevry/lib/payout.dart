import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'api_service.dart';

class PayoutPage
    extends StatefulWidget{

  const PayoutPage({
    super.key,
  });

  @override
  State<PayoutPage>
  createState()=>

      _PayoutPageState();

}

class _PayoutPageState
    extends State<PayoutPage>{

  List payouts=[];

  bool loading=true;

  final primary=

  const Color(
    0xFFEF4138,
  );

  Future load()
  async{

    final r=

    await ApiService
        .payouts();

    payouts=

        r["payouts"]

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

    if(
    s
        .toLowerCase()
    ==

    "paid"
    ){

      return
        Colors.green;

    }

    return
      Colors.orange;

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
        primary,

        title:

        Text(

          "Payouts",

          style:

          GoogleFonts.poppins(

            color:
            Colors.white,

            fontWeight:
            FontWeight.w700,

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

      payouts.isEmpty

          ?

      Center(

        child:

        Column(

          mainAxisAlignment:
          MainAxisAlignment.center,

          children:[

            Icon(

              Icons.account_balance_wallet,

              size:90,

              color:
              Colors.red.shade200,

            ),

            const SizedBox(
              height:20,
            ),

            Text(

              "No Payout Yet",

              style:

              GoogleFonts.poppins(

                fontWeight:
                FontWeight.w700,

                fontSize:20,

              ),

            ),

          ],

        ),

      )

          :

      ListView.builder(

        padding:

        const EdgeInsets.all(
          16,
        ),

        itemCount:
        payouts.length,

        itemBuilder:
            (_,i){

          final p=
          payouts[i];

          return Container(

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

              gradient:

              LinearGradient(

                colors:[

                  primary,

                  Colors.red,

                ],

              ),

              borderRadius:

              BorderRadius.circular(
                26,
              ),

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

                        "₹${p["amount"]}",

                        style:

                        GoogleFonts.poppins(

                          fontSize:30,

                          fontWeight:
                          FontWeight.w800,

                          color:
                          Colors.white,

                        ),

                      ),

                    ),

                    Container(

                      padding:

                      const EdgeInsets.symmetric(

                        horizontal:12,

                        vertical:6,

                      ),

                      decoration:

                      BoxDecoration(

                        color:

                        Colors.white,

                        borderRadius:

                        BorderRadius.circular(
                          30,
                        ),

                      ),

                      child:

                      Text(

                        p["status"],

                        style:

                        GoogleFonts.poppins(

                          fontWeight:
                          FontWeight.w700,

                          color:

                          statusColor(
                            p["status"],
                          ),

                        ),

                      ),

                    ),

                  ],

                ),

                const SizedBox(
                  height:18,
                ),

                info(
                  "Method",
                  p["payment_method"],
                ),

                info(
                  "Transaction",
                  p["transaction_id"],
                ),

                info(
                  "Date",
                  p["payout_date"],
                ),

                info(
                  "Note",
                  p["note"],
                ),

              ],

            ),

          );

        },

      ),

    );

  }

  Widget info(
      String t,
      dynamic v,
      ){

    return Padding(

      padding:

      const EdgeInsets.only(
        bottom:10,
      ),

      child:

      Column(

        crossAxisAlignment:
        CrossAxisAlignment.start,

        children:[

          Text(

            t,

            style:

            GoogleFonts.poppins(

              color:
              Colors.white70,

              fontSize:12,

            ),

          ),

          Text(

            v
                ?.toString()

                ??

                "-",

            style:

            GoogleFonts.poppins(

              color:
              Colors.white,

              fontWeight:
              FontWeight.w600,

            ),

          ),

        ],

      ),

    );

  }

}
