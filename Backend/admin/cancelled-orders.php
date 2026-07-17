<?php
session_start();

require_once 'db.php';
require_once __DIR__ . '/../app/fcm_helper.php';

/* LOGIN CHECK */

if(!isset($_SESSION['admin_id'])){

    header("Location:index.php");
    exit;
}

/* SEND REFUND NOTIFICATION
   No wallet/refund ledger in this app -- refunds are processed manually
   outside the system (bank/UPI transfer), and the customer is just
   notified in-app + via push once it's done. */
$refundSent = false;

if($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['send_refund_notification'])){

    $order_id = intval($_POST['order_id']);
    $amount = trim($_POST['refund_amount']);

    $orderStmt = $pdo->prepare(
        "SELECT orders.user_id, orders.order_no, users.fcm_token
         FROM orders
         LEFT JOIN users ON users.id = orders.user_id
         WHERE orders.id = ?"
    );
    $orderStmt->execute([$order_id]);
    $order = $orderStmt->fetch();

    if($order && !empty($amount)){

        $message = "Your refund of ₹{$amount} for order #{$order['order_no']} has been processed.";

        $notifStmt = $pdo->prepare(
            "INSERT INTO user_notifications (user_id, notification_text) VALUES (?, ?)"
        );
        $notifStmt->execute([$order['user_id'], $message]);

        // 🔥 push, same pattern used elsewhere -- best-effort, doesn't block the notification above
        if(!empty($order['fcm_token'])){

            $access = getFcmAccessToken();
            $project = "zipzapcart-app";

            $payload = [
                "message" => [
                    "token" => $order['fcm_token'],
                    "notification" => [
                        "title" => "Refund Processed",
                        "body" => $message
                    ],
                    "data" => [
                        "type" => "refund",
                        "order_id" => (string)$order_id,
                        "screen" => "orders"
                    ]
                ]
            ];

            $ch = curl_init();
            curl_setopt($ch, CURLOPT_URL, "https://fcm.googleapis.com/v1/projects/" . $project . "/messages:send");
            curl_setopt($ch, CURLOPT_POST, true);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_HTTPHEADER, [
                "Authorization: Bearer " . $access,
                "Content-Type: application/json"
            ]);
            curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));
            curl_exec($ch);
            curl_close($ch);
        }

        $refundSent = true;
    }

    header("Location: cancelled-orders.php?refund_sent=" . ($refundSent ? 1 : 0));
    exit;
}

/* CANCELLED ORDERS QUERY */

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

WHERE LOWER(
orders.order_status
) = 'cancelled'

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

.success-banner{
    background:#16a34a20;
    color:#4ade80;
    padding:14px 20px;
    border-radius:16px;
    margin-bottom:18px;
    font-size:13px;
    font-weight:600;
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
    color:#f87171;
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

.cancelled{ background:#ef444420; color:#f87171; }
.pending{ background:#eab30820; color:#facc15; }
.paid{ background:#16a34a20; color:#4ade80; }
.cod{ background:#7c3aed20; color:#c084fc; }
.online{ background:#06b6d420; color:#22d3ee; }

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

/* REFUND */

.refund-section{
    padding:18px 22px;
    background:rgba(255,255,255,0.02);
    border-top:1px solid rgba(255,255,255,0.06);
    display:flex;
    align-items:center;
    justify-content:flex-end;
    gap:10px;
    flex-wrap:wrap;
}

.refund-label{
    font-size:12px;
    color:#94a3b8;
    margin-right:auto;
}

.refund-form{
    display:flex;
    gap:8px;
}

.refund-input{
    width:120px;
    padding:10px 12px;
    border-radius:10px;
    border:1px solid #334155;
    background:#0f172a;
    color:#fff;
    font-size:13px;
}

.refund-btn{
    padding:10px 18px;
    border-radius:10px;
    border:none;
    background:#4ade8020;
    color:#4ade80;
    font-size:12px;
    font-weight:700;
    cursor:pointer;
    white-space:nowrap;
}

.refund-btn:hover{
    background:#4ade8040;
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
            Cancelled Orders
        </h1>

        <p>
            View all cancelled ecommerce orders
        </p>

    </div>

    <?php if(isset($_GET['refund_sent'])){ ?>

        <div class="success-banner">
            <?php echo $_GET['refund_sent'] == '1'
                ? "Refund notification sent to the customer."
                : "Couldn't send the refund notification. Please try again."; ?>
        </div>

    <?php } ?>

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

                <span class="badge cancelled">
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

            <!-- REFUND NOTIFICATION -->

            <div class="refund-section">

                <span class="refund-label">Already refunded this order manually? Let the customer know:</span>

                <form method="post" class="refund-form">

                    <input type="hidden" name="order_id" value="<?php echo $order['id']; ?>">

                    <input
                        type="number"
                        step="0.01"
                        min="0"
                        name="refund_amount"
                        class="refund-input"
                        placeholder="Amount (₹)"
                        required>

                    <button
                        type="submit"
                        name="send_refund_notification"
                        value="1"
                        class="refund-btn"
                        onclick="return confirm('Send a refund notification to this customer? (Process the actual refund yourself first -- this only notifies them.)');">
                        Notify Customer
                    </button>

                </form>

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
