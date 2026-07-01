import 'dart:convert';

import 'package:http/http.dart'
as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';

class ApiService{

  static Future home(
      int id,
      )
  async{

    final res=

    await http.post(

      Uri.parse(
          AppConstants.baseUrl
      ),

      body:{

        "action":
        "home",

        "delivery_id":
        id.toString(),

      },

    );

    return jsonDecode(
        res.body
    );

  }
  static Future profile()
  async{

    final prefs=

    await SharedPreferences
        .getInstance();

    final id=

    prefs.getInt(
        "delivery_id"
    );

    final res=

    await http.post(

      Uri.parse(
          AppConstants.baseUrl
      ),

      body:{

        "action":
        "profile",

        "delivery_id":
        id.toString(),

      },

    );

    return jsonDecode(
        res.body
    );

  }
  static Future payouts()
  async{

    final prefs=

    await SharedPreferences
        .getInstance();

    final id=

    prefs.getInt(
        "delivery_id"
    );

    final res=

    await http.post(

      Uri.parse(
        AppConstants.baseUrl,
      ),

      body:{

        "action":
        "payouts",

        "delivery_id":
        "$id",

      },

    );

    return jsonDecode(
      res.body,
    );

  }
  static Future orders(
      int deliveryId,
      )
  async{

    final res=

    await http.post(

      Uri.parse(
        AppConstants.baseUrl,
      ),

      body:{

        "action":
        "orders",

        "delivery_id":
        deliveryId.toString(),

      },

    );

    return jsonDecode(
      res.body,
    );

  }

  static Future
  getHome()
  async{

    final prefs=

    await SharedPreferences
        .getInstance();

    final id=

    prefs.getInt(
        "delivery_id"
    );

    final res=

    await http.post(

      Uri.parse(
          AppConstants.baseUrl
      ),

      body:{

        "action":"home",

        "delivery_id":
        id.toString(),

      },

    );

    return jsonDecode(
        res.body
    );

  }
  static Future viewOrder(
      int id,
      )
  async{

    final r=

    await http.post(

      Uri.parse(
          AppConstants.baseUrl
      ),

      body:{

        "action":
        "view_order",

        "order_id":
        id.toString(),

      },

    );

    return jsonDecode(
        r.body
    );

  }

  static Future deliverOrder(
      int id,
      String otp,
      )
  async{

    final r=

    await http.post(

      Uri.parse(
          AppConstants.baseUrl
      ),

      body:{

        "action":
        "deliver_order",

        "order_id":
        id.toString(),

        "otp":
        otp,

      },

    );

    return jsonDecode(
        r.body
    );

  }

  static Future login(

      String phone,

      String password,

      )

  async{

    final res=

    await http.post(

      Uri.parse(
          AppConstants.baseUrl
      ),

      body:{

        "action":"login",

        "phone":phone,

        "password":password,

      },

    );

    print(

      res.body,

    );

    return jsonDecode(
        res.body
    );




  }

}