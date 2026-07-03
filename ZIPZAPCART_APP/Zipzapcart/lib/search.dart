import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'api_service.dart';
import 'constants.dart';
import 'view_product.dart';
import 'widgets/shimmer_card.dart';

class SearchPage
    extends StatefulWidget{

  const SearchPage({
    super.key,
  });

  @override
  State<SearchPage>
  createState()=>

      _SearchPageState();

}

class _SearchPageState
    extends State<SearchPage>{

  List products=[];

  bool loading=false;

  Timer? timer;

  final controller=
  TextEditingController();

  final Color primaryColor=
  const Color(
    0xFFEF4138,
  );

  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _isListening = false;

  Future<void> toggleListening() async {

    if (_isListening) {

      await _speech.stop();

      setState(() {
        _isListening = false;
      });

      return;
    }

    final available = await _speech.initialize();

    if (!available) {
      return;
    }

    setState(() {
      _isListening = true;
    });

    _speech.listen(
      onResult: (result) {

        controller.text = result.recognizedWords;

        controller.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.text.length),
        );

        if (result.finalResult) {

          setState(() {
            _isListening = false;
          });

          search();
        }
      },
    );
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  Future search()
  async{

    loading=true;

    setState((){});

    products=

    await ApiService
        .searchProducts(

      controller.text,

    );

    loading=false;

    setState((){});

  }

  void onChanged(
      String v,
      ){

    timer?.cancel();

    timer=

        Timer(

          const Duration(
            milliseconds:500,
          ),

              (){

            search();

          },

        );

  }

  Widget item(
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
        const EdgeInsets.only(
          bottom:14,
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

        ),

        child:

        Row(

          children:[

            Container(

              height:110,

              width:110,

              padding:
              const EdgeInsets.all(
                10,
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

                      fontWeight:
                      FontWeight.w600,

                    ),

                  ),

                  const SizedBox(
                    height:8,
                  ),

                  Text(

                    item[
                    "product_description"
                    ]

                        ??

                        "",

                    maxLines:2,

                    overflow:
                    TextOverflow.ellipsis,

                    style:

                    GoogleFonts.poppins(

                      fontSize:12,

                      color:
                      Colors.grey,

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
                    height:12,
                  ),

                  Container(

                    height:40,

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

          "Search",

          style:

          GoogleFonts.poppins(

            color:
            Colors.black,

            fontWeight:
            FontWeight.w700,

          ),

        ),

      ),

      body:

      Column(

        children:[

          Padding(

            padding:
            const EdgeInsets.all(
              18,
            ),

            child:

            Container(

              height:58,

              padding:
              const EdgeInsets.symmetric(
                horizontal:16,
              ),

              decoration:

              BoxDecoration(

                color:
                Colors.white,

                borderRadius:
                BorderRadius.circular(
                  22,
                ),

              ),

              child:

              TextField(

                controller:
                controller,

                onChanged:
                onChanged,

                decoration:

                InputDecoration(

                  border:
                  InputBorder.none,

                  hintText:
                  "Search products...",

                  icon:
                  const Icon(
                    Icons.search,
                  ),

                  suffixIcon:
                  IconButton(

                    onPressed: toggleListening,

                    icon: Icon(
                      _isListening
                          ? Icons.mic
                          : Icons.mic_none,

                      color: _isListening
                          ? primaryColor
                          : Colors.grey,
                    ),
                  ),

                ),

              ),

            ),

          ),

          Expanded(

            child:

            loading

                ?

            ListView.builder(

              padding: const EdgeInsets.symmetric(horizontal: 18),

              itemCount: 6,

              itemBuilder: (_, __) => const ShimmerBlock(
                width: double.infinity,
                height: 110,
              ),

            )

                :

            products.isEmpty

                ?

            Center(

              child:

              Text(

                "Search Products",

                style:

                GoogleFonts.poppins(),

              ),

            )

                :

            ListView.builder(

              padding:
              const EdgeInsets.symmetric(
                horizontal:18,
              ),

              itemCount:
              products.length,

              itemBuilder:
                  (
                  _,
                  i,
                  ){

                return item(
                  products[i],
                );

              },

            ),

          ),

        ],

      ),

    );

  }

}