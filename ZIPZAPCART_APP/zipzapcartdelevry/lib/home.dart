import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'api_service.dart';

import 'orders.dart';

import 'profile.dart';

import 'vieworder.dart';

class HomePage
    extends StatefulWidget{

  const HomePage({
    super.key,
  });

  @override
  State<HomePage>
  createState()=>

      _HomePageState();

}

class _HomePageState
    extends State<HomePage>{

  int index=0;

  final pages=[

    const HomeBody(),

    const OrdersPage(),

    const ProfilePage(),

  ];

  final primary=

  const Color(
    0xFFECA202,
  );

  @override
  Widget build(
      context,
      ){

    return Scaffold(

      backgroundColor:

      const Color(
        0xFFF7F7F7,
      ),

      body:

      pages[
      index
      ],

      bottomNavigationBar:

      BottomNavigationBar(

        currentIndex:
        index,

        selectedItemColor:
        primary,

        onTap:(v){

          index=v;

          setState((){});

        },

        items:

        const[

          BottomNavigationBarItem(

            icon:
            Icon(
              Icons.home,
            ),

            label:
            "Home",

          ),

          BottomNavigationBarItem(

            icon:
            Icon(
              Icons.receipt_long,
            ),

            label:
            "Orders",

          ),

          BottomNavigationBarItem(

            icon:
            Icon(
              Icons.person,
            ),

            label:
            "Profile",

          ),

        ],

      ),

    );

  }

}

class HomeBody
    extends StatefulWidget{

  const HomeBody({
    super.key,
  });

  @override
  State<HomeBody>
  createState()=>

      _HomeBodyState();

}

class _HomeBodyState
    extends State<HomeBody>{

  bool loading=true;

  int today=0;

  int total=0;

  List orders=[];

  Future load()
  async{

    final r=

    await ApiService
        .getHome();

    today=

        r["today"]

            ??

            0;

    total=

        r["total"]

            ??

            0;

    orders=

        r["orders"]

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

  @override
  Widget build(
      context,
      ){

    if(
    loading
    ){

      return const Center(

        child:

        CircularProgressIndicator(),

      );

    }

    return SafeArea(

      child:

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

                  Image.asset(

                    "assets/logo.png",

                    height:50,

                  ),

                  const Spacer(),

                  GestureDetector(

                    onTap:(){

                      Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder:
                              (_)=>

                          const ProfilePage(),

                        ),

                      );

                    },

                    child:

                    const CircleAvatar(

                      radius:24,

                      child:

                      Icon(
                        Icons.person,
                      ),

                    ),

                  ),

                ],

              ),

              const SizedBox(
                height:30,
              ),

              Text(

                "Dashboard",

                style:

                GoogleFonts.poppins(

                  fontSize:26,

                  fontWeight:
                  FontWeight.w800,

                ),

              ),

              const SizedBox(
                height:18,
              ),

              Row(

                children:[

                  Expanded(

                    child:

                    card(

                      "Today's Orders",

                      today.toString(),

                      Icons.local_shipping,

                    ),

                  ),

                  const SizedBox(
                    width:14,
                  ),

                  Expanded(

                    child:

                    card(

                      "Total Orders",

                      total.toString(),

                      Icons.inventory,

                    ),

                  ),

                ],

              ),

              const SizedBox(
                height:28,
              ),

              Text(

                "New Orders",

                style:

                GoogleFonts.poppins(

                  fontSize:20,

                  fontWeight:
                  FontWeight.w700,

                ),

              ),

              const SizedBox(
                height:18,
              ),

              orders.isEmpty

                  ?

              Container(

                width:
                double.infinity,

                padding:

                const EdgeInsets.all(
                  28,
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

                  children:[

                    Icon(

                      Icons.delivery_dining,

                      size:80,

                      color:
                      Colors.grey.shade400,

                    ),

                    const SizedBox(
                      height:16,
                    ),

                    Text(

                      "No Orders Right Now",

                      style:

                      GoogleFonts.poppins(

                        fontWeight:
                        FontWeight.w700,

                      ),

                    ),

                  ],

                ),

              )

                  :

              ListView.builder(

                itemCount:
                orders.length,

                shrinkWrap:true,

                physics:

                const NeverScrollableScrollPhysics(),

                itemBuilder:
                    (_,i){

                  final o=

                  orders[i];

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
                        bottom:14,
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

                      Row(

                        children:[

                          const Icon(

                            Icons.receipt_long,

                          ),

                          const SizedBox(
                            width:16,
                          ),

                          Expanded(

                            child:

                            Column(

                              crossAxisAlignment:
                              CrossAxisAlignment.start,

                              children:[

                                Text(

                                  o["order_no"],

                                  style:

                                  GoogleFonts.poppins(

                                    fontWeight:
                                    FontWeight.w700,

                                  ),

                                ),

                                const SizedBox(
                                  height:5,
                                ),

                                Text(

                                  "₹${o["total_amount"]}",

                                  style:

                                  GoogleFonts.poppins(),

                                ),

                              ],

                            ),

                          ),

                          const Icon(

                            Icons.arrow_forward_ios,

                            size:16,

                          ),

                        ],

                      ),

                    ),

                  );

                },

              ),

            ],

          ),

        ),

      ),

    );

  }

  Widget card(

      String title,

      String value,

      IconData icon,

      ){

    return Container(

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

          Icon(
            icon,
          ),

          const SizedBox(
            height:16,
          ),

          Text(

            value,

            style:

            GoogleFonts.poppins(

              fontSize:34,

              fontWeight:
              FontWeight.w800,

            ),

          ),

          Text(

            title,

            style:

            GoogleFonts.poppins(),

          ),

        ],

      ),

    );

  }

}
