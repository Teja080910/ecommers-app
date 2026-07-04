
<?php
session_start();

require_once 'db.php';

/* LOGIN */

if(!isset($_SESSION['seller_id'])){

header("Location:index.php");
exit;

}

$seller_id =
intval(
$_SESSION['seller_id']
);

/* CHECK PRODUCT ID */

if(!isset($_GET['id'])){

header(
"Location:all-products.php"
);

exit;

}

$id =
intval(
$_GET['id']
);

/* FETCH PRODUCT
ONLY OWNER CAN EDIT */

$stmt =
$pdo->prepare(

"

SELECT *

FROM products

WHERE

id=?

AND

seller_id=?

"

);

$stmt->execute([

$id,
$seller_id

]);

$product =
$stmt->fetch();

if(!$product){

header(
"Location:all-products.php"
);

exit;

}

/* FETCH VARIANTS */

$variantsStmt =
$pdo->prepare(

"

SELECT *

FROM product_varients

WHERE product_id=?

ORDER BY id ASC

"

);

$variantsStmt->execute([
$id
]);

$variants =
$variantsStmt->fetchAll();

/* FETCH CATEGORIES */

$categories =
$pdo->query(

"

SELECT *

FROM categories

ORDER BY name ASC

"

)->fetchAll();

/* FETCH SUBCATEGORIES */

$subcategories =
$pdo->query(

"

SELECT *

FROM subcategories

ORDER BY name ASC

"

)->fetchAll();

$success="";

$error="";

/* UPDATE PRODUCT */

if(isset($_POST['update_product'])){

$seller_id =
intval(
$_SESSION['seller_id']
);

$cat_id =
$_POST['cat_id'];

$subcat_id =
$_POST['subcat_id'];

$name =
trim(
$_POST['name']
);

$rate =
$_POST['rate'];

$saleprice =
$_POST['saleprice'];

$stock =
$_POST['stock'];

$topdeals =
$_POST['topdeals'];

$hasvarients =
$_POST['hasvarients'];

$product_description =
trim(
$_POST['product_description']
);

$image =
$product['image'];

/* MAIN IMAGE */

if(!empty($_POST['cropped_image_data'])){

    /* CROPPED (SQUARE) IMAGE FROM BROWSER */

    $data = $_POST['cropped_image_data'];

    if(preg_match('/^data:image\/(jpeg|png|webp);base64,/', $data)){

        $data = substr($data, strpos($data, ',') + 1);

        $decoded = base64_decode($data);

        if($decoded !== false){

            $file =
            time().'_cropped.jpg';

            file_put_contents(
                "../app/uploads/products/".$file,
                $decoded
            );

            $image =
            "uploads/products/".$file;
        }
    }

}else if(
isset($_FILES['image'])
&&
$_FILES['image']['error']==0
){

$file =
time().
'_'.
$_FILES['image']['name'];

move_uploaded_file(

$_FILES['image']['tmp_name'],

"../app/uploads/products/".$file

);

$image =
"uploads/products/".$file;

}

/* OTHER IMAGES (max 3 - 4 total with main image) */

$other_images =
$product['other_images'];

if(
isset(
$_FILES['other_images']
)
){

$uploaded_count = count(array_filter(
$_FILES['other_images']['tmp_name'],
function($tmp){ return $tmp !== ""; }
));

if($uploaded_count > 3){

$error =
"You can upload a maximum of 3 additional images (4 total including the main image).";

}

}

if(
empty($error)
&&
isset(
$_FILES['other_images']
)
){

$imgs=[];

foreach(

$_FILES['other_images']['tmp_name']

as

$key=>$tmp

){

if($tmp==""){
continue;
}

$file =
time().
rand(1000,9999).
"_".
$_FILES['other_images']['name'][$key];

move_uploaded_file(

$tmp,

"../app/uploads/products/".$file

);

$imgs[]=
"uploads/products/".$file;

}

if(
count($imgs)>0
){

$other_images=
implode(
",",
$imgs
);

}

}

/* UPDATE */

if(empty($error)){

$update =
$pdo->prepare(

"

UPDATE products

SET

seller_id=?,
cat_id=?,
subcat_id=?,
name=?,
rate=?,
saleprice=?,
image=?,
other_images=?,
topdeals=?,
hasvarients=?,
product_description=?,
stock=?

WHERE

id=?
AND seller_id=?

"

);

$done =
$update->execute([

$seller_id,
$cat_id,
$subcat_id,
$name,
$rate,
$saleprice,
$image,
$other_images,
$topdeals,
$hasvarients,
$product_description,
$stock,
$id,
$seller_id

]);

if($done){

$pdo->prepare(

"

DELETE
FROM product_varients
WHERE product_id=?

"

)->execute([
$id
]);

if(

$hasvarients=="yes"

&&

isset(
$_POST['varient_name']
)

){

foreach(

$_POST['varient_name']

as

$key=>$value

){

if(
trim($value)
==""
){
continue;
}

$pdo->prepare(

"

INSERT INTO product_varients

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

)

"

)->execute([

$id,

trim($value),

$_POST['varient_rate'][$key],

$_POST['varient_sale'][$key],

$_POST['varient_description'][$key],

$_POST['varient_stock'][$key]

]);

}

}

$success =
"Product Updated Successfully";

$stmt->execute([
$id,
$seller_id
]);

$product =
$stmt->fetch();

$variantsStmt->execute([
$id
]);

$variants =
$variantsStmt->fetchAll();

}

}

}
?>


<!DOCTYPE html>
<html>
<head>

<meta charset="UTF-8">

<meta name="viewport"
content="width=device-width,
initial-scale=1.0">

<title>
Edit Product
</title>

<link rel="stylesheet"
href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">

<link rel="stylesheet"
href="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.6.2/cropper.min.css">

<script
src="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.6.2/cropper.min.js"></script>

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
    border-radius:28px;
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
    background:#ff000020;
    color:#ffb4b4;
}

.grid{
    display:grid;
    grid-template-columns:
    repeat(2,1fr);
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
}

.input-box textarea{
    height:150px;
    resize:none;
}

.full{
    grid-column:1/3;
}

.preview{
    width:120px;
    height:120px;
    border-radius:18px;
    object-fit:cover;
    margin-top:12px;
    background:#1e293b;
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
    grid-template-columns:
    repeat(2,1fr);
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
}

.crop-modal{
    display:none;
    position:fixed;
    top:0;
    left:0;
    width:100%;
    height:100%;
    background:rgba(0,0,0,0.75);
    z-index:999;
    align-items:center;
    justify-content:center;
}

.crop-modal.active{
    display:flex;
}

.crop-box{
    background:#0c0e1c;
    border-radius:20px;
    padding:24px;
    width:90%;
    max-width:500px;
}

.crop-image-wrap{
    max-height:400px;
    margin-bottom:18px;
}

.crop-image-wrap img{
    max-width:100%;
    display:block;
}

.crop-actions{
    display:flex;
    gap:12px;
    margin-top:16px;
}

.crop-actions button{
    flex:1;
    height:46px;
    border:none;
    border-radius:12px;
    cursor:pointer;
    font-size:14px;
    font-weight:600;
}

.crop-use-btn{
    background:linear-gradient(135deg,#06b6d4,#7c3aed);
    color:#fff;
}

.crop-skip-btn{
    background:#1e293b;
    color:#cbd5e1;
}

</style>

</head>
<body>

<?php include 'nav.php'; ?>

<div class="main">

<div class="card">

<div class="title">
    Edit Product
</div>

<div class="sub">
    Update product details
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

<?php foreach($categories as $cat){ ?>

<option

value="<?php echo $cat['id']; ?>"

<?php
if($product['cat_id']
== $cat['id'])
echo 'selected';
?>

>

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

<?php foreach($subcategories as $sub){ ?>

<option

value="<?php echo $sub['id']; ?>"

data-cat="<?php echo $sub['category_id']; ?>"

<?php
if($product['subcat_id']
== $sub['id'])
echo 'selected';
?>

>

<?php echo $sub['name']; ?>

</option>

<?php } ?>

</select>

</div>

<!-- SELLER -->

<!-- PRODUCT NAME -->

<div class="input-box">

<label>
Product Name
</label>

<input
type="text"
name="name"

value="<?php echo htmlspecialchars($product['name']); ?>"

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

value="<?php echo $product['rate']; ?>"

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

value="<?php echo $product['saleprice']; ?>"

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

value="<?php echo $product['stock']; ?>"

required>

</div>

<!-- TOP DEAL -->

<div class="input-box">

<label>
Top Deals
</label>

<select
name="topdeals">

<option

value="no"

<?php
if($product['topdeals']
== "no")
echo 'selected';
?>

>

No

</option>

<option

value="yes"

<?php
if($product['topdeals']
== "yes")
echo 'selected';
?>

>

Yes

</option>

</select>

</div>

<!-- VARIANTS -->

<div class="input-box">

<label>
Has Variants
</label>

<select
name="hasvarients"
id="variantToggle">

<option

value="no"

<?php
if($product['hasvarients']
== "no")
echo 'selected';
?>

>

No

</option>

<option

value="yes"

<?php
if($product['hasvarients']
== "yes")
echo 'selected';
?>

>

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
onchange="openCropModal(this)">

<input type="hidden" name="cropped_image_data" id="croppedImageData">

<img

src="../app/<?php echo $product['image']; ?>"

class="preview">

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

</div>

<!-- DESCRIPTION -->

<div class="input-box full">

<label>
Description
</label>

<textarea
name="product_description"><?php echo $product['product_description']; ?></textarea>

</div>

</div>

<!-- VARIANTS -->

<div

class="variant-area"

id="variantArea"

<?php
if($product['hasvarients']
== "yes"){
?>

style="display:block"

<?php } ?>

>

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

<div id="variantsContainer">

<?php foreach($variants as $v){ ?>

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

name="varient_name[]"

value="<?php echo htmlspecialchars($v['varient_name']); ?>">

</div>

<div class="input-box">

<label>
Rate
</label>

<input

type="number"

step="0.01"

name="varient_rate[]"

value="<?php echo $v['rate']; ?>">

</div>

<div class="input-box">

<label>
Sale Rate
</label>

<input

type="number"

step="0.01"

name="varient_sale[]"

value="<?php echo $v['salerate']; ?>">

</div>

<div class="input-box">

<label>
Stock
</label>

<input

type="number"

name="varient_stock[]"

value="<?php echo $v['stock']; ?>">

</div>

<div
class="input-box full">

<label>
Description
</label>

<textarea
name="varient_description[]"><?php echo $v['product_description']; ?></textarea>

</div>

</div>

</div>

<?php } ?>

</div>

</div>

<button
type="submit"
name="update_product"
class="submit-btn">

<i class="fa fa-save"></i>

Update Product

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
            <button type="button" class="crop-skip-btn" onclick="skipCrop()">Skip Crop</button>
            <button type="button" class="crop-use-btn" onclick="applyCrop()">Crop &amp; Use</button>
        </div>

    </div>

</div>

<script>

let cropperInstance = null;

function openCropModal(input){

    if(!input.files || !input.files[0]){
        return;
    }

    const reader = new FileReader();

    reader.onload = function(e){

        const img = document.getElementById('cropperImage');
        img.src = e.target.result;

        document.getElementById('cropModal').classList.add('active');

        if(cropperInstance){
            cropperInstance.destroy();
        }

        cropperInstance = new Cropper(img, {
            aspectRatio: 1,
            viewMode: 1,
            autoCropArea: 1
        });
    };

    reader.readAsDataURL(input.files[0]);
}

function applyCrop(){

    if(!cropperInstance){
        return;
    }

    const canvas = cropperInstance.getCroppedCanvas({
        width: 800,
        height: 800
    });

    document.getElementById('croppedImageData').value =
        canvas.toDataURL('image/jpeg', 0.9);

    closeCropModal();
}

function skipCrop(){
    document.getElementById('croppedImageData').value = '';
    closeCropModal();
}

function closeCropModal(){

    document.getElementById('cropModal').classList.remove('active');

    if(cropperInstance){
        cropperInstance.destroy();
        cropperInstance = null;
    }
}

function validateOtherImages(input){

    if(input.files.length > 3){

        alert("You can upload a maximum of 3 additional images (4 total including the main image).");

        input.value = "";
    }
}

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
class="input-box full">

<label>
Description
</label>

<textarea
name="varient_description[]"></textarea>

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