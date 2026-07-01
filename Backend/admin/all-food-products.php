<?php
session_start();

require_once 'db.php';

/* Login Check */

if(!isset($_SESSION['admin_id'])){

    header("Location:index.php");
    exit;

}

/* Delete Product */

if(isset($_GET['delete'])){

    $id = intval($_GET['delete']);

    $del = $pdo->prepare("DELETE FROM food_products WHERE id=?");

    $del->execute([$id]);

    header("Location:all-food-products.php");
    exit;

}

/* Fetch Products */

$stmt = $pdo->query("

    SELECT 
        food_products.*,
        franchises.name AS franchise_name,
        food_categories.name AS category_name

    FROM food_products

    LEFT JOIN franchises 
    ON food_products.franchise_id = franchises.id

    LEFT JOIN food_categories
    ON food_products.cat_id = food_categories.id

    ORDER BY food_products.id DESC

");

$products = $stmt->fetchAll();

?>

<!DOCTYPE html>
<html lang="en">
<head>

<meta charset="UTF-8">

<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>All Food Products</title>

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
}

.page-header{
    display:flex;
    align-items:center;
    justify-content:space-between;
    margin-bottom:24px;
}

.page-title h1{
    font-size:28px;
    margin-bottom:6px;
}

.page-title p{
    color:#94a3b8;
    font-size:13px;
}

.add-btn{
    height:50px;
    padding:0 20px;
    border:none;
    border-radius:14px;
    background:linear-gradient(135deg,#f97316,#ef4444);
    color:#fff;
    font-size:13px;
    font-weight:600;
    cursor:pointer;
    text-decoration:none;
    display:flex;
    align-items:center;
    gap:8px;
}

/* Grid */

.product-grid{
    display:grid;
    grid-template-columns:repeat(auto-fit,minmax(260px,1fr));
    gap:20px;
}

/* Card */

.product-card{
    background:#111827;
    border-radius:22px;
    overflow:hidden;
    border:1px solid rgba(255,255,255,0.05);
    transition:.3s;
}

.product-card:hover{
    transform:translateY(-5px);
}

.product-image{
    width:100%;
    height:220px;
    background:#1e293b;
}

.product-image img{
    width:100%;
    height:100%;
    object-fit:contain;
    padding:14px;
}

.product-body{
    padding:18px;
}

.product-name{
    font-size:17px;
    font-weight:600;
    margin-bottom:14px;
}

/* Info */

.product-info{
    display:flex;
    flex-direction:column;
    gap:10px;
    margin-bottom:18px;
}

.info-item{
    display:flex;
    align-items:center;
    justify-content:space-between;
    font-size:13px;
}

.info-label{
    color:#94a3b8;
}

.info-value{
    font-weight:600;
}

/* Actions */

.action-buttons{
    display:flex;
    gap:10px;
}

.delete-btn{
    flex:1;
    height:44px;
    border-radius:12px;
    background:#ef444420;
    color:#f87171;
    text-decoration:none;
    display:flex;
    align-items:center;
    justify-content:center;
    transition:.3s;
}

.delete-btn:hover{
    background:#ef4444;
    color:#fff;
}

/* Responsive */

@media(max-width:900px){

    .main-content{
        margin-left:0;
        padding:85px 15px 20px;
    }

    .page-header{
        flex-direction:column;
        align-items:flex-start;
        gap:15px;
    }

}

</style>

</head>
<body>

<?php include 'nav.php'; ?>

<div class="main-content">

    <!-- Header -->

    <div class="page-header">

        <div class="page-title">

            <h1>All Food Products</h1>

            <p>
                Manage all food products
            </p>

        </div>

        <a href="add-food-product.php" class="add-btn">

            <i class="fa-solid fa-plus"></i>
            Add Food Product

        </a>

    </div>

    <!-- Products -->

    <div class="product-grid">

        <?php foreach($products as $product){ ?>

        <div class="product-card">

            <!-- Image -->

            <div class="product-image">

                <img src="../app/<?php echo $product['image']; ?>">

            </div>

            <!-- Body -->

            <div class="product-body">

                <div class="product-name">

                    <?php echo htmlspecialchars($product['name']); ?>

                </div>

                <!-- Info -->

                <div class="product-info">

                    <div class="info-item">

                        <span class="info-label">
                            Franchise
                        </span>

                        <span class="info-value">

                            <?php echo htmlspecialchars($product['franchise_name']); ?>

                        </span>

                    </div>

                    <div class="info-item">

                        <span class="info-label">
                            Category
                        </span>

                        <span class="info-value">

                            <?php echo htmlspecialchars($product['category_name']); ?>

                        </span>

                    </div>

                    <div class="info-item">

                        <span class="info-label">
                            Rate
                        </span>

                        <span class="info-value">
                            ₹<?php echo $product['rate']; ?>
                        </span>

                    </div>

                    <div class="info-item">

                        <span class="info-label">
                            Sale Rate
                        </span>

                        <span class="info-value">
                            ₹<?php echo $product['sale_rate']; ?>
                        </span>

                    </div>

                    <div class="info-item">

                        <span class="info-label">
                            Stock
                        </span>

                        <span class="info-value">

                            <?php echo $product['stock']; ?>

                        </span>

                    </div>

                </div>

                <!-- Actions -->

                <div class="action-buttons">

                    <a 
                        href="all-food-products.php?delete=<?php echo $product['id']; ?>"
                        class="delete-btn"
                        onclick="return confirm('Delete this product?')"
                    >

                        <i class="fa-solid fa-trash"></i>

                    </a>

                </div>

            </div>

        </div>

        <?php } ?>

    </div>

</div>

</body>
</html>