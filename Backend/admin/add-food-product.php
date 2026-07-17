<?php
session_start();

require_once 'db.php';
require_once '../includes/image_upload.php';

/* Login Check */

if(!isset($_SESSION['admin_id'])){

    header("Location:index.php");
    exit;

}

/* Fetch Franchises */

$fstmt = $pdo->query("SELECT id,name FROM franchises ORDER BY name ASC");

$franchises = $fstmt->fetchAll();

/* Fetch Food Categories */

$cstmt = $pdo->query("SELECT id,name FROM food_categories ORDER BY name ASC");

$categories = $cstmt->fetchAll();

/* Add Product */

$success = "";
$error = "";

if(isset($_POST['add_product'])){

    $franchise_id = intval($_POST['franchise_id']);
    $cat_id = intval($_POST['cat_id']);

    $name = trim($_POST['name']);

    $rate = floatval($_POST['rate']);

    $sale_rate = floatval($_POST['sale_rate']);

    $stock = intval($_POST['stock']);

    $image = "";

    /* Image Upload */

    $uploadError = "";

    $imageFile = handleCroppedOrRawUpload(
        'cropped_image',
        'image',
        "../app/uploads",
        ['jpg','jpeg','png','webp'],
        $uploadError
    );

    if($uploadError != ""){

        $error = $uploadError;

    }else if($imageFile){

        $image = "uploads/".$imageFile;

    }else{

        $error = "Please Select Image";

    }

    /* Insert */

    if(empty($error)){

        $stmt = $pdo->prepare("INSERT INTO food_products(franchise_id,cat_id,image,name,rate,sale_rate,stock) VALUES(?,?,?,?,?,?,?)");

        $insert = $stmt->execute([
            $franchise_id,
            $cat_id,
            $image,
            $name,
            $rate,
            $sale_rate,
            $stock
        ]);

        if($insert){

            $success = "Food Product Added Successfully";

        }else{

            $error = "Failed To Add Product";

        }

    }

}

?>

<!DOCTYPE html>
<html lang="en">
<head>

<meta charset="UTF-8">

<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>Add Food Product</title>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">

<link rel="stylesheet"
href="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.6.2/cropper.min.css">

<link rel="stylesheet" href="../assets/css/image-crop.css">

<script
src="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.6.2/cropper.min.js"></script>

<script src="../assets/js/image-crop.js"></script>

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

.page-title{
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

.form-card{
    width:100%;
    max-width:700px;
    background:#111827;
    border-radius:24px;
    padding:28px;
    border:1px solid rgba(255,255,255,0.05);
}

.input-box{
    margin-bottom:20px;
}

.input-box label{
    display:block;
    margin-bottom:8px;
    color:#cbd5e1;
    font-size:13px;
}

.input-box input,
.input-box select{
    width:100%;
    height:52px;
    border:none;
    outline:none;
    background:#1e293b;
    border-radius:14px;
    padding:0 16px;
    color:#fff;
    font-size:13px;
}

.input-box input[type="file"]{
    padding:14px;
}

.submit-btn{
    width:100%;
    height:54px;
    border:none;
    border-radius:16px;
    background:linear-gradient(135deg,#f97316,#ef4444);
    color:#fff;
    font-size:14px;
    font-weight:600;
    cursor:pointer;
}

.alert{
    padding:14px 16px;
    border-radius:14px;
    margin-bottom:18px;
    font-size:13px;
}

.success{
    background:#16a34a20;
    color:#4ade80;
}

.error{
    background:#dc262620;
    color:#f87171;
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

    <div class="page-title">

        <h1>Add Food Product</h1>

        <p>
            Add new food products for franchise
        </p>

    </div>

    <?php if($success != ""){ ?>

        <div class="alert success">
            <?php echo $success; ?>
        </div>

    <?php } ?>

    <?php if($error != ""){ ?>

        <div class="alert error">
            <?php echo $error; ?>
        </div>

    <?php } ?>

    <div class="form-card">

        <form method="POST" enctype="multipart/form-data">

            <!-- Franchise -->

            <div class="input-box">

                <label>Select Franchise</label>

                <select name="franchise_id" required>

                    <option value="">
                        Select Franchise
                    </option>

                    <?php foreach($franchises as $f){ ?>

                        <option value="<?php echo $f['id']; ?>">

                            <?php echo htmlspecialchars($f['name']); ?>

                        </option>

                    <?php } ?>

                </select>

            </div>

            <!-- Category -->

            <div class="input-box">

                <label>Select Food Category</label>

                <select name="cat_id" required>

                    <option value="">
                        Select Category
                    </option>

                    <?php foreach($categories as $c){ ?>

                        <option value="<?php echo $c['id']; ?>">

                            <?php echo htmlspecialchars($c['name']); ?>

                        </option>

                    <?php } ?>

                </select>

            </div>

            <!-- Product Name -->

            <div class="input-box">

                <label>Food Product Name</label>

                <input 
                    type="text"
                    name="name"
                    required
                >

            </div>

            <!-- Rate -->

            <div class="input-box">

                <label>Original Rate</label>

                <input 
                    type="number"
                    step="0.01"
                    name="rate"
                    required
                >

            </div>

            <!-- Sale Rate -->

            <div class="input-box">

                <label>Sale Rate</label>

                <input 
                    type="number"
                    step="0.01"
                    name="sale_rate"
                    required
                >

            </div>

            <!-- Stock -->

            <div class="input-box">

                <label>Stock</label>

                <input 
                    type="number"
                    name="stock"
                    required
                >

            </div>

            <!-- Image -->

            <div class="input-box">

                <label>Product Image</label>

                <input
                    type="file"
                    name="image"
                    id="mainImageInput"
                    accept="image/*"
                    onchange="ImageCrop.open(this,'croppedImageData')"
                    required
                >

                <input type="hidden" name="cropped_image" id="croppedImageData">

            </div>

            <!-- Submit -->

            <button
                type="submit"
                name="add_product"
                class="submit-btn"
            >

                <i class="fa-solid fa-plus"></i>
                Add Food Product

            </button>

        </form>

    </div>

</div>

<!-- CROP MODAL -->
<div class="crop-modal" id="cropModal">

    <div class="crop-box">

        <div class="crop-image-wrap">
            <img id="cropperImage">
        </div>

        <div class="crop-actions">
            <button type="button" class="crop-skip-btn" onclick="ImageCrop.skip()">Skip Crop</button>
            <button type="button" class="crop-use-btn" onclick="ImageCrop.apply()">Crop &amp; Use</button>
        </div>

    </div>

</div>

</body>
</html>