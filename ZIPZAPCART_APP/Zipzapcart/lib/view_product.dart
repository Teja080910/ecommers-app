import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'api_service.dart';
import 'cart.dart';
import 'checkout.dart';
import 'constants.dart';
import 'offers.dart';
import 'login.dart';

class ViewProductPage extends StatefulWidget {

  final int productId;

  const ViewProductPage({
    super.key,
    required this.productId,
  });

  @override
  State<ViewProductPage> createState() =>
      _ViewProductPageState();
}

class _ViewProductPageState
    extends State<ViewProductPage> {
  int userId = 0;
  Map product = {};

  List variants = [];
  List reviews = [];

  bool loading = true;

  int selectedVariant = 0;
  int currentImage = 0;

  bool isWishlist=false;

  bool outOfStock=false;

  double avgRating = 0;
  int totalReviews = 0;

  double selectedRate = 0;
  double selectedSaleRate = 0;

  String selectedDescription = "";

  int selectedStock = 0;

  List images = [];

  List similarProducts = [];

  bool deliverable = false;
  String? deliveryEstimate;
  bool isExpressDelivery = false;
  String? deliveryEstimateText;

  final TextEditingController reviewController =
  TextEditingController();

  double userRating = 5;

  final Color primaryColor =
  const Color(0xFFEF4138);

  List<String> get productHighlights {

    final lines = selectedDescription
        .split(RegExp(r'\r\n|\n|\r'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    return lines.take(6).toList();
  }

  @override
  void initState() {
    super.initState();
    getUser();

  }
  Future<void> getUser() async {

    final prefs =
    await SharedPreferences.getInstance();

    userId =
        prefs.getInt("user_id") ?? 0;

    loadProduct();
  }
  Future<void> loadProduct() async {

    var data = await ApiService.viewProduct(
      widget.productId,
    );

    if (data["status"] == true) {

      product =
      data["product"];

// 🔥 SET HEART STATE ON PAGE LOAD

      isWishlist =

          product[
          "is_wishlist"
          ]

              ==

              true

              ||

              product[
              "is_wishlist"
              ]

                  ==

                  1;

      variants =
          data["variants"] ?? [];
      reviews = data["reviews"] ?? [];

      avgRating =
          double.parse(
            data["avg_rating"].toString(),
          );

      totalReviews =
          int.parse(
            data["total_reviews"].toString(),
          );

      selectedRate =
          double.parse(
            product["rate"].toString(),
          );

      selectedSaleRate =
          double.parse(
            product["saleprice"].toString(),
          );

      selectedDescription =
          product["product_description"] ?? "";

      selectedStock=

          int.tryParse(
            product["stock"]
                .toString(),
          )

              ??

              0;

      outOfStock=
          selectedStock<1;
      images = [];

      images.add(product["image"]);

      if (product["other_images"] != null &&
          product["other_images"]
              .toString()
              .isNotEmpty) {

        images.addAll(
          product["other_images"]
              .toString()
              .split(","),
        );
      }

      loadSimilarProducts();
      loadDeliveryEstimate();
    }

    setState(() {
      loading = false;
    });
  }

  Future<void> loadSimilarProducts() async {

    final subcatId = int.tryParse(
      product["subcat_id"].toString(),
    );

    if (subcatId == null) {
      return;
    }

    final list = await ApiService.getSimilarProducts(
      subcatId,
      widget.productId,
    );

    if (mounted) {
      setState(() {
        similarProducts = list;
      });
    }
  }

  Future<void> loadDeliveryEstimate() async {

    final address = await ApiService.getDefaultAddress(userId);

    if (address["status"] != true || address["address"] == null) {
      return;
    }

    final pincode = address["address"]["pincode"]?.toString() ?? "";

    if (pincode.isEmpty) {
      return;
    }

    final result = await ApiService.checkDelivery(pincode);

    if (mounted) {
      setState(() {
        deliverable = result["deliverable"] == true;
        deliveryEstimate = result["delivery_estimate"]?.toString();
        isExpressDelivery = result["is_express"] == true;
        deliveryEstimateText = result["estimate_text"]?.toString();
      });
    }
  }

  bool requireLogin() {

    if (userId != 0) {
      return true;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1F1F1F),
        content: const Text(
          "Please login to continue",
        ),
        action: SnackBarAction(
          label: "LOGIN",
          textColor: Colors.orangeAccent,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LoginPage(),
              ),
            );
          },
        ),
      ),
    );

    return false;
  }

  Future<void> addToCart({
    bool buyNow = false,
  }) async {

    if (!requireLogin()) {
      return;
    }

    var data = await ApiService.addToCart(
      userId,
      widget.productId,

      variants.isEmpty
          ? 0
          : int.parse(
        variants[selectedVariant]["id"]
            .toString(),
      ),
    );

    if (data["status"] == true) {

      if (!mounted) {
        return;
      }

      if (buyNow) {

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
            const CheckoutPage(),
          ),
        );

      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Color(0xFF1F1F1F),
            content: Text("Added to cart"),
          ),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
            const CartPage(),
          ),
        );
      }

    } else if (mounted) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          content: Text(
            data["auth_error"] == true
                ? "Session expired. Please log in again."
                : "Couldn't add to cart. Please try again.",
          ),
        ),
      );
    }
  }

  Future<void> submitReview() async {

    if (reviewController.text.isEmpty) {
      return;
    }

    await ApiService.addReview(
      userId,
      widget.productId,
      userRating,
      reviewController.text,
    );

    reviewController.clear();

    loadProduct();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      const Color(0xFFF5F5F5),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,

        iconTheme:
        const IconThemeData(
          color: Colors.black,
        ),

        actions: [

          IconButton(

            onPressed:() async {

              if (!requireLogin()) {
                return;
              }

              final res=

              await ApiService
                  .toggleWishlist(

                userId,

                widget.productId,

              );

              if(
              res["status"]
                  ==
                  true
              ){

                final added =
                res["wishlist"] == true;

                setState(() {
                  isWishlist = added;
                });

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: const Color(0xFF1F1F1F),
                      content: Text(
                        added
                            ? "Added to wishlist"
                            : "Removed from wishlist",
                      ),
                    ),
                  );
                }

              } else if (mounted) {

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.red,
                    content: Text(
                      res["auth_error"] == true
                          ? "Session expired. Please log in again."
                          : "Couldn't update wishlist. Please try again.",
                    ),
                  ),
                );
              }

            },

            icon: Icon(
              isWishlist
                  ? Icons.favorite
                  : Icons.favorite_border,

              size: 20,
              color: Colors.red,
            ),
          ),

          IconButton(

            onPressed: () {

              SharePlus.instance.share(
                ShareParams(
                  text:
                  "${product["name"] ?? "Check this product"} on Zipzapcart!\n"
                  "${AppConstants.imageUrl}product.php?id=${widget.productId}",
                ),
              );
            },

            icon: const Icon(
              Icons.share,
              size: 20,
              color: Colors.black87,
            ),
          ),
        ],
      ),

      bottomNavigationBar: loading
          ? null
          : Container(
        padding:
        const EdgeInsets.all(16),

        decoration:
        const BoxDecoration(
          color: Colors.white,
        ),

        child: Row(
          children: [

            Expanded(
              child: Container(
                height: 56,

                decoration:
                BoxDecoration(
                  borderRadius:
                  BorderRadius.circular(
                    16,
                  ),

                  border: Border.all(
                    color:
                    primaryColor,
                  ),
                ),

                child: Material(
                  color: Colors.transparent,

                  child: InkWell(

                    borderRadius:
                    BorderRadius.circular(
                      16,
                    ),

                    onTap:

                    outOfStock

                        ?

                    null

                        :

                        (){

                      addToCart(
                        buyNow:true,
                      );

                    },

                    child: Center(
                      child: Text(
                        "Buy Now",

                        style:
                        GoogleFonts.poppins(
                          color:
                          primaryColor,

                          fontWeight:
                          FontWeight
                              .w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: SizedBox(
                height: 56,

                child: ElevatedButton(

                  onPressed:

                  outOfStock

                      ?

                  null

                      :

                      (){

                    addToCart();

                  },

                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    primaryColor,

                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        16,
                      ),
                    ),
                  ),

                  child: Text(
                    "Add To Cart",

                    style:
                    GoogleFonts.poppins(
                      color:
                      Colors.white,

                      fontWeight:
                      FontWeight
                          .w700,
                    ),
                  ),
                ),
              ),
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

          : SingleChildScrollView(

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            // 🔥 IMAGES
            Container(
              color: Colors.white,

              child: Column(
                children: [

                  SizedBox(
                    height: 260,

                    child: PageView.builder(
                      itemCount:
                      images.length,

                      onPageChanged:
                          (index) {

                        setState(() {
                          currentImage =
                              index;
                        });
                      },

                      itemBuilder:
                          (_, index) {

                        return Padding(
                          padding:
                          const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 12,
                          ),

                          child: Container(
                            padding:
                            const EdgeInsets.all(
                              18,
                            ),

                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F7F7),
                              borderRadius:
                              BorderRadius.circular(24),
                            ),

                            child:
                            Image.network(
                              AppConstants
                                  .imageUrl +
                                  images[
                                  index],

                              fit:
                              BoxFit.contain,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment
                        .center,

                    children:
                    List.generate(
                      images.length,

                          (index) {

                        return AnimatedContainer(
                          duration:
                          const Duration(
                            milliseconds:
                            300,
                          ),

                          margin:
                          const EdgeInsets.symmetric(
                            horizontal:
                            4,
                          ),

                          height: 8,

                          width:
                          currentImage ==
                              index
                              ? 24
                              : 8,

                          decoration:
                          BoxDecoration(
                            color:
                            currentImage ==
                                index
                                ? primaryColor
                                : Colors
                                .grey
                                .shade300,

                            borderRadius:
                            BorderRadius.circular(
                              20,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),

            Padding(
              padding:
              const EdgeInsets.all(18),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  // 🔥 NAME
                  Text(
                    product["name"] ?? "",

                    style:
                    GoogleFonts.poppins(
                      fontSize: 15,

                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 🔥 RATING
                  Row(
                    children: [

                      Container(
                        padding:
                        const EdgeInsets.symmetric(
                          horizontal:
                          10,

                          vertical: 5,
                        ),

                        decoration:
                        BoxDecoration(
                          color:
                          Colors.green,

                          borderRadius:
                          BorderRadius.circular(
                            8,
                          ),
                        ),

                        child: Row(
                          children: [

                            Text(
                              avgRating
                                  .toString(),

                              style:
                              GoogleFonts.poppins(
                                color:
                                Colors.white,

                                fontWeight:
                                FontWeight
                                    .w600,
                              ),
                            ),

                            const SizedBox(
                              width: 3,
                            ),

                            const Icon(
                              Icons.star,
                              size: 14,
                              color:
                              Colors.white,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 10),

                      Text(
                        "$totalReviews Reviews",

                        style:
                        GoogleFonts.poppins(
                          color:
                          Colors.grey,

                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 🔥 PRICE
                  Row(
                    children: [

                      Text(
                        AppConstants.formatPrice(selectedSaleRate),

                        style:
                        GoogleFonts.poppins(
                          fontSize: 28,

                          fontWeight:
                          FontWeight.w700,

                          color:
                          primaryColor,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Text(
                        AppConstants.formatPrice(selectedRate),

                        style:
                        GoogleFonts.poppins(
                          fontSize: 16,

                          decoration:
                          TextDecoration
                              .lineThrough,

                          color:
                          Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // 🔥 STOCK
                  Container(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),

                    decoration:
                    BoxDecoration(
                      color: Colors.green
                          .withOpacity(
                        0.12,
                      ),

                      borderRadius:
                      BorderRadius.circular(
                        30,
                      ),
                    ),

                    child: Text(
                      outOfStock

                          ?

                      "Out Of Stock"

                          :

                      "$selectedStock In Stock",

                      style:
                      GoogleFonts.poppins(
                        color:

                        outOfStock

                            ?

                        Colors.red

                            :

                        Colors.green,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                  ),

                  // 🔥 DELIVERY ESTIMATE
                  if (deliverable && deliveryEstimate != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),

                        decoration: BoxDecoration(
                          color: isExpressDelivery
                              ? Colors.green.shade50
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(30),
                        ),

                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            Icon(
                              isExpressDelivery
                                  ? Icons.bolt
                                  : Icons.local_shipping_outlined,
                              size: 16,
                              color: isExpressDelivery
                                  ? Colors.green.shade700
                                  : Colors.black87,
                            ),

                            const SizedBox(width: 8),

                            Text(
                              deliveryEstimateText ?? "Delivery by $deliveryEstimate",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isExpressDelivery
                                    ? Colors.green.shade700
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // 🔥 VARIANTS
                  if (variants.isNotEmpty)
                    Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                      children: [

                        const SizedBox(
                          height: 28,
                        ),

                        Text(
                          "Variants",

                          style:
                          GoogleFonts.poppins(
                            fontSize:
                            18,

                            fontWeight:
                            FontWeight
                                .w700,
                          ),
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        Wrap(
                          spacing: 10,
                          runSpacing: 10,

                          children:
                          List.generate(
                            variants.length,

                                (index) {

                              final item =
                              variants[
                              index];

                              bool selected =
                                  selectedVariant ==
                                      index;

                              return GestureDetector(

                                onTap: () {

                                  setState(() {

                                    selectedVariant =
                                        index;

                                    selectedRate =
                                        double.parse(
                                          item["rate"]
                                              .toString(),
                                        );

                                    selectedSaleRate =
                                        double.parse(
                                          item["salerate"]
                                              .toString(),
                                        );

                                    selectedDescription =
                                        item[
                                        "product_description"] ??
                                            "";

                                    selectedStock =
                                        int.parse(
                                          item["stock"]
                                              .toString(),
                                        );
                                  });
                                },

                                child: Container(
                                  padding:
                                  const EdgeInsets.symmetric(
                                    horizontal:
                                    18,

                                    vertical:
                                    12,
                                  ),

                                  decoration:
                                  BoxDecoration(
                                    color:
                                    selected
                                        ? primaryColor
                                        : Colors
                                        .white,

                                    borderRadius:
                                    BorderRadius.circular(
                                      14,
                                    ),

                                    border:
                                    Border.all(

                                      color:

                                      outOfStock

                                          ?

                                      Colors.grey

                                          :

                                      primaryColor,

                                    ),
                                  ),

                                  child: Text(
                                    item[
                                    "varient_name"] ??
                                        "",

                                    style:
                                    GoogleFonts.poppins(
                                      color:
                                      selected
                                          ? Colors
                                          .white
                                          : primaryColor,

                                      fontWeight:
                                      FontWeight
                                          .w600,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 30),

                  // 🔥 HIGHLIGHTS
                  if (productHighlights.isNotEmpty) ...[

                    Text(
                      "Highlights",

                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 12),

                    ...productHighlights.map(

                          (line) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),

                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: primaryColor,
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Text(
                                line,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],

                  // 🔥 DESCRIPTION
                  Text(
                    "Description",

                    style:
                    GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Html(
                    data:
                    selectedDescription,
                  ),

                  const SizedBox(height: 30),

                  // 🔥 EXCLUSIVE OFFERS
                  GestureDetector(

                    onTap: () {

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OffersPage(),
                        ),
                      );
                    },

                    child: Container(

                      padding: const EdgeInsets.all(18),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFF0F0F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),

                      child: Row(
                        children: [

                          Container(
                            height: 48,
                            width: 48,

                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),

                            child: Icon(
                              Icons.local_offer_rounded,
                              size: 22,
                              color: primaryColor,
                            ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Text(
                                  "Exclusive Offers",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),

                                const SizedBox(height: 3),

                                Text(
                                  "Save more on every order",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 10),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),

                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(30),
                            ),

                            child: Text(
                              "View",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 26),

                  // 🔥 WRITE REVIEW
                  Text(
                    "Write Review",

                    style:
                    GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: List.generate(
                      5,

                          (index) {

                        return IconButton(

                          onPressed: () {

                            setState(() {
                              userRating =
                                  (index + 1)
                                      .toDouble();
                            });
                          },

                          icon: Icon(
                            Icons.star,

                            color:
                            index <
                                userRating
                                ? Colors.amber
                                : Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),

                  TextField(
                    controller:
                    reviewController,

                    maxLines: 4,

                    decoration:
                    InputDecoration(
                      hintText:
                      "Write review...",

                      border:
                      OutlineInputBorder(
                        borderRadius:
                        BorderRadius.circular(
                          16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    height: 52,

                    child: ElevatedButton(

                      onPressed: () {

                        submitReview();
                      },

                      style:
                      ElevatedButton.styleFrom(
                        backgroundColor:
                        primaryColor,

                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(
                            14,
                          ),
                        ),
                      ),

                      child: Text(
                        "Submit Review",

                        style:
                        GoogleFonts.poppins(
                          color:
                          Colors.white,

                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 🔥 REVIEWS
                  Text(
                    "Ratings & Reviews",

                    style:
                    GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 18),

                  ...List.generate(
                    reviews.length,

                        (index) {

                      final item =
                      reviews[index];

                      return Container(

                        margin:
                        const EdgeInsets.only(
                          bottom: 14,
                        ),

                        padding:
                        const EdgeInsets.all(
                          14,
                        ),

                        decoration:
                        BoxDecoration(
                          color:
                          Colors.white,

                          borderRadius:
                          BorderRadius.circular(
                            18,
                          ),
                        ),

                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                          children: [

                            Row(
                              children: [

                                Container(
                                  padding:
                                  const EdgeInsets.symmetric(
                                    horizontal:
                                    10,

                                    vertical:
                                    5,
                                  ),

                                  decoration:
                                  BoxDecoration(
                                    color:
                                    Colors.green,

                                    borderRadius:
                                    BorderRadius.circular(
                                      8,
                                    ),
                                  ),

                                  child: Row(
                                    children: [

                                      Text(
                                        item[
                                        "rating"]
                                            .toString(),

                                        style:
                                        GoogleFonts.poppins(
                                          color:
                                          Colors
                                              .white,

                                          fontWeight:
                                          FontWeight
                                              .w600,
                                        ),
                                      ),

                                      const SizedBox(
                                        width:
                                        3,
                                      ),

                                      const Icon(
                                        Icons.star,
                                        size:
                                        14,
                                        color:
                                        Colors.white,
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(
                                  width: 10,
                                ),

                                Text(
                                  item["name"] ??
                                      "User",

                                  style:
                                  GoogleFonts.poppins(
                                    fontWeight:
                                    FontWeight
                                        .w600,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                              height: 10,
                            ),

                            Text(
                              item["review"] ??
                                  "",

                              style:
                              GoogleFonts.poppins(
                                fontSize:
                                13,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  if (similarProducts.isNotEmpty) ...[

                    const SizedBox(height: 30),

                    Text(
                      "Similar Products",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      height: 230,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: similarProducts.length,
                        itemBuilder: (_, index) {

                          final item = similarProducts[index];

                          return GestureDetector(

                            onTap: () {

                              Navigator.pushReplacement(
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
                              width: 150,
                              margin: const EdgeInsets.only(right: 12),

                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                              ),

                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(18),
                                    ),
                                    child: Image.network(
                                      AppConstants.imageUrl +
                                          (item["image"] ?? ""),
                                      height: 130,
                                      width: 150,
                                      fit: BoxFit.contain,
                                    ),
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [

                                        Text(
                                          item["name"] ?? "",
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),

                                        const SizedBox(height: 6),

                                        Text(
                                          AppConstants.formatPrice(item["saleprice"] ?? item["rate"]),
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: primaryColor,
                                          ),
                                        ),
                                      ],
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

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}