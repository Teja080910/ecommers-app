import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'main.dart';

class NotificationService{

  static final local=

  FlutterLocalNotificationsPlugin();

  static Future init()
  async{

    await FirebaseMessaging
        .instance
        .requestPermission(

      alert:true,

      badge:true,

      sound:true,

    );

    final token=

    await FirebaseMessaging
        .instance
        .getToken();

    print(
      "FCM TOKEN = $token",
    );

// LOCAL INIT

    await local.initialize(

      const InitializationSettings(

        android:

        AndroidInitializationSettings(

          '@mipmap/ic_launcher',

        ),

      ),

      onDidReceiveNotificationResponse:
          (_){

        openOrders();

      },

    );

// FOREGROUND

    FirebaseMessaging
        .onMessage
        .listen(

          (message) async{

        print(
          message.notification?.title,
        );

        print(
          message.notification?.body,
        );

        await local.show(

          0,

          message
              .notification
              ?.title

              ??

              "Notification",

          message
              .notification
              ?.body

              ??

              "",

          const NotificationDetails(

            android:

            AndroidNotificationDetails(

              "orders",

              "Orders",

              importance:
              Importance.max,

              priority:
              Priority.high,

              playSound:true,

            ),

          ),

          payload:
          "orders",

        );

      },

    );

// BACKGROUND TAP

    FirebaseMessaging
        .onMessageOpenedApp
        .listen(

          (message){

        openOrders();

      },

    );

// APP CLOSED

    final initial=

    await FirebaseMessaging
        .instance
        .getInitialMessage();

    if(
    initial!=null
    ){

      Future.delayed(

        const Duration(
          milliseconds:500,
        ),

            (){

          openOrders();

        },

      );

    }

  }

  static void openOrders(){

    navigatorKey
        .currentState
        ?.pushNamed(

      "/orders",

    );

  }

  static Future<String>
  getToken()
  async{

    return

      await FirebaseMessaging
          .instance
          .getToken()

          ??

          "";

  }

}