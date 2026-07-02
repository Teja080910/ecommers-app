import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'api_service.dart';

class OffersPage extends StatefulWidget {

  const OffersPage({super.key});

  @override
  State<OffersPage> createState() => _OffersPageState();
}

class _OffersPageState extends State<OffersPage> {

  List offers = [];

  bool loading = true;

  final Color primaryColor = const Color(0xFFEF4138);

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {

    offers = await ApiService.getOffers();

    loading = false;

    setState(() {});
  }

  String discountText(Map item) {

    if (item["discount_type"] == "flat") {
      return "₹${item["discount_amount"]} OFF";
    }

    return "${item["discount_amount"]}% OFF";
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF5F5F5),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(
          "Offers & Discounts",
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : offers.isEmpty
          ? Center(
        child: Text(
          "No offers available right now",
          style: GoogleFonts.poppins(color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: offers.length,
        itemBuilder: (_, index) {

          final item = offers[index];

          return Container(

            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: primaryColor.withOpacity(0.2),
                style: BorderStyle.solid,
              ),
            ),

            child: Row(
              children: [

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        discountText(item),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "Code: ${item["code"]}",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        "Min order ₹${item["min_amount"]}",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                ElevatedButton(

                  onPressed: () {
                    Navigator.pop(context, item["code"]);
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  child: const Text("Apply"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
