import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import 'api_service.dart';
import 'cart.dart';
import 'category.dart';
import 'constants.dart';
import 'myorder.dart';
import 'posts.dart';
import 'profile.dart';
import 'subcategory.dart';
import 'view_product.dart';
import 'search.dart';
import 'topdeals.dart';
import 'translator_service.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();

}

class _HomePageState extends State<HomePage> {
  static const Color themeRed =
  Color(0xFFEF4138);
  final PageController _bannerController =
  PageController(viewportFraction: 0.93);

  int currentBanner = 0;
  int selectedBottom = 0;

  bool loading = true;

  List banners = [];
  List categories = [];
  List topDeals = [];
  List homeCategories = [];

  final List<String> bottomIcons = [
    "assets/icons/home.svg",
    "assets/icons/category.svg",
    "assets/icons/order.svg",
    "assets/icons/post.svg",
    "assets/icons/profile.svg",
  ];

  final List<String> bottomTitles = [
    "Home",
    "Category",
    "Orders",
    "Post",
    "Profile",
  ];
  Widget t(

      String text,{

        TextStyle? style,

        TextAlign? textAlign,

        int? maxLines,

        TextOverflow? overflow,

      }){

    return FutureBuilder<String>(

      future:

      TranslatorService()
          .translate(
        text,
      ),

      builder:
          (
          _,
          snap,
          ){

        return Text(

          snap.data
              ??
              text,

          style:
          style,

          textAlign:
          textAlign,

          maxLines:
          maxLines,

          overflow:
          overflow,

        );

      },

    );

  }
  static const Color primaryColor =
      themeRed;

  @override
  void initState() {
    super.initState();

    loadData();

    Timer.periodic(
      const Duration(seconds: 3),
          (timer) {

        if (!_bannerController.hasClients ||
            banners.isEmpty) {
          return;
        }

        currentBanner++;

        if (currentBanner >= banners.length) {
          currentBanner = 0;
        }

        _bannerController.animateToPage(
          currentBanner,
          duration:
          const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );

        setState(() {});
      },
    );
  }
  Widget navItem({
    required int index,
    required String icon,
    required String title,
  }) {

    final bool isActive = selectedBottom == index;

    return GestureDetector(

      onTap: () {

        setState(() {
          selectedBottom = index;
        });

        if (index == 0) {

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const HomePage(),
            ),
          );
        }

        else if (index == 1) {

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CategoryPage(),
            ),
          );
        }

        else if (index == 2) {

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const MyOrderPage(),
            ),
          );
        }
        else if (index == 3) {

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const PostsPage(),
            ),
          );
        }
        else if (index == 4) {

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ProfilePage(),
            ),
          );
        }
      },

      child: SizedBox(
        width: 62,

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            SvgPicture.asset(
              icon,
              height: 22,
              width: 22,

              colorFilter: ColorFilter.mode(
                isActive
                    ? primaryColor
                    : Colors.grey.shade500,
                BlendMode.srcIn,
              ),
            ),

            const SizedBox(height: 5),

            t(
              title,

              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isActive
                    ? primaryColor
                    : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> loadData() async {

    banners = await ApiService.getBanners();

    categories =
    await ApiService.getCategories();

    topDeals =
    await ApiService.getTopDeals();

    homeCategories =
    await ApiService.getHomeCategoryProducts();

    setState(() {
      loading = false;
    });
  }

  Widget productCard(Map item) {

    return GestureDetector(

      onTap: () {

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ViewProductPage(
              productId: int.parse(
                item["id"].toString(),
              ),
            ),
          ),
        );
      },

      child: Container(
        width: 175,
        margin: const EdgeInsets.only(right: 16),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius:
          BorderRadius.circular(26),

          boxShadow: [
            BoxShadow(
              color:
              Colors.black.withOpacity(0.05),

              blurRadius: 14,

              offset: const Offset(0, 6),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            Container(
              height: 150,
              width: double.infinity,

              padding:
              const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color:
                const Color(0xFFF7F7F7),

                borderRadius:
                BorderRadius.circular(26),
              ),

              child: Image.network(
                AppConstants.imageUrl +
                    item["image"],

                fit: BoxFit.contain,
              ),
            ),

            Padding(
              padding:
              const EdgeInsets.all(14),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  t(
                    item["name"],

                    maxLines: 1,

                    overflow:
                    TextOverflow.ellipsis,

                    style:
                    GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(

                    crossAxisAlignment:
                    CrossAxisAlignment.center,

                    children:[

                      Flexible(

                        flex:2,

                        child:

                        t(

                          "₹${item["saleprice"]}",

                          maxLines:1,

                          overflow:
                          TextOverflow.ellipsis,

                          style:
                          GoogleFonts.poppins(

                            fontSize:16,

                            fontWeight:
                            FontWeight.w700,

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

                          t(

                            "₹${item["rate"]}",

                            maxLines:1,

                            overflow:
                            TextOverflow.ellipsis,

                            style:
                            GoogleFonts.poppins(

                              fontSize:12,

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
      const Color(
        0xFFFFFFFF,
      ),
      bottomNavigationBar: Container(
        height: 82,
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        padding: const EdgeInsets.symmetric(horizontal: 10),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,

          children: [

            navItem(
              index: 0,
              icon: "assets/icons/home.svg",
              title: "Home",
            ),

            navItem(
              index: 1,
              icon: "assets/icons/category.svg",
              title: "Category",
            ),

            navItem(
              index: 2,
              icon: "assets/icons/order.svg",
              title: "Orders",
            ),

            /// SALE ANIMATION
            navItem(
              index: 3,
              icon: "assets/icons/post.svg",
              title: "Posts",
            ),

            navItem(
              index: 4,
              icon: "assets/icons/profile.svg",
              title: "Profile",
            ),
          ],
        ),
      ),
      body: loading

          ? Center(
        child:
        CircularProgressIndicator(
          color: primaryColor,
        ),
      )
          : SafeArea(
        child: SingleChildScrollView(

          physics:
          const BouncingScrollPhysics(),

          child: Column(
            children: [

              Padding(
                padding:
                const EdgeInsets.fromLTRB(
                  18,
                  18,
                  18,
                  12,
                ),

                child: Row(
                  children: [

                    const SizedBox(width: 42),

                    Expanded(
                      child: Center(
                        child: Image.asset(
                          "assets/images/logo.png",
                          height: 42,
                        ),
                      ),
                    ),

                    GestureDetector(

                      onTap: () {

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CartPage(),
                          ),
                        );
                      },

                      child: SvgPicture.asset(
                        "assets/icons/cart.svg",

                        height: 26,
                        width: 26,

                        colorFilter:
                        ColorFilter.mode(
                          primaryColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 18,
                ),

                  child: GestureDetector(

                    onTap:(){

                      Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder:
                              (_)=>

                          const SearchPage(),

                        ),

                      );

                    },

                    child:

                    Container(
                  height: 58,

                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius:
                    BorderRadius.circular(
                      22,
                    ),

                    boxShadow: [
                      BoxShadow(
                        color:
                        Colors.black
                            .withOpacity(
                          0.05,
                        ),

                        blurRadius: 15,

                        offset:
                        const Offset(
                          0,
                          6,
                        ),
                      ),
                    ],
                  ),

                  child: Row(
                    children: [

                      Icon(
                        Icons.search,
                        color:
                        Colors.grey.shade500,
                      ),

                      const SizedBox(width: 10),

                      t(
                        "Search products...",

                        style:
                        GoogleFonts.poppins(
                          color:
                          Colors.grey
                              .shade500,

                          fontWeight:
                          FontWeight.w500,

                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                    ),
                  ),
              ),

              const SizedBox(height: 20),
              Padding(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 18,
                ),

                child: Row(
                  children: [

                    t(
                      "Shop By Category",

                      style:
                      GoogleFonts.poppins(
                        fontSize: 15,

                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              SizedBox(
                height: 122,

                child: ListView.builder(
                  scrollDirection:
                  Axis.horizontal,

                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 18,
                  ),

                  itemCount:
                  categories.length,

                  itemBuilder:
                      (_, index) {

                    final item =
                    categories[index];

                    return GestureDetector(

                      onTap: () {

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                SubCategoryPage(
                                  categoryId:
                                  int.parse(
                                    item["id"]
                                        .toString(),
                                  ),

                                  categoryName:
                                  item["name"],
                                ),
                          ),
                        );
                      },

                      child: Container(
                        width: 92,

                        margin:
                        const EdgeInsets.only(
                          right: 14,
                        ),

                        child: Column(
                          children: [

                            Container(
                              height: 78,
                              width: 78,

                              decoration:
                              BoxDecoration(
                                borderRadius:
                                BorderRadius.circular(
                                  24,
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

                              child: ClipRRect(
                                borderRadius:
                                BorderRadius.circular(
                                  24,
                                ),

                                child:
                                Image.network(
                                  AppConstants
                                      .imageUrl +
                                      item[
                                      "image"],

                                  fit:
                                  BoxFit.cover,
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 10,
                            ),

                            t(
                              item["name"],

                              maxLines: 2,

                              overflow:
                              TextOverflow
                                  .ellipsis,

                              textAlign:
                              TextAlign.center,

                              style:
                              GoogleFonts.poppins(
                                fontSize: 13,

                                fontWeight:
                                FontWeight
                                    .w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(
                height: 180,

                child: PageView.builder(
                  controller:
                  _bannerController,

                  itemCount:
                  banners.length,

                  onPageChanged: (i) {

                    setState(() {
                      currentBanner = i;
                    });
                  },

                  itemBuilder: (_, i) {

                    return Padding(
                      padding:
                      const EdgeInsets.only(
                        right: 8,
                      ),

                      child: ClipRRect(
                        borderRadius:
                        BorderRadius.circular(
                          28,
                        ),

                        child: Image.network(
                          AppConstants
                              .imageUrl +
                              banners[i]
                              ["image"],

                          fit: BoxFit.contain,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 14),

              Row(
                mainAxisAlignment:
                MainAxisAlignment.center,

                children: List.generate(
                  banners.length,

                      (i) => AnimatedContainer(
                    duration:
                    const Duration(
                      milliseconds: 300,
                    ),

                    margin:
                    const EdgeInsets.symmetric(
                      horizontal: 4,
                    ),

                    height: 8,

                    width:
                    currentBanner == i
                        ? 22
                        : 8,

                    decoration: BoxDecoration(
                      color:
                      currentBanner ==
                          i
                          ? primaryColor
                          : Colors.grey
                          .shade300,

                      borderRadius:
                      BorderRadius.circular(
                        20,
                      ),
                    ),
                  ),
                ),
              ),



              const SizedBox(height: 24),



              Padding(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 18,
                ),

                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,

                  children: [

                    t(
                      "Top Deals",

                      style:
                      GoogleFonts.poppins(
                        fontSize: 15,

                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),

                    GestureDetector(

                      onTap:(){

                        Navigator.push(

                          context,

                          MaterialPageRoute(

                            builder:
                                (_)=>

                            const TopDealsPage(),

                          ),

                        );

                      },

                      child:

                      t(

                        "View All",

                        style:

                        GoogleFonts.poppins(

                          fontSize:13,

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

              const SizedBox(height: 18),

              SizedBox(
                height: 265,

                child: ListView.builder(
                  scrollDirection:
                  Axis.horizontal,

                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 18,
                  ),

                  itemCount:
                  topDeals.length,

                  itemBuilder:
                      (_, index) {

                    return productCard(
                      topDeals[index],
                    );
                  },
                ),
              ),

              ...List.generate(
                homeCategories.length,

                    (index) {

                  final category =
                  homeCategories[index];

                  final products =
                      category["products"] ?? [];

                  return Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                    children: [

                      const SizedBox(
                        height: 28,
                      ),

                      Padding(
                        padding:
                        const EdgeInsets.symmetric(
                          horizontal:
                          18,
                        ),

                        child: t(
                          category["name"],

                          style:
                          GoogleFonts.poppins(
                            fontSize:
                            15,

                            fontWeight:
                            FontWeight
                                .w700,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      products.isEmpty

                          ? Padding(
                        padding:
                        const EdgeInsets.symmetric(
                          horizontal:
                          18,
                        ),

                        child: t(
                          "No Products",

                          style:
                          GoogleFonts.poppins(
                            fontSize:
                            14,

                            fontWeight:
                            FontWeight
                                .w600,
                          ),
                        ),
                      )

                          : SizedBox(
                        height: 265,

                        child:
                        ListView.builder(
                          scrollDirection:
                          Axis.horizontal,

                          padding:
                          const EdgeInsets.symmetric(
                            horizontal:
                            18,
                          ),

                          itemCount:
                          products.length,

                          itemBuilder:
                              (_, pindex) {

                            return productCard(
                              products[
                              pindex],
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 50),Padding(

                padding:
                const EdgeInsets.fromLTRB(
                  18,
                  34,
                  18,
                  0,
                ),

                child:

                Container(

                  width:
                  double.infinity,

                  padding:
                  const EdgeInsets.symmetric(

                    horizontal:28,

                    vertical:34,

                  ),

                  decoration:

                  BoxDecoration(

                    color:
                    const Color(
                      0xFFF5F5F5,
                    ),

                    borderRadius:
                    BorderRadius.circular(
                      34,
                    ),

                  ),

                  child:

                  Column(

                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children:[

                      RichText(

                        text:

                        TextSpan(

                          children:[

                            TextSpan(

                              text:

                              "We’re just\nminutes away\nfrom you ",

                              style:

                              GoogleFonts.poppins(

                                fontSize:46,

                                height:0.95,

                                fontWeight:
                                FontWeight.w800,

                                color:
                                const Color(
                                  0xFF888888,
                                ),

                              ),

                            ),

                            const WidgetSpan(

                              alignment:
                              PlaceholderAlignment.middle,

                              child:

                              Text(

                                "🫶",

                                style:

                                TextStyle(

                                  fontSize:
                                  38,

                                ),

                              ),

                            ),

                          ],

                        ),

                      ),

                      const SizedBox(
                        height:24,
                      ),

                      t(

                        "Delivering smiles 😊 across India",

                        style:

                        GoogleFonts.poppins(

                          fontSize:18,

                          fontWeight:
                          FontWeight.w500,

                          color:
                          const Color(
                            0xFF787878,
                          ),

                        ),

                      ),

                    ],

                  ),

                ),

              ),

              const SizedBox(
                height:50,
              ),
            ],
          ),
        ),
      ),
    );
  }
}