import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'home.dart';
class OrderPlacedPage extends StatefulWidget {
  const OrderPlacedPage({super.key});

  @override
  State<OrderPlacedPage> createState() => _OrderPlacedPageState();
}

class _OrderPlacedPageState extends State<OrderPlacedPage> {

  @override
  void initState() {
    super.initState();
    clearCart();
  }

  Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt("user_id") ?? 0;

    // 🔥 CLEAR SERVER CART
    await ApiService.clearCart(userId);

    // 🔥 CLEAR LOCAL (if you store)
    // optional: prefs.remove("cart");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDF6907),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 220,
                  width: 220,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Lottie.asset(
                      "assets/tick.json",
                      repeat: false,
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                const Text(
                  "Order Placed Successfully",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Your grocery order has been placed.\nIt will reach you soon.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 28),

                GestureDetector(
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HomePage(),
                      ),
                          (route) => false,
                    );
                  },
                  child: Container(
                    height: 56,
                    width: 220,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Center(
                      child: Text(
                        "Back to Home",
                        style: TextStyle(
                          color: Color(0xFFCC6D0D),
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}