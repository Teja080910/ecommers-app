import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'translator_service.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() =>
      _LanguagePageState();
}

class _LanguagePageState
    extends State<LanguagePage> {

  static const Color themeRed =
  Color(0xFFEF4138);

  String selectedLang =
      "en";

  bool loading =
  false;

  final List<Map<String,String>>
  languages=[

    {
      "name":"English",
      "code":"EN",
      "lang":"en",
    },

    {
      "name":"Hindi",
      "code":"HI",
      "lang":"hi",
    },

    {
      "name":"Bengali",
      "code":"BN",
      "lang":"bn",
    },

    {
      "name":"Telugu",
      "code":"TE",
      "lang":"te",
    },

    {
      "name":"Marathi",
      "code":"MR",
      "lang":"mr",
    },

    {
      "name":"Tamil",
      "code":"TA",
      "lang":"ta",
    },

    {
      "name":"Gujarati",
      "code":"GU",
      "lang":"gu",
    },

    {
      "name":"Kannada",
      "code":"KN",
      "lang":"kn",
    },

    {
      "name":"Malayalam",
      "code":"ML",
      "lang":"ml",
    },

    {
      "name":"Punjabi",
      "code":"PA",
      "lang":"pa",
    },

  ];

  @override
  void initState() {

    super.initState();

    loadLanguage();

  }

  Future<void>
  loadLanguage()
  async {

    final pref=

    await SharedPreferences
        .getInstance();

    selectedLang=

        pref.getString(
          "app_lang",
        )

            ??

            "en";

    setState(() {});

  }

  String
  getLang(
      String code,
      ){

    switch(
    code
    ){

      case "hi":
        return "hi";

      case "bn":
        return "bn";

      case "te":
        return "te";

      case "mr":
        return "mr";

      case "ta":
        return "ta";

      case "gu":
        return "gu";

      case "kn":
        return "kn";

      case "ml":
        return "ml";

      case "pa":
        return "pa";

      default:
        return "en";

    }

  }
  Future<void>
  applyLanguage()
  async {

    setState(() {
      loading=true;
    });

    final pref=

    await SharedPreferences
        .getInstance();

    await pref.setString(
      "app_lang",
      selectedLang,
    );

    if(
    selectedLang!="en"
    ){

      final model=
      OnDeviceTranslatorModelManager();

      await model
          .downloadModel(

        getLang(
          selectedLang,
        ),

      );

    }

    // 🔥 actually switch the active translator so `t()` calls translate
    await TranslatorService().reload();

    setState(() {
      loading=false;
    });

    if(
    mounted
    ){

      Navigator.pop(
        context,
        true,
      );

    }

  }

  @override
  Widget build(
      BuildContext context
      ){

    return Scaffold(

      backgroundColor:
      const Color(
        0xFFF6F7F9,
      ),

      appBar:

      AppBar(

        elevation:0,

        backgroundColor:
        Colors.white,

        title:

        const Text(
          "Select Language",
        ),

      ),

      body:

      Padding(

        padding:

        const EdgeInsets.all(
          14,
        ),

        child:

        Column(

          children:[

            Expanded(

              child:

              GridView.builder(

                itemCount:
                languages.length,

                gridDelegate:

                const SliverGridDelegateWithFixedCrossAxisCount(

                  crossAxisCount:
                  2,

                  crossAxisSpacing:
                  12,

                  mainAxisSpacing:
                  12,

                  childAspectRatio:
                  2.4,

                ),

                itemBuilder:
                    (
                    _,
                    index
                    ){

                  final lang=

                  languages[
                  index
                  ];

                  bool selected=

                      selectedLang==

                          lang[
                          "lang"
                          ];

                  return GestureDetector(

                    onTap:(){

                      setState(() {

                        selectedLang=

                        lang[
                        "lang"
                        ]!;

                      });

                    },

                    child:

                    Container(

                      padding:

                      const EdgeInsets.symmetric(
                        horizontal:
                        12,
                      ),

                      decoration:

                      BoxDecoration(

                        color:
                        Colors.white,

                        borderRadius:

                        BorderRadius.circular(
                          14,
                        ),

                        border:

                        Border.all(

                          color:

                          selected

                              ?

                          themeRed

                              :

                          Colors.black12,

                          width:

                          selected

                              ?

                          2

                              :

                          1,

                        ),

                      ),

                      child:

                      Row(

                        children:[

                          CircleAvatar(

                            radius:
                            19,

                            backgroundColor:

                            selected

                                ?

                            themeRed

                                :

                            themeRed
                                .withOpacity(
                              0.10,
                            ),

                            child:

                            Text(

                              lang[
                              "code"
                              ]!,

                              style:

                              TextStyle(

                                color:

                                selected

                                    ?

                                Colors.white

                                    :

                                themeRed,

                              ),
                            ),

                          ),

                          const SizedBox(
                            width:
                            10,
                          ),

                          Expanded(

                            child:

                            Text(

                              lang[
                              "name"
                              ]!,
                            ),

                          ),

                        ],
                      ),

                    ),

                  );

                },

              ),

            ),

            SizedBox(

              width:
              double.infinity,

              height:
              52,

              child:

              ElevatedButton(

                onPressed:

                loading

                    ?

                null

                    :

                applyLanguage,

                style:

                ElevatedButton
                    .styleFrom(

                  backgroundColor:
                  themeRed,

                ),

                child:

                loading

                    ?

                const CircularProgressIndicator(
                  color:
                  Colors.white,
                )

                    :

                const Text(

                  "Apply Language",

                  style:

                  TextStyle(

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

}