import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'about.dart';
import 'address.dart';
import 'api_service.dart';
import 'cart.dart';
import 'category.dart';
import 'constants.dart';
import 'help.dart';
import 'language.dart';
import 'login.dart';
import 'myorder.dart';
import 'notification.dart';
import 'offers.dart';
import 'posts.dart';
import 'profile.dart';
import 'subcategory.dart';
import 'view_product.dart';
import 'search.dart';
import 'topdeals.dart';
import 'translator_service.dart';
import 'wallet.dart';
import 'widgets/shimmer_card.dart';
import 'wishlist.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();

}

class _HomePageState extends State<HomePage> {
  static const Color themeRed =
  Color(0xFFEF4138);
  final ScrollController _portraitScroll = ScrollController();
  final ScrollController _landscapeScroll = ScrollController();

  static const double _heroSectionHeight = 260;
  static const double _portraitCardWidth = 150;
  static const double _landscapeCardHeight = 122;
  static const double _landscapeCardWidth = 250;
  static const double _bannerCardGap = 12;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int selectedBottom = 0;

  bool loading = true;

  int userId = 0;
  int cartCount = 0;
  Map? deliveryAddress;
  String userName = "";
  double walletBalance = 0;

  final Set<String> wishlistedIds = {};

  List banners = [];
  List portraitBanners = [];
  List categories = [];
  List topDeals = [];
  List homeCategories = [];
  List wishlistProducts = [];
  List offers = [];

  static const List<Color> _categoryTileColors = [
    Color(0xFFF3E8FF),
    Color(0xFFFFE1E9),
    Color(0xFFFFF4D6),
    Color(0xFFE3F2FD),
    Color(0xFFE8F5E9),
    Color(0xFFFFE9DC),
  ];

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

  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();

    loadData();

    _bannerTimer = Timer.periodic(
      const Duration(seconds: 3),
          (timer) {

        if (!mounted) {
          return;
        }

        _autoScrollBannerRow(
          _portraitScroll,
          portraitBanners.length,
          _portraitCardWidth + _bannerCardGap,
        );

        _autoScrollBannerRow(
          _landscapeScroll,
          banners.length,
          _landscapeCardWidth + _bannerCardGap,
        );
      },
    );
  }

  void _autoScrollBannerRow(
      ScrollController controller,
      int itemCount,
      double cardExtent,
      ) {

    if (!controller.hasClients || itemCount == 0) {
      return;
    }

    final maxScroll = controller.position.maxScrollExtent;

    double next = controller.offset + cardExtent;

    if (next > maxScroll) {
      next = 0;
    }

    controller.animateTo(
      next,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _portraitScroll.dispose();
    _landscapeScroll.dispose();
    super.dispose();
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

  // 🔥 SECTION HEADER (title + optional "View All" pill)
  Widget sectionHeader(
      String title, {
        VoidCallback? onViewAll,
      }) {

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [

          Row(
            children: [
              Container(
                height: 18,
                width: 4,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              t(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          if (onViewAll != null)
            GestureDetector(
              onTap: onViewAll,

              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),

                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    t(
                      "View All",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 10,
                      color: primaryColor,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 🔥 OFFER COUPON CARD
  Widget offerCouponCard(Map offer) {

    final String code = (offer["code"] ?? "").toString();

    final String discountText =
    offer["discount_type"] == "flat"
        ? "${AppConstants.formatPrice(offer["discount_amount"])} OFF"
        : "${offer["discount_amount"]}% OFF";

    return GestureDetector(

      onTap: () async {

        await Clipboard.setData(ClipboardData(text: code));

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Code \"$code\" copied"),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },

      child: Container(
        width: 210,
        margin: const EdgeInsets.only(right: 14),
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: primaryColor.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [
                Icon(Icons.sell_rounded, size: 16, color: primaryColor),
                const SizedBox(width: 6),
                Expanded(
                  child: t(
                    discountText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 9,
              ),

              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: primaryColor.withOpacity(0.3),
                  style: BorderStyle.solid,
                ),
              ),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      code,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Icon(Icons.copy_rounded, size: 13, color: primaryColor),
                ],
              ),
            ),

            const SizedBox(height: 8),

            t(
              "Min order ${AppConstants.formatPrice(offer["min_amount"])}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 10.5,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 WALLET PILL (dynamic balance, tap opens Wallet / Login)
  Widget _walletPill() {

    return GestureDetector(
      onTap: () {

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => userId == 0
                ? const LoginPage()
                : const WalletPage(),
          ),
        );
      },

      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),

        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
        ),

        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_balance_wallet_rounded,
              size: 15,
              color: primaryColor,
            ),
            const SizedBox(width: 6),
            t(
              AppConstants.formatPrice(walletBalance),
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {

    return ListTile(
      onTap: onTap,

      leading: Container(
        height: 38,
        width: 38,

        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),

        child: Icon(icon, size: 18, color: primaryColor),
      ),

      title: t(
        title,
        style: GoogleFonts.poppins(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),

      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 12,
        color: Colors.black26,
      ),
    );
  }

  Widget _buildDrawer() {

    return Drawer(
      backgroundColor: Colors.white,

      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,

          children: [

            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(22, 26, 22, 26),

              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryColor, primaryColor.withOpacity(0.85)],
                ),
              ),

              child: GestureDetector(

                onTap: () {

                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => userId == 0
                          ? const LoginPage()
                          : const ProfilePage(),
                    ),
                  );
                },

                child: Row(
                  children: [

                    Container(
                      height: 54,
                      width: 54,

                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),

                      child: Icon(
                        Icons.person,
                        size: 28,
                        color: primaryColor,
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          t(
                            userId == 0
                                ? "Login / Sign up"
                                : (userName.isNotEmpty
                                    ? userName
                                    : "My Account"),

                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,

                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 4),

                          t(
                            userId == 0
                                ? "Tap to access your account"
                                : "View & edit profile",

                            style: GoogleFonts.poppins(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            _drawerItem(
              icon: Icons.shopping_bag_outlined,
              title: "My Orders",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyOrderPage()),
                );
              },
            ),

            _drawerItem(
              icon: Icons.favorite_border,
              title: "Wishlist",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WishlistPage()),
                );
              },
            ),

            _drawerItem(
              icon: Icons.account_balance_wallet_outlined,
              title: "My Wallet",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        userId == 0 ? const LoginPage() : const WalletPage(),
                  ),
                );
              },
            ),

            _drawerItem(
              icon: Icons.notifications_none_rounded,
              title: "Notifications",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationPage()),
                );
              },
            ),

            _drawerItem(
              icon: Icons.language_rounded,
              title: "Language",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LanguagePage()),
                );
              },
            ),

            _drawerItem(
              icon: Icons.support_agent_rounded,
              title: "Help & Support",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HelpPage()),
                );
              },
            ),

            _drawerItem(
              icon: Icons.info_outline_rounded,
              title: "About Us",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutPage()),
                );
              },
            ),

            const SizedBox(height: 10),

            if (userId != 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),

                child: GestureDetector(

                  onTap: () async {

                    final prefs = await SharedPreferences.getInstance();
                    await prefs.clear();

                    if (!mounted) return;

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                    );
                  },

                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),

                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F0),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFFD8D4)),
                    ),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.logout_rounded,
                          size: 16,
                          color: Color(0xFFE53935),
                        ),
                        const SizedBox(width: 8),
                        t(
                          "Logout",
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFE53935),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> loadData() async {

    final prefs = await SharedPreferences.getInstance();

    userId = prefs.getInt("user_id") ?? 0;
    userName = prefs.getString("name") ?? "";

    banners = await ApiService.getBanners();

    portraitBanners = await ApiService.getPortraitBanners();

    categories =
    await ApiService.getCategories();

    topDeals =
    await ApiService.getTopDeals();

    homeCategories =
    await ApiService.getHomeCategoryProducts();

    offers = await ApiService.getOffers();

    await loadDeliveryAddress();

    await loadCartCount();

    await loadWallet();

    await loadWishlist();

    setState(() {
      loading = false;
    });
  }

  Future<void> loadWishlist() async {

    if (userId == 0) {
      return;
    }

    wishlistProducts = await ApiService.getWishlist(userId);

    wishlistedIds
      ..clear()
      ..addAll(
        wishlistProducts.map((e) => e["id"].toString()),
      );
  }

  Future<void> loadWallet() async {

    if (userId == 0) {
      return;
    }

    final data = await ApiService.getWallet();

    if (data["status"] == true) {
      walletBalance =
          double.tryParse(data["wallet_balance"].toString()) ?? 0;
    }
  }

  Future<void> loadCartCount() async {

    if (userId == 0) {
      return;
    }

    final items = await ApiService.getCart(userId);

    cartCount = items.length;
  }

  Future<void> openCart() async {

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CartPage(),
      ),
    );

    await loadCartCount();

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> loadDeliveryAddress() async {

    if (userId == 0) {
      return;
    }

    final data = await ApiService.getDefaultAddress(userId);

    if (data["status"] == true && data["address"] != null) {

      deliveryAddress = data["address"];
    }
  }

  Future<void> openLocationPicker() async {

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddressPage(),
      ),
    );

    await loadDeliveryAddress();

    if (mounted) {
      setState(() {});
    }
  }

  // 🔥 PORTRAIT HERO CAROUSEL (top section, local bundled assets)
  Widget _portraitCarousel() {

    if (portraitBanners.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: _heroSectionHeight,

      child: ListView.builder(
        controller: _portraitScroll,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),

        itemCount: portraitBanners.length,

        itemBuilder: (_, i) {

          return Container(
            width: _portraitCardWidth,
            margin: EdgeInsets.only(
              right: i == portraitBanners.length - 1
                  ? 0
                  : _bannerCardGap,
            ),

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),

            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),

              child: Image.network(
                AppConstants.imageUrl +
                    (portraitBanners[i]["image"] ?? ""),
                width: _portraitCardWidth,
                height: _heroSectionHeight,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  // 🔥 LANDSCAPE AD CAROUSEL (right column)
  Widget _landscapeCarousel() {

    if (banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: _landscapeCardHeight,

      child: ListView.builder(
        controller: _landscapeScroll,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),

        itemCount: banners.length,

        itemBuilder: (_, i) {

          return Container(
            width: _landscapeCardWidth,
            margin: EdgeInsets.only(
              right: i == banners.length - 1 ? 0 : _bannerCardGap,
            ),

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),

            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),

              child: Image.network(
                AppConstants.imageUrl + (banners[i]["image"] ?? ""),
                width: _landscapeCardWidth,
                height: _landscapeCardHeight,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget topDealLandscapeCard(Map item) {

    final rate = double.tryParse(item["rate"].toString()) ?? 0;
    final saleprice = double.tryParse(item["saleprice"].toString()) ?? 0;
    final hasDiscount = rate > saleprice && rate > 0;

    final discountPercent = hasDiscount
        ? (((rate - saleprice) / rate) * 100).round()
        : 0;

    final stock = int.tryParse(item["stock"]?.toString() ?? "");
    final lowStock = stock != null && stock > 0 && stock <= 5;

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
        width: 264,
        margin: const EdgeInsets.only(right: 14),
        padding: const EdgeInsets.all(12),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF0F0F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Stack(
              clipBehavior: Clip.none,
              children: [

                Container(
                  height: 100,
                  width: 100,
                  padding: const EdgeInsets.all(10),

                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFF9F9F9), Color(0xFFEFEFEF)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),

                  child: Image.network(
                    AppConstants.imageUrl + (item["image"] ?? ""),
                    fit: BoxFit.contain,
                  ),
                ),

                if (hasDiscount)
                  Positioned(
                    top: -4,
                    left: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 4,
                      ),

                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.35),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),

                      child: Text(
                        "$discountPercent% OFF",
                        style: GoogleFonts.poppins(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        size: 13,
                        color: primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "TOP DEAL",
                        style: GoogleFonts.poppins(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Text(
                    item["name"] ?? "",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      height: 1.25,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.end,
                    spacing: 6,
                    runSpacing: 2,
                    children: [

                      Text(
                        AppConstants.formatPrice(saleprice),
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: primaryColor,
                        ),
                      ),

                      if (hasDiscount) ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            AppConstants.formatPrice(rate),
                            style: GoogleFonts.poppins(
                              fontSize: 11.5,
                              decoration: TextDecoration.lineThrough,
                              decorationColor: Colors.grey.shade400,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            "$discountPercent% off",
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  if (lowStock) ...[
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.orange.shade700,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Only $stock left",
                          style: GoogleFonts.poppins(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange.shade800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget productCard(Map item) {

    final id = item["id"].toString();

    final rate = double.tryParse(item["rate"].toString()) ?? 0;
    final saleprice = double.tryParse(item["saleprice"].toString()) ?? 0;
    final hasDiscount = rate > saleprice && rate > 0;

    final discountPercent = hasDiscount
        ? (((rate - saleprice) / rate) * 100).round()
        : 0;

    final isWishlisted = wishlistedIds.contains(id);
    final hasVariants = item["hasvarients"] == "yes";

    final stock = int.tryParse(item["stock"]?.toString() ?? "");
    final lowStock = stock != null && stock > 0 && stock <= 5;

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
          BorderRadius.circular(22),

          border: Border.all(color: const Color(0xFFF0F0F0)),

          boxShadow: [
            BoxShadow(
              color:
              Colors.black.withOpacity(0.06),

              blurRadius: 20,

              offset: const Offset(0, 8),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            Stack(
              clipBehavior: Clip.none,
              children: [

                Container(
                  height: 150,
                  width: double.infinity,

                  padding:
                  const EdgeInsets.all(18),

                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFF9F9F9), Color(0xFFEFEFEF)],
                    ),

                    borderRadius:
                    const BorderRadius.vertical(
                      top: Radius.circular(22),
                    ),
                  ),

                  child: Image.network(
                    AppConstants.imageUrl +
                        item["image"],

                    fit: BoxFit.contain,
                  ),
                ),

                if (hasDiscount)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),

                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.35),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),

                      child: Text(
                        "$discountPercent% OFF",
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(

                    onTap: () async {

                      setState(() {
                        if (isWishlisted) {
                          wishlistedIds.remove(id);
                          wishlistProducts.removeWhere(
                                (e) => e["id"].toString() == id,
                          );
                        } else {
                          wishlistedIds.add(id);
                          wishlistProducts.add(item);
                        }
                      });

                      if (userId != 0) {
                        await ApiService.toggleWishlist(
                          userId,
                          int.parse(id),
                        );
                      }
                    },

                    child: Container(
                      padding: const EdgeInsets.all(6),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.10),
                            blurRadius: 6,
                          ),
                        ],
                      ),

                      child: Icon(
                        isWishlisted
                            ? Icons.favorite
                            : Icons.favorite_border,

                        size: 15,

                        color: isWishlisted
                            ? primaryColor
                            : Colors.grey.shade400,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  bottom: -14,
                  right: 10,
                  child: GestureDetector(

                    onTap: () async {

                      if (hasVariants) {

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ViewProductPage(
                              productId: int.parse(id),
                            ),
                          ),
                        );

                        return;
                      }

                      if (userId != 0) {
                        await ApiService.addToCart(
                          userId,
                          int.parse(id),
                          0,
                        );
                      }
                    },

                    child: Container(
                      padding: const EdgeInsets.all(8),

                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),

                      child: const Icon(
                        Icons.add,
                        size: 17,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding:
              const EdgeInsets.fromLTRB(14, 18, 14, 14),

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
                      fontSize: 13.5,
                      fontWeight:
                      FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Wrap(

                    crossAxisAlignment:
                    WrapCrossAlignment.end,

                    spacing: 6,
                    runSpacing: 2,

                    children:[

                      t(

                        AppConstants.formatPrice(saleprice),

                        maxLines:1,

                        overflow:
                        TextOverflow.ellipsis,

                        style:
                        GoogleFonts.poppins(

                          fontSize:16,

                          fontWeight:
                          FontWeight.w800,

                          color:
                          primaryColor,

                        ),

                      ),

                      if (hasDiscount) ...[

                        Padding(
                          padding: const EdgeInsets.only(bottom: 1.5),
                          child: t(

                            AppConstants.formatPrice(rate),

                            maxLines:1,

                            overflow:
                            TextOverflow.ellipsis,

                            style:
                            GoogleFonts.poppins(

                              fontSize:11.5,

                              decoration:
                              TextDecoration.lineThrough,

                              decorationColor: Colors.grey.shade400,

                              color:
                              Colors.grey.shade400,

                            ),

                          ),
                        ),

                        t(
                          "$discountPercent% off",

                          maxLines: 1,

                          style: GoogleFonts.poppins(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                      ],

                    ],

                  ),

                  if (lowStock) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.orange.shade700,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        t(
                          "Only $stock left",
                          style: GoogleFonts.poppins(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange.shade800,
                          ),
                        ),
                      ],
                    ),
                  ],
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

      key: _scaffoldKey,

      drawer: _buildDrawer(),

      backgroundColor:
      const Color(
        0xFFF8F8FA,
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

          ? SafeArea(
        child: SingleChildScrollView(

          physics: const NeverScrollableScrollPhysics(),

          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const ShimmerBlock(width: double.infinity, height: 44, radius: 16),

              const SizedBox(height: 16),

              const ShimmerBlock(width: double.infinity, height: 58, radius: 22),

              const SizedBox(height: 22),

              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 6,
                  itemBuilder: (_, i) => const ShimmerBlock(width: 74, height: 100, radius: 20),
                ),
              ),

              const SizedBox(height: 10),

              const ShimmerBlock(width: double.infinity, height: 220, radius: 20),

              const SizedBox(height: 10),

              SizedBox(
                height: 250,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  itemBuilder: (_, i) => const ShimmerProductCard(),
                ),
              ),
            ],
          ),
        ),
      )
          : SafeArea(
        child: RefreshIndicator(

          color: primaryColor,

          onRefresh: loadData,

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
                  crossAxisAlignment: CrossAxisAlignment.center,

                  children: [

                    GestureDetector(

                      onTap: () {
                        _scaffoldKey.currentState?.openDrawer();
                      },

                      child: Container(
                        height: 44,
                        width: 44,

                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F7F7),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFF0F0F0),
                          ),
                        ),

                        child: const Icon(
                          Icons.menu_rounded,
                          size: 20,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Image.asset(
                            "assets/images/logo.png",
                            height: 32,
                          ),
                        ),
                      ),
                    ),

                    if (userId != 0) ...[
                      _walletPill(),
                      const SizedBox(width: 10),
                    ],

                    GestureDetector(

                      onTap: openCart,

                      child: Stack(
                        clipBehavior: Clip.none,

                        children: [

                          Container(
                            height: 46,
                            width: 46,

                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F7F7),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFF0F0F0),
                              ),
                            ),

                            child: Center(
                              child: SvgPicture.asset(
                                "assets/icons/cart.svg",

                                height: 20,
                                width: 20,

                                colorFilter:
                                ColorFilter.mode(
                                  primaryColor,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),

                          if (cartCount > 0)
                            Positioned(
                              top: -4,
                              right: -4,
                              child: Container(
                                padding: const EdgeInsets.all(4),

                                constraints: const BoxConstraints(
                                  minWidth: 20,
                                  minHeight: 20,
                                ),

                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),

                                child: Center(
                                  child: Text(
                                    cartCount > 9 ? "9+" : "$cartCount",

                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      height: 1,
                                    ),
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

              // 🔥 SELECT LOCATION
              Padding(
                padding:
                const EdgeInsets.fromLTRB(18, 0, 18, 12),

                child: GestureDetector(

                  onTap: openLocationPicker,

                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFF0F0F0)),
                    ),

                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        Icon(
                          Icons.location_on,
                          size: 15,
                          color: primaryColor,
                        ),

                        const SizedBox(width: 6),

                        Flexible(
                          child: t(
                            deliveryAddress != null
                                ? "Deliver to: ${deliveryAddress!["city"] ?? ""} ${deliveryAddress!["pincode"] ?? ""}"
                                : "Select Location",

                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,

                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),

                        const SizedBox(width: 4),

                        Icon(
                          Icons.keyboard_arrow_down,
                          size: 16,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
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
                        size: 20,
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

              sectionHeader(
                "Shop By Category",
                onViewAll: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CategoryPage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              SizedBox(
                height: 104,

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

                    final tileColor = _categoryTileColors[
                        index % _categoryTileColors.length];

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
                        width: 72,

                        margin:
                        const EdgeInsets.only(
                          right: 14,
                        ),

                        child: Column(
                          children: [

                            Container(
                              height: 60,
                              width: 60,

                              padding: const EdgeInsets.all(12),

                              decoration:
                              BoxDecoration(
                                color: tileColor,
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
                              height: 8,
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
                                fontSize: 11.5,

                                fontWeight:
                                FontWeight
                                    .w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 🔥 PORTRAIT CAROUSEL (top)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: _portraitCarousel(),
              ),

              const SizedBox(height: 14),

              // 🔥 LANDSCAPE CAROUSEL (below)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: _landscapeCarousel(),
              ),

              const SizedBox(height: 26),

              // 🔥 OFFERS FOR YOU
              if (offers.isNotEmpty) ...[

                sectionHeader(
                  "Offers For You",
                  onViewAll: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const OffersPage(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                SizedBox(
                  height: 128,

                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,

                    padding: const EdgeInsets.symmetric(horizontal: 18),

                    itemCount: offers.length,

                    itemBuilder: (_, index) {
                      return offerCouponCard(offers[index]);
                    },
                  ),
                ),

                const SizedBox(height: 10),
              ],

              Padding(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 18,
                ),

                child: GestureDetector(

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

                              t(
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

                              t(
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

                          child: t(
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
              ),

              const SizedBox(height: 24),



              sectionHeader(
                "Top Deals",
                onViewAll: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TopDealsPage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              SizedBox(
                height: 150,

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

                    return topDealLandscapeCard(
                      topDeals[index],
                    );
                  },
                ),
              ),

              // 🔥 FROM YOUR WISHLIST
              if (wishlistProducts.isNotEmpty) ...[

                const SizedBox(height: 28),

                sectionHeader(
                  "From Your Wishlist",
                  onViewAll: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WishlistPage(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                SizedBox(
                  height: 265,

                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,

                    padding: const EdgeInsets.symmetric(horizontal: 18),

                    itemCount: wishlistProducts.length,

                    itemBuilder: (_, index) {
                      return productCard(wishlistProducts[index]);
                    },
                  ),
                ),
              ],

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

                      sectionHeader(
                        category["name"],
                        onViewAll: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SubCategoryPage(
                                categoryId: int.parse(
                                  category["id"].toString(),
                                ),
                                categoryName: category["name"],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(
                        height: 16,
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
                        height: 288,

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
      ),
    );
  }
}