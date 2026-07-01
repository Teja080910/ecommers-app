<?php
// Report all PHP errors
error_reporting(E_ALL);

// Display errors on the screen
ini_set('display_errors', '1');

// (Optional) Display startup errors
ini_set('display_startup_errors', '1');
session_start();

require_once 'db.php';

/* Login Check */

if(!isset($_SESSION['seller_id'])){
?>
<!DOCTYPE html>
<html lang="en">
<head>

<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>Redirecting...</title>

<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&display=swap" rel="stylesheet">

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
        <h3>Login Required</h3>
        <p>Please login to continue</p>
    </div>

</div>

<script>

setTimeout(function(){

    window.location.href = "index.php";

},2000);

</script>

</body>
</html>
<?php
exit;
}

/* Logged Franchise */

$seller_id = $_SESSION['seller_id'];

/* Franchise Details */

$fstmt = $pdo->prepare("
    SELECT * FROM seller 
    WHERE id=?
");

$fstmt->execute([$seller_id]);

$franchise = $fstmt->fetch();

/* Total Products */

$stmt = $pdo->prepare("
    SELECT COUNT(*) 
    FROM products 
    WHERE seller_id=?
");

$stmt->execute([$seller_id]);

$totalProducts = $stmt->fetchColumn();

/* Online Veg Orders */



$stmt = $pdo->prepare("
    SELECT COUNT(*) 
    FROM delivery_boys 
    WHERE seller_id=?
");

$stmt->execute([$seller_id]);

$totalDeliveryBoys = $stmt->fetchColumn();

/* Total Sales */
/* Total Sales */

$stmt = $pdo->prepare("

SELECT
IFNULL(
SUM(order_items.total),
0
)

FROM order_items

INNER JOIN products
ON products.id=
order_items.product_id

WHERE
products.seller_id=?

");

$stmt->execute([
$seller_id
]);

$totalSales =
$stmt->fetchColumn();
/* Total Purchase */


/* Franchise Payout */

$stmt = $pdo->prepare("
    SELECT IFNULL(SUM(amount),0) 
    FROM seller_payouts 
    WHERE seller_id=?
");

$stmt->execute([$seller_id]);

$totalFranchisePayout = $stmt->fetchColumn();

/* Delivery Wallet */

$stmt = $pdo->prepare("
    SELECT IFNULL(SUM(wallet_balance),0) 
    FROM delivery_boys 
    WHERE seller_id=?
");

$stmt->execute([$seller_id]);

$totalWallet = $stmt->fetchColumn();
/* Total Orders */

$stmt = $pdo->prepare("

SELECT
COUNT(
DISTINCT
order_items.order_id
)

FROM order_items

INNER JOIN products
ON products.id=
order_items.product_id

WHERE
products.seller_id=?

");

$stmt->execute([
$seller_id
]);

$orders =
$stmt->fetchColumn();
/* Service Pincodes */

$totalPincodes = 0;

if(!empty($franchise['service_pincodes'])){

    $pins = explode(",",$franchise['service_pincodes']);

    $pins = array_filter($pins);

    $totalPincodes = count($pins);
}

?>

<!DOCTYPE html>
<html lang="en">
<head>

<meta charset="UTF-8">

<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>Franchise Dashboard</title>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">

<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">

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

/* Header */

.dashboard-header{
    margin-bottom:26px;
}

.dashboard-header h1{
    font-size:28px;
    margin-bottom:5px;
}

.dashboard-header p{
    font-size:13px;
    color:#94a3b8;
}

/* Cards */

.cards{
    display:grid;
    grid-template-columns:repeat(auto-fit,minmax(240px,1fr));
    gap:18px;
}

.card{
    position:relative;
    overflow:hidden;
    border-radius:24px;
    padding:24px;
    min-height:145px;
    transition:.35s;
    box-shadow:0 15px 35px rgba(0,0,0,0.25);
}

.card:hover{
    transform:translateY(-6px);
}

.card::before{
    content:'';
    position:absolute;
    width:130px;
    height:130px;
    border-radius:50%;
    background:rgba(255,255,255,0.08);
    top:-40px;
    right:-40px;
}

.card-top{
    display:flex;
    align-items:center;
    justify-content:space-between;
    margin-bottom:18px;
}

.card-top span{
    font-size:13px;
    font-weight:500;
}

.card-top i{
    font-size:18px;
}

.card h2{
    font-size:30px;
    margin-bottom:10px;
    font-weight:700;
}

.card-bottom{
    font-size:12px;
    color:rgba(255,255,255,0.85);
}

/* Gradients */

.gradient1{
    background:linear-gradient(135deg,#2563eb,#1d4ed8);
}

.gradient2{
    background:linear-gradient(135deg,#7c3aed,#5b21b6);
}

.gradient3{
    background:linear-gradient(135deg,#059669,#047857);
}

.gradient4{
    background:linear-gradient(135deg,#ea580c,#c2410c);
}

.gradient5{
    background:linear-gradient(135deg,#db2777,#9d174d);
}

.gradient6{
    background:linear-gradient(135deg,#16a34a,#166534);
}

.gradient7{
    background:linear-gradient(135deg,#0891b2,#155e75);
}

.gradient8{
    background:linear-gradient(135deg,#dc2626,#991b1b);
}

.gradient9{
    background:linear-gradient(135deg,#9333ea,#6b21a8);
}

.gradient10{
    background:linear-gradient(135deg,#f59e0b,#b45309);
}

.gradient11{
    background:linear-gradient(135deg,#14b8a6,#0f766e);
}

/* Responsive */

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

    <!-- Header -->

    <div class="dashboard-header">

        <h1>

            Welcome, 
            <?php echo htmlspecialchars($franchise['name']); ?>

        </h1>

        <p>
            Monitor your franchise analytics and business performance
        </p>

    </div>

    <!-- Cards -->

    <div class="cards">

        <!-- Products -->

        <div class="card gradient1">

            <div class="card-top">

                <span>Total Products</span>

                <i class="fa-solid fa-box-open"></i>

            </div>

            <h2>

                <?php echo $totalProducts; ?>

            </h2>

            <div class="card-bottom">

                Products Listed

            </div>

        </div>

        <!-- Service Pincodes -->

        <div class="card gradient2">

            <div class="card-top">

                <span>Service Pincodes</span>

                <i class="fa-solid fa-location-dot"></i>

            </div>

            <h2>

                <?php echo $totalPincodes; ?>

            </h2>

            <div class="card-bottom">

                Delivery Service Areas

            </div>

        </div>

        <!-- Online Veg Orders -->

        

        <!-- Offline Veg Orders -->

       
        <!-- Online Food Orders -->

        <div class="card gradient5">

            <div class="card-top">

                <span>All  Orders</span>

                <i class="fa-solid fa-burger"></i>

            </div>

            <h2>

                <?php echo $orders; ?>

            </h2>

            <div class="card-bottom">

               All Orders

            </div>

        </div>

        <!-- Offline Food Orders -->

       

        <!-- Delivery Boys -->

        <div class="card gradient7">

            <div class="card-top">

                <span>Delivery Boys</span>

                <i class="fa-solid fa-motorcycle"></i>

            </div>

            <h2>

                <?php echo $totalDeliveryBoys; ?>

            </h2>

            <div class="card-bottom">

                Delivery Partners

            </div>

        </div>

        <!-- Total Sales -->

        <div class="card gradient8">

            <div class="card-top">

                <span>Total Sales</span>

                <i class="fa-solid fa-indian-rupee-sign"></i>

            </div>

            <h2>

                ₹<?php echo number_format($totalSales); ?>

            </h2>

            <div class="card-bottom">

                Overall Revenue

            </div>

        </div>

        <!-- Total Purchase -->

        
        <!-- Wallet -->

        <div class="card gradient10">

            <div class="card-top">

                <span>Delivery Wallet</span>

                <i class="fa-solid fa-wallet"></i>

            </div>

            <h2>

                ₹<?php echo number_format($totalWallet); ?>

            </h2>

            <div class="card-bottom">

                Delivery Boy Wallet Balance

            </div>

        </div>

        <!-- Franchise Payout -->

        <div class="card gradient11">

            <div class="card-top">

                <span>Franchise Payouts</span>

                <i class="fa-solid fa-building-circle-check"></i>

            </div>

            <h2>

                ₹<?php echo number_format($totalFranchisePayout); ?>

            </h2>

            <div class="card-bottom">

                Total Franchise Payments

            </div>

        </div>

    </div>

</div>

</body>
</html>