import 'package:flutter/material.dart';
import 'api_service.dart';

class CashbackPage
    extends StatefulWidget{

  const CashbackPage({
    super.key,
  });

  @override
  State<CashbackPage>
  createState()=>
      _CashbackPageState();

}

class _CashbackPageState
    extends State<CashbackPage>{

  double total=0;

  List data=[];

  bool loading=true;

  bool moving=false;

  @override
  void initState(){

    super.initState();

    load();

  }

  Future load()
  async{

    loading=true;

    setState((){});

    final r=

    await ApiService
        .getCashback();

    total=

        double.tryParse(
          r["total"]
              .toString(),
        )

            ??

            0;

    data=
        r["cashbacks"]
            ??

            [];

    loading=false;

    setState((){});

  }

  Future move()
  async{

    moving=true;

    setState((){});

    final r=

    await ApiService
        .moveCashback();

    moving=false;

    if(
    r["status"]
    =

    true
    ){

      await load();

    }

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

        title:
        const Text(
          "Cashback",
        ),

        backgroundColor:
        Colors.white,

      ),

      body:

      loading

          ?

      const Center(
        child:
        CircularProgressIndicator(),
      )

          :

      Column(

        children:[

          Container(

            margin:
            const EdgeInsets.all(
              18,
            ),

            padding:
            const EdgeInsets.all(
              26,
            ),

            width:
            double.infinity,

            decoration:

            BoxDecoration(

              gradient:

              const LinearGradient(

                colors:[

                  Color(
                    0xFFF7A400,
                  ),

                  Color(
                    0xFFFFC14D,
                  ),

                ],

              ),

              borderRadius:
              BorderRadius.circular(
                34,
              ),

            ),

            child:

            Column(

              children:[

                const Text(

                  "Available Cashback",

                  style:

                  TextStyle(

                    color:
                    Colors.white,

                  ),

                ),

                const SizedBox(
                  height:10,
                ),

                Text(

                  "₹${total.toStringAsFixed(0)}",

                  style:

                  const TextStyle(

                    fontSize:44,

                    fontWeight:
                    FontWeight.w900,

                    color:
                    Colors.white,

                  ),

                ),

                const SizedBox(
                  height:18,
                ),

                SizedBox(

                  width:
                  double.infinity,

                  height:56,

                  child:

                  ElevatedButton(

                    onPressed:

                    moving
                        ||

                        total<=0

                        ?

                    null

                        :

                    move,

                    style:

                    ElevatedButton.styleFrom(

                      backgroundColor:
                      Colors.white,

                    ),

                    child:

                    Text(

                      moving

                          ?

                      "Moving..."

                          :

                      "Move Cashback To Wallet",

                      style:

                      const TextStyle(

                        color:
                        Colors.orange,

                      ),

                    ),

                  ),

                ),

              ],

            ),

          ),

          Expanded(

            child:

            ListView.builder(

              padding:
              const EdgeInsets.symmetric(
                horizontal:18,
              ),

              itemCount:
              data.length,

              itemBuilder:
                  (
                  _,
                  i,
                  ){

                final c=
                data[i];

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

                    color:
                    Colors.white,

                    borderRadius:
                    BorderRadius.circular(
                      24,
                    ),

                  ),

                  child:

                  Column(

                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children:[

                      Row(

                        children:[

                          Text(

                            "₹${c["cashback_amount"]}",

                            style:

                            const TextStyle(

                              fontSize:24,

                              fontWeight:
                              FontWeight.w900,

                            ),

                          ),

                          const Spacer(),

                          Container(

                            padding:
                            const EdgeInsets.symmetric(

                              horizontal:12,

                              vertical:6,

                            ),

                            decoration:

                            BoxDecoration(

                              color:

                              c["transferred"]
                                  ==1

                                  ?

                              Colors.green

                                  .withOpacity(.1)

                                  :

                              Colors.orange

                                  .withOpacity(.1),

                              borderRadius:
                              BorderRadius.circular(
                                40,
                              ),

                            ),

                            child:

                            Text(

                              c["transferred"]
                                  ==1

                                  ?

                              "Moved"

                                  :

                              "Available",

                            ),

                          ),

                        ],

                      ),

                      const SizedBox(
                        height:8,
                      ),

                      Text(

                        c["from_user_name"]
                            ??

                            "Cashback",

                      ),

                      const SizedBox(
                        height:6,
                      ),

                      Text(

                        "Order ₹${c["order_amount"]}",

                      ),

                      Text(

                        c["created_at"],

                        style:

                        TextStyle(

                          color:
                          Colors.grey.shade600,

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

    );

  }

}
