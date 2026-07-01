import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';
import 'home.dart';

class LoginPage
    extends StatefulWidget{

  const LoginPage({
    super.key,
  });

  @override
  State<LoginPage>
  createState()=>

      _LoginPageState();

}

class _LoginPageState
    extends State<LoginPage>{

  final phone=

  TextEditingController();

  final password=

  TextEditingController();

  bool loading=false;

  bool hide=true;

  final primary=

  const Color(
    0xFFECA202,
  );

  Future login()
  async{

    if(

    phone.text.isEmpty

        ||

        password.text.isEmpty

    ){

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(

        const SnackBar(

          content:
          Text(
            "Fill all fields",
          ),

        ),

      );

      return;

    }

    loading=true;

    setState((){});

    try{

      final r=

      await ApiService.login(

        phone.text.trim(),

        password.text.trim(),

      );

      print(r);

      if(

      r["status"]

          ==

          true

      ){

        final prefs=

        await SharedPreferences
            .getInstance();

        await prefs.setBool(
          "logged",
          true,
        );

        await prefs.setInt(

          "delivery_id",

          int.parse(

            r["user"]["id"]
                .toString(),

          ),

        );

        await prefs.setString(

          "name",

          r["user"]["name"]
              .toString(),

        );

        if(
        mounted
        ){

          Navigator.pushReplacement(

            context,

            MaterialPageRoute(

              builder:
                  (_)=>

              const HomePage(),

            ),

          );

        }

      }else{

        ScaffoldMessenger.of(
          context,
        )

            .showSnackBar(

          SnackBar(

            content:

            Text(

              r["message"]

                  ??

                  "Login Failed",

            ),

          ),

        );

      }

    }catch(e){

      print(e);

      ScaffoldMessenger.of(
        context,
      )

          .showSnackBar(

        SnackBar(

          content:

          Text(

            e.toString(),

          ),

        ),

      );

    }

    loading=false;

    setState((){});

  }
  @override
  Widget build(
      context,
      ){

    return Scaffold(

      backgroundColor:
      Colors.white,

      body:

      SafeArea(

        child:

        SingleChildScrollView(

          padding:

          const EdgeInsets.all(
            28,
          ),

          child:

          Column(

            children:[

              const SizedBox(
                height:50,
              ),

              Image.asset(

                "assets/logo.png",

                height:140,

              ),

              const SizedBox(
                height:20,
              ),

              Text(

                "Delivery Partner",

                style:

                GoogleFonts.poppins(

                  fontSize:26,

                  fontWeight:
                  FontWeight.w800,

                ),

              ),

              const SizedBox(
                height:10,
              ),

              Text(

                "Login to continue",

                style:

                GoogleFonts.poppins(

                  color:
                  Colors.grey,

                ),

              ),

              const SizedBox(
                height:40,
              ),

              Container(

                decoration:

                BoxDecoration(

                  color:

                  const Color(
                    0xFFF8F8F8,
                  ),

                  borderRadius:

                  BorderRadius.circular(
                    20,
                  ),

                ),

                child:

                TextField(

                  controller:
                  phone,

                  keyboardType:
                  TextInputType.phone,

                  decoration:

                  const InputDecoration(

                    border:
                    InputBorder.none,

                    contentPadding:

                    EdgeInsets.all(
                      20,
                    ),

                    prefixIcon:

                    Icon(
                      Icons.phone,
                    ),

                    hintText:

                    "Phone Number",

                  ),

                ),

              ),

              const SizedBox(
                height:18,
              ),

              Container(

                decoration:

                BoxDecoration(

                  color:

                  const Color(
                    0xFFF8F8F8,
                  ),

                  borderRadius:

                  BorderRadius.circular(
                    20,
                  ),

                ),

                child:

                TextField(

                  controller:
                  password,

                  obscureText:
                  hide,

                  decoration:

                  InputDecoration(

                    border:
                    InputBorder.none,

                    contentPadding:

                    const EdgeInsets.all(
                      20,
                    ),

                    prefixIcon:

                    const Icon(
                      Icons.lock,
                    ),

                    hintText:

                    "Password",

                    suffixIcon:

                    IconButton(

                      onPressed:(){

                        hide=!hide;

                        setState((){});

                      },

                      icon:

                      Icon(

                        hide

                            ?

                        Icons.visibility

                            :

                        Icons.visibility_off,

                      ),

                    ),

                  ),

                ),

              ),

              const SizedBox(
                height:30,
              ),

              SizedBox(

                width:
                double.infinity,

                height:
                58,

                child:

                ElevatedButton(

                  onPressed:

                  loading

                      ?

                  null

                      :

                  login,

                  style:

                  ElevatedButton.styleFrom(

                    backgroundColor:
                    primary,

                    shape:

                    RoundedRectangleBorder(

                      borderRadius:

                      BorderRadius.circular(
                        18,
                      ),

                    ),

                  ),

                  child:

                  loading

                      ?

                  const SizedBox(

                    height:22,

                    width:22,

                    child:

                    CircularProgressIndicator(

                      strokeWidth:2,

                      color:
                      Colors.white,

                    ),

                  )

                      :

                  Text(

                    "LOGIN",

                    style:

                    GoogleFonts.poppins(

                      fontWeight:
                      FontWeight.w700,

                      fontSize:16,

                      color:
                      Colors.white,

                    ),

                  ),

                ),

              ),

            ],

          ),

        ),

      ),

    );

  }

}
