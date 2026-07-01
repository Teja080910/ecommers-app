import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import 'api_service.dart';

class ViewOrderPage extends StatefulWidget {
  final int orderId;

  const ViewOrderPage({
    super.key,
    required this.orderId,
  });

  @override
  State<ViewOrderPage> createState() => _ViewOrderPageState();
}

class _ViewOrderPageState extends State<ViewOrderPage> {
  Map? order;

  List items = [];

  bool loading = true;

  bool delivering = false;

  final otp = TextEditingController();

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    otp.dispose();
    super.dispose();
  }

  Future load() async {
    final r = await ApiService.viewOrder(
      widget.orderId,
    );

    if (!mounted) return;

    setState(() {
      order = r["order"];

      items = r["items"];

      loading = false;
    });
  }

  Future deliver() async {
    if (otp.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            "Enter Delivery OTP",
          ),
        ),
      );

      return;
    }

    setState(() {
      delivering = true;
    });

    final r = await ApiService.deliverOrder(
      widget.orderId,
      otp.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      delivering = false;
    });

    if (r["status"] == true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            "Order Delivered Successfully",
          ),
        ),
      );

      Navigator.pop(
        context,
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            r["message"] ?? "Invalid OTP",
          ),
        ),
      );
    }
  }

  Future callCustomer() async {
    final phone = order?["mobile"];

    await launchUrl(
      Uri.parse(
        "tel:$phone",
      ),
    );
  }

  Future openMap() async {
    final lat = order?["latitude"];

    final lng = order?["longitude"];

    await launchUrl(
      Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=$lat,$lng",
      ),
      mode: LaunchMode.externalApplication,
    );
  }

  Widget shimmerBox({
    double h = 20,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.white,
      child: Container(
        height: h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            18,
          ),
        ),
      ),
    );
  }

  Widget shimmerScreen() {
    return Padding(
      padding: const EdgeInsets.all(
        20,
      ),
      child: Column(
        children: [
          shimmerBox(
            h: 260,
          ),
          const SizedBox(
            height: 20,
          ),
          shimmerBox(
            h: 130,
          ),
          const SizedBox(
            height: 20,
          ),
          shimmerBox(
            h: 130,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(
      context,
      ) {
    return Scaffold(
      backgroundColor: const Color(
        0xffF6F7FB,
      ),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          "View Order",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
      ),
      body: loading
          ? shimmerScreen()
          : SingleChildScrollView(
        padding: const EdgeInsets.all(
          18,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(
                24,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(
                      0xff6A5AF9,
                    ),
                    Color(
                      0xff836FFF,
                    ),
                  ],
                ),
                borderRadius: BorderRadius.circular(
                  32,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    order!["order_no"],
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(
                    height: 22,
                  ),
                  info(
                    Icons.person,
                    order!["full_name"],
                  ),
                  info(
                    Icons.location_on,
                    "${order!["address"]}, ${order!["city"]}",
                  ),
                  info(
                    Icons.call,
                    order!["mobile"],
                  ),
                  const SizedBox(
                    height: 22,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: actionButton(
                          "Call",
                          Icons.call,
                          Colors.black,
                          callCustomer,
                        ),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        child: actionButton(
                          "Direction",
                          Icons.navigation,
                          Colors.black,
                          openMap,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 22,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Products",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            ...items.map(
                  (e) => Container(
                margin: const EdgeInsets.only(
                  bottom: 14,
                ),
                padding: const EdgeInsets.all(
                  20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    24,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.deepPurple.withOpacity(
                        .1,
                      ),
                      child: const Icon(
                        Icons.shopping_bag,
                      ),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e["product_name"],
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            "Qty ${e["quantity"]}",
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "₹${e["total"]}",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 18,
            ),
            Container(
              padding: const EdgeInsets.all(
                20,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  28,
                ),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: otp,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.lock,
                      ),
                      labelText: "Enter Delivery OTP",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          20,
                        ),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 18,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xff000000,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            22,
                          ),
                        ),
                      ),
                      onPressed: delivering ? null : deliver,
                      child: delivering
                          ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                          : Text(
                        "MARK DELIVERED",
                        style: GoogleFonts.poppins(
                          color:
                          Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
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

  Widget info(
      IconData i,
      String t,
      ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 16,
      ),
      child: Row(
        children: [
          Icon(
            i,
            color: Colors.white,
          ),
          const SizedBox(
            width: 12,
          ),
          Expanded(
            child: Text(
              t,
              style: GoogleFonts.poppins(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget actionButton(
      String t,
      IconData i,
      Color c,
      VoidCallback f,
      ) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: c,

        foregroundColor: Colors.white, // ← Makes icon + text white

        minimumSize: const Size(
          0,
          56,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            18,
          ),
        ),
      ),

      onPressed: f,

      icon: Icon(
        i,
        color: Colors.white,
      ),

      label: Text(
        t,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    }
}
