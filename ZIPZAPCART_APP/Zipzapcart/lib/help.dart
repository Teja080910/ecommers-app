import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'api_service.dart';

class HelpPage
    extends StatefulWidget{

  const HelpPage({
    super.key,
  });

  @override
  State<HelpPage>
  createState()

  =>

      _HelpPageState();

}

class _HelpPageState
    extends State<HelpPage>{

  String supportNumber="";

  String supportEmail="";

  bool loading=true;

  Future<void> load() async{

    try{

      final data=

      await ApiService
          .getAppSetting();

      if(!mounted){
        return;
      }

      setState(() {

        supportNumber=

            data[
            "supportnumber"
            ]

                ??

                "+91";

        supportEmail=

            data[
            "supportemail"
            ]

                ??

                "[support@email.com](mailto:support@email.com)";

        loading=false;

      });

    }

    catch(e){

      if(!mounted){
        return;
      }

      setState(() {

        loading=false;

      });

    }

  }

  @override
  void initState(){

    super.initState();

    load();

  }

  Future<void> _callSupport() async {

    final uri = Uri(scheme: 'tel', path: supportNumber);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _emailSupport() async {

    final uri = Uri(scheme: 'mailto', path: supportEmail);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(
      BuildContext context,
      ){

    return Scaffold(

      backgroundColor:

      const Color(
        0xFFF6F7F9,
      ),

      appBar:

      AppBar(

        elevation:0,

        backgroundColor:
        Colors.white,

        foregroundColor:
        Colors.black,

        centerTitle:true,

        title:

        const Text(

          "Help & Support",

          style:

          TextStyle(

            fontWeight:
            FontWeight.w700,

            fontSize:18,

          ),

        ),

      ),

      body:

      loading

          ?

      const Center(

        child:

        CircularProgressIndicator(
          color: Color(0xFFEF4138),
        ),

      )

          :

      SingleChildScrollView(

        padding:

        const EdgeInsets.fromLTRB(
          14,
          12,
          14,
          20,
        ),

        child:

        Column(

          crossAxisAlignment:

          CrossAxisAlignment.start,

          children:[

            _card(

              child:

              Column(

                children:[

                  _contactTile(

                    icon:
                    Icons.phone_outlined,

                    title:
                    "Call Support",

                    subtitle:
                    supportNumber,

                    onTap:
                    _callSupport,

                  ),

                  const Divider(),

                  _contactTile(

                    icon:
                    Icons.email_outlined,

                    title:
                    "Email Us",

                    subtitle:
                    supportEmail,

                    onTap:
                    _emailSupport,

                  ),

                ],

              ),

            ),

            const SizedBox(
              height:16,
            ),

            const Text(

              "Frequently Asked Questions",

              style:

              TextStyle(

                fontSize:15,

                fontWeight:
                FontWeight.w800,

              ),

            ),

            const SizedBox(
              height:10,
            ),

            _faqItem(

                "How can I place an order?",

                "Browse products, add items to cart and checkout."

            ),

            _faqItem(

                "How do I track my order?",

                "Go to My Orders section."

            ),

            _faqItem(

                "Can I cancel my order?",

                "Orders may be cancelled before shipping."

            ),

            _faqItem(

                "Cash on Delivery available?",

                "Available on selected locations."

            ),

            const SizedBox(
              height:20,
            ),

            SizedBox(

              width:
              double.infinity,

              height:52,

              child:

              ElevatedButton(

                onPressed:_callSupport,

                style:

                ElevatedButton
                    .styleFrom(

                  backgroundColor:

                  const Color(
                    0xFF0B2A6F,
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

                  "Contact Support",

                  style:

                  TextStyle(

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

  }

  Widget _card({

    required Widget child,

  }){

    return Container(

      decoration:

      BoxDecoration(

        color:
        Colors.white,

        borderRadius:

        BorderRadius.circular(
          16,
        ),

        boxShadow:[

          BoxShadow(

            color:

            Colors.black
                .withOpacity(
              0.04,
            ),

            blurRadius:12,

          ),

        ],

      ),

      child:
      child,

    );

  }

  Widget _contactTile({

    required IconData icon,

    required String title,

    required String subtitle,

    VoidCallback? onTap,

  }){

    return InkWell(

      onTap: onTap,

      child: Padding(

      padding:

      const EdgeInsets.all(
        14,
      ),

      child:

      Row(

        children:[

          Container(

            width:40,

            height:40,

            decoration:

            BoxDecoration(

              color:

              const Color(
                0xFF0B2A6F,
              )

                  .withOpacity(
                0.08,
              ),

              borderRadius:

              BorderRadius.circular(
                10,
              ),

            ),

            child:

            Icon(

              icon,

              color:

              const Color(
                0xFF0B2A6F,
              ),

            ),

          ),

          const SizedBox(
            width:12,
          ),

          Expanded(

            child:

            Column(

              crossAxisAlignment:

              CrossAxisAlignment.start,

              children:[

                Text(

                  title,

                  style:

                  const TextStyle(

                    fontWeight:
                    FontWeight.w700,

                  ),

                ),

                Text(

                  subtitle,

                  style:

                  const TextStyle(

                    fontSize:12,

                    color:
                    Colors.black54,

                  ),

                ),

              ],

            ),

          ),

          const Icon(

            Icons.chevron_right,

          ),

        ],

      ),
      ),

    );

  }

  Widget _faqItem(
      String q,
      String a,
      ){

    return Container(

      margin:

      const EdgeInsets.only(
        bottom:10,
      ),

      padding:

      const EdgeInsets.all(
        14,
      ),

      decoration:

      BoxDecoration(

        color:
        Colors.white,

        borderRadius:

        BorderRadius.circular(
          14,
        ),

      ),

      child:

      Column(

        crossAxisAlignment:

        CrossAxisAlignment.start,

        children:[

          Text(

            q,

            style:

            const TextStyle(

              fontWeight:
              FontWeight.w700,

            ),

          ),

          const SizedBox(
            height:8,
          ),

          Text(
            a,
          ),

        ],

      ),

    );

  }

}
