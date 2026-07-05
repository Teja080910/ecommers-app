<?php
header("Content-Type: application/json");
include("db.php");

$action = $_POST['action'] ?? '';

/* ==============================
   AUTH HELPER
   Verifies that the caller actually owns the
   user_id it's acting on, via the per-login
   random token issued by login_register.
================================ */
function requireAuth($conn){

    $user_id = intval($_POST['user_id'] ?? 0);
    $token = $_POST['token'] ?? '';

    if ($user_id <= 0 || empty($token)) {

        echo json_encode([
            "status" => false,
            "message" => "Unauthorized",
            "auth_error" => true
        ]);
        exit;
    }

    $stmt = mysqli_prepare($conn,
        "SELECT id FROM users WHERE id=? AND auth_token=?");

    mysqli_stmt_bind_param($stmt, "is", $user_id, $token);
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);

    if (mysqli_num_rows($result) !== 1) {

        echo json_encode([
            "status" => false,
            "message" => "Unauthorized",
            "auth_error" => true
        ]);
        exit;
    }

    return $user_id;
}

/* ==============================
   LOGIN / REGISTER USER
================================ */
if ($action == "login_register") {

    $phone = $_POST['phone'] ?? '';

    if (empty($phone)) {

        echo json_encode([
            "status" => false,
            "message" => "Phone required"
        ]);
        exit;
    }

    // 🔥 CHECK USER BY PHONE
    $stmt = mysqli_prepare($conn, "SELECT * FROM users WHERE phone=?");
    mysqli_stmt_bind_param($stmt, "s", $phone);
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);

    // 🔥 FRESH AUTH TOKEN ISSUED ON EVERY LOGIN
    $auth_token = bin2hex(random_bytes(32));

    if (mysqli_num_rows($result) > 0) {

        $user = mysqli_fetch_assoc($result);

        $update = mysqli_prepare($conn, "UPDATE users SET auth_token=? WHERE id=?");
        mysqli_stmt_bind_param($update, "si", $auth_token, $user['id']);
        mysqli_stmt_execute($update);

        $user['auth_token'] = $auth_token;

        echo json_encode([
            "status" => true,
            "message" => "Login success",
            "token" => $auth_token,
            "user" => $user
        ]);

    } else {

        // 🔥 GENERATE USERNAME
        do {

            $random_number = rand(10000, 99999);
            $name = "zenvora_user_" . $random_number;

            $check_stmt = mysqli_prepare($conn, "SELECT id FROM users WHERE name=?");
            mysqli_stmt_bind_param($check_stmt, "s", $name);
            mysqli_stmt_execute($check_stmt);
            $check_name = mysqli_stmt_get_result($check_stmt);

        } while (mysqli_num_rows($check_name) > 0);


        // 🔥 GENERATE UNIQUE REFERRAL CODE
        do {

            $referral_code =
                strtoupper(substr(md5(uniqid()), 0, 8));

            $check_stmt = mysqli_prepare($conn, "SELECT id FROM users WHERE referral_code=?");
            mysqli_stmt_bind_param($check_stmt, "s", $referral_code);
            mysqli_stmt_execute($check_stmt);
            $check_code = mysqli_stmt_get_result($check_stmt);

        } while (mysqli_num_rows($check_code) > 0);


        // 🔥 INSERT USER
        $insert = mysqli_prepare($conn,
            "INSERT INTO users (name, phone, referral_code, auth_token)
             VALUES (?, ?, ?, ?)");

        mysqli_stmt_bind_param($insert, "ssss", $name, $phone, $referral_code, $auth_token);
        mysqli_stmt_execute($insert);

        $user_id = mysqli_insert_id($conn);

        echo json_encode([
            "status" => true,
            "message" => "User registered",
            "token" => $auth_token,
            "user" => [
                "id" => $user_id,
                "name" => $name,
                "phone" => $phone,
                "referral_code" => $referral_code
            ]
        ]);
    }

    exit;
}
if ($action == "save_profile_referral") {

    $user_id = requireAuth($conn);
    $name = $_POST['name'] ?? '';
    $sponsor_code = $_POST['sponsor_code'] ?? '';

    if (empty($name)) {

        echo json_encode([
            "status" => false,
            "message" => "Required fields missing"
        ]);

        exit;
    }

    // 🔥 CHECK REFERRAL CODE
    if (!empty($sponsor_code)) {

        $check = mysqli_prepare($conn,
            "SELECT id FROM users WHERE referral_code=?");

        mysqli_stmt_bind_param($check, "s", $sponsor_code);
        mysqli_stmt_execute($check);
        $checkResult = mysqli_stmt_get_result($check);

        if (mysqli_num_rows($checkResult) == 0) {

            echo json_encode([
                "status" => false,
                "message" => "Invalid referral code"
            ]);

            exit;
        }
    }

    // 🔥 UPDATE USER
    $stmt = mysqli_prepare($conn,
        "UPDATE users SET name=?, sponsor_code=? WHERE id=?");

    mysqli_stmt_bind_param($stmt, "ssi", $name, $sponsor_code, $user_id);
    mysqli_stmt_execute($stmt);

    echo json_encode([
        "status" => true,
        "message" => "Profile updated"
    ]);

    exit;
}

if ($action == "get_user") {

    $user_id = requireAuth($conn);

    $stmt = mysqli_prepare($conn,
        "SELECT * FROM users WHERE id=?");

    mysqli_stmt_bind_param($stmt, "i", $user_id);
    mysqli_stmt_execute($stmt);
    $query = mysqli_stmt_get_result($stmt);

    if (mysqli_num_rows($query) > 0) {

        $user = mysqli_fetch_assoc($query);

        echo json_encode([
            "status" => true,
            "user" => $user
        ]);

    } else {

        echo json_encode([
            "status" => false,
            "message" => "User not found"
        ]);
    }

    exit;
}
if ($action == "update_profile") {

$user_id = requireAuth($conn);

$name =
trim(
$_POST["name"] ?? ""
);

if(
empty($name)
){

echo json_encode([

"status"=>false,

"message"=>
"name required"

]);

exit;

}

$stmt = mysqli_prepare($conn,
    "UPDATE users SET name=? WHERE id=?");

mysqli_stmt_bind_param($stmt, "si", $name, $user_id);
$update = mysqli_stmt_execute($stmt);

if($update){

$userStmt = mysqli_prepare($conn,
    "SELECT * FROM users WHERE id=? LIMIT 1");

mysqli_stmt_bind_param($userStmt, "i", $user_id);
mysqli_stmt_execute($userStmt);
$user = mysqli_fetch_assoc(mysqli_stmt_get_result($userStmt));

echo json_encode([

"status"=>true,

"message"=>
"Profile Updated",

"user"=>$user

]);

}else{

echo json_encode([

"status"=>false,

"message"=>
mysqli_error(
$conn
)

]);

}

exit;

}
if($action=="get_notifications"){

$user_id = requireAuth($conn);

$stmt = mysqli_prepare($conn,

"SELECT id, notification_text, created_at
 FROM user_notifications
 WHERE user_id=?
 ORDER BY id DESC");

mysqli_stmt_bind_param($stmt, "i", $user_id);
mysqli_stmt_execute($stmt);
$q = mysqli_stmt_get_result($stmt);

$data = [];

while(

$row =
mysqli_fetch_assoc(
$q
)

){

$data[] =
$row;

}

echo json_encode([

"status"=>true,

"notifications"=>$data

]);

exit;

}
if($action=="get_app_setting"){

$q=

mysqli_query(

$conn,

"

SELECT

supportnumber,

supportemail

FROM appsetting

ORDER BY id DESC

LIMIT 1

"

);

$row=

mysqli_fetch_assoc(
$q
);

echo json_encode([

"status"=>true,

"data"=>$row

]);

exit;

}

/* =====================================
   GET BANNERS
===================================== */
if ($action == "get_banners") {

    $data = [];

    $query = mysqli_query($conn,
        "SELECT * FROM banners ORDER BY id DESC");

    while ($row = mysqli_fetch_assoc($query)) {

        $data[] = [
            "id" => $row['id'],
            "image" => $row['image']
        ];
    }

    echo json_encode([
        "status" => true,
        "banners" => $data
    ]);

    exit;
}

/* =====================================
   GET PORTRAIT BANNERS
===================================== */
if ($action == "get_portrait_banners") {

    $data = [];

    $query = mysqli_query($conn,
        "SELECT * FROM portrait_banners ORDER BY id ASC");

    while ($row = mysqli_fetch_assoc($query)) {

        $data[] = [
            "id" => $row['id'],
            "image" => $row['image']
        ];
    }

    echo json_encode([
        "status" => true,
        "banners" => $data
    ]);

    exit;
}

/* =====================================
   GET MY ORDERS
===================================== */
if ($action == "get_my_orders") {

    $user_id = requireAuth($conn);

    $orders = [];

    $stmt = mysqli_prepare($conn,
        "SELECT *
         FROM orders
         WHERE user_id=?
         ORDER BY id DESC");

    mysqli_stmt_bind_param($stmt, "i", $user_id);
    mysqli_stmt_execute($stmt);
    $query = mysqli_stmt_get_result($stmt);

    while ($row = mysqli_fetch_assoc($query)) {

        $itemStmt = mysqli_prepare($conn,
            "SELECT COUNT(*) as total
             FROM order_items
             WHERE order_id=?");

        mysqli_stmt_bind_param($itemStmt, "i", $row['id']);
        mysqli_stmt_execute($itemStmt);

        $itemData =
        mysqli_fetch_assoc(mysqli_stmt_get_result($itemStmt));

        $previewStmt = mysqli_prepare($conn,
            "SELECT order_items.quantity, products.name, products.image
             FROM order_items
             LEFT JOIN products ON products.id = order_items.product_id
             WHERE order_items.order_id=?
             ORDER BY order_items.id ASC
             LIMIT 3");

        mysqli_stmt_bind_param($previewStmt, "i", $row['id']);
        mysqli_stmt_execute($previewStmt);
        $previewQuery = mysqli_stmt_get_result($previewStmt);

        $previewItems = [];

        while ($p = mysqli_fetch_assoc($previewQuery)) {
            $previewItems[] = [
                "name" => $p['name'],
                "image" => $p['image'],
                "quantity" => $p['quantity'],
            ];
        }

        $orders[] = [

            "id" => $row['id'],

            "order_no" =>
            $row['order_no'],

            "total_amount" =>
            $row['total_amount'],

            "payment_method" =>
            $row['payment_method'],

            "payment_status" =>
            $row['payment_status'],

            "order_status" =>
            $row['order_status'],

            "created_at" =>
            $row['created_at'],

            "items_count" =>
            $itemData['total'],

            "preview_items" =>
            $previewItems,
        ];
    }

    echo json_encode([
        "status" => true,
        "orders" => $orders
    ]);

    exit;
}
/* =====================================
   VIEW ORDER
===================================== */
if ($action == "view_order") {

    $user_id = requireAuth($conn);
    $order_id = intval($_POST['order_id']);

    $stmt = mysqli_prepare($conn,
        "SELECT orders.*,

        user_addresses.full_name,
        user_addresses.mobile,
        user_addresses.address,
        user_addresses.city,
        user_addresses.state,
        user_addresses.pincode,

        delivery_boys.name
        AS delivery_boy_name,

        delivery_boys.phone
        AS delivery_boy_phone,

        delivery_boys.vehicle_number

        FROM orders

        LEFT JOIN user_addresses
        ON user_addresses.id =
        orders.address_id

        LEFT JOIN delivery_boys
        ON delivery_boys.id =
        orders.deliveryboy_id

        WHERE orders.id=? AND orders.user_id=?");

    mysqli_stmt_bind_param($stmt, "ii", $order_id, $user_id);
    mysqli_stmt_execute($stmt);
    $query = mysqli_stmt_get_result($stmt);

    if (mysqli_num_rows($query) == 0) {

        echo json_encode([
            "status" => false
        ]);

        exit;
    }

    $order =
    mysqli_fetch_assoc($query);

    $items = [];

    $itemStmt = mysqli_prepare($conn,
        "SELECT order_items.*,

        products.name,
        products.image

        FROM order_items

        LEFT JOIN products
        ON products.id =
        order_items.product_id

        WHERE order_items.order_id=?");

    mysqli_stmt_bind_param($itemStmt, "i", $order_id);
    mysqli_stmt_execute($itemStmt);
    $itemQuery = mysqli_stmt_get_result($itemStmt);

    while ($item =
    mysqli_fetch_assoc($itemQuery)) {

        $items[] = $item;
    }

    echo json_encode([
        "status" => true,
        "order" => $order,
        "items" => $items
    ]);

    exit;
}
/* =====================================
   GET CATEGORIES
===================================== */
if ($action == "get_categories") {

    $data = [];

    $query = mysqli_query($conn,
        "SELECT * FROM categories ORDER BY id ASC");

    while ($row = mysqli_fetch_assoc($query)) {

        $data[] = [
            "id" => $row['id'],
            "name" => $row['name'],
            "image" => $row['image'],
            "homecategory" => $row['homecategory']
        ];
    }

    echo json_encode([
        "status" => true,
        "categories" => $data
    ]);

    exit;
}


/* =====================================
   GET SUBCATEGORIES
===================================== */
if ($action == "get_subcategories") {

    $category_id = $_POST['category_id'] ?? '';

    $data = [];

    $query = mysqli_query($conn,
        "SELECT * FROM subcategories
         WHERE category_id='$category_id'
         ORDER BY id ASC");

    while ($row = mysqli_fetch_assoc($query)) {

        $data[] = [
            "id" => $row['id'],
            "category_id" => $row['category_id'],
            "name" => $row['name'],
            "image" => $row['image']
        ];
    }

    echo json_encode([
        "status" => true,
        "subcategories" => $data
    ]);

    exit;
}


/* =====================================
   GET TOP DEAL PRODUCTS
===================================== */
if ($action == "get_top_deals") {

    $data = [];

    $query = mysqli_query($conn,
        "SELECT * FROM products
         WHERE topdeals='yes'
         ORDER BY id DESC");

    while ($row = mysqli_fetch_assoc($query)) {

        $data[] = [
            "id" => $row['id'],
            "name" => $row['name'],
            "rate" => $row['rate'],
            "saleprice" => $row['saleprice'],
            "image" => $row['image'],
            "stock" => $row['stock'],
            "hasvarients" => $row['hasvarients']
        ];
    }

    echo json_encode([
        "status" => true,
        "products" => $data
    ]);

    exit;
}


/* =====================================
   GET PRODUCTS BY SUBCATEGORY
===================================== */
if ($action == "get_products") {

    $subcat_id = $_POST['subcat_id'] ?? '';

    $data = [];

    $query = mysqli_query($conn,
        "SELECT * FROM products
         WHERE subcat_id='$subcat_id'
         ORDER BY id DESC");

    while ($row = mysqli_fetch_assoc($query)) {

        $data[] = [
            "id" => $row['id'],
            "name" => $row['name'],
            "rate" => $row['rate'],
            "saleprice" => $row['saleprice'],
            "image" => $row['image'],
            "stock" => $row['stock'],
            "hasvarients" => $row['hasvarients']
        ];
    }

    echo json_encode([
        "status" => true,
        "products" => $data
    ]);

    exit;
}


/* =====================================
   VIEW PRODUCT
===================================== */
if ($action == "view_product") {

$product_id =
$_POST['product_id']
?? '';

$user_id =
$_POST['user_id']
?? 0;

$query =
mysqli_query(

$conn,

"

SELECT *

FROM products

WHERE id='$product_id'

"

);

if(
mysqli_num_rows(
$query
)
==
0
){

echo json_encode([

"status"=>false,

"message"=>
"Product not found"

]);

exit;

}

$product =
mysqli_fetch_assoc(
$query
);

// 🔥 WISHLIST STATUS

$product[
"is_wishlist"
]
=
false;

if(
!empty(
$user_id
)
){

$wish =
mysqli_query(

$conn,

"

SELECT id

FROM wishlist

WHERE

user_id='$user_id'

AND

product_id='$product_id'

LIMIT 1

"

);

$product[
"is_wishlist"
]

=

mysqli_num_rows(
$wish
)

>

0;

}

// 🔥 FIX NULL VALUES

$product['name'] =
$product['name']
?? '';

$product['image'] =
$product['image']
?? '';

$product['product_description'] =
$product['product_description']
?? '';

$product['other_images'] =
$product['other_images']
?? '';

$variants=[];

$vquery=
mysqli_query(

$conn,

"

SELECT *

FROM product_varients

WHERE product_id='$product_id'

"

);

while(
$v=
mysqli_fetch_assoc(
$vquery
)
){

$v[
'varient_name'
]
=
$v[
'varient_name'
]
?? '';

$v[
'product_description'
]
=
$v[
'product_description'
]
?? '';

$v[
'rate'
]
=
$v[
'rate'
]
?? '0';

$v[
'salerate'
]
=
$v[
'salerate'
]
?? '0';

$v[
'stock'
]
=
$v[
'stock'
]
?? '0';

$variants[]=
$v;

}

// 🔥 REVIEWS

$reviews=[];

$rquery=
mysqli_query(

$conn,

"

SELECT

product_reviews.*,

users.name

FROM product_reviews

LEFT JOIN users

ON users.id=
product_reviews.user_id

WHERE product_id='$product_id'

ORDER BY product_reviews.id DESC

"

);

$total_rating=0;

$total_reviews=0;

while(
$r=
mysqli_fetch_assoc(
$rquery
)
){

$r[
'name'
]
=
$r[
'name'
]
??
'User';

$r[
'review'
]
=
$r[
'review'
]
?? '';

$r[
'rating'
]
=
$r[
'rating'
]
?? '0';

$reviews[]=
$r;

$total_rating+=
floatval(
$r[
'rating'
]
);

$total_reviews++;

}

$avg_rating=0;

if(
$total_reviews>0
){

$avg_rating=

round(

$total_rating
/

$total_reviews,

1

);

}

echo json_encode([

"status"=>true,

"product"=>$product,

"variants"=>$variants,

"reviews"=>$reviews,

"avg_rating"=>$avg_rating,

"total_reviews"=>$total_reviews

]);

exit;

}
/* =====================================
   GET SIMILAR PRODUCTS
===================================== */
if ($action == "get_similar_products") {

    $subcat_id = $_POST['subcat_id'] ?? '';
    $exclude_id = $_POST['exclude_id'] ?? '';

    $data = [];

    $query = mysqli_query($conn,
        "SELECT * FROM products
         WHERE subcat_id='$subcat_id'
         AND id != '$exclude_id'
         AND stock > 0
         ORDER BY id DESC
         LIMIT 10");

    while ($row = mysqli_fetch_assoc($query)) {

        $data[] = [
            "id" => $row['id'],
            "name" => $row['name'],
            "rate" => $row['rate'],
            "saleprice" => $row['saleprice'],
            "image" => $row['image'],
            "stock" => $row['stock'],
            "hasvarients" => $row['hasvarients']
        ];
    }

    echo json_encode([
        "status" => true,
        "products" => $data
    ]);

    exit;
}
/* =====================================
   HOME CATEGORY PRODUCTS
===================================== */
if ($action == "home_category_products") {

    $categories = [];

    $catQuery = mysqli_query($conn,
        "SELECT * FROM categories
         WHERE homecategory='yes'
         ORDER BY id ASC");

    while ($cat = mysqli_fetch_assoc($catQuery)) {

        $products = [];

        $productQuery = mysqli_query($conn,
            "SELECT * FROM products
             WHERE cat_id='".$cat['id']."'
             ORDER BY id DESC");

        while ($p = mysqli_fetch_assoc($productQuery)) {

            $products[] = [
                "id" => $p['id'],
                "name" => $p['name'],
                "image" => $p['image'],
                "rate" => $p['rate'],
                "saleprice" => $p['saleprice'],
                "stock" => $p['stock']
            ];
        }

        $categories[] = [
            "id" => $cat['id'],
            "name" => $cat['name'],
            "products" => $products
        ];
    }

    echo json_encode([
        "status" => true,
        "categories" => $categories
    ]);

    exit;
}
/* =====================================
   TOGGLE WISHLIST
===================================== */
if ($action == "toggle_wishlist") {

    $user_id = requireAuth($conn);
    $product_id = intval($_POST['product_id']);

    $check = mysqli_prepare($conn,
        "SELECT id FROM wishlist WHERE user_id=? AND product_id=?");

    mysqli_stmt_bind_param($check, "ii", $user_id, $product_id);
    mysqli_stmt_execute($check);
    $checkResult = mysqli_stmt_get_result($check);

    if (mysqli_num_rows($checkResult) > 0) {

        $del = mysqli_prepare($conn,
            "DELETE FROM wishlist WHERE user_id=? AND product_id=?");

        mysqli_stmt_bind_param($del, "ii", $user_id, $product_id);
        mysqli_stmt_execute($del);

        echo json_encode([
            "status" => true,
            "wishlist" => false
        ]);

    } else {

        $insert = mysqli_prepare($conn,
            "INSERT INTO wishlist (user_id, product_id) VALUES (?, ?)");

        mysqli_stmt_bind_param($insert, "ii", $user_id, $product_id);
        mysqli_stmt_execute($insert);

        echo json_encode([
            "status" => true,
            "wishlist" => true
        ]);
    }

    exit;
}


/* =====================================
   ADD REVIEW
===================================== */
if ($action == "add_review") {

    $user_id = requireAuth($conn);
    $product_id = intval($_POST['product_id']);
    $rating = intval($_POST['rating']);
    $review = $_POST['review'];

    $stmt = mysqli_prepare($conn,
        "INSERT INTO product_reviews (user_id, product_id, rating, review)
         VALUES (?, ?, ?, ?)");

    mysqli_stmt_bind_param($stmt, "iiis", $user_id, $product_id, $rating, $review);
    mysqli_stmt_execute($stmt);

    echo json_encode([
        "status" => true,
        "message" => "Review Added"
    ]);

    exit;
}


/* =====================================
   ADD TO CART
===================================== */
if ($action == "add_to_cart") {

    $user_id = requireAuth($conn);

    $product_id = intval($_POST['product_id']);
    $variant_id = intval($_POST['variant_id'] ?? 0);

    $check = mysqli_prepare($conn,
        "SELECT id FROM cart
         WHERE user_id=? AND product_id=? AND variant_id=?");

    mysqli_stmt_bind_param($check, "iii", $user_id, $product_id, $variant_id);
    mysqli_stmt_execute($check);
    $checkResult = mysqli_stmt_get_result($check);

    if (mysqli_num_rows($checkResult) > 0) {

        $update = mysqli_prepare($conn,
            "UPDATE cart SET quantity=quantity+1
             WHERE user_id=? AND product_id=? AND variant_id=?");

        mysqli_stmt_bind_param($update, "iii", $user_id, $product_id, $variant_id);
        mysqli_stmt_execute($update);

    } else {

        $insert = mysqli_prepare($conn,
            "INSERT INTO cart (user_id, product_id, variant_id, quantity)
             VALUES (?, ?, ?, 1)");

        mysqli_stmt_bind_param($insert, "iii", $user_id, $product_id, $variant_id);
        mysqli_stmt_execute($insert);
    }

    echo json_encode([
        "status" => true
    ]);

    exit;
}

/* =====================================
   GET CART
===================================== */
/* =====================================
   GET CART
===================================== */
if ($action == "get_cart") {

    $user_id = requireAuth($conn);

    $items = [];

    $stmt = mysqli_prepare($conn,
        "SELECT
            cart.*,

            products.name,
            products.image,
            products.saleprice,
            products.rate,

            product_varients.varient_name,
            product_varients.salerate,
            product_varients.rate AS varient_rate

         FROM cart

         LEFT JOIN products
         ON products.id = cart.product_id

         LEFT JOIN product_varients
         ON product_varients.id = cart.variant_id

         WHERE cart.user_id=?

         ORDER BY cart.id DESC");

    mysqli_stmt_bind_param($stmt, "i", $user_id);
    mysqli_stmt_execute($stmt);
    $query = mysqli_stmt_get_result($stmt);

    while ($row = mysqli_fetch_assoc($query)) {

        // 🔥 VARIANT PRICE
        if (
            !empty($row['variant_id']) &&
            $row['variant_id'] != 0
        ) {

            $row['saleprice'] =
                $row['salerate'];

            $row['rate'] =
                $row['varient_rate'];
        }

        // 🔥 FIX NULLS
        $row['name'] =
            $row['name'] ?? '';

        $row['image'] =
            $row['image'] ?? '';

        $row['saleprice'] =
            $row['saleprice'] ?? '0';

        $row['rate'] =
            $row['rate'] ?? '0';

        $row['quantity'] =
            $row['quantity'] ?? '1';

        $row['varient_name'] =
            $row['varient_name'] ?? '';

        $items[] = $row;
    }

    echo json_encode([
        "status" => true,
        "items" => $items
    ]);

    exit;
}
/* =====================================
   SAVE ADDRESS
===================================== */
if($action=="save_address"){

$user_id = requireAuth($conn);

$full_name=
$_POST["full_name"];

$mobile=
$_POST["mobile"];

$address=
$_POST["address"];

$city=
$_POST["city"];

$state=
$_POST["state"];

$pincode=
$_POST["pincode"];

$lat=
$_POST["latitude"];

$lng=
$_POST["longitude"];

$check = mysqli_prepare($conn,
    "SELECT id FROM service_pincodes WHERE pincode=? LIMIT 1");

mysqli_stmt_bind_param($check, "s", $pincode);
mysqli_stmt_execute($check);
$checkResult = mysqli_stmt_get_result($check);

if(
mysqli_num_rows(
$checkResult
)==0
){

echo json_encode([

"status"=>false,

"message"=>

"Service unavailable at current location"

]);

exit;

}

$resetDefault = mysqli_prepare($conn,
    "UPDATE user_addresses SET is_default='no' WHERE user_id=?");

mysqli_stmt_bind_param($resetDefault, "i", $user_id);
mysqli_stmt_execute($resetDefault);

$insert = mysqli_prepare($conn,
    "INSERT INTO user_addresses
    (user_id, full_name, mobile, address, city, state, pincode, latitude, longitude, is_default)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'yes')");

mysqli_stmt_bind_param($insert, "i" . str_repeat("s", 8),
    $user_id, $full_name, $mobile, $address, $city, $state, $pincode, $lat, $lng);

mysqli_stmt_execute($insert);

echo json_encode([

"status"=>true

]);

exit;

}
/* =====================================
   APPLY COUPON
===================================== */
if ($action == "apply_coupon") {

    $code = $_POST['code'];
    $amount = $_POST['amount'];

    $query = mysqli_query($conn,
        "SELECT * FROM coupons
         WHERE code='$code'
         AND status='active'");

    if (mysqli_num_rows($query) == 0) {

        echo json_encode([
            "status" => false,
            "message" => "Invalid Coupon"
        ]);

        exit;
    }

    $coupon = mysqli_fetch_assoc($query);

    if ($amount < $coupon['min_amount']) {

        echo json_encode([
            "status" => false,
            "message" =>
            "Minimum order not matched"
        ]);

        exit;
    }

    $discount = 0;

    if ($coupon['discount_type'] == "flat") {

        $discount =
            $coupon['discount_amount'];

    } else {

        $discount =
            ($amount *
                $coupon['discount_amount']) / 100;
    }

    echo json_encode([
        "status" => true,
        "discount" => $discount
    ]);

    exit;
}
/* =====================================
   GET OFFERS
===================================== */
if ($action == "get_offers") {

    $data = [];

    $query = mysqli_query($conn,
        "SELECT * FROM coupons
         WHERE status='active'
         ORDER BY id DESC");

    while ($row = mysqli_fetch_assoc($query)) {

        $data[] = [
            "id" => $row['id'],
            "code" => $row['code'],
            "discount_type" => $row['discount_type'],
            "discount_amount" => $row['discount_amount'],
            "min_amount" => $row['min_amount']
        ];
    }

    echo json_encode([
        "status" => true,
        "offers" => $data
    ]);

    exit;
}
/* =====================================
   CHECK DELIVERY
===================================== */
if ($action == "check_delivery") {

    $pincode = $_POST['pincode'] ?? '';

    $deliverable = false;

    if (!empty($pincode)) {

        $check = mysqli_query($conn,
            "SELECT id FROM service_pincodes
             WHERE pincode='$pincode'
             LIMIT 1");

        $deliverable = mysqli_num_rows($check) > 0;
    }

    $estimate = $deliverable
        ? date('Y-m-d', strtotime('+1 day'))
        : null;

    echo json_encode([
        "status" => true,
        "deliverable" => $deliverable,
        "delivery_estimate" => $estimate
    ]);

    exit;
}
/* =====================================
   GET DEFAULT ADDRESS
===================================== */
if ($action == "get_default_address") {

    $user_id = requireAuth($conn);

    $stmt = mysqli_prepare($conn,
        "SELECT * FROM user_addresses
         WHERE user_id=?
         ORDER BY id DESC");

    mysqli_stmt_bind_param($stmt, "i", $user_id);
    mysqli_stmt_execute($stmt);
    $query = mysqli_stmt_get_result($stmt);

    if (mysqli_num_rows($query) > 0) {

        $address = mysqli_fetch_assoc($query);

        echo json_encode([
            "status" => true,
            "address" => $address
        ]);

    } else {

        echo json_encode([
            "status" => false
        ]);
    }

    exit;
}
/* =====================================
   PLACE ORDER
===================================== */
/* =====================================
   PLACE ORDER
===================================== */
/* =====================================
   PLACE ORDER
===================================== */
/* =====================================
   PLACE ORDER
===================================== */
if ($action == "place_order") {

    $user_id = requireAuth($conn);
    $address_id = intval($_POST['address_id'] ?? 0);

    $coupon_code =
        $_POST['coupon_code'] ?? '';

    $discount_amount =
        floatval($_POST['discount_amount'] ?? 0);

    $subtotal =
        floatval($_POST['subtotal'] ?? 0);

    $total_amount =
        floatval($_POST['total_amount'] ?? 0);

    $payment_method =
        $_POST['payment_method'] ?? 'cod';

    // 🔥 VALIDATION
    if (empty($address_id)) {

        echo json_encode([
            "status" => false,
            "message" =>
            "Required fields missing"
        ]);

        exit;
    }

    // 🔥 CHECK ADDRESS (must belong to this authenticated user)
    $addressStmt = mysqli_prepare($conn,
        "SELECT id FROM user_addresses
         WHERE id=? AND user_id=?");

    mysqli_stmt_bind_param($addressStmt, "ii", $address_id, $user_id);
    mysqli_stmt_execute($addressStmt);
    $addressQuery = mysqli_stmt_get_result($addressStmt);

    if (mysqli_num_rows($addressQuery) == 0) {

        echo json_encode([
            "status" => false,
            "message" =>
            "Invalid address"
        ]);

        exit;
    }

    // 🔥 GET CART
    $cartStmt = mysqli_prepare($conn,
        "SELECT * FROM cart WHERE user_id=?");

    mysqli_stmt_bind_param($cartStmt, "i", $user_id);
    mysqli_stmt_execute($cartStmt);
    $cartQuery = mysqli_stmt_get_result($cartStmt);

    if (mysqli_num_rows($cartQuery) == 0) {

        echo json_encode([
            "status" => false,
            "message" =>
            "Cart Empty"
        ]);

        exit;
    }

    // 🔥 ORDER NUMBER
    $order_no =
        "ORD".time().rand(100,999);

    // 🔥 PAYMENT STATUS
 // 🔥 PAYMENT STATUS

$payment_status=

(

$payment_method=="online"

||

$payment_method=="wallet"

)

?

"paid"

:

"pending";


// 🔥 WALLET PAYMENT

if(

$payment_method
==
"wallet"

){

$walletStmt = mysqli_prepare($conn,
    "SELECT wallet_balance FROM users WHERE id=? LIMIT 1");

mysqli_stmt_bind_param($walletStmt, "i", $user_id);
mysqli_stmt_execute($walletStmt);
$user = mysqli_fetch_assoc(mysqli_stmt_get_result($walletStmt));

$current=

doubleval(

$user[
"wallet_balance"
]

??

0

);

if(

$current
<
$total_amount

){

echo json_encode([

"status"=>false,

"message"=>

"Insufficient wallet balance"

]);

exit;

}

$remaining=

$current
-
$total_amount;

$walletUpdate = mysqli_prepare($conn,
    "UPDATE users SET wallet_balance=? WHERE id=?");

mysqli_stmt_bind_param($walletUpdate, "di", $remaining, $user_id);
mysqli_stmt_execute($walletUpdate);

}
// 🔥 DELIVERY OTP
$delivery_otp =
rand(
1000,
9999
);

$orderStmt = mysqli_prepare($conn,
"INSERT INTO orders
(
order_no,
user_id,
address_id,
coupon_code,
discount_amount,
subtotal,
total_amount,
payment_method,
payment_status,
order_status,
delivery_otp
)

VALUES

(?, ?, ?, ?, ?, ?, ?, ?, ?, 'Placed', ?)"
);

mysqli_stmt_bind_param($orderStmt, "siisdddsss",
    $order_no, $user_id, $address_id, $coupon_code,
    $discount_amount, $subtotal, $total_amount,
    $payment_method, $payment_status, $delivery_otp);

$insertOrder = mysqli_stmt_execute($orderStmt);

    if (!$insertOrder) {

        echo json_encode([
            "status" => false,
            "message" =>
            mysqli_error($conn)
        ]);

        exit;
    }

    $order_id =
        mysqli_insert_id($conn);

    // 🔥 INSERT ITEMS
    while ($cart =
    mysqli_fetch_assoc($cartQuery)) {

        $product_id =
            intval($cart['product_id']);

        $variant_id =
            intval($cart['variant_id']);

        $quantity =
            intval($cart['quantity']);

        $price = 0;

        $productStmt = mysqli_prepare($conn,
            "SELECT saleprice FROM products WHERE id=?");

        mysqli_stmt_bind_param($productStmt, "i", $product_id);
        mysqli_stmt_execute($productStmt);
        $productQuery = mysqli_stmt_get_result($productStmt);

        if ($product =
        mysqli_fetch_assoc($productQuery)) {

            $price =
            $product['saleprice'];
        }

        if ($variant_id != 0) {

            $variantQuery =
            mysqli_query($conn,
                "SELECT salerate
                 FROM product_varients
                 WHERE id='$variant_id'");

            if ($variant =
            mysqli_fetch_assoc($variantQuery)) {

                $price =
                $variant['salerate'];
            }
        }

        $total =
            $price * $quantity;

        $insertItem =
        mysqli_query($conn,
            "INSERT INTO order_items
            (
                order_id,
                product_id,
                variant_id,
                quantity,
                price,
                total
            )
            VALUES
            (
                '$order_id',
                '$product_id',
                '$variant_id',
                '$quantity',
                '$price',
                '$total'
            )");

        if (!$insertItem) {

            file_put_contents(
                "errorlog.txt",
                "ITEM INSERT FAILED\n",
                FILE_APPEND
            );

            file_put_contents(
                "errorlog.txt",
                mysqli_error($conn)."\n",
                FILE_APPEND
            );

            echo json_encode([
                "status" => false,
                "message" =>
                mysqli_error($conn)
            ]);

            exit;
        }
    }

    // 🔥 CLEAR CART
    $clearCartStmt = mysqli_prepare($conn,
        "DELETE FROM cart WHERE user_id=?");

    mysqli_stmt_bind_param($clearCartStmt, "i", $user_id);
    mysqli_stmt_execute($clearCartStmt);
// 🔥 SEND FCM AFTER ORDER

$fcmStmt = mysqli_prepare($conn,
    "SELECT fcm_token FROM users WHERE id=? LIMIT 1");

mysqli_stmt_bind_param($fcmStmt, "i", $user_id);
mysqli_stmt_execute($fcmStmt);
$user = mysqli_fetch_assoc(mysqli_stmt_get_result($fcmStmt));

$token=

$user[
"fcm_token"
]

??

"";

if(

!empty(
$token
)

){

$access=

trim(

file_get_contents(

"https://zipzapcart.com/app/addaccess_token.php"

)

);

$project=

"ftnews-79e5c";

$payload=[

"message"=>[

"token"=>$token,

"notification"=>[

"title"=>

"Order Placed 🎉",

"body"=>

"Your order #$order_no placed successfully"

],

"data"=>[

"screen"=>

"orders",

"order_id"=>

(string)$order_id

]

]

];

$ch=
curl_init();

curl_setopt(

$ch,

CURLOPT_URL,

"https://fcm.googleapis.com/v1/projects/"

.$project.

"/messages:send"

);

curl_setopt(

$ch,

CURLOPT_POST,

true

);

curl_setopt(

$ch,

CURLOPT_RETURNTRANSFER,

true

);

curl_setopt(

$ch,

CURLOPT_HTTPHEADER,

[

"Authorization: Bearer ".$access,

"Content-Type: application/json"

]

);

curl_setopt(

$ch,

CURLOPT_POSTFIELDS,

json_encode(
$payload
)

);

$response=

curl_exec(
$ch
);

$http=

curl_getinfo(

$ch,

CURLINFO_HTTP_CODE

);

$error=

curl_error(
$ch
);

curl_close(
$ch
);

file_put_contents(

"errorlog.txt",

"\nHTTP=".$http.

"\nERROR=".$error.

"\nRESP=".$response."\n",

FILE_APPEND


);

curl_close($ch);

}
    file_put_contents(
        "errorlog.txt",
        "SUCCESS\n",
        FILE_APPEND
    );

  echo json_encode([
"status"=>true,
"message"=>"Order Placed",
"order_id"=>$order_id,
"order_no"=>$order_no,
"delivery_otp"=>$delivery_otp
]);

    exit;
}
/* =====================================
   UPDATE CART QUANTITY
===================================== */
if ($action == "update_cart_quantity") {

    $user_id = requireAuth($conn);

    $cart_id = intval($_POST['cart_id']);
    $type = $_POST['type'];

    $stmt = mysqli_prepare($conn,
        "SELECT * FROM cart WHERE id=? AND user_id=?");

    mysqli_stmt_bind_param($stmt, "ii", $cart_id, $user_id);
    mysqli_stmt_execute($stmt);
    $query = mysqli_stmt_get_result($stmt);

    if (mysqli_num_rows($query) == 0) {

        echo json_encode([
            "status" => false
        ]);

        exit;
    }

    $cart = mysqli_fetch_assoc($query);

    $qty = intval($cart['quantity']);

    if ($type == "plus") {

        $qty++;

    } else {

        $qty--;
    }

    if ($qty <= 0) {

        $del = mysqli_prepare($conn,
            "DELETE FROM cart WHERE id=? AND user_id=?");

        mysqli_stmt_bind_param($del, "ii", $cart_id, $user_id);
        mysqli_stmt_execute($del);

    } else {

        $upd = mysqli_prepare($conn,
            "UPDATE cart SET quantity=? WHERE id=? AND user_id=?");

        mysqli_stmt_bind_param($upd, "iii", $qty, $cart_id, $user_id);
        mysqli_stmt_execute($upd);
    }

    echo json_encode([
        "status" => true
    ]);

    exit;
}
if($action=="search_products"){

$search=

mysqli_real_escape_string(

$conn,

$_POST["search"]

?? ""

);

$data=[];

$q=

mysqli_query(

$conn,

"

SELECT *

FROM products

WHERE

name

LIKE

'%$search%'

OR

product_description

LIKE

'%$search%'

ORDER BY id DESC

LIMIT 100

"

);

while(

$r=

mysqli_fetch_assoc(
$q
)

){

$data[]=
$r;

}

echo json_encode([

"status"=>true,

"products"=>$data

]);

exit;

}
/* ==============================
SAVE FCM TOKEN
================================ */

if($action=="save_fcm_token"){

$user_id = requireAuth($conn);

$fcm_token=
$_POST["fcm_token"]
?? "";

if(
empty($fcm_token)
){

echo json_encode([

"status"=>false,

"message"=>
"token missing"

]);

exit;

}

$stmt = mysqli_prepare($conn,
    "UPDATE users SET fcm_token=? WHERE id=?");

mysqli_stmt_bind_param($stmt, "si", $fcm_token, $user_id);
mysqli_stmt_execute($stmt);

echo json_encode([

"status"=>true,

"message"=>
"FCM Saved"

]);

exit;

}
/* =====================================
   GET RAZORPAY SETTINGS
===================================== */
if ($action == "get_razorpay_settings") {

    $query = mysqli_query($conn,
        "SELECT * FROM razorpay_settings
         LIMIT 1");

    if (mysqli_num_rows($query) > 0) {

        $row = mysqli_fetch_assoc($query);

        echo json_encode([
            "status" => true,
            "key_id" => $row['razorpay_key']
        ]);

    } else {

        echo json_encode([
            "status" => false
        ]);
    }

    exit;
}

/* =====================================
   GET WISHLIST
===================================== */
if ($action == "get_wishlist") {

    $user_id = requireAuth($conn);

    $products = [];

    $stmt = mysqli_prepare($conn,
        "SELECT wishlist.*,

        products.name,
        products.image,
        products.saleprice,
        products.rate,
        products.stock

        FROM wishlist

        LEFT JOIN products
        ON products.id =
        wishlist.product_id

        WHERE wishlist.user_id=?

        ORDER BY wishlist.id DESC");

    mysqli_stmt_bind_param($stmt, "i", $user_id);
    mysqli_stmt_execute($stmt);
    $query = mysqli_stmt_get_result($stmt);

    while ($row = mysqli_fetch_assoc($query)) {

        $products[] = [

            "id" =>
            $row['product_id'],

            "name" =>
            $row['name'],

            "image" =>
            $row['image'],

            "saleprice" =>
            $row['saleprice'],

            "rate" =>
            $row['rate'],

            "stock" =>
            $row['stock'],
        ];
    }

    echo json_encode([
        "status" => true,
        "products" => $products
    ]);

    exit;
}

/* =====================================
   GET ONBOARDING BANNERS
===================================== */
if ($action == "get_onboarding_banners") {

    $data = [];

    $query = mysqli_query($conn,
        "SELECT * FROM onboarding_banners
         ORDER BY id ASC");

    while ($row = mysqli_fetch_assoc($query)) {

        $data[] = [

            "id" =>
            $row['id'],

            "image" =>
            $row['image'],
        ];
    }

    echo json_encode([
        "status" => true,
        "banners" => $data
    ]);

    exit;
}

/* =====================================
   GET SPLASH
===================================== */
if ($action == "get_splash") {

    $query = mysqli_query($conn,
        "SELECT * FROM splash
         ORDER BY id DESC
         LIMIT 1");

    if (mysqli_num_rows($query) > 0) {

        $row = mysqli_fetch_assoc($query);

        echo json_encode([

            "status" => true,

            "image" =>
            $row['image'],
        ]);

    } else {

        echo json_encode([
            "status" => false
        ]);
    }

    exit;
}



/* ==============================
  OTT API STARTS
================================ */
/* =====================================
   OTT HOME DATA
===================================== */
if ($action == "get_ott_home") {

    $cat_id =
    $_POST['cat_id'] ?? '0';

    // 🔥 MAIN BANNERS
    $banners = [];

    if ($cat_id == "0") {

        $bannerQuery = mysqli_query($conn,

            "SELECT * FROM movies
             ORDER BY id DESC
             LIMIT 8"
        );

    } else {

        $bannerQuery = mysqli_query($conn,

            "SELECT * FROM movies
             WHERE cat_id='$cat_id'
             ORDER BY id DESC
             LIMIT 8"
        );
    }

    while ($b = mysqli_fetch_assoc($bannerQuery)) {

        $banners[] = $b;
    }

    // 🔥 CASTING BANNERS
    $casting = [];

    $castQuery = mysqli_query($conn,

        "SELECT * FROM casting_banner
         ORDER BY id DESC"
    );

    while ($c = mysqli_fetch_assoc($castQuery)) {

        $casting[] = $c;
    }

    // 🔥 CATEGORIES
    $categories = [];

    $catQuery = mysqli_query($conn,

        "SELECT * FROM ottcategory
         ORDER BY id ASC"
    );

    while ($cat = mysqli_fetch_assoc($catQuery)) {

        $movies = [];

        if ($cat_id == "0") {

            $movieQuery = mysqli_query($conn,

                "SELECT * FROM movies
                 WHERE cat_id='".$cat['id']."'
                 ORDER BY id DESC"
            );

        } else {

            if ($cat['id'] != $cat_id) {
                continue;
            }

            $movieQuery = mysqli_query($conn,

                "SELECT * FROM movies
                 WHERE cat_id='$cat_id'
                 ORDER BY id DESC"
            );
        }

        while ($m = mysqli_fetch_assoc($movieQuery)) {

            $movies[] = [

                "id" =>
                $m['id'],

                "title" =>
                $m['title'],

                "mainposter" =>
                $m['mainposter'],

                "verticalposter" =>
                $m['verticalposter'],

                "views" =>
                $m['views'],

                "isfree" =>
                $m['isfree'],
            ];
        }

        $categories[] = [

            "id" =>
            $cat['id'],

            "name" =>
            $cat['name'],

            "movies" =>
            $movies,
        ];
    }

    echo json_encode([

        "status" => true,

        "banners" => $banners,

        "casting_banner" => $casting,

        "categories" => $categories,
    ]);

    exit;
}


/* =====================================
   VIEW MOVIE
===================================== */
if ($action == "view_movie") {

    $movie_id =
    $_POST['movie_id'];

    $query = mysqli_query($conn,

        "SELECT * FROM movies
         WHERE id='$movie_id'"
    );

    if (mysqli_num_rows($query) == 0) {

        echo json_encode([
            "status" => false
        ]);

        exit;
    }

    $movie =
    mysqli_fetch_assoc($query);

    // 🔥 UPDATE VIEWS
    mysqli_query($conn,

        "UPDATE movies
         SET views=views+1
         WHERE id='$movie_id'"
    );

    $casts = [];

    $castids =
    explode(",",
        $movie['castid']);

    foreach ($castids as $cid) {

        $castQuery = mysqli_query($conn,

            "SELECT * FROM cast
             WHERE id='$cid'"
        );

        if (mysqli_num_rows($castQuery) > 0) {

            $casts[] =
            mysqli_fetch_assoc(
                $castQuery
            );
        }
    }

    echo json_encode([

        "status" => true,

        "movie" => $movie,

        "cast" => $casts,
    ]);

    exit;
}


/* =====================================
   TOGGLE WATCHLIST
===================================== */
if ($action == "toggle_watchlist") {

    $user_id =
    $_POST['user_id'];

    $movieid =
    $_POST['movieid'];

    $check = mysqli_query($conn,

        "SELECT * FROM watchlist
         WHERE user_id='$user_id'
         AND movieid='$movieid'"
    );

    if (mysqli_num_rows($check) > 0) {

        mysqli_query($conn,

            "DELETE FROM watchlist
             WHERE user_id='$user_id'
             AND movieid='$movieid'"
        );

        echo json_encode([

            "status" => true,

            "watchlist" => false,
        ]);

    } else {

        mysqli_query($conn,

            "INSERT INTO watchlist
            (user_id,movieid)
            VALUES
            ('$user_id','$movieid')"
        );

        echo json_encode([

            "status" => true,

            "watchlist" => true,
        ]);
    }

    exit;
}

/* =====================================
   SAVE WATCH PROGRESS
===================================== */
if ($action == "save_watch_progress") {

    $user_id =
    $_POST['user_id'];

    $movie_id =
    $_POST['movie_id'];

    $watched_seconds =
    $_POST['watched_seconds'];

    $check = mysqli_query($conn,

        "SELECT id
         FROM movie_watch_history
         WHERE user_id='$user_id'
         AND movie_id='$movie_id'"
    );

    if (mysqli_num_rows($check) > 0) {

        mysqli_query($conn,

            "UPDATE movie_watch_history
             SET watched_seconds='$watched_seconds'
             WHERE user_id='$user_id'
             AND movie_id='$movie_id'"
        );

    } else {

        mysqli_query($conn,

            "INSERT INTO movie_watch_history
            (
            user_id,
            movie_id,
            watched_seconds
            )

            VALUES
            (
            '$user_id',
            '$movie_id',
            '$watched_seconds'
            )"
        );
    }

    echo json_encode([
        "status" => true
    ]);

    exit;
}

/* =====================================
   GET SUBSCRIPTIONS
===================================== */

if($action == "get_subscriptions") {

    $plans = [];

    $q = mysqli_query($conn,

        "SELECT * FROM subscription
         ORDER BY amount ASC"
    );

    while($row = mysqli_fetch_assoc($q)) {

        $plans[] = $row;
    }

    echo json_encode([

        "status" => true,

        "plans" => $plans
    ]);

    exit;
}
/* =========================================
   GET CASTING
========================================= */

if($action == "get_casting") {

    $data = [];

    $query = mysqli_query(

        $conn,

        "SELECT *
         FROM casting
         ORDER BY id DESC"
    );

    while($row = mysqli_fetch_assoc($query)) {

        $data[] = $row;
    }

    echo json_encode([

        "status" => true,

        "casting" => $data
    ]);

    exit;
}


/* =========================================
   SUBMIT CASTING APPLICATION
========================================= */

if($action == "submit_casting_application") {

    $user_id =
    mysqli_real_escape_string(
        $conn,
        $_POST['user_id']
    );

    $casting_id =
    mysqli_real_escape_string(
        $conn,
        $_POST['casting_id']
    );

    $name =
    mysqli_real_escape_string(
        $conn,
        $_POST['name']
    );

    $height =
    mysqli_real_escape_string(
        $conn,
        $_POST['height']
    );

    $weight =
    mysqli_real_escape_string(
        $conn,
        $_POST['weight']
    );

    $workexperience =
    mysqli_real_escape_string(
        $conn,
        $_POST['workexperience']
    );

    // 🔥 CREATE FOLDER
    if(!is_dir("uploads/casting")) {

        mkdir(
            "uploads/casting",
            0777,
            true
        );
    }

    // 🔥 VIDEO
    $videoName = "";

    if(isset($_FILES['video']) &&
       $_FILES['video']['name'] != "") {

        $videoExt =
        pathinfo(

            $_FILES['video']['name'],
            PATHINFO_EXTENSION
        );

        $videoName =
        "uploads/casting/" .
        time() .
        rand(1000,9999) .
        "." .
        $videoExt;

        move_uploaded_file(

            $_FILES['video']['tmp_name'],

            $videoName
        );
    }

    // 🔥 PHOTOS
    $photos = [];

    if(isset($_FILES['photos'])) {

        foreach(
            $_FILES['photos']['tmp_name']
            as $key => $tmp
        ) {

            if($tmp == "") {
                continue;
            }

            $photoExt =
            pathinfo(

                $_FILES['photos']['name'][$key],
                PATHINFO_EXTENSION
            );

            $photoName =
            "uploads/casting/" .
            time() .
            rand(1000,9999) .
            "." .
            $photoExt;

            move_uploaded_file(

                $tmp,

                $photoName
            );

            $photos[] =
            $photoName;
        }
    }

    $photosImploded =
    implode(",", $photos);

    $insert = mysqli_query(

        $conn,

        "INSERT INTO casting_application

        (
        user_id,
        casting_id,
        name,
        photos,
        height,
        weight,
        workexperience,
        video
        )

        VALUES

        (
        '$user_id',
        '$casting_id',
        '$name',
        '$photosImploded',
        '$height',
        '$weight',
        '$workexperience',
        '$videoName'
        )"
    );

    if($insert) {

        echo json_encode([

            "status" => true,

            "message" =>
            "Application Submitted"
        ]);

    } else {

        echo json_encode([

            "status" => false,

            "message" =>
            "Database Error"
        ]);
    }

    exit;
}
/* =====================================
   ACTIVATE SUBSCRIPTION
===================================== */

if($action == "activate_subscription") {

    $user_id =
    $_POST['user_id'];

    $subscription_id =
    $_POST['subscription_id'];

    $payment_id =
    $_POST['payment_id'];

    $planQuery = mysqli_query($conn,

        "SELECT * FROM subscription
         WHERE id='$subscription_id'"
    );

    if(mysqli_num_rows($planQuery) == 0) {

        echo json_encode([

            "status" => false,

            "message" => "Invalid Plan"
        ]);

        exit;
    }

    $plan =
    mysqli_fetch_assoc(
        $planQuery
    );

    $days =
    $plan['days'];

    $startdate =
    date("Y-m-d");

    $enddate =
    date(
        "Y-m-d",
        strtotime("+$days days")
    );

    mysqli_query($conn,

        "UPDATE users SET

        paidstatus='paid',

        startdate='$startdate',

        enddate='$enddate'

        WHERE id='$user_id'"
    );

    echo json_encode([

        "status" => true,

        "message" => "Subscription Activated"
    ]);

    exit;
}
/* =========================================
   GET ZHATPAT SERIES
========================================= */

if($action == "get_zhatpat_series") {

    $data = [];

    $query = mysqli_query($conn,

        "SELECT *
         FROM zhatpat
         ORDER BY id DESC"
    );

    while($row = mysqli_fetch_assoc($query)) {

        $data[] = $row;
    }

    echo json_encode([

        "status" => true,

        "series" => $data
    ]);

    exit;
}

/* =========================================
   GET ZHATPAT VIDEOS
========================================= */

if($action == "get_zhatpat_videos") {

    $zhatpat_id =
    $_POST['zhatpat_id'];

    $videos = [];

    $query = mysqli_query($conn,

        "SELECT *
         FROM zhatpat_videos
         WHERE zhatpat_id='$zhatpat_id'
         ORDER BY id ASC"
    );

    while($row = mysqli_fetch_assoc($query)) {

        $videos[] = $row;
    }

    echo json_encode([

        "status" => true,

        "videos" => $videos
    ]);

    exit;
}

/* =========================================
   GET SHORTS
========================================= */

if($action == "get_shorts") {

    $data = [];

    $query = mysqli_query($conn,

        "SELECT *
         FROM shorts
         ORDER BY id DESC"
    );

    while($row = mysqli_fetch_assoc($query)) {

        $data[] = $row;
    }

    echo json_encode([

        "status" => true,

        "shorts" => $data
    ]);

    exit;
}
/* =========================================
   GET WATCHLIST
========================================= */

if($action == "get_watchlist_movies") {

    $user_id =
    $_POST['user_id'];

    $data = [];

    $query = mysqli_query($conn,

        "SELECT
        watchlist.*,
        movies.title,
        movies.mainposter,
        movies.views,
        movies.isfree

        FROM watchlist

        LEFT JOIN movies
        ON movies.id = watchlist.movieid

        WHERE watchlist.user_id='$user_id'

        ORDER BY watchlist.id DESC"
    );

    while($row = mysqli_fetch_assoc($query)) {

        $data[] = $row;
    }

    echo json_encode([

        "status" => true,

        "movies" => $data
    ]);

    exit;
}
/* =========================================
   GET WATCH HISTORY
========================================= */

if($action == "get_watch_history") {

    $user_id =
    $_POST['user_id'];

    $data = [];

    $query = mysqli_query($conn,

        "SELECT
        movie_watch_history.*,
        movies.title,
        movies.mainposter,
        movies.views,
        movies.isfree

        FROM movie_watch_history

        LEFT JOIN movies
        ON movies.id =
        movie_watch_history.movie_id

        WHERE movie_watch_history.user_id='$user_id'

        GROUP BY movie_watch_history.movie_id

        ORDER BY movie_watch_history.id DESC"
    );

    while($row = mysqli_fetch_assoc($query)) {

        $data[] = $row;
    }

    echo json_encode([

        "status" => true,

        "movies" => $data
    ]);

    exit;
}

/* =====================================
   REMOVE CART ITEM
===================================== */

if ($action == "remove_cart_item") {

    $user_id = requireAuth($conn);

    $cart_id = intval($_POST['cart_id'] ?? 0);

    if (empty($cart_id)) {

        echo json_encode([

            "status" => false,

            "message" =>
            "cart_id required"

        ]);

        exit;
    }

    $check = mysqli_prepare($conn,
        "SELECT id FROM cart WHERE id=? AND user_id=?");

    mysqli_stmt_bind_param($check, "ii", $cart_id, $user_id);
    mysqli_stmt_execute($check);
    $checkResult = mysqli_stmt_get_result($check);

    if (mysqli_num_rows($checkResult) == 0) {

        echo json_encode([

            "status" => false,

            "message" =>
            "Cart item not found"

        ]);

        exit;
    }

    $del = mysqli_prepare($conn,
        "DELETE FROM cart WHERE id=? AND user_id=?");

    mysqli_stmt_bind_param($del, "ii", $cart_id, $user_id);
    mysqli_stmt_execute($del);

    echo json_encode([

        "status" => true,

        "message" =>
        "Item removed"

    ]);

    exit;
}

/*=====================
GET ALL POSTS
======================*/

if($action=="get_posts"){

$data=[];

$q=

mysqli_query(

$conn,

"

SELECT

posts.*,

seller.name
AS seller_name,

(

SELECT COUNT(*)

FROM post_likes

WHERE post_id=
posts.id

)

AS likes,

(

SELECT COUNT(*)

FROM post_comments

WHERE post_id=
posts.id

)

AS comments

FROM posts

LEFT JOIN seller

ON seller.id=
posts.seller_id

ORDER BY posts.id DESC

"

);

while(

$row=

mysqli_fetch_assoc(
$q)

){

$row[
"likes"
]

=

intval(

$row[
"likes"
]

??

0

);

$row[
"comments"
]

=

intval(

$row[
"comments"
]

??

0

);

$data[]=
$row;

}

echo json_encode([

"status"=>true,

"posts"=>$data

]);

exit;

}
/*=====================
POST DETAILS
======================*/

if($action=="post_by_id"){

$id=$_POST["post_id"];

$post=mysqli_fetch_assoc(

mysqli_query(

$conn,

"

SELECT
posts.*,

seller.name
AS seller_name

FROM posts

LEFT JOIN seller

ON seller.id=
posts.seller_id

WHERE posts.id='$id'

"

)

);

$comments=[];

$c=mysqli_query(

$conn,

"

SELECT

post_comments.*,

users.name

FROM post_comments

LEFT JOIN users

ON users.id=
post_comments.user_id

WHERE post_id='$id'

ORDER BY id DESC

"

);
while(
$r=
mysqli_fetch_assoc($c)
){

$r["name"]=

$r["name"]

??

"User";

$comments[]=
$r;

}
echo json_encode([

"status"=>true,

"post"=>$post,

"comments"=>$comments

]);

exit;

}
/*=====================
LIKE POST
======================*/

if($action=="toggle_post_like"){

$post=$_POST["post_id"];

$user=$_POST["user_id"];

$check=mysqli_query(

$conn,

"

SELECT id

FROM post_likes

WHERE post_id='$post'

AND user_id='$user'

"

);

if(
mysqli_num_rows(
$check
)>0
){

mysqli_query(

$conn,

"

DELETE
FROM post_likes

WHERE post_id='$post'

AND user_id='$user'

"

);

}else{

mysqli_query(

$conn,

"

INSERT INTO
post_likes
(post_id,user_id)

VALUES

('$post','$user')

"

);

}

mysqli_query(

$conn,

"

UPDATE posts

SET likes_count=

(
SELECT COUNT(*)

FROM post_likes

WHERE post_id='$post'
)

WHERE id='$post'

"

);

$count=

mysqli_fetch_assoc(

mysqli_query(

$conn,

"

SELECT COUNT(*)
AS total

FROM post_likes

WHERE post_id='$post'

"

)

);

echo json_encode([

"status"=>true,

"likes"=>

intval(
$count["total"]
)

]);

exit;

}
/*=====================
ADD COMMENT
======================*/

if($action=="add_post_comment"){

$post=$_POST["post_id"];

$user=$_POST["user_id"];

$comment=$_POST["comment"];

mysqli_query(

$conn,

"

INSERT INTO
post_comments

(
post_id,
user_id,
comment
)

VALUES

(
'$post',
'$user',
'$comment'
)

"

);

echo json_encode([

"status"=>true

]);

exit;

}
if($action=="get_wallet"){

$user_id = requireAuth($conn);

$walletStmt = mysqli_prepare($conn,
    "SELECT wallet_balance FROM users WHERE id=? LIMIT 1");

mysqli_stmt_bind_param($walletStmt, "i", $user_id);
mysqli_stmt_execute($walletStmt);
$user = mysqli_fetch_assoc(mysqli_stmt_get_result($walletStmt));

$cashbackStmt = mysqli_prepare($conn,
    "SELECT SUM(cashback_amount) AS total FROM user_cashback WHERE user_id=?");

mysqli_stmt_bind_param($cashbackStmt, "i", $user_id);
mysqli_stmt_execute($cashbackStmt);
$cashback = mysqli_fetch_assoc(mysqli_stmt_get_result($cashbackStmt));

$refund=[];

$refundStmt = mysqli_prepare($conn,
    "SELECT * FROM user_refund WHERE user_id=? ORDER BY id DESC");

mysqli_stmt_bind_param($refundStmt, "i", $user_id);
mysqli_stmt_execute($refundStmt);
$q = mysqli_stmt_get_result($refundStmt);

while(

$r=
mysqli_fetch_assoc(
$q)

){

$refund[]=
$r;

}

echo json_encode([

"status"=>true,

"wallet_balance"=>

doubleval(

$user[
"wallet_balance"
]

??

0

),

"cashback_total"=>

doubleval(

$cashback[
"total"
]

??

0

),

"refunds"=>$refund

]);

exit;

}
/* =====================================
   CANCEL ORDER
===================================== */

if ($action == "cancel_order") {

    $user_id = requireAuth($conn);

    $order_id =
    intval($_POST["order_id"] ?? 0);

    if (empty($order_id)) {

        echo json_encode([

            "status" => false,

            "message" =>
            "order_id required"

        ]);

        exit;
    }

    // GET ORDER (must belong to this authenticated user)
    $stmt = mysqli_prepare($conn,

        "SELECT id, order_status
         FROM orders
         WHERE id=? AND user_id=?
         LIMIT 1"

    );

    mysqli_stmt_bind_param($stmt, "ii", $order_id, $user_id);
    mysqli_stmt_execute($stmt);
    $query = mysqli_stmt_get_result($stmt);

    if (
        mysqli_num_rows(
            $query
        ) == 0
    ) {

        echo json_encode([

            "status" => false,

            "message" =>
            "Order not found"

        ]);

        exit;
    }

    $order =
    mysqli_fetch_assoc(
        $query
    );

    $status =
    strtolower(
        trim(
            $order[
            "order_status"
            ]
        )
    );

    // BLOCK AFTER SHIPPING
    if (

    $status ==
    "shipped"

    ||

    $status ==
    "on the way"

    ||

    $status ==
    "delivered"

    ||

    $status ==
    "cancelled"

    ) {

        echo json_encode([

            "status" => false,

            "message" =>

            "Order cannot be cancelled"

        ]);

        exit;
    }

    $updateStmt = mysqli_prepare($conn,

        "UPDATE orders
         SET order_status='Cancelled'
         WHERE id=? AND user_id=?"

    );

    mysqli_stmt_bind_param($updateStmt, "ii", $order_id, $user_id);
    $update = mysqli_stmt_execute($updateStmt);

    if (!$update) {

        echo json_encode([

            "status" => false,

            "message" =>
            mysqli_error(
                $conn
            )

        ]);

        exit;
    }

    echo json_encode([

        "status" => true,

        "message" =>
        "Order Cancelled"

    ]);

    exit;
}

if($action=="get_cashback"){

$user_id = requireAuth($conn);

$totalStmt = mysqli_prepare($conn,
    "SELECT SUM(cashback_amount) AS total
     FROM user_cashback
     WHERE user_id=? AND transferred=0");

mysqli_stmt_bind_param($totalStmt, "i", $user_id);
mysqli_stmt_execute($totalStmt);
$total = mysqli_fetch_assoc(mysqli_stmt_get_result($totalStmt));

$data=[];

$listStmt = mysqli_prepare($conn,
    "SELECT * FROM user_cashback WHERE user_id=? ORDER BY id DESC");

mysqli_stmt_bind_param($listStmt, "i", $user_id);
mysqli_stmt_execute($listStmt);
$q = mysqli_stmt_get_result($listStmt);

while(

$r=

mysqli_fetch_assoc(
$q
)

){

$r[
"cashback_amount"
]=

doubleval(

$r[
"cashback_amount"
]

??

0

);

$data[]=
$r;

}

echo json_encode([

"status"=>true,

"total"=>

doubleval(

$total[
"total"
]

??

0

),

"cashbacks"=>$data

]);

exit;

}
if($action=="move_cashback"){

$user_id = requireAuth($conn);

$getStmt = mysqli_prepare($conn,
    "SELECT SUM(cashback_amount) AS total
     FROM user_cashback
     WHERE user_id=? AND transferred=0");

mysqli_stmt_bind_param($getStmt, "i", $user_id);
mysqli_stmt_execute($getStmt);
$get = mysqli_fetch_assoc(mysqli_stmt_get_result($getStmt));

$amount=

doubleval(

$get[
"total"
]

??

0

);

if(
$amount<=0
){

echo json_encode([

"status"=>false,

"message"=>
"No cashback available"

]);

exit;

}

$walletUpdateStmt = mysqli_prepare($conn,
    "UPDATE users SET wallet_balance=wallet_balance+? WHERE id=?");

mysqli_stmt_bind_param($walletUpdateStmt, "di", $amount, $user_id);
mysqli_stmt_execute($walletUpdateStmt);

$cashbackUpdateStmt = mysqli_prepare($conn,
    "UPDATE user_cashback SET transferred=1
     WHERE user_id=? AND transferred=0");

mysqli_stmt_bind_param($cashbackUpdateStmt, "i", $user_id);
mysqli_stmt_execute($cashbackUpdateStmt);

echo json_encode([

"status"=>true,

"message"=>
"Cashback moved"

]);

exit;

}
if(
$action==
"get_delivery_charge"
){

$pincode=

$_POST[
"pincode"
]

??

"";

$q=

mysqli_query(

$conn,

"

SELECT

delivery_charge

FROM service_pincodes

WHERE pincode='$pincode'

LIMIT 1

"

);

if(

mysqli_num_rows(
$q
)

>

0

){

$row=

mysqli_fetch_assoc(
$q
);

echo json_encode([

"status"=>true,

"delivery_charge"=>

doubleval(

$row[
"delivery_charge"
]

),

]);

}else{

echo json_encode([

"status"=>false,

"delivery_charge"=>0

]);

}

exit;

}
/* ==============================
   INVALID ACTION
================================ */
echo json_encode([
    "status" => false,
    "message" => "Invalid action"
]);
?>