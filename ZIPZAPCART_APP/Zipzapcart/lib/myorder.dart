import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';
import 'constants.dart';
import 'vieworder.dart';
import 'widgets/shimmer_card.dart';

class MyOrderPage extends StatefulWidget {
  const MyOrderPage({super.key});

  @override
  State<MyOrderPage> createState() =>
      _MyOrderPageState();
}

class _MyOrderPageState
    extends State<MyOrderPage> {

  bool loading = true;

  int userId = 0;

  List orders = [];

  static const Color primaryColor =
  Color(0xFFEF4138);

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

    loadOrders();
  }

  Future<void> loadOrders() async {

    orders =
    await ApiService.getMyOrders(
      userId,
    );

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  Color statusColor(String status) {

    switch (status.toLowerCase().trim()) {

      case "placed":
        return const Color(0xFFE8A317);

      case "accepted":
      case "shipped":
        return const Color(0xFF2F80ED);

      case "on the way":
        return const Color(0xFF8E44AD);

      case "delivered":
        return const Color(0xFF1E9E5A);

      case "cancelled":
        return const Color(0xFFE53935);

      default:
        return Colors.black87;
    }
  }

  IconData statusIcon(String status) {

    switch (status.toLowerCase().trim()) {

      case "placed":
        return Icons.receipt_long_rounded;

      case "accepted":
      case "shipped":
        return Icons.local_shipping_outlined;

      case "on the way":
        return Icons.delivery_dining_rounded;

      case "delivered":
        return Icons.check_circle_rounded;

      case "cancelled":
        return Icons.cancel_rounded;

      default:
        return Icons.receipt_long_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      const Color(0xFFF8F8FA),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,

        title: Text(
          "My Orders",

          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: Colors.black87,
          ),
        ),

        centerTitle: true,
      ),

      body: loading

          ? _loadingSkeleton()

          : orders.isEmpty

          ? _emptyState()

          : RefreshIndicator(

        color: primaryColor,

        onRefresh: () async {

          await loadOrders();
        },

        child: ListView.builder(

          padding:
          const EdgeInsets.all(16),

          itemCount: orders.length,

          itemBuilder: (_, index) {

            return orderCard(orders[index]);
          },
        ),
      ),
    );
  }

  Widget _loadingSkeleton() {

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (_, i) => const Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: ShimmerBlock(
          width: double.infinity,
          height: 168,
          radius: 22,
        ),
      ),
    );
  }

  Widget _emptyState() {

    return Center(
      child: Padding(
        padding:
        const EdgeInsets.symmetric(
          horizontal: 28,
        ),

        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [

            Lottie.asset(
              "assets/images/nodata.json",
              height: 230,
            ),

            const SizedBox(height: 20),

            Text(
              "No Orders Yet",

              textAlign:
              TextAlign.center,

              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight:
                FontWeight.w800,
                color:
                const Color(0xFF111111),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "Looks like you haven't placed any orders yet.\nStart shopping to see your orders here.",

              textAlign:
              TextAlign.center,

              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.black54,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 26),

            SizedBox(
              width: double.infinity,
              height: 52,

              child: ElevatedButton(

                onPressed: () {

                  Navigator.popUntil(
                    context,
                    (route) => route.isFirst,
                  );
                },

                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  primaryColor,

                  foregroundColor:
                  Colors.white,

                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(
                      14,
                    ),
                  ),

                  elevation: 0,
                ),

                child: Text(
                  "Start Shopping",

                  style: GoogleFonts.poppins(
                    fontWeight:
                    FontWeight.w700,

                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget orderCard(Map order) {

    final String status =
    (order["order_status"] ?? "").toString();

    final List previewItems =
    order["preview_items"] ?? [];

    final int itemsCount =
    int.tryParse(
      order["items_count"].toString(),
    ) ?? previewItems.length;

    final int extraCount =
    itemsCount - previewItems.length;

    final String firstName =
    previewItems.isNotEmpty
        ? (previewItems.first["name"] ?? "").toString()
        : "";

    return GestureDetector(

      onTap: () {

        Navigator.push(
          context,

          MaterialPageRoute(
            builder: (_) =>
                ViewOrderPage(
                  orderId:
                  int.parse(
                    order["id"]
                        .toString(),
                  ),
                ),
          ),
        );
      },

      child: Container(

        margin:
        const EdgeInsets.only(
          bottom: 16,
        ),

        padding:
        const EdgeInsets.all(
          16,
        ),

        decoration:
        BoxDecoration(
          color: Colors.white,

          borderRadius:
          BorderRadius.circular(
            22,
          ),

          border: Border.all(
            color: const Color(0xFFF0F0F0),
          ),

          boxShadow: [

            BoxShadow(
              color:
              Colors.black
                  .withOpacity(
                0.04,
              ),

              blurRadius: 16,

              offset:
              const Offset(
                0,
                6,
              ),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🔥 PRODUCT PREVIEW ROW
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                SizedBox(
                  height: 64,
                  width: previewItems.isEmpty
                      ? 64
                      : (previewItems.length * 48.0) + 16,

                  child: Stack(
                    children: List.generate(
                      previewItems.isEmpty ? 1 : previewItems.length,
                          (i) {

                        final img = previewItems.isEmpty
                            ? ""
                            : (previewItems[i]["image"] ?? "").toString();

                        return Positioned(
                          left: i * 48.0,

                          child: Container(
                            height: 64,
                            width: 64,

                            padding: const EdgeInsets.all(8),

                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F7F7),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                            ),

                            child: img.isEmpty
                                ? Icon(
                              Icons.shopping_bag_outlined,
                              color: Colors.grey.shade400,
                              size: 22,
                            )
                                : Image.network(
                              AppConstants.imageUrl + img,
                              fit: BoxFit.contain,
                              errorBuilder: (_, e, s) => Icon(
                                Icons.shopping_bag_outlined,
                                color: Colors.grey.shade400,
                                size: 22,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        firstName.isEmpty
                            ? "Order ${order["order_no"] ?? ""}"
                            : firstName,

                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,

                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                      ),

                      const SizedBox(height: 5),

                      if (extraCount > 0)
                        Text(
                          "+$extraCount more item${extraCount > 1 ? 's' : ''}",

                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade500,
                          ),
                        ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),

                  decoration: BoxDecoration(
                    color: statusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),

                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusIcon(status),
                        size: 12,
                        color: statusColor(status),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        status,

                        style: GoogleFonts.poppins(
                          color: statusColor(status),
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Container(
              height: 1,
              color: const Color(0xFFF2F2F2),
            ),

            const SizedBox(height: 14),

            Row(
              children: [

                Expanded(
                  child: Text(
                    order["order_no"] ?? "",

                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),

                Text(
                  AppConstants.formatPrice(order["total_amount"]),

                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: primaryColor,
                  ),
                ),

                const SizedBox(width: 6),

                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
