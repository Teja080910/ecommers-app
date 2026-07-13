<?php

session_start();

require_once 'db.php';
require_once '../includes/image_upload.php';

if(!isset($_SESSION['admin_id'])){
    exit;
}

$search =
isset($_GET['q'])
? trim($_GET['q'])
: '';

/* SEARCH APPROVED, NON-VARIANT MASTER PRODUCTS
   Empty search shows the full catalog (up to the limit); typing narrows
   it down. Admin picks the seller after picking the product, so no
   per-seller "already mapped" flag here -- the unique constraint on
   seller_product_mapping catches a duplicate at submit time instead. */

$stmt = $pdo->prepare(

    "SELECT *
     FROM products
     WHERE status = 'approved'
     AND hasvarients = 'no'
     AND name LIKE ?
     ORDER BY name ASC
     LIMIT 50"
);

$stmt->execute([
    '%' . $search . '%'
]);

$results = $stmt->fetchAll();

if(count($results) == 0){
?>

<div style="
text-align:center;
padding:40px 20px;
color:#94a3b8;
font-size:14px;
">

    <?php echo $search === '' ? 'No products available yet.' : 'No matching products found. Try a different search, or add it manually below.'; ?>

</div>

<?php
exit;
}
?>

<?php foreach($results as $p){ ?>

<div class="master-product-item"
     data-id="<?php echo $p['id']; ?>"
     data-name="<?php echo htmlspecialchars($p['name'], ENT_QUOTES); ?>"
     data-rate="<?php echo htmlspecialchars($p['rate']); ?>"
     data-saleprice="<?php echo htmlspecialchars($p['saleprice']); ?>"
     data-stock="<?php echo htmlspecialchars($p['stock']); ?>"
     data-description="<?php echo htmlspecialchars($p['product_description'] ?? '', ENT_QUOTES); ?>"
     data-cat="<?php echo htmlspecialchars($p['cat_id'] ?? ''); ?>"
     data-subcat="<?php echo htmlspecialchars($p['subcat_id'] ?? ''); ?>"
     data-image="<?php echo htmlspecialchars(resolveProductImageSrc($p['image'] ?? ''), ENT_QUOTES); ?>"
     data-other-images="<?php echo htmlspecialchars($p['other_images'] ?? '', ENT_QUOTES); ?>"
     data-topdeals="<?php echo htmlspecialchars($p['topdeals'] ?? 'no'); ?>"
     data-bestseller="<?php echo htmlspecialchars($p['bestseller'] ?? 'no'); ?>"
     data-recommended="<?php echo htmlspecialchars($p['recommended'] ?? 'no'); ?>">

    <img class="master-product-thumb"
         src="<?php echo htmlspecialchars(resolveProductImageSrc($p['image'] ?? '')); ?>"
         onerror="this.style.visibility='hidden'">

    <div style="flex:1">
        <div class="master-product-name"><?php echo htmlspecialchars($p['name']); ?></div>
    </div>

</div>

<?php } ?>
