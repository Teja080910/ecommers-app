import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'api_service.dart';
import 'constants.dart';
import 'view_product.dart';
import 'widgets/shimmer_card.dart';

class TopDealsPage
    extends StatefulWidget{

  const TopDealsPage({
    super.key,
  });

  @override
  State<TopDealsPage>
  createState()=>

      _TopDealsPageState();

}

class _TopDealsPageState
    extends State<TopDealsPage>{

  List products=[];

  bool loading=true;

  final Color primaryColor=
  const Color(
    0xFFEF4138,
  );

  @override
  void initState(){

    super.initState();

    load();

  }

  Future load()
  async{

    products=

    await ApiService
        .getTopDeals();

    loading=false;

    setState((){});

  }

  Widget productItem(
      Map item,
      ){

    return GestureDetector(

      onTap:(){

        Navigator.push(

          context,

          MaterialPageRoute(

            builder:
                (_)=>

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

      child:

      Container(

        margin:
        const EdgeInsets.fromLTRB(
          14,
          0,
          14,
          14,
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
            22,
          ),

          boxShadow:[

            BoxShadow(

              color:
              Colors.black
                  .withOpacity(
                0.04,
              ),

              blurRadius:12,

            ),

          ],

        ),

        child:

        Row(

          children:[

            Container(

              height:120,

              width:120,

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
                    .imageUrl+

                    item["image"],

                fit:
                BoxFit.contain,

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

                  Text(

                    item["name"],

                    maxLines:2,

                    overflow:
                    TextOverflow.ellipsis,

                    style:

                    GoogleFonts.poppins(

                      fontSize:15,

                      fontWeight:
                      FontWeight.w600,

                    ),

                  ),

                  const SizedBox(
                    height:12,
                  ),

                  Row(

                    children:[

                      Flexible(

                        flex:2,

                        child:

                        Text(

                          AppConstants.formatPrice(item["saleprice"]),

                          maxLines:1,

                          overflow:
                          TextOverflow.ellipsis,

                          style:

                          GoogleFonts.poppins(

                            fontSize:20,

                            fontWeight:
                            FontWeight.w800,

                            color:
                            primaryColor,

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

                            AppConstants.formatPrice(item["rate"]),

                            maxLines:1,

                            overflow:
                            TextOverflow.ellipsis,

                            style:

                            GoogleFonts.poppins(

                              fontSize:13,

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
                    height:16,
                  ),

                  Container(

                    height:44,

                    alignment:
                    Alignment.center,

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

                    Text(

                      "View Product",

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

              ),

            ),

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
        0xFFF5F5F5,
      ),

      appBar:

      AppBar(

        backgroundColor:
        Colors.white,

        title:

        Text(

          "Top Deals",

          style:

          GoogleFonts.poppins(

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

      ListView.builder(

        padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),

        itemCount: 6,

        itemBuilder: (_, __) => const ShimmerBlock(
          width: double.infinity,
          height: 144,
        ),

      )

          :

      products.isEmpty

          ?

      Center(

        child:

        Text(

          "No Top Deals",

          style:

          GoogleFonts.poppins(),

        ),

      )

          :

      ListView.builder(

        padding:
        const EdgeInsets.only(
          top:14,
          bottom:20,
        ),

        itemCount:
        products.length,

        itemBuilder:
            (
            _,
            i,
            ){

          return productItem(
            products[i],
          );

        },

      ),

    );

  }

}