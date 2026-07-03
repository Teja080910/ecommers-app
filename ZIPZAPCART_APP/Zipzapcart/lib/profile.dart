import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login.dart';
import 'api_service.dart';

// 🔥 IMPORT PAGES
import 'myorder.dart';
import 'address.dart';
import 'wallet.dart';
import 'wishlist.dart';
import 'language.dart';
import 'mode.dart';
import 'notification.dart';
import 'terms.dart';
import 'help.dart';
import 'about.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() =>
      _ProfilePageState();
}

class _ProfilePageState
    extends State<ProfilePage> {

  String name = "Loading...";
  String phone = "";
  String appTheme = "light";

  bool get isDark =>
      appTheme == "dark";
  int userId = 0;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    loadUser();
  }

  Future<void> loadUser() async {

    final prefs =
    await SharedPreferences
        .getInstance();
    appTheme =
        prefs.getString(
          "app_theme",
        ) ??
            "light";
    userId =
        prefs.getInt("user_id") ?? 0;

    // 🔥 LOAD CACHE FIRST
    setState(() {

      name =
          prefs.getString("name") ??
              "Guest User";

      phone =
          prefs.getString("phone") ??
              "";
    });

    if (userId == 0) {

      setState(() {
        isLoading = false;
      });

      return;
    }

    try {

      final res =
      await ApiService.getUser(
        userId,
      );

      if (res["status"] == true &&
          res["user"] != null) {

        name =
            res["user"]["name"] ??
                "User";

        phone =
            res["user"]["phone"] ??
                "";

        await prefs.setString(
          "name",
          name,
        );

        await prefs.setString(
          "phone",
          phone,
        );

        print(
          "PROFILE API: $res",
        );
      }

    } catch (e) {

      print(
        "USER LOAD ERROR: $e",
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  void editName() {

    final controller =
    TextEditingController(
      text: name,
    );

    showModalBottomSheet(

      context: context,

      isScrollControlled: true,

      backgroundColor:
      Colors.transparent,

      builder: (_) {

        return Padding(

          padding:

          EdgeInsets.only(

            bottom:

            MediaQuery.of(
              context,
            )

                .viewInsets
                .bottom,

          ),

          child:

          Container(

            padding:
            const EdgeInsets.all(
              20,
            ),

            decoration:

            BoxDecoration(

              color:

              isDark

                  ?

              const Color(
                0xFF1E1E1E,
              )

                  :

              Colors.white,

              borderRadius:

              const BorderRadius.vertical(

                top:
                Radius.circular(
                  28,
                ),

              ),

            ),

            child:

            Column(

              mainAxisSize:
              MainAxisSize.min,

              children:[

                Container(

                  width:60,
                  height:5,

                  decoration:

                  BoxDecoration(

                    color:
                    Colors.grey,

                    borderRadius:
                    BorderRadius.circular(
                      20,
                    ),

                  ),

                ),

                const SizedBox(
                  height:20,
                ),

                Row(

                  children:[

                    Container(

                      width:54,
                      height:54,

                      decoration:

                      BoxDecoration(

                        color:

                        const Color(
                          0xFFEF4138,
                        )

                            .withOpacity(
                          0.12,
                        ),

                        shape:
                        BoxShape.circle,

                      ),

                      child:

                      const Icon(

                        Icons.edit,

                        size: 20,

                        color:
                        Color(
                          0xFFEF4138,
                        ),

                      ),

                    ),

                    const SizedBox(
                      width:14,
                    ),

                    Expanded(

                      child:

                      Text(

                        "Update Name",

                        style:

                        TextStyle(

                          fontSize:20,

                          fontWeight:
                          FontWeight.w800,

                          color:

                          isDark

                              ?

                          Colors.white

                              :

                          Colors.black,

                        ),

                      ),

                    ),

                  ],

                ),

                const SizedBox(
                  height:18,
                ),

                TextField(

                  controller:
                  controller,

                  style:

                  TextStyle(

                    color:

                    isDark

                        ?

                    Colors.white

                        :

                    Colors.black,

                  ),

                  decoration:

                  InputDecoration(

                    hintText:
                    "Enter display name",

                    filled:true,

                    fillColor:

                    isDark

                        ?

                    const Color(
                      0xFF2A2A2A,
                    )

                        :

                    const Color(
                      0xFFF7F7F7,
                    ),

                    prefixIcon:

                    const Icon(

                      Icons.person,

                      color:
                      Color(
                        0xFFEF4138,
                      ),

                    ),

                    border:

                    OutlineInputBorder(

                      borderRadius:
                      BorderRadius.circular(
                        18,
                      ),

                      borderSide:
                      BorderSide.none,

                    ),

                  ),

                ),

                const SizedBox(
                  height:18,
                ),

                SizedBox(

                  width:
                  double.infinity,

                  height:54,

                  child:

                  ElevatedButton(

                    onPressed:
                        () async {

                      if(
                      controller.text
                          .trim()
                          .isEmpty
                      ){

                        return;

                      }

                      bool ok =

                      await ApiService
                          .updateProfile(

                        userId,

                        controller.text
                            .trim(),

                      );

                      if(ok){

                        final prefs =

                        await SharedPreferences
                            .getInstance();

                        await prefs.setString(

                          "name",

                          controller.text
                              .trim(),

                        );

                        setState(() {

                          name =
                              controller.text
                                  .trim();

                        });

                      }

                      if(context.mounted){

                        Navigator.pop(
                          context,
                        );

                      }

                    },

                    style:

                    ElevatedButton
                        .styleFrom(

                      backgroundColor:

                      const Color(
                        0xFFEF4138,
                      ),

                      shape:

                      RoundedRectangleBorder(

                        borderRadius:
                        BorderRadius.circular(
                          16,
                        ),

                      ),

                    ),

                    child:

                    const Text(

                      "Update",

                      style:

                      TextStyle(
                        color:
                        Colors.white,
                        fontSize:16,

                        fontWeight:
                        FontWeight.w700,

                      ),

                    ),

                  ),

                ),

              ],

            ),

          ),

        );

      },

    );

  }


  Future<void> _logout(
      BuildContext context,
      ) async {

    final prefs =
    await SharedPreferences
        .getInstance();

    await prefs.clear();

    Navigator.pushAndRemoveUntil(

      context,

      MaterialPageRoute(
        builder:
            (_) => const LoginPage(),
      ),

          (route) => false,
    );
  }

  void nav(Widget page) {

    Navigator.push(

      context,

      MaterialPageRoute(
        builder: (_) => page,
      ),
    );
  }

  @override
  Widget build(
      BuildContext context,
      ) {

    return Scaffold(

      backgroundColor:

      isDark

          ? const Color(
        0xFF121212,
      )

          : const Color(
        0xFFF6F7F9,
      ),
      body: SafeArea(

        child: RefreshIndicator(

          color:
          const Color(0xFFEF4138),

          onRefresh: loadUser,

          child:
          SingleChildScrollView(

            physics:
            const AlwaysScrollableScrollPhysics(),

            padding:
            const EdgeInsets.fromLTRB(
              14,
              8,
              14,
              24,
            ),

            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,

              children: [

                // 🔥 HEADER
                Row(
                  children: [

                    IconButton(

                      padding:
                      EdgeInsets.zero,

                      constraints:
                      const BoxConstraints(),

                      onPressed: () =>
                          Navigator.pop(
                            context,
                          ),

                      icon:  Icon(
                        Icons
                            .arrow_back_ios_new_rounded,
                        color:
                        isDark

                            ? Colors.white

                            : Colors.black,
                      ),
                    ),

                    const SizedBox(
                      width: 12,
                    ),

                     Expanded(
                      child: Text(

                        "My Account",

                        style: TextStyle(

                          fontSize: 19,

                          fontWeight:
                          FontWeight.w700,

                          color:
                          isDark

                              ? Colors.white

                              : Colors.black,
                        ),
                      ),
                    ),


              IconButton(

              onPressed: () {

        nav(

        const NotificationPage(),

        );

        },

          icon: Icon(

            Icons
                .notifications_none_rounded,

            color:

            isDark

                ?

            Colors.white

                :

            Colors.black,

          ),

        ),


        ],
                ),

                const SizedBox(
                  height: 14,
                ),

                // 🔥 USER CARD
                GestureDetector(

                  onTap: editName,

                  child: Container(

                    padding:
                    const EdgeInsets.all(
                      14,
                    ),

                    decoration: _card(),

                    child: Row(
                      children: [

                        _avatar(),

                        const SizedBox(
                          width: 12,
                        ),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                            children: [

                              isLoading

                                  ? _shimmerBox(
                                width: 120,
                                height: 16,
                              )

                                  : Text(

                                name,

                                style:
                                 TextStyle(
                                  fontWeight:
                                  FontWeight.w700,

                                  fontSize: 17,
                                  color:

                                  isDark

                                      ? Colors.white

                                      : Colors.black,
                                ),
                              ),

                              const SizedBox(
                                height: 4,
                              ),

                              isLoading

                                  ? _shimmerBox(
                                width: 100,
                                height: 12,
                              )

                                  : Text(

                                "+91 $phone",

                                style:
                                 TextStyle(
                                  color:

                                  isDark

                                      ? Colors.white70

                                      : Colors.black54,

                                  fontSize:
                                  11.8,

                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(
                  height: 14,
                ),

                // 🔥 APP SETTINGS
                _sectionTitle(
                  "App Settings",
                ),

                const SizedBox(
                  height: 8,
                ),

                _settingTile(

                  Icons.shopping_basket_outlined,

                  "Wishlist",

                  "Your Wishlist Here",

                      () => nav(
                    const WishlistPage(),
                  ),
                ),

                _settingTile(

                  Icons.language_rounded,

                  "Language",

                  "English, Hindi and regional languages",

                      () => nav(
                    const LanguagePage(),
                  ),
                ),


                const SizedBox(
                  height: 14,
                ),

                // 🔥 ACCOUNT SETTINGS
                _sectionTitle(
                  "Account & Support",
                ),

                const SizedBox(
                  height: 8,
                ),

                _settingTile(

                  Icons.shopping_bag_outlined,

                  "My Orders",

                  "Track current and past orders",

                      () => nav(
                    const MyOrderPage(),
                  ),
                ),

                _settingTile(

                  Icons.location_on_outlined,

                  "Saved Addresses",

                  "Manage home, office and other addresses",

                      () => nav(
                    const AddressPage(),
                  ),
                ),

                _settingTile(

                  Icons.account_balance_wallet_outlined,

                  "Wallet & Payments",

                  "Cards, UPI, refunds and balance",

                      () => nav(
                    const WalletPage(),
                  ),
                ),

                _settingTile(

                  Icons.rule_folder_outlined,

                  "Terms & Policies",

                  "Read terms, privacy and refund policies",

                      () => nav(
                    const TermsPage(),
                  ),
                ),

                _settingTile(

                  Icons.support_agent_outlined,

                  "Help & Support",

                  "Report issue or contact support",

                      () => nav(
                    const HelpPage(),
                  ),
                ),

                _settingTile(

                  Icons.info_outline_rounded,

                  "About App",

                  "Version, legal and platform information",

                      () => nav(
                    const AboutPage(),
                  ),
                ),

                const SizedBox(
                  height: 18,
                ),

                // 🔥 LOGOUT
                SizedBox(

                  width:
                  double.infinity,

                  child:
                  ElevatedButton(

                    onPressed:
                        () => _logout(
                      context,
                    ),

                    style:
                    ElevatedButton.styleFrom(

                      backgroundColor:
                      const Color(
                        0xFFEF4138,
                      ),

                      foregroundColor:
                      Colors.white,

                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                          14,
                        ),
                      ),
                    ),

                    child:
                    const Text(
                      "Logout",
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

  // 🔥 CARD
  BoxDecoration _card() =>
      BoxDecoration(

        color:

        isDark

            ? const Color(
          0xFF1E1E1E,
        )

            : Colors.white,

        borderRadius:
        BorderRadius.circular(
          16,
        ),

        boxShadow: [

          BoxShadow(
            color:
            Colors.black.withOpacity(
              0.04,
            ),

            blurRadius: 12,

            offset:
            const Offset(0, 4),
          ),
        ],
      );

  // 🔥 AVATAR
  Widget _avatar() => Container(

    width: 54,
    height: 54,

    decoration: const BoxDecoration(

      shape: BoxShape.circle,

      gradient: LinearGradient(
        colors: [
          Color(0xFFF4C31A),
          Color(0xFFFF9B49),
        ],
      ),
    ),

    child: const Icon(
      Icons.person,
      color: Colors.white,
    ),
  );

  // 🔥 TITLE
  Widget _sectionTitle(
      String title,
      ) {

    return Text(

      title,

      style:  TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color:

        isDark

            ? Colors.white

            : const Color(
          0xFF111111,
        ),
      ),
    );
  }

  // 🔥 SETTINGS TILE
  Widget _settingTile(

      IconData icon,
      String title,
      String subtitle,
      VoidCallback onTap,

      ) {

    return InkWell(

      onTap: onTap,

      child: Padding(

        padding:
        const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),

        child: Row(
          children: [

            Container(

              width: 38,
              height: 38,

              decoration:
              BoxDecoration(

                color:
                const Color(
                  0xFFEF4138,
                ).withOpacity(
                  0.08,
                ),

                borderRadius:
                BorderRadius.circular(
                  10,
                ),
              ),

              child: Icon(
                icon,

                color:
                const Color(
                  0xFFEF4138,
                ),

                size: 20,
              ),
            ),

            const SizedBox(
              width: 12,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,

                children: [

                  Text(

                    title,

                    style:
                     TextStyle(
                      fontWeight:
                      FontWeight.w600,

                      fontSize: 14.5,
                      color:

                      isDark

                          ? Colors.white

                          : Colors.black,
                    ),
                  ),

                  const SizedBox(
                    height: 3,
                  ),

                  Text(

                    subtitle,

                    style:
                     TextStyle(
                      color:

                      isDark

                          ? Colors.white70

                          : Colors.black54,

                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

             Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color:

              isDark

                  ? Colors.white54

                  : Colors.black45,
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 SHIMMER
  Widget _shimmerBox({

    required double width,
    required double height,

  }) {

    return Container(

      width: width,
      height: height,

      decoration: BoxDecoration(

        color:
        Colors.grey.shade300,

        borderRadius:
        BorderRadius.circular(
          6,
        ),
      ),
    );
  }
}