<?php
/* Public product landing page — no auth. Meant to be opened from a shared
   link (see view_product.dart share button). Shows basic product info and
   an "Open in App" button that triggers the app's custom URL scheme. */

require_once 'db.php';

$product_id = intval($_GET['id'] ?? 0);

$product = null;

if ($product_id > 0) {

    $stmt = mysqli_prepare($conn, "SELECT * FROM products WHERE id=? LIMIT 1");
    mysqli_stmt_bind_param($stmt, "i", $product_id);
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);
    $product = mysqli_fetch_assoc($result);
}

$appLink = "zipzapcart://product/" . $product_id;
?>
<!DOCTYPE html>
<html lang="en">
<head>

<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title><?php echo $product ? htmlspecialchars($product['name']) . " - Zipzapcart" : "Zipzapcart"; ?></title>

<style>

*{
    margin:0;
    padding:0;
    box-sizing:border-box;
    font-family:Arial, sans-serif;
}

body{
    background:#f5f5f5;
    min-height:100vh;
    display:flex;
    align-items:center;
    justify-content:center;
    padding:20px;
}

.card{
    background:#fff;
    border-radius:24px;
    max-width:420px;
    width:100%;
    padding:28px;
    box-shadow:0 4px 24px rgba(0,0,0,0.08);
    text-align:center;
}

.logo{
    font-size:20px;
    font-weight:800;
    color:#EF4138;
    margin-bottom:20px;
}

.product-image{
    width:100%;
    max-width:280px;
    height:280px;
    object-fit:contain;
    background:#f7f7f7;
    border-radius:18px;
    margin:0 auto 20px;
    display:block;
}

.product-name{
    font-size:18px;
    font-weight:700;
    color:#111;
    margin-bottom:10px;
}

.price-row{
    display:flex;
    align-items:center;
    justify-content:center;
    gap:10px;
    margin-bottom:24px;
}

.sale-price{
    font-size:22px;
    font-weight:800;
    color:#EF4138;
}

.orig-price{
    font-size:15px;
    color:#94a3b8;
    text-decoration:line-through;
}

.open-btn{
    display:block;
    width:100%;
    padding:16px;
    border-radius:16px;
    background:#EF4138;
    color:#fff;
    font-size:15px;
    font-weight:700;
    text-decoration:none;
}

.empty-state{
    color:#64748b;
    font-size:14px;
    padding:20px 0;
}

</style>

</head>
<body>

<div class="card">

<div class="logo">Zipzapcart</div>

<?php if ($product) { ?>

    <img class="product-image" src="<?php echo htmlspecialchars($product['image']); ?>" alt="<?php echo htmlspecialchars($product['name']); ?>">

    <div class="product-name"><?php echo htmlspecialchars($product['name']); ?></div>

    <div class="price-row">
        <span class="sale-price">&#8377;<?php echo number_format($product['saleprice'], 0); ?></span>
        <?php if ($product['rate'] > $product['saleprice']) { ?>
        <span class="orig-price">&#8377;<?php echo number_format($product['rate'], 0); ?></span>
        <?php } ?>
    </div>

    <a class="open-btn" href="<?php echo htmlspecialchars($appLink); ?>">Open in App</a>

<?php } else { ?>

    <div class="empty-state">Product not found.</div>

<?php } ?>

</div>

</body>
</html>
