<?php
session_start();

require_once 'db.php';

/* LOGIN CHECK */

if(!isset($_SESSION['admin_id'])){
?>
<!DOCTYPE html>
<html lang="en">
<head>

<meta charset="UTF-8">

<meta name="viewport"
content="width=device-width,
initial-scale=1.0">

<title>
Redirecting...
</title>

<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&display=swap"
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
    overflow:hidden;
}

.toast{
    position:fixed;
    top:25px;
    right:25px;
    min-width:320px;
    background:#ef4444;
    color:#fff;
    padding:16px 20px;
    border-radius:16px;
    display:flex;
    align-items:center;
    gap:14px;
    box-shadow:0 15px 40px rgba(0,0,0,0.35);
}

.toast-icon{
    width:40px;
    height:40px;
    border-radius:50%;
    background:rgba(255,255,255,0.15);
    display:flex;
    align-items:center;
    justify-content:center;
}

</style>

</head>
<body>

<div class="toast">

    <div class="toast-icon">
        !
    </div>

    <div>

        <h3>
            Login Required
        </h3>

        <p>
            Please login to continue
        </p>

    </div>

</div>

<script>

setTimeout(function(){

    window.location.href =
    "index.php";

},2000);

</script>

</body>
</html>
<?php
exit;
}

/* TOTAL USERS */

$totalUsers =
$pdo->query(

"SELECT COUNT(*)
FROM users"

)->fetchColumn();

/* TOTAL PRODUCTS */

$totalProducts =
$pdo->query(

"SELECT COUNT(*)
FROM products"

)->fetchColumn();

/* TOTAL SELLERS */

$totalSellers =
$pdo->query(

"SELECT COUNT(*)
FROM seller"

)->fetchColumn();

/* TOTAL DELIVERY BOYS */

$totalDeliveryBoys =
$pdo->query(

"SELECT COUNT(*)
FROM delivery_boys"

)->fetchColumn();

/* TOTAL ORDERS */

$totalOrders =
$pdo->query(

"SELECT COUNT(*)
FROM orders"

)->fetchColumn();

/* TOTAL SALES */

$totalSales =
$pdo->query(

"SELECT IFNULL(
SUM(total_amount),
0
)
FROM orders"

)->fetchColumn();

/* TOTAL PENDING ORDERS */

$totalPendingOrders =
$pdo->query(

"SELECT COUNT(*)
FROM orders
WHERE order_status='Placed'"

)->fetchColumn();

/* TOTAL ON THE WAY */

$totalOnTheWay =
$pdo->query(

"SELECT COUNT(*)
FROM orders
WHERE order_status='On the way'"

)->fetchColumn();

/* TOTAL COD ORDERS */

$totalCODOrders =
$pdo->query(

"SELECT COUNT(*)
FROM orders
WHERE payment_method='cod'"

)->fetchColumn();

/* TOTAL ONLINE ORDERS */

$totalOnlineOrders =
$pdo->query(

"SELECT COUNT(*)
FROM orders
WHERE payment_method='online'"

)->fetchColumn();

/* TOTAL PRODUCTS STOCK */

$totalStock =
$pdo->query(

"SELECT IFNULL(
SUM(stock),
0
)
FROM products"

)->fetchColumn();

/* TOTAL VARIANTS */

$totalVariants =
$pdo->query(

"SELECT COUNT(*)
FROM product_varients"

)->fetchColumn();

/* TOTAL PINCODES */

$totalPincodes =
$pdo->query(

"SELECT COUNT(*)
FROM service_pincodes"

)->fetchColumn();

/* TOTAL USER ADDRESSES */

$totalAddresses =
$pdo->query(

"SELECT COUNT(*)
FROM user_addresses"

)->fetchColumn();

/* TOTAL COUPONS */

$totalCoupons =
$pdo->query(

"SELECT COUNT(*)
FROM coupons"

)->fetchColumn();

/* TOTAL WALLET */

$totalWallet =
$pdo->query(

"SELECT IFNULL(
SUM(wallet_balance),
0
)
FROM delivery_boys"

)->fetchColumn();

/* TOTAL SELLER PAYOUT */

$totalSellerPayout =
$pdo->query(

"SELECT IFNULL(
SUM(amount),
0
)
FROM seller_payouts"

)->fetchColumn();

/* TOTAL DELIVERY PAYOUT */

$totalDeliveryPayout =
$pdo->query(

"SELECT IFNULL(
SUM(amount),
0
)
FROM delivery_boy_payouts"

)->fetchColumn();

/* TOTAL PAID USERS */

$totalPaidUsers =
$pdo->query(

"SELECT COUNT(*)
FROM users
WHERE paidstatus='paid'"

)->fetchColumn();

/* TOTAL FREE USERS */

$totalFreeUsers =
$pdo->query(

"SELECT COUNT(*)
FROM users
WHERE paidstatus='free'"

)->fetchColumn();

?>

<!DOCTYPE html>
<html lang="en">
<head>

<meta charset="UTF-8">

<meta name="viewport"
content="width=device-width,
initial-scale=1.0">

<title>
Dashboard
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

.main-content{
    margin-left:240px;
    padding:28px;
    min-height:100vh;
}

/* HEADER */

.dashboard-header{
    margin-bottom:28px;
}

.dashboard-header h1{
    font-size:28px;
    margin-bottom:6px;
}

.dashboard-header p{
    font-size:13px;
    color:#94a3b8;
}

/* GRID */

.cards{
    display:grid;
    grid-template-columns:
    repeat(auto-fit,minmax(240px,1fr));
    gap:18px;
}

/* CARD */

.card{
    position:relative;
    overflow:hidden;
    border-radius:24px;
    padding:24px;
    min-height:145px;
    transition:.35s;
    box-shadow:
    0 15px 35px rgba(0,0,0,0.28);
}

.card:hover{
    transform:translateY(-6px);
}

.card::before{
    content:'';
    position:absolute;
    width:130px;
    height:130px;
    background:rgba(255,255,255,0.08);
    border-radius:50%;
    top:-40px;
    right:-40px;
}

.card-top{
    display:flex;
    justify-content:space-between;
    align-items:center;
    margin-bottom:18px;
}

.card-top span{
    font-size:13px;
    font-weight:500;
}

.card-top i{
    font-size:20px;
}

.card h2{
    font-size:30px;
    font-weight:700;
    margin-bottom:10px;
}

.card-bottom{
    font-size:12px;
    color:rgba(255,255,255,0.85);
}

/* GRADIENTS */

.gradient1{
    background:linear-gradient(
    135deg,
    #2563eb,
    #1d4ed8
    );
}

.gradient2{
    background:linear-gradient(
    135deg,
    #7c3aed,
    #5b21b6
    );
}

.gradient3{
    background:linear-gradient(
    135deg,
    #059669,
    #047857
    );
}

.gradient4{
    background:linear-gradient(
    135deg,
    #ea580c,
    #c2410c
    );
}

.gradient5{
    background:linear-gradient(
    135deg,
    #db2777,
    #9d174d
    );
}

.gradient6{
    background:linear-gradient(
    135deg,
    #16a34a,
    #166534
    );
}

.gradient7{
    background:linear-gradient(
    135deg,
    #0891b2,
    #155e75
    );
}

.gradient8{
    background:linear-gradient(
    135deg,
    #dc2626,
    #991b1b
    );
}

.gradient9{
    background:linear-gradient(
    135deg,
    #9333ea,
    #6b21a8
    );
}

.gradient10{
    background:linear-gradient(
    135deg,
    #f59e0b,
    #b45309
    );
}

.gradient11{
    background:linear-gradient(
    135deg,
    #14b8a6,
    #0f766e
    );
}

.gradient12{
    background:linear-gradient(
    135deg,
    #6366f1,
    #4338ca
    );
}

.gradient13{
    background:linear-gradient(
    135deg,
    #0f766e,
    #115e59
    );
}

.gradient14{
    background:linear-gradient(
    135deg,
    #be123c,
    #881337
    );
}

.gradient15{
    background:linear-gradient(
    135deg,
    #0284c7,
    #075985
    );
}

.gradient16{
    background:linear-gradient(
    135deg,
    #65a30d,
    #3f6212
    );
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

    <div class="dashboard-header">

        <h1>

            Welcome,
            <?php echo htmlspecialchars($_SESSION['admin_username']); ?>

        </h1>

        <p>

            Ecommerce analytics
            and business overview

        </p>

    </div>

    <!-- CARDS -->

    <div class="cards">

        <!-- USERS -->

        <div class="card gradient1">

            <div class="card-top">

                <span>
                    Total Users
                </span>

                <i class="fa-solid fa-users"></i>

            </div>

            <h2>

                <?php echo $totalUsers; ?>

            </h2>

            <div class="card-bottom">

                Registered users

            </div>

        </div>

        <!-- PAID USERS -->

        <div class="card gradient2">

            <div class="card-top">

                <span>
                    Paid Users
                </span>

                <i class="fa-solid fa-crown"></i>

            </div>

            <h2>

                <?php echo $totalPaidUsers; ?>

            </h2>

            <div class="card-bottom">

                Premium users

            </div>

        </div>

        <!-- FREE USERS -->

        <div class="card gradient3">

            <div class="card-top">

                <span>
                    Free Users
                </span>

                <i class="fa-solid fa-user"></i>

            </div>

            <h2>

                <?php echo $totalFreeUsers; ?>

            </h2>

            <div class="card-bottom">

                Free plan users

            </div>

        </div>

        <!-- PRODUCTS -->

        <div class="card gradient4">

            <div class="card-top">

                <span>
                    Total Products
                </span>

                <i class="fa-solid fa-box-open"></i>

            </div>

            <h2>

                <?php echo $totalProducts; ?>

            </h2>

            <div class="card-bottom">

                Products listed

            </div>

        </div>

        <!-- VARIANTS -->

        <div class="card gradient5">

            <div class="card-top">

                <span>
                    Product Variants
                </span>

                <i class="fa-solid fa-layer-group"></i>

            </div>

            <h2>

                <?php echo $totalVariants; ?>

            </h2>

            <div class="card-bottom">

                Total variants

            </div>

        </div>

        <!-- STOCK -->

        <div class="card gradient6">

            <div class="card-top">

                <span>
                    Total Stock
                </span>

                <i class="fa-solid fa-warehouse"></i>

            </div>

            <h2>

                <?php echo $totalStock; ?>

            </h2>

            <div class="card-bottom">

                Available inventory

            </div>

        </div>

        <!-- SELLERS -->

        <div class="card gradient7">

            <div class="card-top">

                <span>
                    Total Sellers
                </span>

                <i class="fa-solid fa-store"></i>

            </div>

            <h2>

                <?php echo $totalSellers; ?>

            </h2>

            <div class="card-bottom">

                Registered sellers

            </div>

        </div>

        <!-- ORDERS -->

        <div class="card gradient8">

            <div class="card-top">

                <span>
                    Total Orders
                </span>

                <i class="fa-solid fa-cart-shopping"></i>

            </div>

            <h2>

                <?php echo $totalOrders; ?>

            </h2>

            <div class="card-bottom">

                Ecommerce orders

            </div>

        </div>

        <!-- PENDING -->

        <div class="card gradient9">

            <div class="card-top">

                <span>
                    Pending Orders
                </span>

                <i class="fa-solid fa-clock"></i>

            </div>

            <h2>

                <?php echo $totalPendingOrders; ?>

            </h2>

            <div class="card-bottom">

                Orders in placed state

            </div>

        </div>

        <!-- ON THE WAY -->

        <div class="card gradient10">

            <div class="card-top">

                <span>
                    On The Way
                </span>

                <i class="fa-solid fa-truck"></i>

            </div>

            <h2>

                <?php echo $totalOnTheWay; ?>

            </h2>

            <div class="card-bottom">

                Shipping orders

            </div>

        </div>

        <!-- COD -->

        <div class="card gradient11">

            <div class="card-top">

                <span>
                    COD Orders
                </span>

                <i class="fa-solid fa-money-bill"></i>

            </div>

            <h2>

                <?php echo $totalCODOrders; ?>

            </h2>

            <div class="card-bottom">

                Cash on delivery

            </div>

        </div>

        <!-- ONLINE -->

        <div class="card gradient12">

            <div class="card-top">

                <span>
                    Online Orders
                </span>

                <i class="fa-solid fa-credit-card"></i>

            </div>

            <h2>

                <?php echo $totalOnlineOrders; ?>

            </h2>

            <div class="card-bottom">

                Paid online orders

            </div>

        </div>

        <!-- SALES -->

        <div class="card gradient13">

            <div class="card-top">

                <span>
                    Total Sales
                </span>

                <i class="fa-solid fa-indian-rupee-sign"></i>

            </div>

            <h2>

                ₹<?php echo number_format($totalSales); ?>

            </h2>

            <div class="card-bottom">

                Revenue generated

            </div>

        </div>

        <!-- DELIVERY BOYS -->

        <div class="card gradient14">

            <div class="card-top">

                <span>
                    Delivery Boys
                </span>

                <i class="fa-solid fa-motorcycle"></i>

            </div>

            <h2>

                <?php echo $totalDeliveryBoys; ?>

            </h2>

            <div class="card-bottom">

                Delivery partners

            </div>

        </div>

        <!-- WALLET -->

        <div class="card gradient15">

            <div class="card-top">

                <span>
                    Delivery Wallet
                </span>

                <i class="fa-solid fa-wallet"></i>

            </div>

            <h2>

                ₹<?php echo number_format($totalWallet); ?>

            </h2>

            <div class="card-bottom">

                Wallet balances

            </div>

        </div>

        <!-- PINCODES -->

        <div class="card gradient16">

            <div class="card-top">

                <span>
                    Service Pincodes
                </span>

                <i class="fa-solid fa-location-dot"></i>

            </div>

            <h2>

                <?php echo $totalPincodes; ?>

            </h2>

            <div class="card-bottom">

                Delivery service areas

            </div>

        </div>

        <!-- ADDRESSES -->

        <div class="card gradient3">

            <div class="card-top">

                <span>
                    Saved Addresses
                </span>

                <i class="fa-solid fa-map-location-dot"></i>

            </div>

            <h2>

                <?php echo $totalAddresses; ?>

            </h2>

            <div class="card-bottom">

                User saved addresses

            </div>

        </div>

        <!-- COUPONS -->

        <div class="card gradient5">

            <div class="card-top">

                <span>
                    Coupons
                </span>

                <i class="fa-solid fa-ticket"></i>

            </div>

            <h2>

                <?php echo $totalCoupons; ?>

            </h2>

            <div class="card-bottom">

                Discount coupons

            </div>

        </div>

        <!-- SELLER PAYOUT -->

        <div class="card gradient6">

            <div class="card-top">

                <span>
                    Seller Payouts
                </span>

                <i class="fa-solid fa-building-circle-check"></i>

            </div>

            <h2>

                ₹<?php echo number_format($totalSellerPayout); ?>

            </h2>

            <div class="card-bottom">

                Seller payments

            </div>

        </div>

        <!-- DELIVERY PAYOUT -->

        <div class="card gradient7">

            <div class="card-top">

                <span>
                    Delivery Payouts
                </span>

                <i class="fa-solid fa-money-bill-transfer"></i>

            </div>

            <h2>

                ₹<?php echo number_format($totalDeliveryPayout); ?>

            </h2>

            <div class="card-bottom">

                Delivery partner payouts

            </div>

        </div>

    </div>

</div>

</body>
</html>