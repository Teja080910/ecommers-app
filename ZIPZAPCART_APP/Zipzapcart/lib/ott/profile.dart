import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api_service.dart';
import '../constants.dart';

import 'about_app.dart';
import 'mylist.dart';
import 'privacy_policy.dart';
import 'rewards.dart';
import 'terms_condition.dart';
import 'upgrade.dart';
import 'watchhistory.dart';

class ProfilePage extends StatefulWidget {

  const ProfilePage({
    super.key,
  });

  @override
  State<ProfilePage> createState() =>
      _ProfilePageState();
}

class _ProfilePageState
    extends State<ProfilePage> {

  bool loading = true;

  Map user = {};

  @override
  void initState() {
    super.initState();

    loadUser();
  }

  Future<void> loadUser() async {

    final prefs =
    await SharedPreferences
        .getInstance();

    int userId =
        prefs.getInt(
          "user_id",
        ) ??
            0;

    final data =
    await ApiService.getUser(
      userId,
    );

    user =
        data["user"] ?? {};

    loading = false;

    setState(() {});
  }

  @override
  Widget build(
      BuildContext context,
      ) {

    String paidStatus =
        user["paidstatus"] ??
            "free";

    bool isPremium =
        paidStatus == "paid";

    return Scaffold(

      backgroundColor:
      Colors.black,

      body: loading

          ? const Center(

        child:
        CircularProgressIndicator(
          color:
          Color(
            0xFFE8C37A,
          ),
        ),
      )

          : SafeArea(

        child:
        SingleChildScrollView(

          padding:
          const EdgeInsets.fromLTRB(
            14,
            8,
            14,
            24,
          ),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [

              Row(
                children: [

                  IconButton(

                    padding:
                    EdgeInsets.zero,

                    constraints:
                    const BoxConstraints(),

                    onPressed:
                        () =>
                        Navigator.pop(
                          context,
                        ),

                    icon:
                    const Icon(

                      Icons
                          .arrow_back_ios_new_rounded,

                      color:
                      Colors.white,

                      size: 24,
                    ),
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  const Expanded(

                    child: Text(

                      "My Account",

                      overflow:
                      TextOverflow.ellipsis,

                      style: TextStyle(

                        color:
                        Colors.white,

                        fontSize:
                        19,

                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 18,
              ),

              // 🔥 USER CARD
              Container(

                padding:
                const EdgeInsets.all(
                  16,
                ),

                decoration:
                BoxDecoration(

                  color:
                  const Color(
                    0xFF111317,
                  ),

                  borderRadius:
                  BorderRadius.circular(
                    18,
                  ),
                ),

                child: Column(
                  children: [

                    Row(
                      children: [

                        Container(

                          width: 66,
                          height: 66,

                          decoration:
                          BoxDecoration(

                            shape:
                            BoxShape.circle,

                            border:
                            Border.all(
                              color:
                              const Color(
                                0xFFE8C37A,
                              ),
                              width: 2,
                            ),
                          ),

                          child:
                          ClipOval(

                            child:
                            user["photo"] ==
                                null ||
                                user["photo"]
                                    .toString()
                                    .isEmpty

                                ? Container(

                              color:
                              const Color(
                                0xFF1F1F1F,
                              ),

                              child:
                              const Icon(

                                Icons.person,

                                color:
                                Colors.white,

                                size: 36,
                              ),
                            )

                                : CachedNetworkImage(

                              imageUrl:
                              AppConstants.imageUrl +
                                  user[
                                  "photo"],

                              fit:
                              BoxFit.cover,
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 14,
                        ),

                        Expanded(

                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,

                            children: [

                              Text(

                                user["name"] ??
                                    "",

                                style:
                                const TextStyle(

                                  color:
                                  Colors.white,

                                  fontSize:
                                  19,

                                  fontWeight:
                                  FontWeight.w800,
                                ),
                              ),

                              const SizedBox(
                                height:
                                4,
                              ),

                              Text(

                                user["phone"] ??
                                    "",

                                style:
                                const TextStyle(

                                  color:
                                  Colors.white70,

                                  fontSize:
                                  13,
                                ),
                              ),

                              const SizedBox(
                                height:
                                8,
                              ),

                              Container(

                                padding:
                                const EdgeInsets.symmetric(
                                  horizontal:
                                  12,

                                  vertical:
                                  7,
                                ),

                                decoration:
                                BoxDecoration(

                                  borderRadius:
                                  BorderRadius.circular(
                                    30,
                                  ),

                                  gradient:
                                  LinearGradient(
                                    colors:

                                    isPremium

                                        ? [

                                      const Color(
                                        0xFFE8C37A,
                                      ),

                                      const Color(
                                        0xFFC58D36,
                                      ),
                                    ]

                                        : [

                                      Colors.grey.shade800,

                                      Colors.grey.shade700,
                                    ],
                                  ),
                                ),

                                child: Text(

                                  isPremium

                                      ? "ZENVORA GOLD"

                                      : "FREE USER",

                                  style:
                                  TextStyle(

                                    color:

                                    isPremium

                                        ? Colors.black

                                        : Colors.white,

                                    fontWeight:
                                    FontWeight.w800,

                                    fontSize:
                                    11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // 🔥 JOIN GOLD
                    if (!isPremium)

                      Column(
                        children: [

                          const SizedBox(
                            height: 18,
                          ),

                          GestureDetector(

                            onTap: () {

                              Navigator.push(

                                context,

                                MaterialPageRoute(
                                  builder:
                                      (_) =>
                                  const UpgradePage(),
                                ),
                              );
                            },

                            child:
                            Container(

                              height:
                              52,

                              decoration:
                              BoxDecoration(

                                borderRadius:
                                BorderRadius.circular(
                                  14,
                                ),

                                gradient:
                                const LinearGradient(
                                  colors: [

                                    Color(
                                      0xFFE8C37A,
                                    ),

                                    Color(
                                      0xFFC58D36,
                                    ),
                                  ],
                                ),
                              ),

                              child:
                              const Center(

                                child: Text(

                                  "Upgrade To Gold",

                                  style: TextStyle(

                                    color:
                                    Colors.black,

                                    fontWeight:
                                    FontWeight.w900,

                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              const SizedBox(
                height: 14,
              ),

              // 🔥 QUICK ACTIONS
              Container(

                padding:
                const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),

                decoration:
                BoxDecoration(

                  color:
                  const Color(
                    0xFF111317,
                  ),

                  borderRadius:
                  BorderRadius.circular(
                    14,
                  ),
                ),

                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly,

                  children: [

                    _QuickItem(

                      icon:
                      Icons.bookmark,

                      label:
                      "My List",

                      onTap: () {

                        Navigator.push(

                          context,

                          MaterialPageRoute(
                            builder:
                                (_) =>
                            const MyListPage(),
                          ),
                        );
                      },
                    ),

                    _QuickItem(

                      icon:
                      Icons.history,

                      label:
                      "Watch History",

                      onTap: () {

                        Navigator.push(

                          context,

                          MaterialPageRoute(
                            builder:
                                (_) =>
                            const WatchHistoryPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 14,
              ),

              // 🔥 REWARD CARD
              GestureDetector(

                onTap: () {

                  Navigator.push(

                    context,

                    MaterialPageRoute(
                      builder:
                          (_) =>
                      const RewardsPage(),
                    ),
                  );
                },

                child: Container(

                  height: 90,

                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),

                  decoration:
                  BoxDecoration(

                    borderRadius:
                    BorderRadius.circular(
                      14,
                    ),

                    gradient:
                    const LinearGradient(
                      colors: [

                        Color(
                          0xFF8A0068,
                        ),

                        Color(
                          0xFF4C00D7,
                        ),
                      ],
                    ),
                  ),

                  child: Row(
                    children: [

                      const Icon(

                        Icons.card_giftcard,

                        color:
                        Colors.orangeAccent,

                        size: 34,
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      const Expanded(

                        child: Column(
                          mainAxisAlignment:
                          MainAxisAlignment.center,

                          crossAxisAlignment:
                          CrossAxisAlignment.start,

                          children: [

                            Text(

                              "REWARD WALL",

                              style: TextStyle(

                                color:
                                Colors.white,

                                fontSize:
                                15,

                                fontWeight:
                                FontWeight.w900,
                              ),
                            ),

                            SizedBox(
                              height: 4,
                            ),

                            Text(

                              "Your Rewards Are Waiting Here!",

                              style: TextStyle(

                                color:
                                Colors.white,

                                fontSize:
                                12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(

                        padding:
                        const EdgeInsets.symmetric(
                          horizontal:
                          12,

                          vertical:
                          12,
                        ),

                        decoration:
                        BoxDecoration(

                          color:
                          Colors.white,

                          borderRadius:
                          BorderRadius.circular(
                            10,
                          ),
                        ),

                        child:
                        const Text(

                          "Rewards",

                          style: TextStyle(

                            color:
                            Colors.black87,

                            fontSize:
                            12,

                            fontWeight:
                            FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              // 🔥 SETTINGS
              Container(

                padding:
                const EdgeInsets.symmetric(
                  vertical: 6,
                ),

                decoration:
                BoxDecoration(

                  color:
                  const Color(
                    0xFF111317,
                  ),

                  borderRadius:
                  BorderRadius.circular(
                    14,
                  ),
                ),

                child: Column(
                  children: [

                    _settingTile(

                      icon:
                      Icons.info_outline,

                      title:
                      "About App",

                      onTap: () {

                        Navigator.push(

                          context,

                          MaterialPageRoute(
                            builder:
                                (_) =>
                            const AboutAppPage(),
                          ),
                        );
                      },
                    ),

                    _settingTile(

                      icon:
                      Icons.privacy_tip_outlined,

                      title:
                      "Privacy Policy",

                      onTap: () {

                        Navigator.push(

                          context,

                          MaterialPageRoute(
                            builder:
                                (_) =>
                            const PrivacyPolicyPage(),
                          ),
                        );
                      },
                    ),

                    _settingTile(

                      icon:
                      Icons.gavel_outlined,

                      title:
                      "Terms & Conditions",

                      onTap: () {

                        Navigator.push(

                          context,

                          MaterialPageRoute(
                            builder:
                                (_) =>
                            const TermsConditionPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _settingTile({

    required IconData icon,

    required String title,

    required VoidCallback onTap,

  }) {

    return GestureDetector(

      onTap: onTap,

      child: Padding(

        padding:
        const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),

        child: Row(
          children: [

            Icon(
              icon,
              color:
              Colors.white,
              size: 24,
            ),

            const SizedBox(
              width: 14,
            ),

            Expanded(

              child: Text(

                title,

                style:
                const TextStyle(

                  color:
                  Colors.white,

                  fontSize:
                  15,

                  fontWeight:
                  FontWeight.w500,
                ),
              ),
            ),

            const Icon(

              Icons.chevron_right_rounded,

              color:
              Colors.white70,

              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickItem
    extends StatelessWidget {

  final IconData icon;

  final String label;

  final VoidCallback onTap;

  const _QuickItem({

    required this.icon,

    required this.label,

    required this.onTap,
  });

  @override
  Widget build(
      BuildContext context,
      ) {

    return Expanded(

      child:
      GestureDetector(

        onTap: onTap,

        child: Column(
          children: [

            Icon(

              icon,

              color:
              const Color(
                0xFF1F78FF,
              ),

              size: 30,
            ),

            const SizedBox(
              height: 6,
            ),

            Text(

              label,

              textAlign:
              TextAlign.center,

              style:
              const TextStyle(

                color:
                Colors.white70,

                fontSize:
                11.5,

                fontWeight:
                FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}