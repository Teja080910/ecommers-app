<?php
session_start();

require_once 'db.php';

/* LOGIN CHECK */

if(!isset($_SESSION['admin_id'])){

    header("Location:index.php");
    exit;
}

/* APPROVE / REJECT */

$actionMessage = null;

if($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['product_id'])){

    $product_id = intval($_POST['product_id']);

    if(isset($_POST['approve'])){

        $stmt = $pdo->prepare("UPDATE products SET status='approved' WHERE id=? AND status='pending'");
        $stmt->execute([$product_id]);

        $actionMessage = 'approved';

    }elseif(isset($_POST['reject'])){

        // remove the mapping row created at submission time (if any),
        // then the variants (if any), then the product itself
        $pdo->prepare("DELETE FROM seller_product_mapping WHERE product_id=?")->execute([$product_id]);
        $pdo->prepare("DELETE FROM product_varients WHERE product_id=?")->execute([$product_id]);
        $pdo->prepare("DELETE FROM products WHERE id=? AND status='pending'")->execute([$product_id]);

        $actionMessage = 'rejected';
    }

    header("Location: product-requests.php?result=" . $actionMessage);
    exit;
}

/* PENDING PRODUCTS */

$sql = "

SELECT

products.*,

seller.name AS seller_name,

spm.price AS mapping_price,
spm.saleprice AS mapping_saleprice,
spm.stock AS mapping_stock,
spm.sku AS mapping_sku

FROM products

LEFT JOIN seller
ON seller.id = products.submitted_by_seller_id

LEFT JOIN seller_product_mapping spm
ON spm.product_id = products.id
AND spm.seller_id = products.submitted_by_seller_id

WHERE products.status = 'pending'

ORDER BY products.id DESC

";

$stmt = $pdo->prepare($sql);
$stmt->execute();
$requests = $stmt->fetchAll();

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
Product Requests
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
}

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

.error-banner{
    background:#ef444420;
    color:#f87171;
    padding:14px 20px;
    border-radius:16px;
    margin-bottom:18px;
    font-size:13px;
    font-weight:600;
}

.request-list{
    display:flex;
    flex-direction:column;
    gap:16px;
}

.request-card{
    background:#111827;
    border-radius:22px;
    border:1px solid rgba(255,255,255,0.06);
    overflow:hidden;
}

.request-card-header{
    display:flex;
    align-items:center;
    gap:16px;
    padding:18px 22px;
    background:rgba(255,255,255,0.02);
    border-bottom:1px solid rgba(255,255,255,0.06);
}

.request-thumb{
    width:56px;
    height:56px;
    border-radius:14px;
    object-fit:cover;
    background:#1e293b;
    flex-shrink:0;
}

.product-name{
    font-size:16px;
    font-weight:700;
}

.small-text{
    font-size:12px;
    color:#94a3b8;
    margin-top:3px;
}

.request-card-body{
    padding:20px 22px;
    display:grid;
    grid-template-columns:1fr 1fr;
    gap:22px;
}

@media(max-width:800px){
    .request-card-body{
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

.detail-row{
    display:flex;
    justify-content:space-between;
    font-size:13px;
    padding:6px 0;
    border-bottom:1px solid rgba(255,255,255,0.04);
}

.detail-row span:first-child{
    color:#94a3b8;
}

.description{
    font-size:13px;
    color:#cbd5e1;
    line-height:1.6;
    max-height:120px;
    overflow-y:auto;
}

.action-bar{
    padding:18px 22px;
    background:rgba(255,255,255,0.02);
    border-top:1px solid rgba(255,255,255,0.06);
    display:flex;
    justify-content:flex-end;
    gap:10px;
}

.action-bar form{
    display:inline;
}

.btn{
    padding:10px 20px;
    border-radius:10px;
    border:none;
    font-size:12px;
    font-weight:700;
    cursor:pointer;
}

.btn-approve{
    background:#4ade8020;
    color:#4ade80;
}

.btn-approve:hover{
    background:#4ade8040;
}

.btn-reject{
    background:#f8717120;
    color:#f87171;
}

.btn-reject:hover{
    background:#f8717140;
}

.badge{
    display:inline-block;
    padding:6px 12px;
    border-radius:30px;
    font-size:10px;
    font-weight:700;
    text-transform:uppercase;
    background:#eab30820;
    color:#facc15;
}

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

    <div class="page-header">

        <h1>
            Product Requests
        </h1>

        <p>
            New products submitted by sellers, awaiting approval before they join the shared catalog
        </p>

    </div>

    <?php if(isset($_GET['result'])){ ?>

        <?php if($_GET['result'] === 'approved'){ ?>
            <div class="success-banner">Product approved and added to the shared catalog.</div>
        <?php }elseif($_GET['result'] === 'rejected'){ ?>
            <div class="error-banner">Product request rejected and removed.</div>
        <?php } ?>

    <?php } ?>

    <?php if(count($requests) > 0){ ?>

    <div class="request-list">

        <?php foreach($requests as $req){ ?>

        <?php

        $variants = [];

        if($req['hasvarients'] === 'yes'){

            $vStmt = $pdo->prepare("SELECT * FROM product_varients WHERE product_id=?");
            $vStmt->execute([$req['id']]);
            $variants = $vStmt->fetchAll();
        }

        ?>

        <div class="request-card">

            <div class="request-card-header">

                <img class="request-thumb" src="../app/uploads/products/<?php echo htmlspecialchars(basename(s($req['image']))); ?>" onerror="this.style.visibility='hidden'">

                <div style="flex:1">
                    <div class="product-name"><?php echo htmlspecialchars(s($req['name'])); ?></div>
                    <div class="small-text">Submitted by <?php echo htmlspecialchars(s($req['seller_name']) ?: 'Unknown seller'); ?></div>
                </div>

                <span class="badge">Pending</span>

            </div>

            <div class="request-card-body">

                <div>
                    <div class="section-label">Proposed Pricing</div>

                    <?php if($req['hasvarients'] === 'yes'){ ?>

                        <?php foreach($variants as $v){ ?>
                            <div class="detail-row">
                                <span><?php echo htmlspecialchars(s($v['varient_name'])); ?></span>
                                <span>₹<?php echo number_format((float)$v['salerate'], 2); ?> &middot; Stock: <?php echo intval($v['stock']); ?></span>
                            </div>
                        <?php } ?>

                    <?php }else{ ?>

                        <div class="detail-row">
                            <span>Price (MRP)</span>
                            <span>₹<?php echo number_format((float)($req['mapping_price'] ?? 0), 2); ?></span>
                        </div>
                        <div class="detail-row">
                            <span>Sale Price</span>
                            <span>₹<?php echo number_format((float)($req['mapping_saleprice'] ?? 0), 2); ?></span>
                        </div>
                        <div class="detail-row">
                            <span>Stock</span>
                            <span><?php echo intval($req['mapping_stock'] ?? 0); ?></span>
                        </div>
                        <?php if(!empty($req['mapping_sku'])){ ?>
                        <div class="detail-row">
                            <span>SKU</span>
                            <span><?php echo htmlspecialchars(s($req['mapping_sku'])); ?></span>
                        </div>
                        <?php } ?>

                    <?php } ?>
                </div>

                <div>
                    <div class="section-label">Description</div>
                    <div class="description"><?php echo nl2br(htmlspecialchars(s($req['product_description']))); ?></div>
                </div>

            </div>

            <div class="action-bar">

                <form method="post" onsubmit="return confirm('Reject and remove this product request?');">
                    <input type="hidden" name="product_id" value="<?php echo $req['id']; ?>">
                    <button type="submit" name="reject" value="1" class="btn btn-reject">Reject</button>
                </form>

                <form method="post" onsubmit="return confirm('Approve this product? It will become visible to all customers and sellers can map to it.');">
                    <input type="hidden" name="product_id" value="<?php echo $req['id']; ?>">
                    <button type="submit" name="approve" value="1" class="btn btn-approve">Approve</button>
                </form>

            </div>

        </div>

        <?php } ?>

    </div>

    <?php }else{ ?>

    <div class="empty-box">

        <i class="fa-solid fa-clipboard-check"></i>

        <h2>
            No Pending Requests
        </h2>

        <p>
            All caught up -- no new product submissions waiting for review
        </p>

    </div>

    <?php } ?>

</div>

</body>
</html>
