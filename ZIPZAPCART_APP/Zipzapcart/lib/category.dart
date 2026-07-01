import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'api_service.dart';
import 'constants.dart';
import 'productlist.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() =>
      _CategoryPageState();
}

class _CategoryPageState
    extends State<CategoryPage> {

  static const Color themeRed =
  Color(0xFFEF4138);

  List categories = [];
  List subcategories = [];

  bool loading = true;

  int selectedCategory = 0;

  @override
  void initState() {
    super.initState();

    loadCategories();
  }

  Future<void> loadCategories() async {

    categories =
    await ApiService
        .getCategories();

    if (
    categories.isNotEmpty
    ) {

      await loadSubCategories(
        0,
      );
    }

    loading = false;

    setState(() {});
  }

  Future<void>
  loadSubCategories(
      int index,
      ) async {

    selectedCategory =
        index;

    subcategories =

    await ApiService
        .getSubcategories(

      int.parse(

        categories[
        index
        ]
        ["id"]
            .toString(),
      ),
    );

    setState(() {});
  }

  @override
  Widget build(
      BuildContext context
      ) {

    return Scaffold(

      backgroundColor:
      Colors.white,

      appBar:
      AppBar(

        elevation: 0,

        backgroundColor:
        Colors.white,

        centerTitle: true,

        title:

        Text(

          "Categories",

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

      loading

          ?

      const Center(

        child:

        CircularProgressIndicator(

          color:
          themeRed,
        ),
      )

          :

      Row(

        children: [

          /// LEFT CATEGORY

          Container(

            width: 110,

            decoration:

            BoxDecoration(

              color:
              Colors.white,

              boxShadow: [

                BoxShadow(

                  color:
                  Colors.black
                      .withOpacity(
                    0.05,
                  ),

                  blurRadius:
                  10,
                ),
              ],
            ),

            child:

            ListView.builder(

              itemCount:
              categories.length,

              itemBuilder:
                  (
                  _,
                  index
                  ) {

                bool active =

                    selectedCategory
                        ==
                        index;

                final item =

                categories[
                index
                ];

                return GestureDetector(

                  onTap: () {

                    loadSubCategories(
                      index,
                    );
                  },

                  child:

                  AnimatedContainer(

                    duration:

                    const Duration(
                      milliseconds:
                      250,
                    ),

                    padding:

                    const EdgeInsets.symmetric(
                      vertical:
                      16,
                    ),

                    decoration:

                    BoxDecoration(

                      color:

                      active

                          ?

                      themeRed
                          .withOpacity(
                        0.08,
                      )

                          :

                      Colors.white,

                      border:

                      Border(

                        left:

                        BorderSide(

                          color:

                          active

                              ?

                          themeRed

                              :

                          Colors
                              .transparent,

                          width:
                          5,
                        ),
                      ),
                    ),

                    child:

                    Column(

                      children: [

                        Container(

                          height:
                          62,

                          width:
                          62,

                          padding:
                          const EdgeInsets.all(
                            8,
                          ),

                          decoration:

                          BoxDecoration(

                            color:

                            active

                                ?

                            themeRed
                                .withOpacity(
                              0.08,
                            )

                                :

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
                                .imageUrl +

                                item[
                                "image"],

                            fit:
                            BoxFit.contain,
                          ),
                        ),

                        const SizedBox(
                          height:
                          10,
                        ),

                        Text(

                          item[
                          "name"],

                          textAlign:
                          TextAlign.center,

                          maxLines:
                          2,

                          overflow:
                          TextOverflow
                              .ellipsis,

                          style:

                          GoogleFonts
                              .poppins(

                            fontSize:
                            11,

                            color:

                            active

                                ?

                            themeRed

                                :

                            Colors.black,

                            fontWeight:

                            active

                                ?

                            FontWeight.w700

                                :

                            FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          /// RIGHT SUBCATEGORY

          Expanded(

            child:

            subcategories
                .isEmpty

                ?

            Center(

              child:

              Text(

                "No Subcategories",

                style:

                GoogleFonts
                    .poppins(),
              ),
            )

                :

            GridView.builder(

              padding:
              const EdgeInsets.all(
                16,
              ),

              itemCount:
              subcategories.length,

              gridDelegate:

              const SliverGridDelegateWithFixedCrossAxisCount(

                crossAxisCount:
                2,

                crossAxisSpacing:
                16,

                mainAxisSpacing:
                16,

                childAspectRatio:
                0.68,
              ),

              itemBuilder:
                  (
                  _,
                  index
                  ) {

                final item =

                subcategories[
                index
                ];

                return GestureDetector(

                  onTap: () {

                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder:

                            (_) =>

                            ProductListPage(

                              subcatId:

                              int.parse(

                                item[
                                "id"]
                                    .toString(),
                              ),

                              title:

                              item[
                              "name"],
                            ),
                      ),
                    );
                  },

                  child:

                  Container(

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
                            0.05,
                          ),

                          blurRadius:
                          12,

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

                      mainAxisAlignment:
                      MainAxisAlignment.start,

                      children: [

                        Container(

                          height:
                          74,

                          width:
                          74,

                          decoration:

                          BoxDecoration(

                            color:

                            themeRed
                                .withOpacity(
                              0.06,
                            ),

                            borderRadius:

                            BorderRadius.circular(
                              22,
                            ),
                          ),

                          child:

                          Padding(

                            padding:
                            const EdgeInsets.all(
                              14,
                            ),

                            child:

                            Image.network(

                              AppConstants
                                  .imageUrl +

                                  item[
                                  "image"],

                              fit:
                              BoxFit.contain,
                            ),
                          ),
                        ),

                        const SizedBox(
                          height:
                          16,
                        ),

                    Flexible(

                      child:

                      Padding(

                        padding:

                        const EdgeInsets.symmetric(
                          horizontal:8,
                        ),

                        child:

                        Text(

                            item[
                            "name"],

                            textAlign:
                            TextAlign.center,

                            maxLines:
                            2,

                            overflow:
                            TextOverflow
                                .ellipsis,

                            style:

                            GoogleFonts
                                .poppins(

                              fontSize:
                              14,

                              fontWeight:
                              FontWeight.w700,
                            ),
                          ),
                      ),
                     ),

                      ],
                    ),
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
