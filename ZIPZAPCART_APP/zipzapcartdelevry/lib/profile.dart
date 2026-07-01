import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';

import 'login.dart';

import 'payout.dart';

import 'privacy.dart';

import 'terms.dart';

import 'constants.dart';

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

  Map data = {};

  bool loading = true;

  Future load() async {

    final r =
    await ApiService.profile();

    data =
        r["profile"]
            ??
            {};

    loading = false;

    setState(() {});

  }

  Future logout() async {

    final prefs =
    await SharedPreferences.getInstance();

    await prefs.clear();

    Navigator.pushAndRemoveUntil(

      context,

      MaterialPageRoute(

        builder:
            (_) =>
        const LoginPage(),

      ),

          (_) => false,

    );

  }

  @override
  void initState() {

    super.initState();

    load();

  }

  @override
  Widget build(
      BuildContext context,
      ) {

    if (loading) {

      return const Scaffold(

        body:

        Center(

          child:
          CircularProgressIndicator(),

        ),

      );

    }

    return Scaffold(

      backgroundColor:
      const Color(
        0xFFF5F7FA,
      ),

      body:

      CustomScrollView(

        slivers: [

          SliverAppBar(

            expandedHeight: 290,

            pinned: true,

            elevation: 0,

            backgroundColor:
            const Color(
              0xFF0F4C81,
            ),

            flexibleSpace:

            FlexibleSpaceBar(

              background:

              Container(

                decoration:

                const BoxDecoration(

                  gradient:

                  LinearGradient(

                    colors: [

                      Color(
                        0xFF0F4C81,
                      ),

                      Color(
                        0xFF2575FC,
                      ),

                    ],

                    begin:
                    Alignment.topLeft,

                    end:
                    Alignment.bottomRight,

                  ),

                ),

                child:

                SafeArea(

                  child:

                  Column(

                    children: [

                      const SizedBox(
                        height: 24,
                      ),

                      CircleAvatar(

                        radius: 55,

                        backgroundColor:
                        Colors.white,

                        backgroundImage:

                        data["profile_photo"] != null &&
                            data["profile_photo"]
                                .toString()
                                .isNotEmpty

                            ?

                        NetworkImage(

                          AppConstants.imageUrl +
                              data["profile_photo"],

                        )

                            :

                        null,

                        child:

                        data["profile_photo"] == null

                            ?

                        const Icon(

                          Icons.person,

                          size: 55,

                        )

                            :

                        null,

                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      Text(

                        data["name"] ?? "",

                        style:

                        GoogleFonts.poppins(

                          color:
                          Colors.white,

                          fontSize: 25,

                          fontWeight:
                          FontWeight.w700,

                        ),

                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      Container(

                        padding:

                        const EdgeInsets.symmetric(

                          horizontal: 18,

                          vertical: 8,

                        ),

                        decoration:

                        BoxDecoration(

                          color:
                          Colors.white24,

                          borderRadius:

                          BorderRadius.circular(
                            50,
                          ),

                        ),

                        child:

                        Text(

                          data["status"] ?? "",

                          style:

                          GoogleFonts.poppins(

                            color:
                            Colors.white,

                          ),

                        ),

                      ),

                    ],

                  ),

                ),

              ),

            ),

          ),

          SliverToBoxAdapter(

            child:

            Padding(

              padding:

              const EdgeInsets.all(
                18,
              ),

              child:

              Column(

                children: [

                  walletCard(),

                  section(

                    "Contact",

                    [

                      info(
                        Icons.phone,
                        "Phone",
                        data["phone"],
                      ),

                      info(
                        Icons.email,
                        "Email",
                        data["email"],
                      ),

                      info(
                        Icons.location_on,
                        "Address",
                        data["address"],
                      ),

                    ],

                  ),

                  section(

                    "Vehicle",

                    [

                      info(
                        Icons.local_shipping,
                        "Type",
                        data["vehicle_type"],
                      ),

                      info(
                        Icons.drive_eta,
                        "Vehicle",
                        data["vehicle_name"],
                      ),

                      info(
                        Icons.confirmation_number,
                        "Number",
                        data["vehicle_number"],
                      ),

                    ],

                  ),

                  section(

                    "Documents",

                    [

                      info(
                        Icons.badge,
                        "Aadhaar",
                        data["aadhaar_number"],
                      ),

                      info(
                        Icons.credit_card,
                        "PAN",
                        data["pan_number"],
                      ),

                      info(
                        Icons.assignment,
                        "License",
                        data["driving_license_number"],
                      ),

                    ],

                  ),

                  menuCard(),

                ],

              ),

            ),

          ),

        ],

      ),

    );

  }

  Widget walletCard() {

    return premium(

      child:

      Column(

        children: [

          const Icon(

            Icons.account_balance_wallet,

            size: 40,

            color:
            Color(
              0xFFECA202,
            ),

          ),

          const SizedBox(
            height: 10,
          ),

          Text(

            "Wallet Balance",

            style:
            GoogleFonts.poppins(),

          ),

          Text(

            "₹${data["wallet_balance"]}",

            style:

            GoogleFonts.poppins(

              fontSize: 32,

              fontWeight:
              FontWeight.w700,

            ),

          ),

        ],

      ),

    );

  }

  Widget section(
      String title,
      List<Widget> children,
      ) {

    return premium(

      child:

      Column(

        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Text(

            title,

            style:

            GoogleFonts.poppins(

              fontSize: 18,

              fontWeight:
              FontWeight.w700,

            ),

          ),

          const SizedBox(
            height: 18,
          ),

          ...children,

        ],

      ),

    );

  }

  Widget info(
      IconData icon,
      String title,
      dynamic value,
      ) {

    return Padding(

      padding:

      const EdgeInsets.only(
        bottom: 18,
      ),

      child:

      Row(

        children: [

          Container(

            padding:

            const EdgeInsets.all(
              12,
            ),

            decoration:

            BoxDecoration(

              color:
              Colors.blue.shade50,

              borderRadius:

              BorderRadius.circular(
                16,
              ),

            ),

            child:

            Icon(
              icon,
            ),

          ),

          const SizedBox(
            width: 14,
          ),

          Expanded(

            child:

            Column(

              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Text(

                  title,

                  style:

                  GoogleFonts.poppins(

                    color:
                    Colors.grey,

                  ),

                ),

                Text(

                  "${value ?? "-"}",

                  style:

                  GoogleFonts.poppins(

                    fontWeight:
                    FontWeight.w600,

                  ),

                ),

              ],

            ),

          ),

        ],

      ),

    );

  }

  Widget menuCard() {

    return premium(

      child:

      Column(

        children: [

          tile(
            Icons.payments,
            "Payout",
                () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) =>
                  const PayoutPage(),
                ),
              );
            },
          ),

          tile(
            Icons.description,
            "Terms",
                () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) =>
                  const TermsPage(),
                ),
              );
            },
          ),

          tile(
            Icons.privacy_tip,
            "Privacy",
                () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) =>
                  const PrivacyPage(),
                ),
              );
            },
          ),

          tile(
            Icons.logout,
            "Logout",
            logout,
            red: true,
          ),

        ],

      ),

    );

  }

  Widget tile(
      IconData icon,
      String title,
      VoidCallback tap, {
        bool red = false,
      }) {

    return ListTile(

      leading:

      Icon(

        icon,

        color:
        red
            ? Colors.red
            : null,

      ),

      title:

      Text(

        title,

        style:

        GoogleFonts.poppins(

          color:
          red
              ? Colors.red
              : null,

        ),

      ),

      trailing:

      const Icon(
        Icons.chevron_right,
      ),

      onTap:
      tap,

    );

  }

  Widget premium({
    required Widget child,
  }) {

    return Container(

      margin:

      const EdgeInsets.only(
        bottom: 18,
      ),

      padding:

      const EdgeInsets.all(
        20,
      ),

      decoration:

      BoxDecoration(

        color:
        Colors.white,

        borderRadius:

        BorderRadius.circular(
          28,
        ),

        boxShadow: [

          BoxShadow(

            color:

            Colors.black
                .withOpacity(
              0.06,
            ),

            blurRadius: 25,

            offset:
            const Offset(
              0,
              8,
            ),

          ),

        ],

      ),

      child:
      child,

    );

  }

}