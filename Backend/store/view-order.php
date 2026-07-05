<?php

session_start();

require_once 'db.php';

if(
!isset($_SESSION['seller_id'])
){
header("Location:index.php");
exit;
}

$seller_id =
intval($_SESSION['seller_id']);

if(
!isset($_GET['id'])
){
header("Location:order-history.php");
exit;
}

$order_id =
intval($_GET['id']);

/* ORDER */

$stmt =
$pdo->prepare(

"

SELECT DISTINCT

orders.*,

users.name
AS user_name,

users.phone
AS user_phone

FROM orders

INNER JOIN order_items

ON
order_items.order_id=
orders.id

INNER JOIN products

ON
products.id=
order_items.product_id

LEFT JOIN users

ON
users.id=
orders.user_id

WHERE

orders.id=?

AND

products.seller_id=?

"

);

$stmt->execute([

$order_id,

$seller_id

]);

$order =
$stmt->fetch();

if(!$order){

header(
"Location:order-history.php"
);

exit;

}

/* ITEMS */

$itemStmt =
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

products.seller_id=?

"

);

$itemStmt->execute([

$order_id,

$seller_id

]);

$items =
$itemStmt->fetchAll();

?>

<!DOCTYPE html>

<html>

<head>

<title>

View Order

</title>

<style>

body{

margin:0;

background:#0f172a;

font-family:Arial;

color:#fff;

}

.wrap{

max-width:900px;

margin:40px auto;

padding:20px;

}

.card{

background:#111827;

padding:25px;

border-radius:20px;

}

.row{

margin-bottom:18px;

}

.title{

font-size:28px;

margin-bottom:20px;

}

.item{

padding:14px;

background:#1e293b;

margin-bottom:10px;

border-radius:12px;

}

.badge{

display:inline-block;

padding:8px 14px;

border-radius:30px;

background:#2563eb;

}

a{

color:#22d3ee;

}

</style>

</head>

<body>

<div class="wrap">

<div class="card">

<div class="title">

Order

<?=
$order['order_no']
?>

</div>

<div class="row">

Customer:

<b>

<?=

htmlspecialchars(
$order['user_name']
)

?>

</b>

</div>

<div class="row">

Phone:

<?=

$order['user_phone']

?>

</div>

<div class="row">

Payment:

<span class="badge">

<?=

$order['payment_method']

?>

</span>

</div>

<div class="row">

Status:

<span class="badge">

<?=

$order['order_status']

?>

</span>

</div>

<div class="row">

Amount:

₹

<?=

number_format(
$order['total_amount'],
2
)

?>

</div>

<h3>

Products

</h3>

<?php
foreach(
$items
as
$item
){
?>

<div class="item">

<?=

$item['product_name']

?>

<?php
if(
!empty(
$item['varient_name']
)
){
?>

<br>

Variant:

<?=

$item['varient_name']

?>

<?php } ?>

<br>

Qty:

<?=

$item['quantity']

?>

</div>

<?php } ?>

<br>

<a
href="order-history.php">

← Back

</a>

</div>

</div>

</body>

</html>

