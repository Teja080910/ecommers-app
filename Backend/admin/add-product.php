<?php
session_start();

require_once 'db.php';
require_once '../includes/image_upload.php';

/* LOGIN */

if(!isset($_SESSION['admin_id'])){

    header("Location:index.php");
    exit;
}

/* CREATE FOLDER */

if(!is_dir("../app/uploads/products")){

    mkdir(
        "../app/uploads/products",
        0777,
        true
    );
}

/* FETCH CATEGORIES */

$categories = $pdo->query(

    "SELECT * FROM categories
     ORDER BY name ASC"

)->fetchAll();

/* FETCH SUBCATEGORIES */

$subcategories = $pdo->query(

    "SELECT * FROM subcategories
     ORDER BY name ASC"

)->fetchAll();

/* FETCH SELLERS */

$sellers = $pdo->query(

    "SELECT * FROM seller
     ORDER BY name ASC"

)->fetchAll();

$success = "";
$error = "";

/* MAP AN EXISTING MASTER PRODUCT TO A SELLER (shared catalog) */

if(isset($_POST['map_product'])){

    $map_seller_id = intval($_POST['map_seller_id'] ?? 0);
    $map_product_id = intval($_POST['product_id']);
    $map_price = $_POST['price'];
    $map_saleprice = $_POST['saleprice'];
    $map_stock = $_POST['stock'];
    $map_discount = (isset($_POST['discount']) && $_POST['discount'] !== '') ? $_POST['discount'] : null;
    $map_sku = trim($_POST['sku'] ?? '');

    if(empty($map_seller_id)){

        $error = "Select a seller to assign this product to.";

    }else{

        $check = $pdo->prepare(
            "SELECT id FROM products WHERE id=? AND status='approved' AND hasvarients='no'"
        );
        $check->execute([$map_product_id]);

        if(!$check->fetch()){

            $error = "That product isn't available to add right now.";

        }else{

            try{

                $stmt = $pdo->prepare(
                    "INSERT INTO seller_product_mapping
                    (seller_id, product_id, price, saleprice, stock, discount, sku)
                    VALUES (?, ?, ?, ?, ?, ?, ?)"
                );

                $stmt->execute([
                    $map_seller_id,
                    $map_product_id,
                    $map_price,
                    $map_saleprice,
                    $map_stock,
                    $map_discount,
                    $map_sku !== '' ? $map_sku : null
                ]);

                $success = "Product assigned to seller.";

            }catch(PDOException $e){

                if((int)$e->getCode() === 23000 || strpos($e->getMessage(), 'uniq_seller_product') !== false){

                    $error = "That seller already sells this product.";

                }else{

                    $error = "Failed to assign product.";
                }
            }
        }
    }
}

/* ADD PRODUCT */

if(isset($_POST['add_product'])){

    $seller_id =
    $_POST['seller_id'];

    $cat_id =
    $_POST['cat_id'];

    $subcat_id =
    $_POST['subcat_id'];

    $name =
    trim($_POST['name']);

    $rate =
    $_POST['rate'];

    $saleprice =
    $_POST['saleprice'];

    $stock =
    $_POST['stock'];

    $topdeals =
    $_POST['topdeals'];

    $bestseller =
    $_POST['bestseller'] ?? 'no';

    $recommended =
    $_POST['recommended'] ?? 'no';

    $hasvarients =
    $_POST['hasvarients'];

    $product_description =
    trim($_POST['product_description']);

    $image = "";

    $other_images = [];

    /* MAIN IMAGE */

    $uploadError = "";

    $mainImageFile = handleCroppedOrRawUpload(
        'cropped_image_data',
        'image',
        "../app/uploads/products",
        ['jpg','jpeg','png','webp'],
        $uploadError
    );

    if($uploadError != ""){

        $error = $uploadError;

    }else if($mainImageFile){

        $image = resolveUploadedImagePath($mainImageFile);
    }

    /* OTHER IMAGES (max 3 - 4 total with main image) */

    if(empty($error) && isset($_FILES['other_images'])){

        $uploaded_count = count(array_filter(
            $_FILES['other_images']['tmp_name'],
            function($tmp){ return $tmp !== ""; }
        ));

        if($uploaded_count > 3){

            $error =
            "You can upload a maximum of 3 additional images (4 total including the main image).";
        }
    }

    if(empty($error)){

        $otherImageFiles = handleCroppedOrRawMultiUpload(
            'cropped_other_images',
            'other_images',
            "../app/uploads/products",
            ['jpg','jpeg','png','webp']
        );

        foreach($otherImageFiles as $f){
            $other_images[] = resolveUploadedImagePath($f);
        }
    }

    $other_images =
    implode(",", $other_images);

    /* INSERT PRODUCT */

    if(empty($error)){

        $stmt = $pdo->prepare(

            "INSERT INTO products

            (
            seller_id,
            cat_id,
            subcat_id,
            name,
            rate,
            saleprice,
            image,
            other_images,
            topdeals,
            bestseller,
            recommended,
            hasvarients,
            product_description,
            stock
            )

            VALUES

            (
            ?,
            ?,
            ?,
            ?,
            ?,
            ?,
            ?,
            ?,
            ?,
            ?,
            ?,
            ?,
            ?,
            ?
            )"
        );

        $insert = $stmt->execute([

            $seller_id,
            $cat_id,
            $subcat_id,
            $name,
            $rate,
            $saleprice,
            $image,
            $other_images,
            $topdeals,
            $bestseller,
            $recommended,
            $hasvarients,
            $product_description,
            $stock
        ]);

        if($insert){

            $product_id =
            $pdo->lastInsertId();

            /* SELLER MAPPING (shared catalog -- non-variant products only) */

            if($hasvarients != "yes" && !empty($seller_id)){

                $mappingStmt = $pdo->prepare(
                    "INSERT INTO seller_product_mapping
                    (seller_id, product_id, price, saleprice, stock)
                    VALUES (?, ?, ?, ?, ?)"
                );

                $mappingStmt->execute([
                    $seller_id,
                    $product_id,
                    $rate,
                    $saleprice,
                    $stock
                ]);
            }

            /* INSERT VARIANTS */

            if($hasvarients == "yes" &&
               isset($_POST['varient_name'])){

                foreach(

                    $_POST['varient_name']
                    as $key => $value

                ){

                    $varient_name =
                    trim($value);

                    if($varient_name == ""){
                        continue;
                    }

                    $varient_rate =
                    $_POST['varient_rate'][$key];

                    $varient_sale =
                    $_POST['varient_sale'][$key];

                    $varient_stock =
                    $_POST['varient_stock'][$key];

                    $varient_description =
                    $_POST['varient_description'][$key];

                    $variantStmt =
                    $pdo->prepare(

                        "INSERT INTO product_varients

                        (
                        product_id,
                        varient_name,
                        rate,
                        salerate,
                        product_description,
                        stock
                        )

                        VALUES

                        (
                        ?,
                        ?,
                        ?,
                        ?,
                        ?,
                        ?
                        )"
                    );

                    $variantStmt->execute([

                        $product_id,

                        $varient_name,

                        $varient_rate,

                        $varient_sale,

                        $varient_description,

                        $varient_stock
                    ]);
                }
            }

            $success =
            "Product Added Successfully";

        }else{

            $error =
            "Failed To Add Product";
        }
    }
}
?>

<!DOCTYPE html>
<html>
<head>

<meta charset="UTF-8">

<meta name="viewport"
content="width=device-width, initial-scale=1.0">

<title>
Add Product
</title>

<link rel="stylesheet"
href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">

<link rel="stylesheet"
href="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.6.2/cropper.min.css">

<link rel="stylesheet" href="../assets/css/image-crop.css">

<script
src="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.6.2/cropper.min.js"></script>

<script src="../assets/js/image-crop.js"></script>

<style>

*{
    margin:0;
    padding:0;
    box-sizing:border-box;
    font-family:Arial;
}

body{
    background:#0f172a;
    color:#fff;
}

.main{
    margin-left:240px;
    padding:28px;
}

.card{
    background:#111827;
    border-radius:26px;
    padding:28px;
    max-width:1150px;
    margin:auto;
}

.title{
    font-size:28px;
    font-weight:700;
    margin-bottom:8px;
}

.sub{
    color:#94a3b8;
    font-size:13px;
    margin-bottom:28px;
}

.alert{
    padding:15px 18px;
    border-radius:14px;
    margin-bottom:20px;
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

.grid{
    display:grid;
    grid-template-columns:repeat(2,1fr);
    gap:18px;
}

.input-box{
    display:flex;
    flex-direction:column;
}

.input-box label{
    margin-bottom:8px;
    font-size:13px;
    color:#cbd5e1;
}

.input-box input,
.input-box select,
.input-box textarea{
    width:100%;
    border:none;
    outline:none;
    background:#1e293b;
    border-radius:14px;
    padding:14px 16px;
    color:#fff;
    font-size:13px;
}

.input-box textarea{
    height:150px;
    resize:none;
}

.input-box input[type="file"]{
    padding:14px;
}

.full{
    grid-column:1/3;
}

.submit-btn{
    width:100%;
    height:58px;
    border:none;
    border-radius:18px;
    margin-top:24px;
    background:linear-gradient(
        135deg,
        #06b6d4,
        #7c3aed
    );
    color:#fff;
    font-size:15px;
    font-weight:700;
    cursor:pointer;
}

.variant-area{
    display:none;
    margin-top:35px;
}

.variant-header{
    display:flex;
    align-items:center;
    justify-content:space-between;
    margin-bottom:20px;
}

.variant-header h2{
    font-size:24px;
}

.add-variant-btn{
    height:46px;
    border:none;
    padding:0 18px;
    border-radius:14px;
    background:#22c55e;
    color:#fff;
    font-weight:700;
    cursor:pointer;
}

.variant-card{
    background:#1e293b;
    border-radius:22px;
    padding:22px;
    margin-bottom:18px;
    position:relative;
}

.variant-grid{
    display:grid;
    grid-template-columns:repeat(2,1fr);
    gap:16px;
}

.remove-variant{
    position:absolute;
    top:16px;
    right:16px;
    width:42px;
    height:42px;
    border:none;
    border-radius:12px;
    background:#ef444420;
    color:#f87171;
    cursor:pointer;
}

@media(max-width:900px){

    .main{
        margin-left:0;
        padding:85px 15px;
    }

    .grid,
    .variant-grid{
        grid-template-columns:1fr;
    }

    .full{
        grid-column:auto;
    }

    .variant-header{
        flex-direction:column;
        align-items:flex-start;
        gap:14px;
    }
}

/* TABS */

.mode-tabs{
    display:flex;
    gap:10px;
    margin-bottom:26px;
}

.mode-tab{
    flex:1;
    text-align:center;
    padding:16px;
    border-radius:16px;
    background:#1e293b;
    color:#94a3b8;
    font-weight:700;
    font-size:14px;
    cursor:pointer;
    border:2px solid transparent;
}

.mode-tab.active{
    background:#06b6d420;
    color:#22d3ee;
    border-color:#06b6d4;
}

.mode-panel{
    display:none;
}

.mode-panel.active{
    display:block;
}

/* SEARCH */

.search-box{
    width:100%;
    padding:16px 18px;
    border:none;
    border-radius:16px;
    background:#1e293b;
    color:#fff;
    font-size:14px;
    margin-bottom:16px;
}

.search-results{
    max-height:360px;
    overflow-y:auto;
    border-radius:16px;
    background:#1e293b;
    margin-bottom:20px;
}

.master-product-item{
    display:flex;
    align-items:center;
    gap:14px;
    padding:14px 16px;
    cursor:pointer;
    border-bottom:1px solid rgba(255,255,255,0.05);
}

.master-product-item:hover{
    background:rgba(255,255,255,0.04);
}

.master-product-thumb{
    width:44px;
    height:44px;
    border-radius:10px;
    object-fit:cover;
    background:#0f172a;
    flex-shrink:0;
}

.master-product-name{
    font-size:14px;
    font-weight:600;
}

.map-form{
    display:none;
    background:#1e293b;
    border-radius:18px;
    padding:22px;
}

.map-form.active{
    display:block;
}

.map-form-title{
    font-size:16px;
    font-weight:700;
    margin-bottom:18px;
}

.manual-link{
    text-align:center;
    margin-top:20px;
    font-size:13px;
}

.manual-link a{
    color:#22d3ee;
    cursor:pointer;
    text-decoration:underline;
}

</style>
</head>
<body>

<?php include 'nav.php'; ?>

<div class="main">

    <div class="card">

        <div class="title">
            Add Product
        </div>

        <div class="sub">
            Add products with variants,
            categories and sellers
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

        <div class="mode-tabs">
            <div class="mode-tab active" id="tabSearch" onclick="switchMode('search')">Sell an Existing Product</div>
            <div class="mode-tab" id="tabManual" onclick="switchMode('manual')">Add New Product</div>
        </div>

        <!-- SEARCH / MAP EXISTING PRODUCT -->

        <div class="mode-panel active" id="searchPanel">

            <input type="text" class="search-box" id="masterSearchInput"
                placeholder="Search for a product to assign to a seller..."
                oninput="searchMasterProducts(this.value)">

            <div class="search-results" id="masterSearchResults">
                <div style="text-align:center;padding:40px 20px;color:#94a3b8;font-size:14px;">
                    Loading products...
                </div>
            </div>

            <div class="map-form" id="mapForm">

                <div class="map-form-title">
                    Assigning: <span id="mapProductName"></span>
                </div>

                <form method="POST">

                    <input type="hidden" name="product_id" id="mapProductId">

                    <div class="grid">

                        <div class="input-box full">
                            <label>Seller</label>
                            <select name="map_seller_id" required>
                                <option value="">Select Seller</option>
                                <?php foreach($sellers as $seller){ ?>
                                <option value="<?php echo $seller['id']; ?>">
                                    <?php echo $seller['name']; ?>
                                </option>
                                <?php } ?>
                            </select>
                        </div>

                        <div class="input-box">
                            <label>Price (MRP)</label>
                            <input type="number" step="0.01" name="price" required>
                        </div>

                        <div class="input-box">
                            <label>Sale Price</label>
                            <input type="number" step="0.01" name="saleprice" required>
                        </div>

                        <div class="input-box">
                            <label>Stock</label>
                            <input type="number" name="stock" required>
                        </div>

                        <div class="input-box">
                            <label>Discount % (optional)</label>
                            <input type="number" step="0.01" name="discount">
                        </div>

                        <div class="input-box full">
                            <label>SKU (optional)</label>
                            <input type="text" name="sku">
                        </div>

                    </div>

                    <button type="submit" name="map_product" class="submit-btn">
                        <i class="fa fa-plus"></i>
                        Assign To Seller
                    </button>

                </form>

            </div>

            <div class="manual-link">
                Can't find the product? <a onclick="switchMode('manual')">Add it manually</a>
            </div>

        </div>

        <!-- ADD NEW PRODUCT (manual) -->

        <div class="mode-panel" id="manualPanel">

        <form
        method="POST"
        enctype="multipart/form-data">

            <div class="grid">

                <!-- CATEGORY -->

                <div class="input-box">

                    <label>
                        Category
                    </label>

                    <select
                    name="cat_id"
                    id="categorySelect"
                    required>

                        <option value="">
                            Select Category
                        </option>

                        <?php foreach($categories as $cat){ ?>

                        <option
                        value="<?php echo $cat['id']; ?>">

                            <?php echo $cat['name']; ?>

                        </option>

                        <?php } ?>

                    </select>

                </div>

                <!-- SUBCATEGORY -->

                <div class="input-box">

                    <label>
                        Subcategory
                    </label>

                    <select
                    name="subcat_id"
                    id="subCategorySelect"
                    required>

                        <option value="">
                            Select Subcategory
                        </option>

                        <?php foreach($subcategories as $sub){ ?>

                        <option

                        value="<?php echo $sub['id']; ?>"

                        data-cat="<?php echo $sub['category_id']; ?>">

                            <?php echo $sub['name']; ?>

                        </option>

                        <?php } ?>

                    </select>

                </div>

                <!-- SELLER -->

                <div class="input-box">

                    <label>
                        Seller
                    </label>

                    <select
                    name="seller_id"
                    required>

                        <option value="">
                            Select Seller
                        </option>

                        <?php foreach($sellers as $seller){ ?>

                        <option
                        value="<?php echo $seller['id']; ?>">

                            <?php echo $seller['name']; ?>

                        </option>

                        <?php } ?>

                    </select>

                </div>

                <!-- PRODUCT NAME -->

                <div class="input-box">

                    <label>
                        Product Name
                    </label>

                    <input
                    type="text"
                    name="name"
                    required>

                </div>

                <!-- RATE -->

                <div class="input-box">

                    <label>
                        Rate
                    </label>

                    <input
                    type="number"
                    step="0.01"
                    name="rate"
                    required>

                </div>

                <!-- SALE PRICE -->

                <div class="input-box">

                    <label>
                        Sale Price
                    </label>

                    <input
                    type="number"
                    step="0.01"
                    name="saleprice"
                    required>

                </div>

                <!-- STOCK -->

                <div class="input-box">

                    <label>
                        Stock
                    </label>

                    <input
                    type="number"
                    name="stock"
                    required>

                </div>

                <!-- TOP DEAL -->

                <div class="input-box">

                    <label>
                        Top Deals
                    </label>

                    <select
                    name="topdeals">

                        <option value="no">
                            No
                        </option>

                        <option value="yes">
                            Yes
                        </option>

                    </select>

                </div>

                <!-- BEST SELLER -->

                <div class="input-box">

                    <label>
                        Best Seller
                    </label>

                    <select
                    name="bestseller">

                        <option value="no">
                            No
                        </option>

                        <option value="yes">
                            Yes
                        </option>

                    </select>

                </div>

                <!-- RECOMMENDED -->

                <div class="input-box">

                    <label>
                        Recommended
                    </label>

                    <select
                    name="recommended">

                        <option value="no">
                            No
                        </option>

                        <option value="yes">
                            Yes
                        </option>

                    </select>

                </div>

                <!-- HAS VARIANTS -->

                <div class="input-box">

                    <label>
                        Has Variants
                    </label>

                    <select
                    name="hasvarients"
                    id="variantToggle">

                        <option value="no">
                            No
                        </option>

                        <option value="yes">
                            Yes
                        </option>

                    </select>

                </div>

                <!-- MAIN IMAGE -->

                <div class="input-box">

                    <label>
                        Main Image (square crop recommended)
                    </label>

                    <input
                    type="file"
                    name="image"
                    id="mainImageInput"
                    accept="image/*"
                    onchange="ImageCrop.open(this,'croppedImageData')"
                    required>

                    <input type="hidden" name="cropped_image_data" id="croppedImageData">

                </div>

                <!-- OTHER IMAGES -->

                <div class="input-box full">

                    <label>
                        Other Images (max 3 - 4 total with main image)
                    </label>

                    <input
                    type="file"
                    name="other_images[]"
                    id="otherImagesInput"
                    onchange="validateOtherImages(this)"
                    multiple>

                    <input type="hidden" name="cropped_other_images" id="croppedOtherImagesData">

                </div>

                <!-- DESCRIPTION -->

                <div class="input-box full">

                    <label>
                        Product Description
                    </label>

                    <textarea
                    name="product_description"></textarea>

                </div>

            </div>

            <!-- VARIANTS -->

            <div
            class="variant-area"
            id="variantArea">

                <div class="variant-header">

                    <h2>
                        Product Variants
                    </h2>

                    <button

                    type="button"

                    class="add-variant-btn"

                    onclick="addVariant()">

                        + Add Variant

                    </button>

                </div>

                <div
                id="variantsContainer">

                </div>

            </div>

            <!-- SUBMIT -->

            <button
            type="submit"
            name="add_product"
            class="submit-btn">

                <i class="fa fa-plus"></i>
                Add Product

            </button>

        </form>

        </div>

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

<script>

function validateOtherImages(input){

    if(input.files.length > 3){

        alert("You can upload a maximum of 3 additional images (4 total including the main image).");

        input.value = "";
        return;
    }

    ImageCrop.openMulti(input, 'croppedOtherImagesData');
}

document
.getElementById(
"categorySelect"
)

.addEventListener(
"change",

function(){

    let catId =
    this.value;

    let options =
    document.querySelectorAll(
    "#subCategorySelect option"
    );

    options.forEach(function(option){

        if(option.value == ""){

            option.style.display =
            "block";

            return;
        }

        if(
            option.getAttribute(
                "data-cat"
            ) == catId
        ){

            option.style.display =
            "block";

        }else{

            option.style.display =
            "none";
        }
    });

    document
    .getElementById(
    "subCategorySelect"
    ).value = "";
});

document
.getElementById(
"variantToggle"
)

.addEventListener(
"change",

function(){

    if(this.value == "yes"){

        document
        .getElementById(
        "variantArea"
        )

        .style.display =
        "block";

    }else{

        document
        .getElementById(
        "variantArea"
        )

        .style.display =
        "none";
    }
});

function addVariant(){

    let html = `

    <div class="variant-card">

        <button
        type="button"
        class="remove-variant"

        onclick="
        this.parentElement.remove()
        ">

            <i class="fa fa-trash"></i>

        </button>

        <div class="variant-grid">

            <div class="input-box">

                <label>
                    Variant Name
                </label>

                <input
                type="text"
                name="varient_name[]">

            </div>

            <div class="input-box">

                <label>
                    Rate
                </label>

                <input
                type="number"
                step="0.01"
                name="varient_rate[]">

            </div>

            <div class="input-box">

                <label>
                    Sale Rate
                </label>

                <input
                type="number"
                step="0.01"
                name="varient_sale[]">

            </div>

            <div class="input-box">

                <label>
                    Stock
                </label>

                <input
                type="number"
                name="varient_stock[]">

            </div>

            <div
            class="input-box"
            style="
            grid-column:1/3;
            ">

                <label>
                    Description
                </label>

                <textarea

                name="varient_description[]"

                style="
                height:120px;
                background:#0f172a;
                border:none;
                border-radius:14px;
                padding:14px;
                color:#fff;
                ">

                </textarea>

            </div>

        </div>

    </div>
    `;

    document
    .getElementById(
    "variantsContainer"
    )

    .insertAdjacentHTML(
        "beforeend",
        html
    );
}

/* MODE TABS */

function switchMode(mode){

    document.getElementById('tabSearch').classList.toggle('active', mode === 'search');
    document.getElementById('tabManual').classList.toggle('active', mode === 'manual');

    document.getElementById('searchPanel').classList.toggle('active', mode === 'search');
    document.getElementById('manualPanel').classList.toggle('active', mode === 'manual');
}

/* MASTER PRODUCT SEARCH */

let masterSearchTimer = null;

function searchMasterProducts(query, immediate){

    clearTimeout(masterSearchTimer);

    const run = function(){

        fetch('search-master-products.php?q=' + encodeURIComponent(query))
            .then(function(res){ return res.text(); })
            .then(function(html){

                const results = document.getElementById('masterSearchResults');
                results.innerHTML = html;

                results.querySelectorAll('.master-product-item').forEach(function(item){

                    item.addEventListener('click', function(){

                        document.getElementById('mapProductId').value = item.getAttribute('data-id');
                        document.getElementById('mapProductName').textContent = item.getAttribute('data-name');

                        // 🔥 Pre-fill with the master product's existing price/stock so
                        // admin isn't typing from scratch -- still fully editable.
                        const mapForm = document.getElementById('mapForm');
                        mapForm.querySelector('input[name="price"]').value = item.getAttribute('data-rate');
                        mapForm.querySelector('input[name="saleprice"]').value = item.getAttribute('data-saleprice');
                        mapForm.querySelector('input[name="stock"]').value = item.getAttribute('data-stock');

                        mapForm.classList.add('active');
                        mapForm.scrollIntoView({behavior:'smooth', block:'center'});
                    });
                });
            });
    };

    if(immediate){
        run();
    }else{
        masterSearchTimer = setTimeout(run, 300);
    }
}

/* Load the full catalog by default so admin can browse, not just search */
searchMasterProducts('', true);

</script>

</body>
</html>