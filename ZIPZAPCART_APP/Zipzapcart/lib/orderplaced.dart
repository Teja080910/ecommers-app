import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';
import 'constants.dart';
import 'home.dart';
import 'vieworder.dart';
import 'widgets/shimmer_card.dart';

class OrderPlacedPage extends StatefulWidget {

  final int orderId;

  const OrderPlacedPage({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderPlacedPage> createState() => _OrderPlacedPageState();
}

class _OrderPlacedPageState extends State<OrderPlacedPage> {

  static const Color primaryColor = Color(0xFFEF4138);

  bool loading = true;

  Map order = {};

  List items = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {

    await clearCart();

    await loadOrder();
  }

  Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt("user_id") ?? 0;

    await ApiService.clearCart(userId);
  }

  Future<void> loadOrder() async {

    final data = await ApiService.viewOrder(widget.orderId);

    if (data["status"] == true) {
      order = data["order"] ?? {};
      items = data["items"] ?? [];
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FA),

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),

          child: Column(
            children: [

              // 🔥 HERO SUCCESS PANEL
              Container(
                width: double.infinity,

                padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),

                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [primaryColor, Color(0xFFD8352C)],
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(36),
                  ),
                ),

                child: Column(
                  children: [

                    Container(
                      height: 170,
                      width: 170,

                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.14),
                        shape: BoxShape.circle,
                      ),

                      child: Center(
                        child: Container(
                          height: 130,
                          width: 130,

                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),

                          child: Center(
                            child: Lottie.asset(
                              "assets/tick.json",
                              repeat: false,
                              width: 90,
                              height: 90,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    Text(
                      "Order Placed!",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Thank you for shopping with us.\nYour order is being prepared.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 13,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    if (!loading && (order["order_no"] ?? "").toString().isNotEmpty) ...[

                      const SizedBox(height: 18),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),

                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.16),
                          borderRadius: BorderRadius.circular(30),
                        ),

                        child: Text(
                          "Order No: ${order["order_no"]}",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 🔥 ORDER SUMMARY
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),

                child: loading
                    ? const ShimmerBlock(
                  width: double.infinity,
                  height: 160,
                  radius: 22,
                )
                    : _summaryCard(),
              ),

              const SizedBox(height: 16),

              // Hidden from the customer — this OTP is for the delivery partner only.
              if (false)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: _otpCard(),
                ),

              const SizedBox(height: 26),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),

                child: Column(
                  children: [

                    SizedBox(
                      width: double.infinity,
                      height: 54,

                      child: ElevatedButton(
                        onPressed: () {

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ViewOrderPage(
                                orderId: widget.orderId,
                              ),
                            ),
                          );
                        },

                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),

                        child: Text(
                          "Track Order",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: 54,

                      child: OutlinedButton(
                        onPressed: () {

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HomePage(),
                            ),
                                (route) => false,
                          );
                        },

                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black87,
                          side: const BorderSide(color: Color(0xFFE5E5E5)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),

                        child: Text(
                          "Continue Shopping",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryCard() {

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            "Items Ordered",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 14),

          ...List.generate(items.length, (i) {

            final item = items[i];

            return Padding(
              padding: EdgeInsets.only(
                bottom: i == items.length - 1 ? 0 : 12,
              ),

              child: Row(
                children: [

                  Container(
                    height: 46,
                    width: 46,

                    padding: const EdgeInsets.all(6),

                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: Image.network(
                      AppConstants.imageUrl + (item["image"] ?? ""),
                      fit: BoxFit.contain,
                      errorBuilder: (_, e, s) => Icon(
                        Icons.shopping_bag_outlined,
                        color: Colors.grey.shade400,
                        size: 18,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      "${item["name"] ?? ""}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  Text(
                    "x${item["quantity"]}",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Text(
                    AppConstants.formatPrice(item["total"]),
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 14),

          Container(height: 1, color: const Color(0xFFF2F2F2)),

          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Text(
                "Total Paid",
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),

              Text(
                AppConstants.formatPrice(order["total_amount"]),
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _otpCard() {

    final otp = order["delivery_otp"].toString();

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: primaryColor.withOpacity(0.18)),
      ),

      child: Row(
        children: [

          Icon(Icons.verified_user_outlined, color: primaryColor, size: 22),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Delivery OTP",
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  "Share this with your delivery partner",
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          Text(
            otp,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: primaryColor,
              letterSpacing: 3,
            ),
          ),
        ],
      ),
    );
  }
}
