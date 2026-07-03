import 'package:flutter/material.dart';

import 'package:lottie/lottie.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';

class NotificationPage
    extends StatefulWidget{

  const NotificationPage({
    super.key,
  });

  @override
  State<NotificationPage>
  createState()

  =>

      _NotificationPageState();

}

class _NotificationPageState
    extends State<NotificationPage>{

  List notifications=[];

  bool loading=true;

  Future<void> load() async {

    setState(() {
      loading=true;
    });

    final prefs =
    await SharedPreferences
        .getInstance();

    final int userId =

        prefs.getInt(
          "user_id",
        )

            ??

            0;

    if(
    userId==0
    ){

      if(mounted){

        setState(() {

          notifications=[];

          loading=false;

        });

      }

      return;

    }

    try{

      final data=

      await ApiService
          .getNotifications(

        userId
            .toString(),

      );

      if(!mounted){
        return;
      }

      setState(() {

        notifications=
            data;

        loading=false;

      });

    }

    catch(e){

      if(!mounted){
        return;
      }

      setState(() {

        notifications=[];

        loading=false;

      });

    }

  }
  @override
  void initState(){

    super.initState();

    load();

  }

  @override
  Widget build(
      BuildContext context,
      ){

    return Scaffold(

      backgroundColor:

      const Color(
        0xFFF7F8FC,
      ),

      appBar:

      AppBar(

        backgroundColor:
        Colors.white,

        surfaceTintColor:
        Colors.white,

        centerTitle:true,

        elevation:0,

        title:

        const Text(

          "Notifications",

          style:

          TextStyle(

            color:
            Colors.black,

            fontWeight:
            FontWeight.w800,

          ),

        ),

      ),

      body:

      loading

          ?

      const Center(

        child:

        CircularProgressIndicator(

          color:

          Color(
            0xFFEF4138,
          ),

        ),

      )

          :

      notifications.isEmpty

          ?

      Center(

        child:

        Padding(

          padding:
          const EdgeInsets.symmetric(
            horizontal: 32,
          ),

          child:

          Column(

            mainAxisAlignment:

            MainAxisAlignment.center,

            children:[

              SizedBox(

                height:200,

                child:

                Lottie.asset(

                  "assets/images/nodata.json",

                ),

              ),

              const SizedBox(
                height:18,
              ),

              const Text(

                "No Notifications Yet",

                textAlign:
                TextAlign.center,

                style:

                TextStyle(

                  fontSize:18,

                  fontWeight:
                  FontWeight.w800,

                  color:
                  Color(0xFF111111),

                ),

              ),

              const SizedBox(
                height:8,
              ),

              const Text(

                "You don't have any notifications right now.\nWe'll let you know when something new arrives.",

                textAlign:
                TextAlign.center,

                style:

                TextStyle(

                  color:
                  Colors.black54,

                  fontSize:13,

                  height:1.4,

                ),

              ),

            ],

          ),

        ),

      )

          :

      RefreshIndicator(

        color:

        const Color(
          0xFFEF4138,
        ),

        onRefresh:
        load,

        child:

        ListView.builder(

          padding:

          const EdgeInsets.all(
            16,
          ),

          itemCount:

          notifications.length,

          itemBuilder:

              (
              context,
              index,
              ){

            final n=

            notifications[
            index
            ];

            return Container(

              margin:

              const EdgeInsets.only(
                bottom:14,
              ),

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

                boxShadow:[

                  BoxShadow(

                    color:

                    Colors.black
                        .withOpacity(
                      0.05,
                    ),

                    blurRadius:18,

                  ),

                ],

              ),

              child:

              Row(

                children:[

                  Container(

                    height:52,

                    width:52,

                    decoration:

                    BoxDecoration(

                      color:

                      const Color(
                        0xFFEF4138,
                      )

                          .withOpacity(
                        0.12,
                      ),

                      shape:
                      BoxShape.circle,

                    ),

                    child:

                    const Icon(

                      Icons.notifications,

                      color:

                      Color(
                        0xFFEF4138,
                      ),

                    ),

                  ),

                  const SizedBox(
                    width:16,
                  ),

                  Expanded(

                    child:

                    Column(

                      crossAxisAlignment:

                      CrossAxisAlignment.start,

                      children:[

                        Text(

                          n[
                          "notification_text"
                          ]
                              .toString(),

                          style:

                          const TextStyle(

                            fontSize:15,

                            fontWeight:
                            FontWeight.w700,

                          ),

                        ),

                        const SizedBox(
                          height:8,
                        ),

                        Text(

                          n[
                          "created_at"
                          ]
                              .toString(),

                          style:

                          const TextStyle(

                            color:
                            Colors.grey,

                            fontSize:12,

                          ),

                        ),

                      ],

                    ),

                  ),

                ],

              ),

            );

          },

        ),

      ),

    );

  }

}
