import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

class TermsPage
    extends StatelessWidget{

  const TermsPage({
    super.key,
  });

  @override
  Widget build(
      context,
      ){

    return Scaffold(

      backgroundColor:

      const Color(
        0xFFF7F7F7,
      ),

      appBar:

      AppBar(

        backgroundColor:

        const Color(
          0xFFEF4138,
        ),

        title:

        Text(

          "Terms & Conditions",

          style:

          GoogleFonts.poppins(

            color:
            Colors.white,

            fontWeight:
            FontWeight.w700,

          ),

        ),

      ),

      body:

      SingleChildScrollView(

        padding:

        const EdgeInsets.all(
          18,
        ),

        child:

        Container(

          padding:

          const EdgeInsets.all(
            22,
          ),

          decoration:

          BoxDecoration(

            color:
            Colors.white,

            borderRadius:

            BorderRadius.circular(
              28,
            ),

          ),

          child:

          Column(

            crossAxisAlignment:
            CrossAxisAlignment.start,

            children:[

              title(
                "Welcome",
              ),

              text(

                "These Terms & Conditions govern use of ZipZap Cart Delivery Partner App.",

              ),

              title(
                "Account Responsibility",
              ),

              text(

                "You are responsible for maintaining account confidentiality and keeping login details secure.",

              ),

              title(
                "Delivery Responsibilities",
              ),

              text(

                "Delivery partners must deliver orders accurately, verify customer details when required and follow assigned routes responsibly.",

              ),

              title(
                "Wallet & Payouts",
              ),

              text(

                "Payouts, incentives and wallet balances are subject to verification and company approval.",

              ),

              title(
                "Order Handling",
              ),

              text(

                "Orders must not be cancelled, delayed or marked delivered without successful delivery and OTP verification.",

              ),

              title(
                "Location Access",
              ),

              text(

                "The app may use device location to assist order delivery and navigation.",

              ),

              title(
                "Account Suspension",
              ),

              text(

                "Violation of policies may lead to temporary or permanent account restriction.",

              ),

              title(
                "Updates",
              ),

              text(

                "ZipZap Cart reserves the right to modify terms at any time.",

              ),

              const SizedBox(
                height:30,
              ),

              Center(

                child:

                Text(

                  "© ZipZap Cart",

                  style:

                  GoogleFonts.poppins(

                    fontWeight:
                    FontWeight.w700,

                    color:
                    Colors.grey,

                  ),

                ),

              ),

            ],

          ),

        ),

      ),

    );

  }

  Widget title(
      String t,
      ){

    return Padding(

      padding:

      const EdgeInsets.only(
        bottom:10,
        top:20,
      ),

      child:

      Text(

        t,

        style:

        GoogleFonts.poppins(

          fontSize:20,

          fontWeight:
          FontWeight.w700,

        ),

      ),

    );

  }

  Widget text(
      String t,
      ){

    return Text(

      t,

      style:

      GoogleFonts.poppins(

        fontSize:14,

        height:1.8,

        color:
        Colors.black87,

      ),

    );

  }

}
