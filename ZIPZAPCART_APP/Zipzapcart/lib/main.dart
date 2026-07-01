import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';

import 'notification_service.dart';

import 'splash_screen.dart';
import 'myorder.dart';

final navigatorKey=
GlobalKey<NavigatorState>();

void main() async {

  WidgetsFlutterBinding
      .ensureInitialized();

  await Firebase
      .initializeApp();



  await SystemChrome
      .setPreferredOrientations([

    DeviceOrientation
        .portraitUp,

    DeviceOrientation
        .portraitDown,

  ]);

  await SystemChrome
      .setEnabledSystemUIMode(

    SystemUiMode
        .immersiveSticky,

    overlays:[],

  );

  runApp(

    const MyApp(),

  );
  await NotificationService
      .init();
}

class MyApp
    extends StatelessWidget{

  const MyApp({
    super.key,
  });

  @override
  Widget build(
      BuildContext context,
      ){

    return MaterialApp(

      navigatorKey:
      navigatorKey,

      debugShowCheckedModeBanner:
      false,

      routes:{

        "/orders":

            (_)=>

        const MyOrderPage(),

      },

      home:

      const SplashScreen(),

    );

  }

}