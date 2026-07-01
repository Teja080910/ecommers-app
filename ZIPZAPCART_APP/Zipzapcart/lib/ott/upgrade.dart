import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart';

class UpgradePage extends StatefulWidget {

  const UpgradePage({
    super.key,
  });

  @override
  State<UpgradePage> createState() =>
      _UpgradePageState();
}

class _UpgradePageState
    extends State<UpgradePage> {

  List plans = [];

  bool loading = true;

  late Razorpay _razorpay;

  String razorpayKey = "";

  int userId = 0;

  Map? selectedPlan;

  @override
  void initState() {
    super.initState();

    _razorpay = Razorpay();

    _razorpay.on(
      Razorpay.EVENT_PAYMENT_SUCCESS,
      _handlePaymentSuccess,
    );

    _razorpay.on(
      Razorpay.EVENT_PAYMENT_ERROR,
      _handlePaymentError,
    );

    _razorpay.on(
      Razorpay.EVENT_EXTERNAL_WALLET,
      _handleExternalWallet,
    );

    loadData();
  }

  Future<void> loadData() async {

    final prefs =
    await SharedPreferences
        .getInstance();

    userId =
        prefs.getInt(
          "user_id",
        ) ??
            0;

    final razor =
    await ApiService
        .getRazorpaySettings();

    razorpayKey =
        razor["key_id"] ?? "";

    final res = await ApiService.getSubscriptions();

    plans =
        res["plans"] ?? [];

    loading = false;

    setState(() {});
  }

  void openPayment(Map plan) {

    selectedPlan = plan;

    var options = {

      'key': razorpayKey,

      'amount':
      (double.parse(
        plan["amount"]
            .toString(),
      ) *
          100)
          .toInt(),

      'name':
      'ZENVORA GOLD',

      'description':
      plan["title"],

      'prefill': {
        'contact': '',
        'email': '',
      },

      'theme': {
        'color': '#E8C37A'
      }
    };

    try {

      _razorpay.open(options);

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content:
          Text(e.toString()),
        ),
      );
    }
  }

  Future<void>
  _handlePaymentSuccess(
      PaymentSuccessResponse response,
      ) async {

    if (selectedPlan == null) return;

    final res =
    await ApiService.activateSubscription(

      userId:
      userId.toString(),

      subscriptionId:
      selectedPlan!["id"]
          .toString(),

      paymentId:
      response.paymentId ?? "",
    );

    if (res["status"] == true) {

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          backgroundColor:
          Colors.green,

          content: Text(
            "Premium Activated",
          ),
        ),
      );

      Navigator.pop(context);

    } else {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(
            res["message"] ??
                "Failed",
          ),
        ),
      );
    }
  }

  void _handlePaymentError(
      PaymentFailureResponse response,
      ) {

    ScaffoldMessenger.of(context)
        .showSnackBar(

      const SnackBar(

        backgroundColor:
        Colors.red,

        content: Text(
          "Payment Failed",
        ),
      ),
    );
  }

  void _handleExternalWallet(
      ExternalWalletResponse response,
      ) {}

  @override
  void dispose() {

    _razorpay.clear();

    super.dispose();
  }

  @override
  Widget build(
      BuildContext context,
      ) {

    return Scaffold(

      backgroundColor:
      Colors.black,

      appBar: AppBar(

        backgroundColor:
        Colors.black,

        elevation: 0,

        title: const Text(

          "Upgrade To Gold",

          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),

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

          : ListView(

        padding:
        const EdgeInsets.all(
          16,
        ),

        children: [

          // 🔥 HEADER
          Container(

            padding:
            const EdgeInsets.all(
              24,
            ),

            decoration:
            BoxDecoration(

              borderRadius:
              BorderRadius.circular(
                24,
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

            child: Column(
              children: [

                const Icon(

                  Icons.workspace_premium,

                  size: 70,

                  color:
                  Colors.black,
                ),

                const SizedBox(
                  height: 16,
                ),

                const Text(

                  "ZENVORA GOLD",

                  style: TextStyle(

                    color:
                    Colors.black,

                    fontSize: 26,

                    fontWeight:
                    FontWeight.w900,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                const Text(

                  "Watch Premium Movies, Ad Free Streaming & Early Access Content",

                  textAlign:
                  TextAlign.center,

                  style: TextStyle(

                    color:
                    Colors.black87,

                    fontSize: 15,

                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 28,
          ),

          // 🔥 SUBSCRIPTION LIST
          ...plans.map((plan) {

            return Container(

              margin:
              const EdgeInsets.only(
                bottom: 18,
              ),

              padding:
              const EdgeInsets.all(
                18,
              ),

              decoration:
              BoxDecoration(

                borderRadius:
                BorderRadius.circular(
                  22,
                ),

                gradient:
                const LinearGradient(
                  colors: [

                    Color(
                      0xFF1E1E1E,
                    ),

                    Color(
                      0xFF2B2B2B,
                    ),
                  ],
                ),

                border: Border.all(
                  color:
                  Colors.white10,
                ),
              ),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  Row(
                    children: [

                      Container(

                        padding:
                        const EdgeInsets.all(
                          10,
                        ),

                        decoration:
                        BoxDecoration(

                          color:
                          const Color(
                            0xFFE8C37A,
                          ).withOpacity(
                            0.15,
                          ),

                          borderRadius:
                          BorderRadius.circular(
                            14,
                          ),
                        ),

                        child: const Icon(

                          Icons.workspace_premium,

                          color:
                          Color(
                            0xFFE8C37A,
                          ),
                        ),
                      ),

                      const SizedBox(
                        width: 14,
                      ),

                      Expanded(

                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                          children: [

                            Text(

                              plan["title"],

                              style:
                              const TextStyle(

                                color:
                                Colors.white,

                                fontSize:
                                18,

                                fontWeight:
                                FontWeight.w800,
                              ),
                            ),

                            const SizedBox(
                              height:
                              4,
                            ),

                            Text(

                              "${plan["days"]} Days Premium",

                              style:
                              const TextStyle(

                                color:
                                Colors.white60,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Text(

                        "₹${plan["amount"]}",

                        style:
                        const TextStyle(

                          color:
                          Color(
                            0xFFE8C37A,
                          ),

                          fontSize:
                          24,

                          fontWeight:
                          FontWeight.w900,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  GestureDetector(

                    onTap: () {

                      openPayment(plan);
                    },

                    child: Container(

                      height: 54,

                      decoration:
                      BoxDecoration(

                        borderRadius:
                        BorderRadius.circular(
                          16,
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

                          "Upgrade Now",

                          style: TextStyle(

                            color:
                            Colors.black,

                            fontWeight:
                            FontWeight.w900,

                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}