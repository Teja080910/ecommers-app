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

</script>

</body>
</html>