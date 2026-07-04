import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notification_service.dart';
import 'api_service.dart';
import 'home.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController phoneController = TextEditingController();
  static const Color themeRed =
  Color(0xFFEF4138);
  String verificationId = "";
  bool isLoading = false;

  // 🔥 SEND OTP
  Future<void> sendOtp() async {
    setState(() => isLoading = true);

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: "+91${phoneController.text}",

      verificationCompleted: (PhoneAuthCredential credential) async {
        final userCred =
        await FirebaseAuth.instance.signInWithCredential(credential);

        final res = await ApiService.loginOrRegister({
          "phone": phoneController.text,
          "firebase_uid": userCred.user!.uid,
        });

        await _saveLogin(res);
      },

      verificationFailed: (FirebaseAuthException e) {
        setState(() => isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(e.message ?? "OTP Failed"),
          ),
        );
      },

      codeSent: (String verId, int? resendToken) {
        verificationId = verId;

        setState(() => isLoading = false);

        _showOtpSheet();
      },

      codeAutoRetrievalTimeout: (String verId) {},
    );
  }

  // 🔥 VERIFY OTP
  Future<void> verifyOtp(
      String otp, {
        required VoidCallback onInvalidOtp,
      }) async {

    setState(() => isLoading = true);

    try {

      PhoneAuthCredential credential =
      PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      await FirebaseAuth.instance
          .signInWithCredential(credential);

      var res=

      await ApiService
          .loginOrRegister({

        "phone":
        phoneController.text,

      });

      if (res["status"] != true) {

        setState(() => isLoading = false);

        onInvalidOtp();

        return;
      }

      // 🔥 SAVE SESSION *BEFORE* ANY AUTHENTICATED CALL,
      // so ApiService's auth params pick up the fresh id/token.
      final prefs = await SharedPreferences.getInstance();

      prefs.setInt(
        "user_id",
        int.parse(res["user"]["id"].toString()),
      );

      prefs.setString(
        "auth_token",
        res["token"]?.toString() ?? "",
      );

      prefs.setBool("isLoggedIn", true);

      final token=

      await NotificationService
          .getToken();

      await ApiService
          .saveFcmToken(

        int.parse(

          res["user"]["id"]
              .toString(),

        ),

        token,

      );

      setState(() => isLoading = false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomePage(),
        ),
      );

    } on FirebaseAuthException catch (e) {

      setState(() => isLoading = false);

      debugPrint(
        "🔥 OTP VERIFY FAILED — code: ${e.code}, message: ${e.message}",
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 6),
            content: Text(
              "Firebase error [${e.code}]: ${e.message ?? 'unknown'}",
            ),
          ),
        );
      }

      onInvalidOtp();

    } catch (e) {

      setState(() => isLoading = false);

      debugPrint("🔥 OTP VERIFY FAILED — non-Firebase error: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 6),
            content: Text("Login error: $e"),
          ),
        );
      }

      onInvalidOtp();
    }
  }

  // 🔥 SAVE LOGIN
  Future<void> _saveLogin(Map<String, dynamic> res) async {
    final prefs = await SharedPreferences.getInstance();

    if (res["status"] == true && res["user"] != null) {

      prefs.setInt(
        "user_id",
        int.parse(res["user"]["id"].toString()),
      );

      prefs.setString(
        "auth_token",
        res["token"]?.toString() ?? "",
      );
    }

    await prefs.setBool("isLoggedIn", true);

    setState(() => isLoading = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  // 🔥 OTP SHEET
  void _showOtpSheet() {

    final List<TextEditingController>
    otpControllers =
    List.generate(
      6,
          (_) => TextEditingController(),
    );

    final List<FocusNode>
    focusNodes =
    List.generate(
      6,
          (_) => FocusNode(),
    );

    String? otpError;
    bool sheetMounted = true;

    showModalBottomSheet(

      context: context,

      isScrollControlled: true,

      backgroundColor:
      const Color(
        0xFFF8F8F8,
      ),

      shape:
      const RoundedRectangleBorder(

        borderRadius:
        BorderRadius.vertical(

          top:
          Radius.circular(
            34,
          ),
        ),
      ),

      builder: (context) {

        return StatefulBuilder(
          builder: (context, setModalState) {

        return SafeArea(

          top: false,

          child:
          AnimatedPadding(

            duration:
            const Duration(
              milliseconds: 250,
            ),

            curve:
            Curves.easeOut,

            padding:
            EdgeInsets.only(

              left: 22,

              right: 22,

              top: 24,

              bottom:

              MediaQuery.of(
                context,
              )
                  .viewInsets
                  .bottom +

                  MediaQuery.of(
                    context,
                  )
                      .padding
                      .bottom +

                  24,
            ),

            child:
            SingleChildScrollView(

              child:

              Column(

                mainAxisSize:
                MainAxisSize.min,

                children: [

                  Container(

                    width: 70,

                    height: 5,

                    decoration:
                    BoxDecoration(

                      color:
                      Colors.black12,

                      borderRadius:
                      BorderRadius.circular(
                        50,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  const Text(

                    "Verify OTP",

                    style:
                    TextStyle(

                      fontSize: 26,

                      fontWeight:
                      FontWeight.bold,

                      color:
                      Color(
                        0xFF0A2A75,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Text(

                    "Enter the 6-digit code sent to +91 ${phoneController.text}",

                    textAlign:
                    TextAlign.center,

                    style:
                    TextStyle(

                      color:
                      Colors.black
                          .withOpacity(
                        0.6,
                      ),

                      fontSize:
                      15,
                    ),
                  ),

                  const SizedBox(
                    height: 30,
                  ),

                  Row(

                    mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,

                    children:

                    List.generate(
                      6,
                          (index) {

                        return SizedBox(

                          width: 46,

                          height: 60,

                          child:

                          TextField(

                            controller:
                            otpControllers[index],

                            focusNode:
                            focusNodes[index],

                            keyboardType:
                            TextInputType.number,

                            textAlign:
                            TextAlign.center,

                            maxLength: 1,

                            style:
                            const TextStyle(

                              fontSize:
                              22,

                              fontWeight:
                              FontWeight.bold,
                            ),

                            decoration:
                            InputDecoration(

                              counterText:
                              "",

                              filled:
                              true,

                              fillColor:
                              Colors.white,

                              enabledBorder:

                              OutlineInputBorder(

                                borderRadius:
                                BorderRadius.circular(
                                  18,
                                ),

                                borderSide:

                                BorderSide(

                                  color:
                                  otpError != null
                                      ? Colors.red
                                      : Colors
                                      .grey
                                      .shade300,

                                  width:
                                  1.6,
                                ),
                              ),

                              focusedBorder:

                              OutlineInputBorder(

                                borderRadius:
                                BorderRadius.circular(
                                  18,
                                ),

                                borderSide:

                                const BorderSide(

                                  color:
                                  themeRed,

                                  width:
                                  2.5,
                                ),
                              ),
                            ),

                            onChanged:
                                (value) {

                              if(
                              otpError != null &&
                              sheetMounted
                              ){

                                setModalState(() {
                                  otpError = null;
                                });
                              }

                              if(
                              value
                                  .isNotEmpty
                              ){

                                if(
                                index
                                    <
                                    5
                                ){

                                  FocusScope.of(
                                    context,
                                  )
                                      .requestFocus(

                                    focusNodes[
                                    index+1
                                    ],
                                  );
                                }

                              }else{

                                if(
                                index
                                    >
                                    0
                                ){

                                  FocusScope.of(
                                    context,
                                  )
                                      .requestFocus(

                                    focusNodes[
                                    index-1
                                    ],
                                  );
                                }
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  if(otpError != null) ...[

                    const SizedBox(
                      height: 12,
                    ),

                    Text(
                      otpError!,

                      textAlign:
                      TextAlign.center,

                      style:
                      const TextStyle(
                        color: Colors.red,
                        fontSize: 13,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                  ],

                  const SizedBox(
                    height: 30,
                  ),

                  SizedBox(

                    width:
                    double.infinity,

                    height:
                    58,

                    child:

                    ElevatedButton(

                      onPressed: () {

                        String otp =

                        otpControllers

                            .map(
                              (e)
                          =>
                          e.text,
                        )

                            .join();

                        if(
                        otp.length
                            ==
                            6
                        ){

                          verifyOtp(
                            otp,
                            onInvalidOtp: () {

                              if (!sheetMounted) {
                                return;
                              }

                              setModalState(() {

                                otpError =
                                "Incorrect OTP. Please try again.";

                                for(
                                final c
                                in otpControllers
                                ){
                                  c.clear();
                                }
                              });

                              FocusScope.of(
                                context,
                              ).requestFocus(
                                focusNodes[0],
                              );
                            },
                          );

                        }else{

                          setModalState(() {
                            otpError =
                            "Please enter the complete 6-digit OTP";
                          });
                        }
                      },

                      style:
                      ElevatedButton
                          .styleFrom(

                        elevation:
                        10,

                        backgroundColor:

                        themeRed,
                        foregroundColor:

                        Colors.white,

                        shape:

                        RoundedRectangleBorder(

                          borderRadius:
                          BorderRadius.circular(
                            22,
                          ),
                        ),
                      ),

                      child:
                      const Text(

                        "Verify OTP",

                        style:
                        TextStyle(

                          fontWeight:
                          FontWeight.bold,

                          fontSize:
                          17,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                ],
              ),
            ),
          ),
        );
          },
        );
      },
    ).then((_) {
      sheetMounted = false;
    });
  }
  // 🔥 PHONE FIELD
  Widget _phoneInputField() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.18),
            Colors.white.withOpacity(0.08),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color:
              themeRed
                  .withOpacity(
                0.20,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              "+91",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),

          const SizedBox(width: 14),

          Container(
            width: 1,
            height: 26,
            color: Colors.white24,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: TextField(
              controller: phoneController,
              keyboardType: TextInputType.number,
              maxLength: 10,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              decoration: const InputDecoration(
                counterText: "",
                border: InputBorder.none,
                hintText: "Enter mobile number",
                hintStyle: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,

      body: Stack(
        children: [
          // 🔥 BACKGROUND IMAGE
          Positioned.fill(
            child: Image.asset(
              "assets/images/back.png",
              fit: BoxFit.cover,
            ),
          ),

          // 🔥 DARK OVERLAY
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.15),
                    Colors.black.withOpacity(0.55),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              padding: EdgeInsets.fromLTRB(
                22,
                22,
                22,
                22 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),

                  // 🔥 GLASS CARD
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(34),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.18),
                          Colors.white.withOpacity(0.08),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.18),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Welcome to Zipzapcart",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          "India's Smart Shopping Experience",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.78),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 30),

                        _phoneInputField(),

                        const SizedBox(height: 24),

                        // 🔥 LOGIN BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: () {
                              if (phoneController.text.length == 10) {
                                sendOtp();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Enter valid mobile number",
                                    ),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 10,
                              backgroundColor:
                              themeRed,

                              foregroundColor:
                              Colors.white,

                              shadowColor:
                              themeRed
                                  .withOpacity(
                                0.50,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [
                                Icon(Icons.phone_rounded, size: 22),
                                SizedBox(width: 10),
                                Text(
                                  "Continue with Phone",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        Center(
                          child: Text(
                            "Secure Login with OTP",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 🔥 LOADER
          if (isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  color: themeRed,
                ),
              ),
            ),
        ],
      ),
    );
  }
}