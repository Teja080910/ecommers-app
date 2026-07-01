import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';
import 'constants.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'orderplaced.dart';
import 'package:geolocator/geolocator.dart';

import 'package:geocoding/geocoding.dart';
class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() =>
      _CheckoutPageState();
}

class _CheckoutPageState
    extends State<CheckoutPage> {

  List items = [];
  int userId = 0;
  bool loading = true;
  double latitude=0;

  double longitude=0;

  bool fetchingLocation=false;
  double subtotal = 0;

  double deliveryCharge=0;

  double walletBalance=0;
  double discount = 0;

  String paymentMethod = "cod";

  Map? selectedAddress;

  late Razorpay razorpay;

  String razorpayKey = "";
  final couponController =
  TextEditingController();

  final nameController =
  TextEditingController();

  final mobileController =
  TextEditingController();

  final addressController =
  TextEditingController();

  final cityController =
  TextEditingController();

  final stateController =
  TextEditingController();

  final pincodeController =
  TextEditingController();

  final Color primaryColor =
  const Color(0xFFECA202);

  @override
  void initState() {
    super.initState();

    razorpay = Razorpay();

    razorpay.on(
      Razorpay.EVENT_PAYMENT_SUCCESS,
      handlePaymentSuccess,
    );

    razorpay.on(
      Razorpay.EVENT_PAYMENT_ERROR,
      handlePaymentError,
    );

    razorpay.on(
      Razorpay.EVENT_EXTERNAL_WALLET,
      handleExternalWallet,
    );

    getUser();

  }
  @override
  void dispose() {

    razorpay.clear();

    super.dispose();
  }
  Future<void> getUser() async {

    final prefs =
    await SharedPreferences.getInstance();

    userId =
        prefs.getInt("user_id") ?? 0;

    loadData();
  }
  Future<void> getRazorpayKey() async {

    var data =
    await ApiService.getRazorpaySettings();

    if (data["status"] == true) {

      razorpayKey =
      data["key_id"];
    }
  }

  void openRazorpay() {

    if (razorpayKey.isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
          Text("Razorpay Key Missing"),
        ),
      );

      return;
    }

    try {

      var options = {

        'key': razorpayKey,

        'amount':
        (finalTotal * 100).toInt(),

        'name': 'Zipzapcart',

        'description':
        'Order Payment',

        'timeout': 300,

        'prefill': {

          'contact':
          selectedAddress?["mobile"]
              .toString() ?? "",

          'email':
          'demo@gmail.com',
        }
      };

      print(options);

      razorpay.open(options);

    } catch (e) {

      print(e);

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
          Text(e.toString()),
        ),
      );
    }
  }

  void handlePaymentSuccess(
      PaymentSuccessResponse response,
      ) async {

    var order =
    await ApiService.placeOrder(
      userId,
      int.parse(
        selectedAddress!["id"]
            .toString(),
      ),

      couponController.text,
      discount,
      subtotal,
      finalTotal,
      "online",
    );

    if (order["status"] == true) {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
          const OrderPlacedPage(),
        ),
      );
    }
  }

  void handlePaymentError(
      PaymentFailureResponse response,
      ) {

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content:
        Text("Payment Failed"),
      ),
    );
  }

  void handleExternalWallet(
      ExternalWalletResponse response,
      ) {}

  Future<void> loadData() async {

    await getRazorpayKey();

    items =
    await ApiService.getCart(userId);

    print(items);

    subtotal = 0;

    for (var item in items) {

      subtotal +=
      (double.parse(
        item["saleprice"]
            .toString(),
      ) *
          int.parse(
            item["quantity"]
                .toString(),
          ));
    }
    final user=

    await ApiService
        .getUser(
      userId,
    );

    if(
    user["status"]==
        true
    ){

      walletBalance=

          double.tryParse(

            user[
            "user"
            ][
            "wallet_balance"
            ]
                .toString(),

          )

              ??

              0;

    }
    var address =
    await ApiService.getDefaultAddress(
      userId,
    );

    if (address["status"] == true) {

      selectedAddress =
      address["address"];
      await loadDeliveryCharge();

    }

    setState(() {
      loading = false;
    });
  }

  double get finalTotal {

    return subtotal +
        deliveryCharge -
        discount;
  }
  Future loadDeliveryCharge()
  async{

    if(
    selectedAddress==
        null
    ){

      deliveryCharge=0;

      return;

    }

    final data=

    await ApiService
        .getDeliveryCharge(

      selectedAddress![
      "pincode"
      ]
          .toString(),

    );

    if(
    data[
    "status"
    ]
        ==
        true
    ){

      deliveryCharge=

          double.parse(

            data[
            "delivery_charge"
            ]
                .toString(),

          );

    }

    setState((){});

  }
  Future<void> applyCoupon() async {

    var data =
    await ApiService.applyCoupon(
      couponController.text,
      subtotal,
    );

    if (data["status"] == true) {

      discount =
          double.parse(
            data["discount"]
                .toString(),
          );

      setState(() {});

      Navigator.pop(context);

    } else {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
          Text(data["message"]),
        ),
      );
    }
  }
  Future fetchCurrentLocation()
  async{

    fetchingLocation=true;

    setState((){});

    LocationPermission permission=

    await Geolocator
        .checkPermission();

    if(
    permission==
        LocationPermission.denied
    ){

      permission=

      await Geolocator
          .requestPermission();

    }

    Position pos=

    await Geolocator
        .getCurrentPosition(

      desiredAccuracy:
      LocationAccuracy.high,

    );

    latitude=
        pos.latitude;

    longitude=
        pos.longitude;

    List<Placemark>
    place=

    await placemarkFromCoordinates(

      latitude,

      longitude,

    );

    if(
    place
        .isNotEmpty
    ){

      cityController.text=
          place.first.locality
              ?? "";

      stateController.text=
          place.first.administrativeArea
              ?? "";

      pincodeController.text=
          place.first.postalCode
              ?? "";

    }

    fetchingLocation=false;

    setState((){});

  }
  Future<void> saveAddress() async {

    var data =
    await ApiService
        .saveAddress(

      userId,

      nameController.text,

      mobileController.text,

      addressController.text,

      cityController.text,

      stateController.text,

      pincodeController.text,

      latitude,

      longitude,

    );

    if (data["status"] == true) {

      Navigator.pop(context);

      selectedAddress=null;

      deliveryCharge=0;

      await loadData();

    }else {

      Navigator.pop(context);

      nameController.clear();
      mobileController.clear();
      addressController.clear();
      cityController.clear();
      stateController.clear();
      pincodeController.clear();

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
          Text(data["message"]),
        ),
      );
    }
  }

  void couponBottomSheet() {

    showModalBottomSheet(
      context: context,

      backgroundColor: Colors.white,

      shape:
      const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),

      builder: (_) {

        return Padding(
          padding:
          const EdgeInsets.all(20),

          child: Column(
            mainAxisSize:
            MainAxisSize.min,

            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [

              Text(
                "Apply Coupon",

                style:
                GoogleFonts.poppins(
                  fontSize: 18,

                  fontWeight:
                  FontWeight.w700,
                ),
              ),

              const SizedBox(height: 18),

              TextField(
                controller:
                couponController,

                decoration:
                InputDecoration(
                  hintText:
                  "Enter Coupon Code",

                  filled: true,

                  fillColor:
                  const Color(
                    0xFFF7F7F7,
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

              const SizedBox(height: 20),

              SizedBox(
                width:
                double.infinity,

                height: 56,

                child:
                ElevatedButton(

                  onPressed: () {

                    applyCoupon();
                  },

                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    primaryColor,

                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        18,
                      ),
                    ),
                  ),

                  child: Text(
                    "Apply Coupon",

                    style:
                    GoogleFonts.poppins(
                      color:
                      Colors.white,

                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void addressBottomSheet() {

    showModalBottomSheet(
      context: context,

      isScrollControlled: true,

      backgroundColor: Colors.white,

      shape:
      const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(
          top: Radius.circular(32),
        ),
      ),

      builder: (_) {

        return StatefulBuilder(
          builder:
              (context, setSheet) {

            return Padding(
              padding:
              EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,

                bottom:
                MediaQuery.of(
                  context,
                ).viewInsets.bottom +
                    24,
              ),

              child:
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

                  children: [

                    Center(
                      child: Container(
                        width: 60,
                        height: 5,

                        decoration:
                        BoxDecoration(
                          color:
                          Colors.grey
                              .shade300,

                          borderRadius:
                          BorderRadius.circular(
                            20,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    Text(
                      "Add Address",

                      style:
                      GoogleFonts.poppins(
                        fontSize: 22,

                        fontWeight:
                        FontWeight
                            .w700,
                      ),
                    ),

                    const SizedBox(
                      height: 22,
                    ),

                    customField(
                      controller:
                      nameController,

                      hint:
                      "Full Name",
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    customField(
                      controller:
                      mobileController,

                      hint:
                      "Mobile Number",
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    customField(
                      controller:
                      addressController,

                      hint:
                      "Full Address",

                      lines: 3,
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    Row(
                      children: [

                        Expanded(
                          child:
                          customField(
                            controller:
                            cityController,

                            hint:
                            "City",
                          ),
                        ),

                        const SizedBox(
                          width: 14,
                        ),

                        Expanded(
                          child:
                          customField(
                            controller:
                            stateController,

                            hint:
                            "State",
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    customField(
                      controller:
                      pincodeController,

                      hint:
                      "Pincode",
                    ),

                    const SizedBox(
                      height: 24,
                    ),
                    SizedBox(

                      width:
                      double.infinity,

                      height:
                      56,

                      child:

                      OutlinedButton(

                        onPressed:

                        fetchingLocation

                            ?

                        null

                            :

                        fetchCurrentLocation,

                        child:

                        Text(

                          fetchingLocation

                              ?

                          "Fetching Location..."

                              :

                          "Use Current Location",

                        ),

                      ),

                    ),
                    SizedBox(
                      width:
                      double.infinity,

                      height: 58,

                      child:
                      ElevatedButton(

                        onPressed: () {

                          saveAddress();
                        },

                        style:
                        ElevatedButton.styleFrom(
                          backgroundColor:
                          primaryColor,

                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(
                              20,
                            ),
                          ),
                        ),

                        child: Text(
                          "Save Address",

                          style:
                          GoogleFonts.poppins(
                            color:
                            Colors.white,

                            fontWeight:
                            FontWeight
                                .w700,
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
      },
    );
  }

  Widget customField({
    required TextEditingController
    controller,
    required String hint,
    int lines = 1,
  }) {

    return TextField(
      controller: controller,
      maxLines: lines,

      decoration: InputDecoration(
        hintText: hint,

        filled: true,

        fillColor:
        const Color(0xFFF7F7F7),

        contentPadding:
        const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
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
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      const Color(0xFFF5F5F5),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,

        title: Text(
          "Checkout",

          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      bottomNavigationBar:
      loading
          ? null
          : Container(
        padding:
        const EdgeInsets.all(18),

        color: Colors.white,

        child: SizedBox(
          height: 58,

          child:
          ElevatedButton(

            onPressed: () async {
              print("BUTTON CLICKED");
              print(userId);
              print(selectedAddress);
              print(finalTotal);
              if (selectedAddress == null) {

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Please add address",
                    ),
                  ),
                );

                return;
              }

              if (paymentMethod == "online") {

                openRazorpay();

              } else {

                var order =
                await ApiService.placeOrder(
                  userId,

                  int.parse(
                    selectedAddress!["id"]
                        .toString(),
                  ),

                  couponController.text,

                  discount,

                  subtotal,

                  finalTotal,

                  paymentMethod,

                );

                print(order);

                if (order["status"] == true) {

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                      const OrderPlacedPage(),
                    ),
                  );

                } else {

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    SnackBar(
                      content: Text(
                        order["message"]
                            .toString(),
                      ),
                    ),
                  );
                }
              }
            },
            style:
            ElevatedButton.styleFrom(
              backgroundColor:
              primaryColor,

              shape:
              RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(
                  18,
                ),
              ),
            ),

            child: Text(
              "Place Order ₹$finalTotal",

              style:
              GoogleFonts.poppins(
                color: Colors.white,

                fontWeight:
                FontWeight.w700,

                fontSize: 16,
              ),
            ),
          ),
        ),
      ),

      body: loading

          ? Center(
        child:
        CircularProgressIndicator(
          color: primaryColor,
        ),
      )
          : SingleChildScrollView(
        padding:
        const EdgeInsets.all(16),

        child: Column(
          children: [

            // 🔥 ADDRESS
            Container(
              padding:
              const EdgeInsets.all(
                18,
              ),

              decoration:
              BoxDecoration(
                color:
                Colors.white,

                borderRadius:
                BorderRadius.circular(
                  24,
                ),
              ),

              child: Column(
                children: [

                  Row(
                    children: [

                      Expanded(
                        child: Text(
                          "Delivery Address",

                          style:
                          GoogleFonts.poppins(
                            fontSize:
                            18,

                            fontWeight:
                            FontWeight
                                .w700,
                          ),
                        ),
                      ),

                      GestureDetector(

                        onTap: () {

                          addressBottomSheet();
                        },

                        child: Container(
                          padding:
                          const EdgeInsets.symmetric(
                            horizontal:
                            14,

                            vertical:
                            8,
                          ),

                          decoration:
                          BoxDecoration(
                            color:
                            primaryColor
                                .withOpacity(
                              0.12,
                            ),

                            borderRadius:
                            BorderRadius.circular(
                              30,
                            ),
                          ),

                          child: Text(
                            selectedAddress ==
                                null
                                ? "Add"
                                : "Change",

                            style:
                            GoogleFonts.poppins(
                              color:
                              primaryColor,

                              fontWeight:
                              FontWeight
                                  .w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  if (selectedAddress ==
                      null)

                    Text(
                      "No Address Added",

                      style:
                      GoogleFonts.poppins(
                        color:
                        Colors.grey,
                      ),
                    )

                  else

                    Row(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                      children: [

                        Icon(
                          Icons.location_on,
                          color:
                          primaryColor,
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
                                selectedAddress![
                                "full_name"],

                                style:
                                GoogleFonts.poppins(
                                  fontWeight:
                                  FontWeight
                                      .w700,
                                ),
                              ),

                              const SizedBox(
                                height: 6,
                              ),

                              Text(
                                "${selectedAddress!["address"]}, ${selectedAddress!["city"]}, ${selectedAddress!["state"]} - ${selectedAddress!["pincode"]}",

                                style:
                                GoogleFonts.poppins(
                                  height:
                                  1.6,

                                  color:
                                  Colors.grey
                                      .shade700,
                                ),
                              ),

                              const SizedBox(
                                height: 6,
                              ),

                              Text(
                                selectedAddress![
                                "mobile"],

                                style:
                                GoogleFonts.poppins(
                                  fontWeight:
                                  FontWeight
                                      .w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 🔥 ORDER ITEMS
            Container(
              padding:
              const EdgeInsets.all(
                18,
              ),

              decoration:
              BoxDecoration(
                color:
                Colors.white,

                borderRadius:
                BorderRadius.circular(
                  24,
                ),
              ),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,

                children: [

                  Text(
                    "Order Items",

                    style:
                    GoogleFonts.poppins(
                      fontSize: 18,

                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 18),

                  ...List.generate(
                    items.length,

                        (index) {

                      final item =
                      items[index];

                      return Container(

                        margin:
                        const EdgeInsets.only(
                          bottom: 14,
                        ),

                        child: Row(
                          children: [

                            Container(
                              height: 80,
                              width: 80,

                              padding:
                              const EdgeInsets.all(
                                10,
                              ),

                              decoration:
                              BoxDecoration(
                                color:
                                const Color(
                                  0xFFF7F7F7,
                                ),

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
                              width: 14,
                            ),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                                children: [

                                  Text(
                                    item["name"],

                                    maxLines:
                                    2,

                                    overflow:
                                    TextOverflow
                                        .ellipsis,

                                    style:
                                    GoogleFonts.poppins(
                                      fontWeight:
                                      FontWeight
                                          .w600,
                                    ),
                                  ),

                                  const SizedBox(
                                    height:
                                    8,
                                  ),

                                  Text(
                                    "Qty : ${item["quantity"]}",

                                    style:
                                    GoogleFonts.poppins(
                                      color:
                                      Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Text(
                              "₹${item["saleprice"]}",

                              style:
                              GoogleFonts.poppins(
                                fontWeight:
                                FontWeight
                                    .w700,

                                color:
                                primaryColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 🔥 COUPON
            GestureDetector(

              onTap: () {

                couponBottomSheet();
              },

              child: Container(
                padding:
                const EdgeInsets.all(
                  18,
                ),

                decoration:
                BoxDecoration(
                  color:
                  Colors.white,

                  borderRadius:
                  BorderRadius.circular(
                    24,
                  ),
                ),

                child: Row(
                  children: [

                    Icon(
                      Icons.discount,
                      color:
                      primaryColor,
                    ),

                    const SizedBox(
                      width: 14,
                    ),

                    Expanded(
                      child: Text(
                        couponController
                            .text
                            .isEmpty
                            ? "Apply Coupon"
                            : couponController
                            .text,

                        style:
                        GoogleFonts.poppins(
                          fontWeight:
                          FontWeight
                              .w600,
                        ),
                      ),
                    ),

                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color:
                      Colors.grey,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // 🔥 PAYMENT
            Container(
              padding:
              const EdgeInsets.all(
                18,
              ),

              decoration:
              BoxDecoration(
                color:
                Colors.white,

                borderRadius:
                BorderRadius.circular(
                  24,
                ),
              ),

              child: Column(
                children: [

                  RadioListTile(
                    value: "cod",
                    groupValue:
                    paymentMethod,

                    onChanged: (v) {

                      setState(() {
                        paymentMethod =
                        v!;
                      });
                    },

                    activeColor:
                    primaryColor,

                    title: Text(
                      "Cash On Delivery",

                      style:
                      GoogleFonts.poppins(
                        fontWeight:
                        FontWeight
                            .w600,
                      ),
                    ),
                  ),
                  if(
                  walletBalance>
                      finalTotal
                  )

                    RadioListTile(

                      value:
                      "wallet",

                      groupValue:
                      paymentMethod,

                      onChanged:(v){

                        setState((){

                          paymentMethod=
                          v!;

                        });

                      },

                      activeColor:
                      primaryColor,

                      title:

                      Text(

                        "Wallet (₹${walletBalance.toStringAsFixed(0)})",

                        style:

                        GoogleFonts.poppins(

                          fontWeight:
                          FontWeight.w600,

                        ),

                      ),

                    ),
                  RadioListTile(
                    value: "online",
                    groupValue:
                    paymentMethod,

                    onChanged: (v) {

                      setState(() {
                        paymentMethod =
                        v!;
                      });
                    },

                    activeColor:
                    primaryColor,

                    title: Text(
                      "Online UPI/CARD/NETBANKING",

                      style:
                      GoogleFonts.poppins(
                        fontWeight:
                        FontWeight
                            .w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // 🔥 PRICE DETAILS
            Container(
              padding:
              const EdgeInsets.all(
                18,
              ),

              decoration:
              BoxDecoration(
                color:
                Colors.white,

                borderRadius:
                BorderRadius.circular(
                  24,
                ),
              ),

              child: Column(
                children: [

                  priceRow(
                    "Subtotal",
                    subtotal,
                  ),

                  const SizedBox(height: 14),

                  priceRow(
                    "Delivery Charges",
                    deliveryCharge,
                  ),

                  const SizedBox(height: 14),

                  priceRow(
                    "Discount",
                    -discount,
                  ),

                  const Divider(
                    height: 28,
                  ),

                  Row(
                    children: [

                      Expanded(
                        child: Text(
                          "Total",

                          style:
                          GoogleFonts.poppins(
                            fontSize:
                            20,

                            fontWeight:
                            FontWeight
                                .w700,
                          ),
                        ),
                      ),

                      Text(
                        "₹$finalTotal",

                        style:
                        GoogleFonts.poppins(
                          fontSize:
                          24,

                          fontWeight:
                          FontWeight
                              .w700,

                          color:
                          primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget priceRow(
      String title,
      double value,
      ) {

    return Row(
      children: [

        Expanded(
          child: Text(
            title,

            style:
            GoogleFonts.poppins(
              fontSize: 14,
            ),
          ),
        ),

        Text(
          "₹$value",

          style:
          GoogleFonts.poppins(
            fontWeight:
            FontWeight.w600,
          ),
        ),
      ],
    );
  }
}