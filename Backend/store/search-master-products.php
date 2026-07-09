<?php

session_start();

require_once 'db.php';
require_once '../includes/image_upload.php';

if(!isset($_SESSION['seller_id'])){
    exit;
}

$seller_id = intval($_SESSION['seller_id']);

$search =
isset($_GET['q'])
? trim($_GET['q'])
: '';

/* SEARCH APPROVED, NON-VARIANT MASTER PRODUCTS
   Empty search shows the full catalog (up to the limit); typing narrows
   it down. Sellers already mapped to a product are flagged so the UI can
   point them to "My Products" instead of letting them create a duplicate. */

$stmt = $pdo->prepare(

    "SELECT products.*,
        (SELECT COUNT(*) FROM seller_product_mapping
         WHERE seller_product_mapping.product_id = products.id
         AND seller_product_mapping.seller_id = ?) AS already_mapped
     FROM products
     WHERE products.status = 'approved'
     AND products.hasvarients = 'no'
     AND products.name LIKE ?
     ORDER BY products.name ASC
     LIMIT 50"
);

$stmt->execute([
    $seller_id,
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
     data-mapped="<?php echo $p['already_mapped'] > 0 ? '1' : '0'; ?>">

    <img class="master-product-thumb"
         src="<?php echo htmlspecialchars(resolveProductImageSrc($p['image'] ?? '')); ?>"
         onerror="this.style.visibility='hidden'">

    <div style="flex:1">
        <div class="master-product-name"><?php echo htmlspecialchars($p['name']); ?></div>
        <?php if($p['already_mapped'] > 0){ ?>
            <div class="master-product-tag">You already sell this &mdash; edit it from My Products</div>
        <?php } ?>
    </div>

</div>

<?php } ?>
