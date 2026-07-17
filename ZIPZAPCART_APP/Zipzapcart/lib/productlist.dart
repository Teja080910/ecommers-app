import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'api_service.dart';
import 'constants.dart';
import 'view_product.dart';

class ProductListPage extends StatefulWidget {

  final int subcatId;
  final String title;

  const ProductListPage({
    super.key,
    required this.subcatId,
    required this.title,
  });

  @override
  State<ProductListPage> createState() =>
      _ProductListPageState();
}

class _ProductListPageState
    extends State<ProductListPage> {

  List products = [];

  List filteredProducts = [];

  bool loading = true;

  String sortType = "default";

  final Color primaryColor =
  const Color(0xFFEF4138);

  @override
  void initState() {
    super.initState();

    loadProducts();
  }

  Future<void> loadProducts() async {

    products = await ApiService.getProducts(
      widget.subcatId,
    );

    filteredProducts =
        List.from(products);

    setState(() {
      loading = false;
    });
  }

  void sortProducts(String type) {

    sortType = type;

    if (type == "low_to_high") {

      filteredProducts.sort(
            (a, b) =>
            double.parse(
              a["saleprice"]
                  .toString(),
            ).compareTo(
              double.parse(
                b["saleprice"]
                    .toString(),
              ),
            ),
      );
    }

    else if (type == "high_to_low") {

      filteredProducts.sort(
            (a, b) =>
            double.parse(
              b["saleprice"]
                  .toString(),
            ).compareTo(
              double.parse(
                a["saleprice"]
                    .toString(),
              ),
            ),
      );
    }

    else if (type == "name_asc") {

      filteredProducts.sort(
            (a, b) =>
            a["name"]
                .toString()
                .compareTo(
              b["name"]
                  .toString(),
            ),
      );
    }

    else if (type == "stock") {

      filteredProducts.sort(
            (a, b) =>
            int.parse(
              b["stock"]
                  .toString(),
            ).compareTo(
              int.parse(
                a["stock"]
                    .toString(),
              ),
            ),
      );
    }

    else {

      filteredProducts =
          List.from(products);
    }

    setState(() {});
  }

  void sortBottomSheet() {

    showModalBottomSheet(

      context: context,

      isScrollControlled: true,

      backgroundColor:
      Colors.white,

      shape:
      const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),

      builder: (_) {

        return SafeArea(
          child: SingleChildScrollView(

            child: Padding(
              padding:
              const EdgeInsets.all(22),

              child: Column(
                mainAxisSize:
                MainAxisSize.min,

                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  Center(
                    child: Container(
                      height: 5,
                      width: 70,

                      decoration:
                      BoxDecoration(
                        color:
                        Colors.grey
                            .shade300,

                        borderRadius:
                        BorderRadius.circular(
                          30,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 22,
                  ),

                  Text(
                    "Sort Products",

                    style:
                    GoogleFonts.poppins(
                      fontSize: 20,

                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  sortTile(
                    "Default",
                    "default",
                  ),

                  sortTile(
                    "Price Low to High",
                    "low_to_high",
                  ),

                  sortTile(
                    "Price High to Low",
                    "high_to_low",
                  ),

                  sortTile(
                    "Name A-Z",
                    "name_asc",
                  ),

                  sortTile(
                    "Highest Stock",
                    "stock",
                  ),

                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget sortTile(
      String title,
      String value,
      ) {

    bool selected =
        sortType == value;

    return GestureDetector(

      onTap: () {

        Navigator.pop(context);

        sortProducts(value);
      },

      child: Container(

        margin:
        const EdgeInsets.only(
          bottom: 14,
        ),

        padding:
        const EdgeInsets.all(18),

        decoration:
        BoxDecoration(
          color:
          selected
              ? primaryColor
              .withOpacity(
            0.12,
          )
              : const Color(
            0xFFF7F7F7,
          ),

          borderRadius:
          BorderRadius.circular(
            18,
          ),
        ),

        child: Row(
          children: [

            Expanded(
              child: Text(
                title,

                style:
                GoogleFonts.poppins(
                  fontWeight:
                  FontWeight.w600,

                  color:
                  selected
                      ? primaryColor
                      : Colors.black,
                ),
              ),
            ),

            if (selected)

              Icon(
                Icons.check_circle,

                color:
                primaryColor,
              ),
          ],
        ),
      ),
    );
  }

  Widget productItem(Map item) {

    return GestureDetector(

      onTap: () {

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
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

      child: Container(

        margin:
        const EdgeInsets.only(
          left: 14,
          right: 14,
          bottom: 10,
        ),

        padding:
        const EdgeInsets.all(10),

        decoration:
        BoxDecoration(
          color: Colors.white,

          borderRadius:
          BorderRadius.circular(16),

          boxShadow: [

            BoxShadow(
              color:
              Colors.black.withOpacity(
                0.04,
              ),

              blurRadius: 10,

              offset:
              const Offset(0, 4),
            ),
          ],
        ),

        child: Row(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            // 🔥 IMAGE
            Container(
              height: 88,
              width: 88,

              padding:
              const EdgeInsets.all(8),

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

              child: Image.network(
                AppConstants.resolveImage(item["image"]),

                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(width: 12),

            // 🔥 DETAILS
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
                      fontSize: 12.5,

                      fontWeight:
                      FontWeight
                          .w600,

                      color:
                      Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [

                      Container(
                        padding:
                        const EdgeInsets.symmetric(
                          horizontal:
                          6,

                          vertical: 3,
                        ),

                        decoration:
                        BoxDecoration(
                          color:
                          Colors.green
                              .withOpacity(
                            0.12,
                          ),

                          borderRadius:
                          BorderRadius.circular(
                            7,
                          ),
                        ),

                        child: Row(
                          children: [

                            const Icon(
                              Icons.star,
                              size: 11,
                              color:
                              Colors.green,
                            ),

                            const SizedBox(
                              width: 3,
                            ),

                            Text(
                              "4.5",

                              style:
                              GoogleFonts.poppins(
                                fontSize:
                                9.5,

                                fontWeight:
                                FontWeight
                                    .w600,

                                color:
                                Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 6),

                      Text(
                        item["stock"]
                            .toString() +
                            " Left",

                        style:
                        GoogleFonts.poppins(
                          fontSize: 9.5,

                          color:
                          Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
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
                            FontWeight.w700,

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

                  const SizedBox(height: 8),

                  Row(
                    children: [

                      Expanded(
                        child: Container(
                          height: 34,

                          decoration:
                          BoxDecoration(
                            color:
                            primaryColor,

                            borderRadius:
                            BorderRadius.circular(
                              10,
                            ),
                          ),

                          child: Center(
                            child: Text(
                              "View Product",

                              style:
                              GoogleFonts.poppins(
                                color:
                                Colors.white,

                                fontWeight:
                                FontWeight
                                    .w600,

                                fontSize: 11.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      const Color(0xFFF5F5F5),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,

        title: Text(
          widget.title,

          style: GoogleFonts.poppins(
            color: Colors.black,

            fontWeight:
            FontWeight.w700,
          ),
        ),

        actions: [

          IconButton(

            onPressed: () {

              sortBottomSheet();
            },

            icon: const Icon(
              Icons.sort,
              color: Colors.black,
            ),
          ),
        ],
      ),

      body: loading

          ? Center(
        child:
        CircularProgressIndicator(
          color: primaryColor,
        ),
      )

          : filteredProducts.isEmpty

          ? Center(
        child: Text(
          "No Products",

          style:
          GoogleFonts.poppins(
            fontSize: 16,

            fontWeight:
            FontWeight.w600,
          ),
        ),
      )

          : ListView.builder(
        padding:
        const EdgeInsets.only(
          top: 14,
          bottom: 20,
        ),

        itemCount:
        filteredProducts.length,

        itemBuilder:
            (_, index) {

          return productItem(
            filteredProducts[index],
          );
        },
      ),
    );
  }
}