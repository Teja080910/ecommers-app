
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
intval(
$_SESSION['seller_id']
);

if(
!isset($_GET['id'])
){
exit("Invalid Order");
}

$order_id =
intval(
$_GET['id']);

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

exit(
"Invoice Not Found"
);

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

Invoice

</title>

<style>

body{

margin:0;

background:#eef2ff;

font-family:Arial;

}

.invoice{

max-width:900px;

margin:30px auto;

background:#fff;

padding:40px;

border-radius:20px;

}

.top{

display:flex;

justify-content:space-between;

margin-bottom:35px;

}

.logo{

font-size:28px;

font-weight:700;

}

.title{

font-size:34px;

font-weight:700;

}

.box{

margin-bottom:25px;

}

table{

width:100%;

border-collapse:collapse;

}

th,
td{

padding:14px;

border-bottom:

1px solid
#ddd;

text-align:left;

}

.total{

text-align:right;

font-size:26px;

margin-top:25px;

}

.print{

margin-top:30px;

}

button{

height:54px;

padding:0 35px;

border:none;

background:#2563eb;

color:#fff;

border-radius:14px;

cursor:pointer;

}

@media print{

.print{

display:none;

}

body{

background:#fff;

}

.invoice{

box-shadow:none;

}

}

</style>

</head>

<body>

<div class="invoice">

<div class="top">

<div>

<div class="logo">

Invoice

</div>

Order #

<?=

$order['order_no']

?>

</div>

<div>

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

<div class="box">

<b>

Customer

</b>

<br><br>

<?=

htmlspecialchars(
$order['user_name']
)

?>

<br>

<?=

$order['user_phone']

?>

</div>

<table>

<tr>

<th>

Product

</th>

<th>

Variant

</th>

<th>

Qty

</th>

<th>

Price

</th>

</tr>

<?php
foreach(
$items
as
$item
){
?>

<tr>

<td>

<?=

$item['product_name']

?>

</td>

<td>

<?=

$item['varient_name']

?>

</td>

<td>

<?=

$item['quantity']

?>

</td>

<td>

₹<?=

number_format(
$item['total'],
2
)

?>

</td>

</tr>

<?php } ?>

</table>

<div class="total">

Total :

₹

<?=

number_format(
$order['total_amount'],
2
)

?>

</div>

<div
style="
margin-top:10px;
text-align:right;
">

Payment :

<?=

$order['payment_method']

?>

<br>

Status :

<?=

$order['order_status']

?>

</div>

<div class="print">

<button
onclick="window.print()">

Print Invoice

</button>

</div>

</div>

</body>

</html>

