<?php

require_once 'db.php';

$product_id =
isset($_GET['product_id'])
? intval($_GET['product_id'])
: 0;

/* FETCH VARIANTS */

$stmt = $pdo->prepare(

    "SELECT *
     FROM product_varients
     WHERE product_id=?
     ORDER BY id DESC"
);

$stmt->execute([
    $product_id
]);

$variants =
$stmt->fetchAll();

/* EMPTY */

if(count($variants) == 0){
?>

<div style="
text-align:center;
padding:40px 20px;
color:#94a3b8;
font-size:14px;
">

    No variants found

</div>

<?php
exit;
}
?>

<?php foreach($variants as $v){ ?>

<div class="variant-item">

    <!-- NAME -->

    <div class="variant-name">

        <?php echo htmlspecialchars($v['varient_name']); ?>

    </div>

    <!-- PRICE -->

    <div class="variant-price">

        ₹<?php echo number_format($v['salerate'],2); ?>

        <span style="
        color:#94a3b8;
        text-decoration:line-through;
        font-size:13px;
        margin-left:8px;
        ">

            ₹<?php echo number_format($v['rate'],2); ?>

        </span>

    </div>

    <!-- STOCK -->

    <div class="variant-stock">

        Stock :
        <?php echo $v['stock']; ?>

    </div>

    <!-- DESCRIPTION -->

    <?php if(!empty($v['product_description'])){ ?>

    <div style="
    margin-top:10px;
    font-size:13px;
    color:#cbd5e1;
    line-height:1.6;
    ">

        <?php echo $v['product_description']; ?>

    </div>

    <?php } ?>

</div>

<?php } ?>