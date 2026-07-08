<?php

session_start();

require_once 'db.php';
require_once __DIR__ . '/../app/fcm_helper.php';

/* LOGIN */

if(
!isset(
$_SESSION['seller_id']
)
){

header(
"Location:index.php"
);

exit;

}

$seller_id =
intval(
$_SESSION['seller_id']
);

/* UPDATE ORDER */

if(
isset(
$_POST['update_order']
)
){

$order_id =
intval(
$_POST['order_id']
);

$order_status =
trim(
$_POST['order_status']
);

$deliveryboy_id =
0;

if(

$order_status
==
"on the way"

&&

isset(
$_POST['deliveryboy_id']
)

){

$deliveryboy_id =
intval(
$_POST['deliveryboy_id']
);

}

/* CHECK ORDER BELONGS SELLER */

$check =
$pdo->prepare(

"

SELECT
COUNT(*)

FROM
order_items

WHERE

order_items.order_id=?

AND

order_items.seller_id=?

"

);

$check->execute([

$order_id,

$seller_id

]);

if(
$check->fetchColumn()
>0
){

$update =
$pdo->prepare(

"

UPDATE orders

SET

order_status=?,

deliveryboy_id=?

WHERE id=?

"

);

$update->execute([

$order_status,

$deliveryboy_id,

$order_id

]);

// 🔥 SEND ORDER STATUS FCM

$userStmt=

$pdo->prepare(

"

SELECT

users.fcm_token,

orders.order_no

FROM orders

LEFT JOIN users

ON users.id=
orders.user_id

WHERE orders.id=?

LIMIT 1

"

);

$userStmt->execute([

$order_id

]);

$user=

$userStmt
->fetch();

if(

!empty(
$user["fcm_token"]
)

){

$access= getFcmAccessToken();

$project=

"zipzapcart-app";

$title=

"Order Update 📦";

$body=

"Order #"

.$user["order_no"]

." is "

.ucwords(
$order_status
);

$payload=[

"message"=>[

"token"=>

$user[
"fcm_token"
],

"notification"=>[

"title"=>
$title,

"body"=>
$body

],

"data"=>[

"screen"=>"orders",

"order_id"=>

(string)$order_id,

"status"=>

$order_status

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
$ch
);

}


}

}

/* DELIVERY BOYS */

$deliveryStmt =
$pdo->prepare(

"

SELECT *

FROM delivery_boys

WHERE seller_id=?

ORDER BY name ASC

"

);

$deliveryStmt->execute([

$seller_id

]);

$deliveryBoys =
$deliveryStmt->fetchAll();

/* SELLER ORDERS */

$stmt =
$pdo->prepare(

"

SELECT DISTINCT

orders.*,

users.name
AS user_name,

users.phone
AS user_phone,

delivery_boys.name
AS delivery_name

FROM orders

INNER JOIN order_items

ON
order_items.order_id=
orders.id

LEFT JOIN users

ON
users.id=
orders.user_id

LEFT JOIN delivery_boys

ON
delivery_boys.id=
orders.deliveryboy_id

WHERE

order_items.seller_id=?

ORDER BY
orders.id DESC

"

);

$stmt->execute([

$seller_id

]);

$orders =
$stmt->fetchAll();

?>

<!DOCTYPE html>

<html lang="en">

<head>

<meta charset="UTF-8">

<meta
name="viewport"
content="
width=device-width,
initial-scale=1.0
">

<title>
Order History
</title>

<link
rel="stylesheet"

href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">

<link

href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap"

rel="stylesheet">

<style>

*{

margin:0;

padding:0;

box-sizing:border-box;

font-family:
'Inter',
sans-serif;

}

body{

background:#0f172a;

color:#fff;

}

/* MAIN */

.main-content{

margin-left:240px;

padding:28px;

min-height:100vh;

}

/* HEADER */

.page-header{

margin-bottom:24px;

}

.page-header h1{

font-size:30px;

font-weight:700;

margin-bottom:6px;

}

.page-header p{

font-size:13px;

color:#94a3b8;

}

/* TABLE */

.orders-table{

background:#111827;

border-radius:24px;

overflow:auto;

}

/* HEAD */

.table-head{

display:grid;

grid-template-columns:

140px
180px
360px
140px
130px
150px
250px
220px;

gap:16px;

padding:20px;

background:#1e293b;

font-size:13px;

font-weight:700;

min-width:1700px;

}

/* ROW */

.table-row{

display:grid;

grid-template-columns:

140px
180px
360px
140px
130px
150px
250px
220px;

gap:16px;

padding:20px;

min-width:1700px;

align-items:start;

border-bottom:

1px solid

rgba(
255,
255,
255,
0.05
);

}

.table-row:hover{

background:

rgba(
255,
255,
255,
0.02
);

}

/* TEXT */

.order-id{

color:#22d3ee;

font-size:12px;

font-weight:700;

}

.user-name{

font-size:15px;

font-weight:700;

margin-bottom:4px;

}

.small-text{

font-size:12px;

color:#94a3b8;

}

.amount{

color:#4ade80;

font-size:18px;

font-weight:700;

}

/* ITEMS */

.order-items{

display:flex;

flex-direction:column;

gap:10px;

}

.item{

font-size:13px;

color:#cbd5e1;

line-height:1.6;

}

/* BADGE */

.badge{

display:inline-flex;

align-items:center;

justify-content:center;

padding:8px 14px;

border-radius:30px;

font-size:11px;

font-weight:700;

text-transform:uppercase;

}

.cod{

background:#7c3aed22;

color:#c084fc;

}

.online{

background:#0891b222;

color:#22d3ee;

}

.pending{

background:#f59e0b22;

color:#facc15;

}

.paid{

background:#16a34a22;

color:#4ade80;

}

/* FORM */

.table-row select{

width:100%;

height:46px;

border:none;

border-radius:12px;

background:#1e293b;

color:#fff;

padding:0 12px;

margin-bottom:10px;

}

.table-row button{

width:100%;

height:46px;

border:none;

border-radius:12px;

background:

linear-gradient(
135deg,
#2563eb,
#7c3aed
);

color:#fff;

font-weight:700;

cursor:pointer;

}

.actions{

display:flex;

flex-direction:column;

gap:10px;

}

.actions a{

text-decoration:none;

padding:12px;

text-align:center;

border-radius:12px;

font-size:13px;

font-weight:700;

}

.view-btn{

background:#0891b222;

color:#22d3ee;

}

.invoice-btn{

background:#16a34a22;

color:#4ade80;

}

/* EMPTY */

.empty-box{

background:#111827;

padding:80px;

border-radius:24px;

text-align:center;

}

.empty-box i{

font-size:60px;

color:#475569;

margin-bottom:18px;

}

.empty-box h2{

margin-bottom:8px;

}

.empty-box p{

color:#94a3b8;

}

/* MOBILE */

@media(
max-width:900px
){

.main-content{

margin-left:0;

padding:

85px
15px
20px;

}

}

</style>

</head>

<body>

<?php include 'nav.php'; ?>

<div class="main-content">

<div class="page-header">

<h1>

Order History

</h1>

<p>

Manage orders,
assign delivery,
print invoices

</p>

</div>

<?php
if(
count(
$orders
)>0
){
?>

<div
class="orders-table">

<div
class="table-head">

<div>Order</div>

<div>Customer</div>

<div>Products</div>

<div>Amount</div>

<div>Payment</div>

<div>Pay Status</div>

<div>Update</div>

<div>Actions</div>

</div>

<?php foreach($orders as $order){ ?>

<?php

$itemQuery =
$pdo->prepare(

"

SELECT

order_items.*,

products.name
AS product_name,

product_varients.varient_name

FROM order_items

INNER JOIN products

ON
products.id=
order_items.product_id

LEFT JOIN product_varients

ON
product_varients.id=
order_items.variant_id

WHERE

order_items.order_id=?

AND

order_items.seller_id=?

"

);

$itemQuery->execute([

$order['id'],

$seller_id

]);

$items =
$itemQuery->fetchAll();

?>

<div class="table-row">

<!-- ORDER -->

<div>

<div class="order-id">

<?=
$order['order_no']
?>

</div>

<div
class="small-text">

#<?=
$order['id']
?>

</div>

</div>

<!-- CUSTOMER -->

<div>

<div
class="user-name">

<?=

htmlspecialchars(
$order['user_name']
)

?>

</div>

<div
class="small-text">

<?=

$order['user_phone']

?>

</div>

<br>

<div
class="small-text">

<?=

date(
"d M Y",

strtotime(
$order['created_at']
)

)

?>

</div>

</div>

<!-- PRODUCTS -->

<div
class="order-items">

<?php
foreach(
$items
as
$item
){
?>

<div
class="item">

<?=

htmlspecialchars(
$item['product_name']
)

?>

<?php
if(
!empty(
$item['varient_name']
)
){
?>

<br>

<small>

Variant:

<?=

htmlspecialchars(
$item['varient_name']
)

?>

</small>

<?php } ?>

<br>

Qty:

<?=

$item['quantity']

?>

</div>

<?php } ?>

</div>

<!-- AMOUNT -->

<div
class="amount">

₹<?=

number_format(
$order['total_amount'],
2
)

?>

</div>

<!-- PAYMENT -->

<div>

<span
class="badge
<?=

strtolower(
$order['payment_method']
)

?>">

<?=

$order['payment_method']

?>

</span>

</div>

<!-- PAYMENT STATUS -->

<div>

<span
class="badge
<?=

strtolower(
$order['payment_status']
)

?>">

<?=

$order['payment_status']

?>

</span>

</div>

<!-- UPDATE -->

<div>

<form
method="POST">

<input
type="hidden"
name="order_id"

value="<?=

$order['id']

?>">

<select
name="order_status"

id="status<?= $order['id'] ?>">

<option

value="placed"

<?=

$order['order_status']
=="placed"

?

"selected"

:

""

?>

>

Placed

</option>

<option

value="shipped"

<?=

$order['order_status']
=="shipped"

?

"selected"

:

""

?>

>

Shipped

</option>

<option

value="on the way"

<?=

$order['order_status']
=="on the way"

?

"selected"

:

""

?>

>

On The Way

</option>

<option

value="delivered"

<?=

$order['order_status']
=="delivered"

?

"selected"

:

""

?>

>

Delivered

</option>

</select>

<select
name="deliveryboy_id">

<option value="0">

Select Delivery Partner

</option>

<?php
foreach(
$deliveryBoys
as
$boy
){
?>

<option

value="<?=

$boy['id']

?>">

<?=

$boy['name']

?>

</option>

<?php } ?>

</select>

<button

type="submit"

name="update_order">

Update

</button>

</form>

</div>

<!-- ACTION -->

<div
class="actions">

<a

class="view-btn"

href="view-order.php?id=<?=
$order['id']
?>">

View Order

</a>

<a

class="invoice-btn"

target="_blank"

href="invoice.php?id=<?=
$order['id']
?>">

Print Invoice

</a>

<?php
if(
!empty(
$order['delivery_name']
)
){
?>

<div
class="small-text">

Assigned:

<br>

<?=

$order['delivery_name']

?>

</div>

<?php } ?>

</div>

</div>

<?php } ?>

</div>

<?php }else{ ?>

<div
class="empty-box">

<i
class="fa-solid
fa-bag-shopping">

</i>

<h2>

No Orders

</h2>

<p>

No seller orders available

</p>

</div>

<?php } ?>

</div>

</body>

</html>

