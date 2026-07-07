<?php
error_reporting(E_ALL);

ini_set(
"display_errors",
1
);

mysqli_report(

MYSQLI_REPORT_ERROR

|

MYSQLI_REPORT_STRICT

);
header("Content-Type:application/json");

require_once "db.php";

$action = $_POST["action"] ?? "";

/* LOGIN */

if ($action == "login") {
    $phone = mysqli_real_escape_string(
        $conn,

        $_POST["phone"] ?? ""
    );

    $password = mysqli_real_escape_string(
        $conn,

        $_POST["password"] ?? ""
    );

    $q = mysqli_query(
        $conn,

        "

SELECT *

FROM delivery_boys

WHERE

phone='$phone'

AND

password='$password'

AND

is_active=1

LIMIT 1

"
    );

    if (mysqli_num_rows($q)) {
        $user = mysqli_fetch_assoc($q);

        echo json_encode([
            "status" => true,

            "user" => $user,
        ]);
    } else {
        echo json_encode([
            "status" => false,

            "message" => "Invalid phone or password",
        ]);
    }

    exit();
}

/* DASHBOARD */


if(
$action=="home"
){

$id=
intval(
$_POST["delivery_id"]
);

$today=

mysqli_fetch_assoc(

mysqli_query(

$conn,

"

SELECT
COUNT(*)
AS total

FROM orders

WHERE

deliveryboy_id='$id'

AND

DATE(created_at)=CURDATE()

"

)

);

$total=

mysqli_fetch_assoc(

mysqli_query(

$conn,

"

SELECT
COUNT(*)
AS total

FROM orders

WHERE

deliveryboy_id='$id'

"

)

);

$orders=[];

$q=

mysqli_query(

$conn,

"

SELECT

orders.*

FROM orders

WHERE

deliveryboy_id='$id'

AND

order_status!='Delivered'

ORDER BY id DESC

"

);

while(
$r=
mysqli_fetch_assoc(
$q
)
){

$orders[]=
$r;

}

echo json_encode([

"status"=>true,

"today"=>

intval(
$today["total"]
),

"total"=>

intval(
$total["total"]
),

"orders"=>$orders

]);

exit;

}
/* ORDER DETAILS */

if($action=="view_order"){

$id=intval($_POST["order_id"]);

$q=mysqli_query(

$conn,

"

SELECT

orders.*,

users.name,

users.phone,

user_addresses.full_name,

user_addresses.mobile,

user_addresses.address,

user_addresses.city,

user_addresses.state,

user_addresses.pincode,

user_addresses.latitude,

user_addresses.longitude

FROM orders

LEFT JOIN users
ON users.id=orders.user_id

LEFT JOIN user_addresses
ON user_addresses.id=orders.address_id

WHERE orders.id='$id'

LIMIT 1

"

);

$order=

mysqli_fetch_assoc($q);

$items=[];

$itemQuery=

mysqli_query(

$conn,

"

SELECT

order_items.*,

products.name product_name,

products.image

FROM order_items

LEFT JOIN products

ON products.id=
order_items.product_id

WHERE order_id='$id'

"

);

while(

$row=

mysqli_fetch_assoc(
$itemQuery
)

){

$items[]=$row;

}

echo json_encode([

"status"=>true,

"order"=>$order,

"items"=>$items,

]);

exit();

}

/* VERIFY OTP */
/* VERIFY OTP + SEND DELIVERY FCM */

if($action=="deliver_order"){

$order_id=
intval(
$_POST["order_id"]
);

$otp=
trim(
$_POST["otp"]
);

$q=
mysqli_query(

$conn,

"

SELECT

orders.*,
users.fcm_token

FROM orders

LEFT JOIN users
ON users.id=
orders.user_id

WHERE

orders.id='$order_id'

AND

orders.delivery_otp='$otp'

LIMIT 1

"

);

if(
mysqli_num_rows($q)
){

$order=
mysqli_fetch_assoc($q);

/* UPDATE ORDER */

mysqli_query(

$conn,

"

UPDATE orders

SET

order_status='Delivered'

WHERE id='$order_id'

"

);

/* IN-APP NOTIFICATION (independent of whether push delivery succeeds) */

$deliveredNotifText =
"Your order #" . $order["order_no"] . " has been delivered successfully";

$deliveredNotifStmt = mysqli_prepare($conn,
    "INSERT INTO user_notifications (user_id, notification_text) VALUES (?, ?)");

mysqli_stmt_bind_param($deliveredNotifStmt, "is", $order["user_id"], $deliveredNotifText);
mysqli_stmt_execute($deliveredNotifStmt);

/* SEND FCM */

$token=
$order["fcm_token"]
?? "";

if(
!empty($token)
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
"Order Delivered 🎉",

"body"=>
"Your order #".$order["order_no"]." has been delivered successfully"

],

"data"=>[

"type"=>
"delivered",

"order_id"=>
(string)$order_id,

"screen"=>
"orders"

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

curl_close(
$ch);

}

echo json_encode([

"status"=>true,

"message"=>
"Order Delivered"

]);

}else{

echo json_encode([

"status"=>false,

"message"=>
"Invalid OTP"

]);

}

exit();

}
if(
$action=="profile"
){

$id=

intval(

$_POST["delivery_id"]

);

$q=

mysqli_query(

$conn,

"

SELECT *

FROM delivery_boys

WHERE id='$id'

LIMIT 1

"

);

if(

mysqli_num_rows(
$q
)

){

echo json_encode([

"status"=>true,

"profile"=>

mysqli_fetch_assoc(
$q
),

]);

}else{

echo json_encode([

"status"=>false,

]);

}

exit();

}
/* PAYOUTS */

if(
$action=="payouts"
){

$id=

intval(

$_POST[
"delivery_id"
]

);

$list=[];

$q=

mysqli_query(

$conn,

"

SELECT *

FROM
delivery_boy_payouts

WHERE

delivery_boy_id='$id'

ORDER BY
id DESC

"

);

while(

$r=

mysqli_fetch_assoc(
$q
)

){

$list[]=
$r;

}

echo json_encode([

"status"=>true,

"payouts"=>$list,

]);

exit();

}
/* ALL ORDERS */

if(
$action=="orders"
){

$id=

intval(
$_POST["delivery_id"]
);

$list=[];

$q=

mysqli_query(

$conn,

"

SELECT *

FROM orders

WHERE

deliveryboy_id='$id'

ORDER BY id DESC

"

);

while(

$r=

mysqli_fetch_assoc(
$q
)

){

$list[]=
$r;

}

echo json_encode([

"status"=>true,

"orders"=>$list,

]);

exit();

}


echo json_encode([
    "status" => false,

    "message" => "Invalid Action",
]);

?>
