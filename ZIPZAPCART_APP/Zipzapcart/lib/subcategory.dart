// 🔥 CREATE subcategory.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'api_service.dart';
import 'constants.dart';
import 'productlist.dart';

class SubCategoryPage extends StatefulWidget {

  final int categoryId;
  final String categoryName;

  const SubCategoryPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<SubCategoryPage> createState() =>
      _SubCategoryPageState();
}

class _SubCategoryPageState
    extends State<SubCategoryPage> {

  List subcategories = [];

  bool loading = true;

  final Color primaryColor =
  const Color(0xFFECA202);

  @override
  void initState() {
    super.initState();

    loadData();
  }

  Future<void> loadData() async {

    subcategories =
    await ApiService.getSubcategories(
      widget.categoryId,
    );

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      const Color(0xFFF8F8F8),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,

        title: Text(
          widget.categoryName,
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: loading

          ? Center(
        child:
        CircularProgressIndicator(
          color: primaryColor,
        ),
      )
          : GridView.builder(
        padding: const EdgeInsets.all(18),

        itemCount: subcategories.length,

        gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 18,
          crossAxisSpacing: 18,
          childAspectRatio: 0.78,
        ),

        itemBuilder: (_, index) {

          final item =
          subcategories[index];

          return GestureDetector(

            onTap: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ProductListPage(
                        subcatId:
                        int.parse(
                          item["id"]
                              .toString(),
                        ),
                        title:
                        item["name"],
                      ),
                ),
              );
            },

            child: Container(

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius:
                BorderRadius.circular(28),

                boxShadow: [
                  BoxShadow(
                    color:
                    Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset:
                    const Offset(0, 6),
                  ),
                ],
              ),

              child: Padding(
                padding:
                const EdgeInsets.all(14),

                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,

                  children: [

                    Container(
                      height: 90,
                      width: 90,

                      decoration:
                      BoxDecoration(
                        borderRadius:
                        BorderRadius.circular(22),

                        color:
                        const Color(0xFFF7F7F7),
                      ),

                      child: ClipRRect(
                        borderRadius:
                        BorderRadius.circular(22),

                        child: Image.network(
                          AppConstants
                              .imageUrl +
                              item["image"],

                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      item["name"],

                      textAlign:
                      TextAlign.center,

                      style:
                      GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),

                      decoration:
                      BoxDecoration(
                        color:
                        primaryColor
                            .withOpacity(0.12),

                        borderRadius:
                        BorderRadius.circular(
                          30,
                        ),
                      ),

                      child: Text(
                        "Explore",

                        style:
                        GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight:
                          FontWeight.w600,

                          color:
                          primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}