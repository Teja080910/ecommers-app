import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'login.dart';
import 'home.dart';

class SplashPage
    extends StatefulWidget{

  const SplashPage({
    super.key,
  });

  @override
  State<SplashPage>
  createState()=>

      _SplashPageState();

}

class _SplashPageState
    extends State<SplashPage>{

  @override
  void initState(){

    super.initState();

    go();

  }

  Future go()
  async{

    await Future.delayed(

      const Duration(
        seconds:2,
      ),

    );

    final prefs=

    await SharedPreferences
        .getInstance();

    bool logged=

        prefs.getBool(
            "logged"
        )

            ??

            false;

    Navigator.pushReplacement(

      context,

      MaterialPageRoute(

        builder:

            (_)=>

        logged

            ?

        const HomePage()

            :

        const LoginPage(),

      ),

    );

  }

  @override
  Widget build(
      context,
      ){

    return Scaffold(

      backgroundColor:
      Colors.white,

      body:

      Center(

        child:

        Column(

          mainAxisAlignment:
          MainAxisAlignment.center,

          children:[

            Image.asset(

              "assets/logo.png",

              height:140,

            ),

            const SizedBox(
              height:30,
            ),

            const CircularProgressIndicator(),

          ],

        ),

      ),

    );

  }

}
