import 'package:flutter/material.dart';

import 'api_service.dart';
import 'cashback_page.dart';
import 'constants.dart';

class WalletPage
    extends StatefulWidget{

  const WalletPage({
    super.key,
  });

  @override
  State<WalletPage>
  createState()=>

      _WalletPageState();

}

class _WalletPageState
    extends State<WalletPage>{

  final Color primaryColor=
  const Color(
    0xFFEF4138,
  );

  double wallet=0;

  double cashback=0;

  List refunds=[];

  bool loading=true;

  @override
  void initState(){

    super.initState();

    load();

  }

  Future load()
  async{

    loading=true;

    if(mounted){
      setState((){});
    }

    final data=
    await ApiService
        .getWallet();

    if(
    data["status"]
        ==
        true
    ){

      wallet=

          double.tryParse(
            data[
            "wallet_balance"
            ]
                .toString(),
          )

              ??

              0;

      cashback=

          double.tryParse(
            data[
            "cashback_total"
            ]
                .toString(),
          )

              ??

              0;

      refunds=
          data[
          "refunds"
          ]

              ??

              [];

    }

    loading=false;

    if(
    mounted
    ){

      setState((){});

    }

  }

  @override
  Widget build(
      BuildContext context,
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

        centerTitle:true,

        title:

        const Text(

          "Wallet",

          style:

          TextStyle(

            color:
            Colors.black,

            fontWeight:
            FontWeight.w500,

          ),

        ),

      ),

      body:

      loading

          ?

      Center(

        child:

        SizedBox(

          height:34,

          width:34,

          child:

          CircularProgressIndicator(
            color: primaryColor,
          ),

        ),

      )

          :

      RefreshIndicator(

        onRefresh:
        load,

        child:

        SingleChildScrollView(

          physics:
          const AlwaysScrollableScrollPhysics(),

          padding:
          const EdgeInsets.all(
            18,
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

                    walletCard(

                      title:
                      "Wallet Balance",

                      amount:
                      AppConstants.formatPrice(wallet),

                      icon:
                      Icons.account_balance_wallet,

                      onTap:null,

                    ),

                  ),

                  const SizedBox(
                    width:14,
                  ),

                  Expanded(

                    child:

                    walletCard(

                      title:
                      "Cashback Received",

                      amount:
                      AppConstants.formatPrice(cashback),

                      icon:
                      Icons.local_offer,

                      onTap:(){

                        Navigator.push(

                          context,

                          MaterialPageRoute(

                            builder:
                                (_)=>

                            const CashbackPage(),

                          ),

                        ).then((_){

                          load();

                        });

                      },

                    ),

                  ),

                ],

              ),

              const SizedBox(
                height:34,
              ),

              const Text(

                "Refund History",

                style:

                TextStyle(

                  fontSize:20,

                  fontWeight:
                  FontWeight.w800,

                ),

              ),

              const SizedBox(
                height:18,
              ),

              refunds.isEmpty

                  ?

              Container(

                padding:
                const EdgeInsets.all(
                  40,
                ),

                alignment:
                Alignment.center,

                child:

                Column(

                  children:[

                    Icon(

                      Icons.receipt_long,

                      size:74,

                      color:
                      Colors.grey.shade300,

                    ),

                    const SizedBox(
                      height:18,
                    ),

                    const Text(

                      "No Refund History",

                      style:

                      TextStyle(

                        fontSize:20,

                        fontWeight:
                        FontWeight.w800,

                      ),

                    ),

                    const SizedBox(
                      height:8,
                    ),

                    Text(

                      "Your refund transactions will appear here",

                      style:

                      TextStyle(

                        color:
                        Colors.grey.shade600,

                      ),

                    ),

                  ],

                ),

              )

                  :

              ListView.builder(

                itemCount:
                refunds.length,

                shrinkWrap:true,

                physics:
                const NeverScrollableScrollPhysics(),

                itemBuilder:
                    (
                    context,
                    index,
                    ){

                  final r=
                  refunds[index];

                  return Container(

                    margin:
                    const EdgeInsets.only(
                      bottom:12,
                    ),

                    padding:
                    const EdgeInsets.all(
                      16,
                    ),

                    decoration:

                    BoxDecoration(

                      color:
                      Colors.white,

                      borderRadius:
                      BorderRadius.circular(
                        22,
                      ),

                      boxShadow:[

                        BoxShadow(

                          color:
                          Colors.black
                              .withOpacity(
                            0.03,
                          ),

                          blurRadius:12,

                          offset:
                          const Offset(
                            0,
                            4,
                          ),

                        ),

                      ],

                    ),

                    child:

                    Row(

                      children:[

                        Container(

                          height:52,

                          width:52,

                          decoration:

                          BoxDecoration(

                            color:

                            const Color(
                              0xFFFFF6E0,
                            ),

                            borderRadius:
                            BorderRadius.circular(
                              16,
                            ),

                          ),

                          child:

                          Icon(

                            Icons.reply_rounded,

                            color:
                            primaryColor,

                            size:26,

                          ),

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

                              Row(

                                children:[

                                  Expanded(

                                    child:

                                    Text(

                                      r["source"]
                                          ??

                                          "Refund",

                                      maxLines:1,

                                      overflow:
                                      TextOverflow.ellipsis,

                                      style:

                                      const TextStyle(

                                        fontSize:15,

                                        fontWeight:
                                        FontWeight.w700,

                                      ),

                                    ),

                                  ),

                                  Text(

                                    AppConstants.formatPrice(r["refund_amount"]),

                                    style:

                                    TextStyle(

                                      fontSize:20,

                                      fontWeight:
                                      FontWeight.w900,

                                      color:
                                      primaryColor,

                                    ),

                                  ),

                                ],

                              ),

                              const SizedBox(
                                height:6,
                              ),

                              Text(

                                "Order #${r["order_no"]}",

                                style:

                                TextStyle(

                                  fontSize:13,

                                  color:
                                  Colors.grey,

                                ),

                              ),

                              const SizedBox(
                                height:3,
                              ),

                              Text(

                                r["created_at"],

                                style:

                                TextStyle(

                                  fontSize:12,

                                  color:
                                  Colors.grey.shade500,

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

              const SizedBox(
                height:100,
              ),

            ],

          ),

        ),

      ),

    );

  }

  Widget detail(
      String k,
      String v,
      ){

    return Padding(

      padding:
      const EdgeInsets.only(
        bottom:12,
      ),

      child:

      Row(

        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,

        children:[

          Text(
            k,
          ),

          Text(

            v,

            style:

            const TextStyle(

              fontWeight:
              FontWeight.w700,

            ),

          ),

        ],

      ),

    );

  }

  Widget walletCard({

    required String title,

    required String amount,

    required IconData icon,

    VoidCallback? onTap,

  }){

    return GestureDetector(

      onTap:onTap,

      child:

      Container(

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
            26,
          ),

          boxShadow:[

            BoxShadow(

              color:
              Colors.black
                  .withOpacity(
                0.04,
              ),

              blurRadius:18,

            ),

          ],

        ),

        child:

        Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,

          children:[

            Container(

              height:48,

              width:48,

              decoration:

              BoxDecoration(

                color:
                const Color(
                  0xFFFFF7DF,
                ),

                borderRadius:
                BorderRadius.circular(
                  14,
                ),

              ),

              child:

              Icon(

                icon,

                color:
                primaryColor,

              ),

            ),

            const SizedBox(
              height:18,
            ),

            Text(

              title,

              style:

              TextStyle(

                color:
                Colors.grey.shade700,

                fontWeight:
                FontWeight.w600,

              ),

            ),

            const SizedBox(
              height:10,
            ),

            Text(

              amount,

              style:

              TextStyle(

                fontSize:15,

                fontWeight:
                FontWeight.w900,

                color:
                primaryColor,

              ),

            ),

          ],

        ),

      ),

    );

  }

}