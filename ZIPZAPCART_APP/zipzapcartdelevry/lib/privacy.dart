import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

class PrivacyPage
    extends StatelessWidget{

  const PrivacyPage({
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

          "Privacy Policy",

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
                "Introduction",
              ),

              text(

                "ZipZap Cart values your privacy and protects your personal information while using the Delivery Partner application.",

              ),

              title(
                "Information We Collect",
              ),

              text(

                "We may collect profile information, phone number, location, delivery activity and payout details to operate services.",

              ),

              title(
                "Location Usage",
              ),

              text(

                "Live location may be used during deliveries to improve navigation, tracking and order completion.",

              ),

              title(
                "Order Information",
              ),

              text(

                "Delivery partners may access customer delivery details only for completing assigned deliveries.",

              ),

              title(
                "Payments & Wallet",
              ),

              text(

                "Wallet balances and payout information are processed securely for operational purposes.",

              ),

              title(
                "Data Protection",
              ),

              text(

                "We apply reasonable measures to protect stored account and operational information.",

              ),

              title(
                "Third Party Services",
              ),

              text(

                "The application may use external services including maps, notifications and analytics providers.",

              ),

              title(
                "Account Deletion",
              ),

              text(

                "You may contact support regarding account closure or personal information requests.",

              ),

              title(
                "Policy Updates",
              ),

              text(

                "ZipZap Cart may update this Privacy Policy periodically without prior notice.",

              ),

              const SizedBox(
                height:30,
              ),

              Center(

                child:

                Text(

                  "ZipZap Cart Delivery",

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
      String textValue,
      ){

    return Padding(

      padding:

      const EdgeInsets.only(
        top:20,
        bottom:10,
      ),

      child:

      Text(

        textValue,

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
      String value,
      ){

    return Text(

      value,

      style:

      GoogleFonts.poppins(

        height:1.8,

        fontSize:14,

        color:
        Colors.black87,

      ),

    );

  }

}
