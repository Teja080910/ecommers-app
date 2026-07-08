<?php
session_start();

require_once 'db.php';

/* LOGIN CHECK */

if(!isset($_SESSION['seller_id'])){

    header("Location:index.php");
    exit;
}

/* CANCELLED ORDERS QUERY */

/* LOGGED SELLER */

$seller_id =
intval(
$_SESSION['seller_id']
);

/* CANCELLED ORDERS OF SELLER */

$sql = "

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

LEFT JOIN users

ON
users.id=
orders.user_id

WHERE

order_items.seller_id=?

AND

LOWER(
orders.order_status
)=

'cancelled'

ORDER BY

orders.id DESC

";

$stmt =
$pdo->prepare(
$sql
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

<meta name="viewport"
content="width=device-width,
initial-scale=1.0">

<title>
Cancelled Orders
</title>

<link rel="stylesheet"
href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">

<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap"
rel="stylesheet">

<style>

*{
    margin:0;
    padding:0;
    box-sizing:border-box;
    font-family:'Inter',sans-serif;
}

body{
    background:#0f172a;
    color:#fff;
}

/* MAIN */

.main-content{
    margin-left:240px;
    padding:28px;
}

/* HEADER */

.page-header{
    margin-bottom:22px;
}

.page-header h1{
    font-size:26px;
    margin-bottom:5px;
}

.page-header p{
    font-size:13px;
    color:#94a3b8;
}

/* TABLE */

.orders-table{
    background:#111827;
    border-radius:24px;
    overflow:hidden;
}

/* HEAD */

.table-head{
    display:grid;

    grid-template-columns:

    120px
    1.5fr
    1.6fr
    130px
    130px
    140px
    150px
    170px;

    gap:14px;

    padding:18px 20px;

    background:#1e293b;

    font-size:13px;
    font-weight:600;
}

/* ROW */

.table-row{
    display:grid;

    grid-template-columns:

    120px
    1.5fr
    1.6fr
    130px
    130px
    140px
    150px
    170px;

    gap:14px;

    align-items:center;

    padding:18px 20px;

    border-bottom:
    1px solid rgba(255,255,255,0.05);

    transition:.3s;
}

.table-row:hover{
    background:#18212f;
}

/* TEXT */

.order-id{
    font-size:15px;
    font-weight:700;
    color:#f87171;
}

.user-name{
    font-size:14px;
    font-weight:600;
    margin-bottom:4px;
}

.small-text{
    font-size:12px;
    color:#94a3b8;
}

.amount{
    font-size:15px;
    font-weight:700;
    color:#4ade80;
}

/* BADGES */

.badge{
    display:inline-block;
    padding:7px 14px;
    border-radius:30px;
    font-size:11px;
    font-weight:600;
    text-transform:uppercase;
}

.cancelled{
    background:#ef444420;
    color:#f87171;
}

.pending{
    background:#eab30820;
    color:#facc15;
}

.paid{
    background:#16a34a20;
    color:#4ade80;
}

.cod{
    background:#7c3aed20;
    color:#c084fc;
}

.online{
    background:#06b6d420;
    color:#22d3ee;
}

/* ITEMS */

.order-items{
    display:flex;
    flex-direction:column;
    gap:6px;
}

.item{
    font-size:12px;
    color:#cbd5e1;
    line-height:1.5;
}

/* EMPTY */

.empty-box{
    background:#111827;
    padding:70px 20px;
    border-radius:24px;
    text-align:center;
}

.empty-box i{
    font-size:60px;
    color:#475569;
    margin-bottom:15px;
}

.empty-box h2{
    margin-bottom:6px;
}

.empty-box p{
    color:#94a3b8;
    font-size:13px;
}

/* RESPONSIVE */

@media(max-width:1400px){

    .orders-table{
        overflow-x:auto;
    }

    .table-head,
    .table-row{
        min-width:1400px;
    }
}

@media(max-width:900px){

    .main-content{
        margin-left:0;
        padding:85px 15px 20px;
    }
}

</style>

</head>
<body>

<?php include 'nav.php'; ?>

<div class="main-content">

    <!-- HEADER -->

    <div class="page-header">

        <h1>
            Cancelled Orders
        </h1>

        <p>
            View all cancelled ecommerce orders
        </p>

    </div>

    <?php if(count($orders) > 0){ ?>

    <div class="orders-table">

        <!-- HEAD -->

        <div class="table-head">

            <div>
                Order No
            </div>

            <div>
                User
            </div>

            <div>
                Products
            </div>

            <div>
                Amount
            </div>

            <div>
                Payment
            </div>

            <div>
                Payment Status
            </div>

            <div>
                Order Status
            </div>

            <div>
                Date
            </div>

        </div>

        <!-- ROWS -->

        <?php foreach($orders as $order){ ?>

        <?php

        /* ITEMS */

        $itemQuery =
        $pdo->prepare(

        "SELECT

        order_items.*,

        products.name
        AS product_name,

        product_varients.varient_name

        FROM order_items

        LEFT JOIN products
        ON products.id =
        order_items.product_id

        LEFT JOIN product_varients
        ON product_varients.id =
        order_items.variant_id

        WHERE order_items.order_id=?
        AND order_items.seller_id=?"

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

                    <?php echo $order['order_no']; ?>

                </div>

            </div>

            <!-- USER -->

            <div>

                <div class="user-name">

                    <?php echo htmlspecialchars($order['user_name']); ?>

                </div>

                <div class="small-text">

                    <?php echo htmlspecialchars($order['user_phone']); ?>

                </div>

            </div>

            <!-- PRODUCTS -->

            <div class="order-items">

                <?php foreach($items as $item){ ?>

                <div class="item">

                    <?php echo htmlspecialchars($item['product_name']); ?>

                    <?php if($item['varient_name'] != ""){ ?>

                    (
                    <?php echo htmlspecialchars($item['varient_name']); ?>
                    )

                    <?php } ?>

                    × <?php echo $item['quantity']; ?>

                </div>

                <?php } ?>

            </div>

            <!-- AMOUNT -->

            <div class="amount">

                ₹<?php echo $order['total_amount']; ?>

            </div>

            <!-- PAYMENT -->

            <div>

                <span class="badge <?php echo strtolower($order['payment_method']); ?>">

                    <?php echo $order['payment_method']; ?>

                </span>

            </div>

            <!-- PAYMENT STATUS -->

            <div>

                <span class="badge <?php echo strtolower($order['payment_status']); ?>">

                    <?php echo $order['payment_status']; ?>

                </span>

            </div>

            <!-- ORDER STATUS -->

            <div>

                <span class="badge cancelled">

                    <?php echo $order['order_status']; ?>

                </span>

            </div>

            <!-- DATE -->

            <div class="small-text">

                <?php echo date(

                "d M Y",

                strtotime(
                $order['created_at']
                )

                ); ?>

                <br>

                <?php echo date(

                "h:i A",

                strtotime(
                $order['created_at']
                )

                ); ?>

            </div>

        </div>

        <?php } ?>

    </div>

    <?php }else{ ?>

    <div class="empty-box">

        <i class="fa-solid fa-ban"></i>

        <h2>
            No Cancelled Orders
        </h2>

        <p>
            No cancelled ecommerce orders found
        </p>

    </div>

    <?php } ?>

</div>

</body>
</html>