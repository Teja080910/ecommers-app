import 'dart:convert';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static Future<Map<String, dynamic>> sendEmailOtp(String email) async {

    try {

      final response = await http.post(
        Uri.parse(AppConstants.baseUrl),
        body: {
          "action": "send_email_otp",
          "email": email,
        },
      );

      return json.decode(response.body);

    } catch (e) {

      return {
        "status": false,
        "message": "API FAILED"
      };
    }
  }

  static Future<Map<String, dynamic>> verifyEmailOtp(
      String email, String otp) async {

    try {

      final response = await http.post(
        Uri.parse(AppConstants.baseUrl),
        body: {
          "action": "verify_email_otp",
          "email": email,
          "otp": otp,
        },
      );

      return json.decode(response.body);

    } catch (e) {

      return {
        "status": false,
        "message": "API FAILED"
      };
    }
  }

  // 🔥 AUTH PARAMS — every authenticated request is signed with the
  // per-login token issued by login_register, so the server can verify
  // the caller actually owns the account it's acting on.
  static Future<Map<String, String>> _authParams() async {

    final prefs = await SharedPreferences.getInstance();

    return {
      "user_id": (prefs.getInt("user_id") ?? 0).toString(),
      "token": prefs.getString("auth_token") ?? "",
    };
  }

  static Future<void> clearCart(int userId) async {
    await http.post(
      Uri.parse(AppConstants.baseUrl),
      body: {
        "action": "clear_cart",
        "user_id": userId.toString(),
      },
    );
  }

  // 🔥 GET USER
  static Future<Map<String, dynamic>> getUser(int userId) async {
    try {
      final auth = await _authParams();

      final res = await http.post(
        Uri.parse(AppConstants.baseUrl),
        body: {
          "action": "get_user",
          ...auth,
        },
      );

      return json.decode(res.body);
    } catch (e) {
      return {"status": false};
    }
  }
  static Future<List<dynamic>>
  getNotifications(

      String userId,

      ) async {

    final auth = await _authParams();

    final response =

    await http.post(

      Uri.parse(
          AppConstants.baseUrl
      ),

      body:{

        "action":
        "get_notifications",

        ...auth,

      },

    );

    final data =

    jsonDecode(
      response.body,
    );

    if(

    data["status"]

        ==

        true

    ){

      return

        data[
        "notifications"
        ];

    }

    return [];

  }
  static Future saveFcmToken(

      int userId,

      String token,

      )

  async{

    try{

      final auth = await _authParams();

      final res=

      await http.post(

        Uri.parse(
          AppConstants.baseUrl,
        ),

        body:{

          "action":
          "save_fcm_token",

          ...auth,

          "fcm_token":
          token,

        },

      );

      return json.decode(
        res.body,
      );

    }catch(e){

      return{

        "status":false,

      };

    }

  }
  static Future<Map<String,dynamic>>
  getAppSetting()
  async{

    final response=

    await http.post(

      Uri.parse(
          AppConstants.baseUrl
      ),

      body:{

        "action":

        "get_app_setting",

      },

    );

    final data=

    jsonDecode(
      response.body,
    );

    if(

    data[
    "status"
    ]

        ==

        true

    ){

      return

        data[
        "data"
        ];

    }

    return {};

  }

  static Future<Map<String, dynamic>> updateProfile(
      int userId, String name,
      {String? phone, String? username, String? gender}) async {
    try {
      final auth = await _authParams();

      final res = await http.post(
        Uri.parse(AppConstants.baseUrl),
        body: {
          "action": "update_profile",
          ...auth,
          "name": name,
          if (phone != null) "phone": phone,
          if (username != null) "username": username,
          if (gender != null) "gender": gender,
        },
      );

      return json.decode(res.body);
    } catch (e) {
      return {"status": false, "message": "API FAILED"};
    }
  }
  // 🔥 ADD IN api_service.dart

  static Future<List> getBanners() async {

    try {

      final res = await http.post(
        Uri.parse(AppConstants.baseUrl),
        body: {
          "action": "get_banners",
        },
      );

      final data = json.decode(res.body);

      return data["banners"] ?? [];

    } catch (e) {

      return [];
    }
  }

// 🔥 GET PORTRAIT BANNERS
  static Future<List> getPortraitBanners() async {

    try {

      final res = await http.post(
        Uri.parse(AppConstants.baseUrl),
        body: {
          "action": "get_portrait_banners",
        },
      );

      final data = json.decode(res.body);

      return data["banners"] ?? [];

    } catch (e) {

      return [];
    }
  }


// 🔥 GET CATEGORIES
  static Future<List> getCategories() async {

    try {

      final res = await http.post(
        Uri.parse(AppConstants.baseUrl),
        body: {
          "action": "get_categories",
        },
      );

      final data = json.decode(res.body);

      return data["categories"] ?? [];

    } catch (e) {

      return [];
    }
  }


// 🔥 GET SUBCATEGORIES
  static Future<List> getSubcategories(
      int categoryId) async {

    try {

      final res = await http.post(
        Uri.parse(AppConstants.baseUrl),
        body: {
          "action": "get_subcategories",
          "category_id": categoryId.toString(),
        },
      );

      final data = json.decode(res.body);

      return data["subcategories"] ?? [];

    } catch (e) {

      return [];
    }
  }


// 🔥 GET TOP DEALS
  static Future<List> getTopDeals() async {

    try {

      final res = await http.post(
        Uri.parse(AppConstants.baseUrl),
        body: {
          "action": "get_top_deals",
        },
      );

      final data = json.decode(res.body);

      return data["products"] ?? [];

    } catch (e) {

      return [];
    }
  }

  static Future<List> getBestSellers() async {

    try {

      final res = await http.post(
        Uri.parse(AppConstants.baseUrl),
        body: {
          "action": "get_best_sellers",
        },
      );

      final data = json.decode(res.body);

      return data["products"] ?? [];

    } catch (e) {

      return [];
    }
  }

  static Future<List> getRecommended() async {

    try {

      final res = await http.post(
        Uri.parse(AppConstants.baseUrl),
        body: {
          "action": "get_recommended",
        },
      );

      final data = json.decode(res.body);

      return data["products"] ?? [];

    } catch (e) {

      return [];
    }
  }


// 🔥 GET PRODUCTS
  static Future<List> getProducts(
      int subcatId) async {

    try {

      final res = await http.post(
        Uri.parse(AppConstants.baseUrl),
        body: {
          "action": "get_products",
          "subcat_id": subcatId.toString(),
        },
      );

      final data = json.decode(res.body);

      return data["products"] ?? [];

    } catch (e) {

      return [];
    }
  }


// 🔥 VIEW PRODUCT
  static Future<Map<String, dynamic>>
  viewProduct(
      int productId,
      ) async {

    try {

      final prefs =

      await SharedPreferences
          .getInstance();

      final userId =

          prefs.getInt(
            "user_id",
          )

              ??

              0;

      final res =
      await http.post(

        Uri.parse(
          AppConstants.baseUrl,
        ),

        body: {

          "action":
          "view_product",

          "product_id":
          productId.toString(),

          "user_id":
          userId.toString(),

        },

      );

      return json.decode(
        res.body,
      );

    }

    catch (e) {

      return {

        "status":
        false

      };

    }

  }

// 🔥 HOME CATEGORY PRODUCTS
  static Future<List> getHomeCategoryProducts() async {

    try {

      final res = await http.post(
        Uri.parse(AppConstants.baseUrl),
        body: {
          "action": "home_category_products",
        },
      );

      final data = json.decode(res.body);

      return data["categories"] ?? [];

    } catch (e) {

      return [];
    }
  }
// 🔥 ADD IN api_service.dart

  static Future<Map<String, dynamic>>
  toggleWishlist(
      int userId,
      int productId,
      ) async {

    try {

      final auth = await _authParams();

      final res = await http.post(
        Uri.parse(AppConstants.baseUrl),

        body: {
          "action": "toggle_wishlist",
          ...auth,
          "product_id": productId.toString(),
        },
      );

      return json.decode(res.body);

    } catch (e) {

      return {
        "status": false
      };
    }
  }


  static Future<Map<String, dynamic>>
  addReview(
      int userId,
      int productId,
      double rating,
      String review,
      ) async {

    try {

      final auth = await _authParams();

      final res = await http.post(
        Uri.parse(AppConstants.baseUrl),

        body: {
          "action": "add_review",
          ...auth,
          "product_id": productId.toString(),
          "rating": rating.toString(),
          "review": review,
        },
      );

      return json.decode(res.body);

    } catch (e) {

      return {
        "status": false
      };
    }
  }

  // api_service.dart

  static Future<Map<String, dynamic>>
  addToCart(
      int userId,
      int productId,
      int variantId,
      ) async {

    try {

      final auth = await _authParams();

      final res = await http.post(
        Uri.parse(AppConstants.baseUrl),

        body: {
          "action": "add_to_cart",
          ...auth,
          "product_id": productId.toString(),
          "variant_id": variantId.toString(),
        },
      );

      return json.decode(res.body);

    } catch (e) {

      return {
        "status": false
      };
    }
  }


  static Future<List>
  getCart(
      int userId,
      ) async {

    try {

      final auth = await _authParams();

      final res = await http.post(
        Uri.parse(AppConstants.baseUrl),

        body: {
          "action": "get_cart",
          ...auth,
        },
      );

      final data = json.decode(res.body);

      return data["items"] ?? [];

    } catch (e) {

      return [];
    }
  }


  static Future<Map<String,dynamic>>
  saveAddress(

      int userId,

      String fullName,

      String mobile,

      String address,

      String city,

      String state,

      String pincode,

      double lat,

      double lng,

      ) async {

    try{

      final auth = await _authParams();

      final res=
      await http.post(

        Uri.parse(
          AppConstants.baseUrl,
        ),

        body:{

          "action":
          "save_address",

          ...auth,

          "full_name":
          fullName,

          "mobile":
          mobile,

          "address":
          address,

          "city":
          city,

          "state":
          state,

          "pincode":
          pincode,

          "latitude":
          lat.toString(),

          "longitude":
          lng.toString(),

        },

      );

      return json.decode(
        res.body,
      );

    }

    catch(e){

      return{
        "status":false
      };

    }

  }
  static Future<Map<String, dynamic>>
  applyCoupon(
      String code,
      double amount,
      ) async {

    try {

      final res = await http.post(
        Uri.parse(AppConstants.baseUrl),

        body: {
          "action": "apply_coupon",
          "code": code,
          "amount": amount.toString(),
        },
      );

      return json.decode(res.body);

    } catch (e) {

      return {
        "status": false
      };
    }
  }
  // api_service.dart

  static Future<Map<String, dynamic>>
  getDefaultAddress(
      int userId,
      ) async {

    try {

      final auth = await _authParams();

      final res = await http.post(
        Uri.parse(AppConstants.baseUrl),

        body: {
          "action": "get_default_address",
          ...auth,
        },
      );

      return json.decode(res.body);

    } catch (e) {

      return {
        "status": false
      };
    }
  }


  static Future<Map<String, dynamic>>
  placeOrder(
      int userId,
      int addressId,
      String couponCode,
      double discount,
      double subtotal,
      double total,
      String paymentMethod,
      ) async {

    try {

      final auth = await _authParams();

      final response = await http.post(
        Uri.parse(AppConstants.baseUrl),

        body: {
          "action": "place_order",
          ...auth,
          "address_id": addressId.toString(),
          "coupon_code": couponCode,
          "discount_amount":
          discount.toString(),

          "subtotal":
          subtotal.toString(),

          "total_amount":
          total.toString(),

          "payment_method":
          paymentMethod,
        },
      );

      print("PLACE ORDER RAW:");
      print(response.body);

      return json.decode(response.body);

    } catch (e) {

      print("PLACE ORDER ERROR:");
      print(e);

      return {
        "status": false,
        "message": e.toString()
      };
    }
  }

  static Future<Map<String, dynamic>>
  updateCartQuantity(
      int cartId,
      String type,
      ) async {

    try {

      final auth = await _authParams();

      final res = await http.post(
        Uri.parse(AppConstants.baseUrl),

        body: {
          "action": "update_cart_quantity",
          ...auth,
          "cart_id": cartId.toString(),
          "type": type,
        },
      );

      return json.decode(res.body);

    } catch (e) {

      return {
        "status": false
      };
    }
  }

  static Future<List>
  getMyOrders(int userId) async {

    try {

      final auth = await _authParams();

      final res = await http.post(
        Uri.parse(AppConstants.baseUrl),

        body: {
          "action": "get_my_orders",
          ...auth,
        },
      );

      final data = json.decode(res.body);

      return data["orders"] ?? [];

    } catch (e) {

      return [];
    }
  }

  static Future<Map<String,dynamic>>
  viewOrder(int orderId) async {

    try {

      final auth = await _authParams();

      final res = await http.post(
        Uri.parse(AppConstants.baseUrl),

        body: {
          "action": "view_order",
          ...auth,
          "order_id": orderId.toString(),
        },
      );

      return json.decode(res.body);

    } catch (e) {

      return {
        "status": false
      };
    }
  }

  static Future<bool>
  cancelOrder(int orderId) async {

    try {

      final auth = await _authParams();

      final res = await http.post(
        Uri.parse(AppConstants.baseUrl),

        body: {
          "action": "cancel_order",
          ...auth,
          "order_id": orderId.toString(),
        },
      );

      final data = json.decode(res.body);

      return data["status"] == true;

    } catch (e) {

      return false;
    }
  }

  static Future<List>
  getWishlist(int userId) async {

    try {

      final auth = await _authParams();

      final res = await http.post(
        Uri.parse(AppConstants.baseUrl),

        body: {
          "action": "get_wishlist",
          ...auth,
        },
      );

      final data = json.decode(res.body);

      return data["products"] ?? [];

    } catch (e) {

      return [];
    }
  }
  static Future<Map<String, dynamic>>
  removeCartItem(
      int cartId,
      ) async {

    try {

      final auth = await _authParams();

      final res = await http.post(
        Uri.parse(AppConstants.baseUrl),

        body: {
          "action": "remove_cart_item",
          ...auth,
          "cart_id": cartId.toString(),
        },
      );

      return json.decode(res.body);

    } catch (e) {

      return {
        "status": false
      };
    }
  }
  static Future<List>
  getPosts() async {

    final res=
    await http.post(

        Uri.parse(
            AppConstants.baseUrl
        ),

        body:{
          "action":
          "get_posts"
        }

    );

    return
      json.decode(
          res.body
      )["posts"];

  }
  static Future<Map>
  getPostById(
      int id
      ) async {

    final res=
    await http.post(

        Uri.parse(
            AppConstants.baseUrl
        ),

        body:{

          "action":
          "post_by_id",

          "post_id":
          id.toString()

        }

    );

    return
      json.decode(
          res.body
      );

  }
  static Future<Map>
  getWallet()
  async{

    try{

      final auth = await _authParams();

      final res=

      await http.post(

        Uri.parse(
          AppConstants.baseUrl,
        ),

        body:{

          "action":
          "get_wallet",

          ...auth,

        },

      );

      return jsonDecode(
        res.body,
      );

    }

    catch(e){

      return{

        "status":false

      };

    }

  }
  static Future<Map>
  getCashback()
  async{

    try{

      final auth = await _authParams();

      final res=

      await http.post(

        Uri.parse(
          AppConstants.baseUrl,
        ),

        body:{

          "action":
          "get_cashback",

          ...auth,

        },

      );

      return jsonDecode(
        res.body,
      );

    }

    catch(e){

      return{

        "status":false,

        "total":0,

        "cashbacks":[]

      };

    }

  }
  static Future<Map>
  moveCashback()
  async{

    try{

      final auth = await _authParams();

      final res=

      await http.post(

        Uri.parse(
          AppConstants.baseUrl,
        ),

        body:{

          "action":
          "move_cashback",

          ...auth,

        },

      );

      return jsonDecode(
        res.body,
      );

    }

    catch(e){

      return{

        "status":false

      };

    }

  }
  static Future<Map>
  getDeliveryCharge(
      String pincode,
      )
  async{

    try{

      final res=

      await http.post(

        Uri.parse(
          AppConstants.baseUrl,
        ),

        body:{

          "action":
          "get_delivery_charge",

          "pincode":
          pincode,

        },

      );

      return jsonDecode(
        res.body,
      );

    }

    catch(e){

      return{

        "status":false,

        "delivery_charge":0

      };

    }

  }
  static Future<Map<String,dynamic>>
  togglePostLike(

      int user,

      int post,

      ) async {

    try{

      final res=

      await http.post(

        Uri.parse(
          AppConstants.baseUrl,
        ),

        body:{

          "action":
          "toggle_post_like",

          "user_id":
          user.toString(),

          "post_id":
          post.toString(),

        },

      );

      return json.decode(
        res.body,
      );

    }

    catch(e){

      return{

        "status":false,

        "likes":0,

      };

    }

  }
  static Future addComment(

      int user,

      int post,

      String comment

      ) async {

    await http.post(

        Uri.parse(
            AppConstants.baseUrl
        ),

        body:{

          "action":
          "add_post_comment",

          "user_id":
          "$user",

          "post_id":
          "$post",

          "comment":
          comment

        }

    );

  }
  static Future<Map<String, dynamic>>
  getRazorpaySettings() async {

    try {

      final res = await http.post(
        Uri.parse(AppConstants.baseUrl),

        body: {
          "action":
          "get_razorpay_settings",
        },
      );

      return json.decode(res.body);

    } catch (e) {

      return {
        "status": false
      };
    }
  }

  static Future<List>
  getOnboardingBanners() async {

    try {

      final res = await http.post(
        Uri.parse(AppConstants.baseUrl),

        body: {
          "action":
          "get_onboarding_banners",
        },
      );

      final data = json.decode(res.body);

      return data["banners"] ?? [];

    } catch (e) {

      return [];
    }
  }

  static Future<String>
  getSplashImage() async {

    try {

      print("🔥 CALLING SPLASH API");

      final res = await http.post(
        Uri.parse(AppConstants.baseUrl),

        body: {
          "action": "get_splash",
        },
      );

      print("🔥 SPLASH RESPONSE");
      print(res.body);

      final data =
      json.decode(res.body);

      if (data["status"] == true) {

        return data["image"];
      }

      return "";

    } catch (e) {

      print("🔥 SPLASH ERROR");
      print(e);

      return "";
    }
  }
  static Future<Map>
  getOttHome(String catId) async {

    try {

      final res = await http.post(

        Uri.parse(
          AppConstants.baseUrl,
        ),

        body: {

          "action":
          "get_ott_home",

          "cat_id":
          catId,
        },
      );

      return json.decode(res.body);

    } catch (e) {

      return {};
    }
  }

  static Future<List>
  getOttCategories() async {

    try {

      final res = await http.post(

        Uri.parse(
          AppConstants.baseUrl,
        ),

        body: {

          "action":
          "get_ott_categories",
        },
      );

      final data =
      json.decode(res.body);

      return data["categories"] ?? [];

    } catch (e) {

      return [];
    }
  }
  static Future<List>
  searchProducts(
      String search,
      )
  async{

    try{

      final res=

      await http.post(

        Uri.parse(
          AppConstants.baseUrl,
        ),

        body:{

          "action":
          "search_products",

          "search":
          search,

        },

      );

      final data=

      jsonDecode(
        res.body,
      );

      return

        data[
        "products"
        ]

            ??

            [];

    }

    catch(e){

      return[];

    }

  }

  static Future<Map>
  viewMovie(
      String movieId,
      String userId,
      ) async {

    try {

      final res = await http.post(

        Uri.parse(
          AppConstants.baseUrl,
        ),

        body: {

          "action":
          "view_movie",

          "movie_id":
          movieId,

          "user_id":
          userId,
        },
      );

      return json.decode(res.body);

    } catch (e) {

      return {};
    }
  }

  static Future<bool>
  toggleWatchlist(
      String userId,
      String movieId,
      ) async {

    try {

      final res = await http.post(

        Uri.parse(
          AppConstants.baseUrl,
        ),

        body: {

          "action":
          "toggle_watchlist",

          "user_id":
          userId,

          "movieid":
          movieId,
        },
      );

      final data =
      json.decode(res.body);

      return data["watchlist"] ?? false;

    } catch (e) {

      return false;
    }
  }

  static Future<void>
  saveWatchProgress({

    required String userId,

    required String movieId,

    required int watchedSeconds,

  }) async {

    try {

      await http.post(

        Uri.parse(
          AppConstants.baseUrl,
        ),

        body: {

          "action":
          "save_watch_progress",

          "user_id":
          userId,

          "movie_id":
          movieId,

          "watched_seconds":
          watchedSeconds.toString(),
        },
      );

    } catch (e) {}
  }

  static Future<Map>
  getSubscriptions() async {

    try {

      final res = await http.post(

        Uri.parse(
          AppConstants.baseUrl,
        ),

        body: {
          "action":
          "get_subscriptions",
        },
      );

      return json.decode(
        res.body,
      );

    } catch (e) {

      return {};
    }
  }

  static Future<Map>
  activateSubscription({

    required String userId,

    required String subscriptionId,

    required String paymentId,

  }) async {

    try {

      final res = await http.post(

        Uri.parse(
          AppConstants.baseUrl,
        ),

        body: {

          "action":
          "activate_subscription",

          "user_id":
          userId,

          "subscription_id":
          subscriptionId,

          "payment_id":
          paymentId,
        },
      );

      return json.decode(
        res.body,
      );

    } catch (e) {

      return {
        "status": false
      };
    }
  }

  static Future<Map> getZhatpatSeries() async {

    try {

      final response = await http.post(

        Uri.parse(
          AppConstants.baseUrl,
        ),

        body: {
          "action":
          "get_zhatpat_series",
        },
      );

      return json.decode(
        response.body,
      );

    } catch (e) {

      return {};
    }
  }

  static Future<Map> getZhatpatVideos(
      String zhatpatId,
      ) async {

    try {

      final response = await http.post(

        Uri.parse(
          AppConstants.baseUrl,
        ),

        body: {

          "action":
          "get_zhatpat_videos",

          "zhatpat_id":
          zhatpatId,
        },
      );

      return json.decode(
        response.body,
      );

    } catch (e) {

      return {};
    }
  }

  static Future<Map> getShorts() async {

    try {

      final response = await http.post(

        Uri.parse(
          AppConstants.baseUrl,
        ),

        body: {
          "action":
          "get_shorts",
        },
      );

      return json.decode(
        response.body,
      );

    } catch (e) {

      return {};
    }
  }
  static Future<Map> getCasting() async {

    try {

      final response = await http.post(

        Uri.parse(
          AppConstants.baseUrl,
        ),

        body: {
          "action":
          "get_casting",
        },
      );

      return json.decode(
        response.body,
      );

    } catch (e) {

      return {};
    }
  }
  static Future<Map> submitCastingApplication({

    required String userId,

    required String castingId,

    required String name,

    required String height,

    required String weight,

    required String experience,

    required List<File> photos,

    required File video,

  }) async {

    try {

      var request =
      http.MultipartRequest(

        "POST",

        Uri.parse(
          AppConstants.baseUrl,
        ),
      );

      request.fields["action"] =
      "submit_casting_application";

      request.fields["user_id"] =
          userId;

      request.fields["casting_id"] =
          castingId;

      request.fields["name"] =
          name;

      request.fields["height"] =
          height;

      request.fields["weight"] =
          weight;

      request.fields["workexperience"] =
          experience;

      // 🔥 VIDEO
      request.files.add(

        await http.MultipartFile
            .fromPath(

          "video",

          video.path,
        ),
      );

      // 🔥 PHOTOS
      for (int i = 0;
      i < photos.length;
      i++) {

        request.files.add(

          await http.MultipartFile
              .fromPath(

            "photos[]",

            photos[i].path,
          ),
        );
      }

      var response =
      await request.send();

      var res =
      await response.stream
          .bytesToString();

      return json.decode(res);

    } catch (e) {

      return {
        "status": false
      };
    }
  }
  static Future<List>
  getWatchlistMovies(
      String userId,
      ) async {

    try {

      final res = await http.post(

        Uri.parse(
          AppConstants.baseUrl,
        ),

        body: {

          "action":
          "get_watchlist_movies",

          "user_id":
          userId,
        },
      );

      final data =
      json.decode(
        res.body,
      );

      return data["movies"] ?? [];

    } catch (e) {

      return [];
    }
  }
  static Future<List>
  getWatchHistory(
      String userId,
      ) async {

    try {

      final response =
      await http.post(

        Uri.parse(
          AppConstants.baseUrl,
        ),

        body: {

          "action":
          "get_watch_history",

          "user_id":
          userId,
        },
      );

      final data =
      json.decode(
        response.body,
      );

      return data["movies"] ?? [];

    } catch (e) {

      return [];
    }
  }

// 🔥 GET SIMILAR PRODUCTS
  static Future<List> getSimilarProducts(
      int subcatId,
      int excludeId,
      ) async {

    try {

      final res = await http.post(
        Uri.parse(AppConstants.baseUrl),
        body: {
          "action": "get_similar_products",
          "subcat_id": subcatId.toString(),
          "exclude_id": excludeId.toString(),
        },
      );

      final data = json.decode(res.body);

      return data["products"] ?? [];

    } catch (e) {

      return [];
    }
  }

// 🔥 GET OFFERS
  static Future<List> getOffers() async {

    try {

      final res = await http.post(
        Uri.parse(AppConstants.baseUrl),
        body: {
          "action": "get_offers",
        },
      );

      final data = json.decode(res.body);

      return data["offers"] ?? [];

    } catch (e) {

      return [];
    }
  }

// 🔥 CHECK DELIVERY
  static Future<Map<String, dynamic>> checkDelivery(
      String pincode,
      ) async {

    try {

      final res = await http.post(
        Uri.parse(AppConstants.baseUrl),
        body: {
          "action": "check_delivery",
          "pincode": pincode,
        },
      );

      return json.decode(res.body);

    } catch (e) {

      return {
        "status": false,
        "deliverable": false,
      };
    }
  }
}