<?php
session_start();

require_once 'db.php';

/* LOGIN CHECK */

if(!isset($_SESSION['admin_id'])){

    header("Location:index.php");
    exit;
}

/* ORDERS QUERY */

$sql = "

SELECT

orders.*,

users.name
AS user_name,

users.phone
AS user_phone

FROM orders

LEFT JOIN users
ON users.id =
orders.user_id

ORDER BY orders.id DESC

";

$stmt =
$pdo->prepare($sql);

$stmt->execute();

$orders =
$stmt->fetchAll();

/* helper: never pass null into a string function (PHP 8.1+ deprecation) */
function s($value){
    return (string)($value ?? '');
}

?>

<!DOCTYPE html>
<html lang="en">
<head>

<meta charset="UTF-8">

<meta name="viewport"
content="width=device-width,
initial-scale=1.0">

<title>
Order History
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

/* ORDER LIST */

.order-list{
    display:flex;
    flex-direction:column;
    gap:16px;
}

/* CARD */

.order-card{
    background:#111827;
    border-radius:22px;
    border:1px solid rgba(255,255,255,0.06);
    overflow:hidden;
}

.order-card-header{
    display:flex;
    align-items:flex-start;
    justify-content:space-between;
    gap:14px;
    padding:18px 22px;
    background:rgba(255,255,255,0.02);
    border-bottom:1px solid rgba(255,255,255,0.06);
    flex-wrap:wrap;
}

.order-id{
    font-size:15px;
    font-weight:700;
    color:#22d3ee;
}

.order-date{
    font-size:12px;
    color:#94a3b8;
    margin-top:3px;
}

/* BODY */

.order-card-body{
    display:grid;
    grid-template-columns:1fr 1fr;
    gap:22px;
    padding:20px 22px;
}

@media(max-width:800px){
    .order-card-body{
        grid-template-columns:1fr;
    }
}

.section-label{
    font-size:11px;
    font-weight:700;
    text-transform:uppercase;
    letter-spacing:.04em;
    color:#64748b;
    margin-bottom:10px;
}

/* CUSTOMER + PAYMENT */

.info-row{
    display:flex;
    align-items:center;
    justify-content:space-between;
    gap:12px;
    flex-wrap:wrap;
}

.user-name{
    font-size:15px;
    font-weight:700;
}

.small-text{
    font-size:12px;
    color:#94a3b8;
}

.amount{
    font-size:20px;
    font-weight:700;
    color:#4ade80;
    white-space:nowrap;
}

.badge-row{
    display:flex;
    gap:8px;
    margin-top:12px;
    flex-wrap:wrap;
}

/* BADGES */

.badge{
    display:inline-block;
    padding:7px 14px;
    border-radius:30px;
    font-size:11px;
    font-weight:600;
    text-transform:uppercase;
    white-space:nowrap;
}

.placed{ background:#2563eb20; color:#60a5fa; }
.pending{ background:#eab30820; color:#facc15; }
.paid{ background:#16a34a20; color:#4ade80; }
.cod{ background:#7c3aed20; color:#c084fc; }
.online{ background:#06b6d420; color:#22d3ee; }
.shipped{ background:#7c3aed20; color:#c084fc; }
.on-the-way{ background:#eab30820; color:#facc15; }
.delivered{ background:#16a34a20; color:#4ade80; }
.cancelled{ background:#dc262620; color:#f87171; }

/* PRODUCTS */

.order-items{
    display:flex;
    flex-direction:column;
    gap:10px;
}

.item{
    display:flex;
    align-items:baseline;
    justify-content:space-between;
    gap:12px;
    font-size:13px;
    line-height:1.5;
    padding-bottom:10px;
    border-bottom:1px solid rgba(255,255,255,0.04);
}

.item:last-child{
    border-bottom:none;
    padding-bottom:0;
}

.item-name{
    color:#e2e8f0;
    word-break:break-word;
}

.item-name .variant{
    color:#94a3b8;
    font-size:12px;
}

.item-qty{
    color:#64748b;
    font-size:12px;
    white-space:nowrap;
    flex-shrink:0;
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
            Order History
        </h1>

        <p>
            View all ecommerce orders
        </p>

    </div>

    <?php if(count($orders) > 0){ ?>

    <div class="order-list">

        <?php foreach($orders as $order){ ?>

        <?php

        /* ITEMS */

        $itemQuery =
        $pdo->prepare(

        "SELECT

        order_items.*,

        products.name
        AS product_name,

        products.image
        AS product_image,

        product_varients.varient_name

        FROM order_items

        LEFT JOIN products
        ON products.id =
        order_items.product_id

        LEFT JOIN product_varients
        ON product_varients.id =
        order_items.variant_id

        WHERE order_items.order_id=?"

        );

        $itemQuery->execute([
        $order['id']
        ]);

        $items =
        $itemQuery->fetchAll();

        ?>

        <div class="order-card">

            <!-- CARD HEADER: order no / date / status -->

            <div class="order-card-header">

                <div>
                    <div class="order-id">
                        <?php echo htmlspecialchars(s($order['order_no'])); ?>
                    </div>
                    <div class="order-date">
                        <?php echo date("d M Y, h:i A", strtotime($order['created_at'])); ?>
                    </div>
                </div>

                <span class="badge <?php echo strtolower(str_replace(' ', '-', s($order['order_status']))); ?>">
                    <?php echo htmlspecialchars(s($order['order_status'])); ?>
                </span>

            </div>

            <div class="order-card-body">

                <!-- CUSTOMER + PAYMENT -->

                <div>

                    <div class="section-label">Customer</div>

                    <div class="info-row">
                        <div>
                            <div class="user-name">
                                <?php echo htmlspecialchars(s($order['user_name'])); ?>
                            </div>
                            <div class="small-text">
                                <?php echo htmlspecialchars(s($order['user_phone'])); ?>
                            </div>
                        </div>

                        <div class="amount">
                            ₹<?php echo number_format((float)$order['total_amount'], 2); ?>
                        </div>
                    </div>

                    <div class="badge-row">
                        <span class="badge <?php echo strtolower(s($order['payment_method'])); ?>">
                            <?php echo htmlspecialchars(s($order['payment_method'])); ?>
                        </span>
                        <span class="badge <?php echo strtolower(s($order['payment_status'])); ?>">
                            <?php echo htmlspecialchars(s($order['payment_status'])); ?>
                        </span>
                    </div>

                </div>

                <!-- PRODUCTS -->

                <div>

                    <div class="section-label">Products</div>

                    <div class="order-items">

                        <?php foreach($items as $item){ ?>

                        <div class="item">

                            <div class="item-name">
                                <?php echo htmlspecialchars(s($item['product_name'])); ?>
                                <?php if(!empty($item['varient_name'])){ ?>
                                    <span class="variant">(<?php echo htmlspecialchars(s($item['varient_name'])); ?>)</span>
                                <?php } ?>
                            </div>

                            <div class="item-qty">
                                × <?php echo intval($item['quantity']); ?>
                            </div>

                        </div>

                        <?php } ?>

                    </div>

                </div>

            </div>

        </div>

        <?php } ?>

    </div>

    <?php }else{ ?>

    <div class="empty-box">

        <i class="fa-solid fa-bag-shopping"></i>

        <h2>
            No Orders Found
        </h2>

        <p>
            No ecommerce orders available
        </p>

    </div>

    <?php } ?>

</div>

</body>
</html>
