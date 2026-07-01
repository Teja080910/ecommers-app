import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TranslatorService {

  static final TranslatorService _instance =
  TranslatorService._();

  factory TranslatorService() =>
      _instance;

  TranslatorService._();

  OnDeviceTranslator?
  translator;

  String current =
      "en";

  Future<void>
  init()
  async {

    final pref =

    await SharedPreferences
        .getInstance();

    current =

        pref.getString(
          "app_lang",
        )

            ??

            "en";

    if(
    current!="en"
    ){

      translator=

          OnDeviceTranslator(

            sourceLanguage:
            TranslateLanguage.english,

            targetLanguage:

            TranslateLanguage.values
                .firstWhere(

                  (e)=>

              e.bcpCode
                  ==

                  current,

            ),

          );

    }

  }

  Future<String>
  translate(
      String text,
      )
  async{

    if(
    current=="en"
    ){

      return text;

    }

    if(
    translator==null
    ){

      return text;

    }

    try{

      return await translator!
          .translateText(
        text,
      );

    }

    catch(_){

      return text;

    }

  }

  Future<void>
  reload()
  async{

    await translator
        ?.close();

    translator=
    null;

    await init();

  }

}