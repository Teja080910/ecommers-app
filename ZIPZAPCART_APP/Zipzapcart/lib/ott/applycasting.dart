import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api_service.dart';

class ApplyCastingPage extends StatefulWidget {

  final Map casting;

  const ApplyCastingPage({

    super.key,

    required this.casting,
  });

  @override
  State<ApplyCastingPage> createState() =>
      _ApplyCastingPageState();
}

class _ApplyCastingPageState
    extends State<ApplyCastingPage> {

  final nameController =
  TextEditingController();

  final heightController =
  TextEditingController();

  final weightController =
  TextEditingController();

  final experienceController =
  TextEditingController();

  List<File> photos = [];

  File? video;

  bool loading = false;

  late Razorpay razorpay;

  final picker =
  ImagePicker();

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
  }

  @override
  void dispose() {

    razorpay.clear();

    super.dispose();
  }

  Future<void> pickPhotos() async {

    final picked =
    await picker.pickMultiImage();

    if (picked.isNotEmpty) {

      photos =
          picked
              .take(6)
              .map(
                (e) =>
                File(e.path),
          )
              .toList();

      setState(() {});
    }
  }

  Future<void> pickVideo() async {

    final picked =
    await picker.pickVideo(

      source:
      ImageSource.gallery,
    );

    if (picked != null) {

      File file =
      File(picked.path);

      double size =
          await file.length() /
              1024 /
              1024;

      if (size > 50) {

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(

          const SnackBar(
            content: Text(
              "Max Video Size 50MB",
            ),
          ),
        );

        return;
      }

      video = file;

      setState(() {});
    }
  }

  Future<void>
  submitApplication() async {

    final prefs =
    await SharedPreferences
        .getInstance();

    int userId =
        prefs.getInt(
          "user_id",
        ) ??
            0;

    setState(() {

      loading = true;
    });

    final res =
    await ApiService
        .submitCastingApplication(

      userId:
      userId.toString(),

      castingId:
      widget.casting["id"]
          .toString(),

      name:
      nameController.text,

      height:
      heightController.text,

      weight:
      weightController.text,

      experience:
      experienceController.text,

      photos:
      photos,

      video:
      video!,
    );

    setState(() {

      loading = false;
    });

    if (res["status"] == true) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          backgroundColor:
          Colors.green,

          content: Text(
            "Application Submitted",
          ),
        ),
      );

      Navigator.pop(context);

    } else {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          backgroundColor:
          Colors.red,

          content: Text(
            "Submission Failed",
          ),
        ),
      );
    }
  }

  void openRazorpay() {

    var options = {

      'key':
      'rzp_test_xxxxxxxxx',

      'amount':
      (int.parse(
        widget.casting[
        "amount"]
            .toString(),
      ) *
          100),

      'name':
      'Zenvora Casting',

      'description':
      widget.casting[
      "title"],

      'prefill': {

        'contact':
        '',

        'email':
        ''
      },

      'theme': {

        'color':
        '#0A84FF'
      }
    };

    try {

      razorpay.open(
        options,
      );

    } catch (e) {

      print(e.toString());
    }
  }

  void handlePaymentSuccess(
      PaymentSuccessResponse
      response,
      ) async {

    await submitApplication();
  }

  void handlePaymentError(
      PaymentFailureResponse
      response,
      ) {

    ScaffoldMessenger.of(context)
        .showSnackBar(

      const SnackBar(

        backgroundColor:
        Colors.red,

        content:
        Text(
          "Payment Failed",
        ),
      ),
    );
  }

  void handleExternalWallet(
      ExternalWalletResponse
      response,
      ) {}

  @override
  Widget build(BuildContext context) {

    bool isFree =
        widget.casting["isfree"] ==
            "yes";

    return Scaffold(

      backgroundColor:
      Colors.black,

      appBar: AppBar(

        backgroundColor:
        Colors.black,

        elevation: 0,

        iconTheme:
        const IconThemeData(

          color: Colors.white,
        ),

        title: const Text(

          "Apply Now",

          style: TextStyle(

            color:
            Colors.white,

            fontWeight:
            FontWeight.w700,
          ),
        ),
      ),


      body: SingleChildScrollView(

        padding:
        const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            // 🔥 TITLE
            Text(

              widget.casting["title"],

              style:
              const TextStyle(

                color:
                Colors.white,

                fontSize:
                22,

                fontWeight:
                FontWeight.w800,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            Container(

              padding:
              const EdgeInsets.symmetric(

                horizontal: 12,
                vertical: 8,
              ),

              decoration:
              BoxDecoration(

                color:
                isFree

                    ? Colors.green

                    : Colors.orange,

                borderRadius:
                BorderRadius.circular(
                  30,
                ),
              ),

              child: Text(

                isFree

                    ? "FREE APPLY"

                    : "₹${widget.casting["amount"]}",

                style:
                const TextStyle(

                  color:
                  Colors.white,

                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            TextField(

              controller:
              nameController,

              style:
              const TextStyle(
                color:
                Colors.white,
              ),

              decoration:
              inputDecoration(
                "Full Name",
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            TextField(

              controller:
              heightController,

              style:
              const TextStyle(
                color:
                Colors.white,
              ),

              decoration:
              inputDecoration(
                "Height",
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            TextField(

              controller:
              weightController,

              style:
              const TextStyle(
                color:
                Colors.white,
              ),

              decoration:
              inputDecoration(
                "Weight",
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            TextField(

              controller:
              experienceController,

              maxLines: 4,

              style:
              const TextStyle(
                color:
                Colors.white,
              ),

              decoration:
              inputDecoration(
                "Work Experience",
              ),
            ),

            const SizedBox(
              height: 22,
            ),

            GestureDetector(

              onTap: pickPhotos,

              child: Container(

                height: 120,

                width:
                double.infinity,

                decoration:
                BoxDecoration(

                  color:
                  const Color(
                    0xFF151515,
                  ),

                  border:
                  Border.all(
                    color:
                    Colors.white24,
                  ),

                  borderRadius:
                  BorderRadius.circular(
                    16,
                  ),
                ),

                child: Center(

                  child: Text(

                    photos.isEmpty

                        ? "Upload Photos (Max 6)"

                        : "${photos.length} Photos Selected",

                    style:
                    const TextStyle(
                      color:
                      Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            GestureDetector(

              onTap: pickVideo,

              child: Container(

                height: 120,

                width:
                double.infinity,

                decoration:
                BoxDecoration(

                  color:
                  const Color(
                    0xFF151515,
                  ),

                  border:
                  Border.all(
                    color:
                    Colors.white24,
                  ),

                  borderRadius:
                  BorderRadius.circular(
                    16,
                  ),
                ),

                child: Center(

                  child: Text(

                    video == null

                        ? "Upload Video (Max 50MB)"

                        : "Video Selected",

                    style:
                    const TextStyle(
                      color:
                      Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            SizedBox(

              width:
              double.infinity,

              height: 55,

              child:
              ElevatedButton(

                onPressed:
                loading

                    ? null

                    : () async {

                  if (nameController
                      .text
                      .isEmpty ||

                      heightController
                          .text
                          .isEmpty ||

                      weightController
                          .text
                          .isEmpty ||

                      experienceController
                          .text
                          .isEmpty ||

                      photos
                          .isEmpty ||

                      video ==
                          null) {

                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(

                      const SnackBar(
                        content:
                        Text(
                          "Fill All Fields",
                        ),
                      ),
                    );

                    return;
                  }

                  if (isFree) {

                    await submitApplication();

                  } else {

                    openRazorpay();
                  }
                },

                style:
                ElevatedButton.styleFrom(

                  backgroundColor:
                  const Color(
                    0xFF0A84FF,
                  ),

                  shape:
                  RoundedRectangleBorder(

                    borderRadius:
                    BorderRadius.circular(
                      14,
                    ),
                  ),
                ),

                child:
                loading

                    ? const SizedBox(

                  height: 24,
                  width: 24,

                  child:
                  CircularProgressIndicator(

                    color:
                    Colors.white,
                  ),
                )

                    : Text(

                  isFree

                      ? "Submit Application"

                      : "Pay & Apply",

                  style:
                  const TextStyle(

                    color:
                    Colors.white,

                    fontWeight:
                    FontWeight.w700,

                    fontSize:
                    15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration inputDecoration(
      String text,
      ) {

    return InputDecoration(

      hintText: text,

      hintStyle:
      const TextStyle(
        color:
        Colors.white54,
      ),

      filled: true,

      fillColor:
      const Color(0xFF151515),

      border:
      OutlineInputBorder(

        borderRadius:
        BorderRadius.circular(
          14,
        ),

        borderSide:
        BorderSide.none,
      ),
    );
  }
}