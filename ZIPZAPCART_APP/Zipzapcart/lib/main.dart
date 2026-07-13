import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_links/app_links.dart';

import 'notification_service.dart';
import 'view_product.dart';

import 'splash_screen.dart';
import 'myorder.dart';

final navigatorKey=
GlobalKey<NavigatorState>();

// 🔥 DEEP LINK: zipzapcart://product/<id> opens the shared product directly
void _handleIncomingLink(Uri uri) {

  if (uri.host != "product") {
    return;
  }

  final segments = uri.pathSegments;

  if (segments.isEmpty) {
    return;
  }

  final productId = int.tryParse(segments.first);

  if (productId == null) {
    return;
  }

  navigatorKey.currentState?.push(
    MaterialPageRoute(
      builder: (_) => ViewProductPage(productId: productId),
    ),
  );
}

void _initDeepLinks() {

  final appLinks = AppLinks();

  appLinks.getInitialLink().then((uri) {
    if (uri != null) {
      _handleIncomingLink(uri);
    }
  });

  appLinks.uriLinkStream.listen(_handleIncomingLink);
}

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

  _initDeepLinks();
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

      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        primaryTextTheme: GoogleFonts.poppinsTextTheme(),
      ),

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