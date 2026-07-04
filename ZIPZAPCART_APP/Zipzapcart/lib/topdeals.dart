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
          10,
        ),

        padding:
        const EdgeInsets.all(
          10,
        ),

        decoration:

        BoxDecoration(

          color:
          Colors.white,

          borderRadius:
          BorderRadius.circular(
            16,
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

              height:88,

              width:88,

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
                    .imageUrl+

                    item["image"],

                fit:
                BoxFit.contain,

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

                    item["name"],

                    maxLines:2,

                    overflow:
                    TextOverflow.ellipsis,

                    style:

                    GoogleFonts.poppins(

                      fontSize:12.5,

                      fontWeight:
                      FontWeight.w600,

                    ),

                  ),

                  const SizedBox(
                    height:8,
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

                            fontSize:15.5,

                            fontWeight:
                            FontWeight.w800,

                            color:
                            primaryColor,

                          ),

                        ),

                      ),

                      const SizedBox(
                        width:6,
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

                              fontSize:11,

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
                    height:8,
                  ),

                  Container(

                    height:34,

                    alignment:
                    Alignment.center,

                    decoration:

                    BoxDecoration(

                      color:
                      primaryColor,

                      borderRadius:
                      BorderRadius.circular(
                        10,
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

                        fontSize: 11.5,

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