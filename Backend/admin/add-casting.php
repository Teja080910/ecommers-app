<?php
session_start();

require_once 'db.php';
require_once '../includes/image_upload.php';

if(!isset($_SESSION['admin_id'])){

    header("Location:index.php");
    exit;
}

if(!is_dir("../app/uploads/casting")){

    mkdir(
        "../app/uploads/casting",
        0777,
        true
    );
}

$success = "";
$error = "";

if(isset($_POST['add_casting'])){

    $title =
    trim($_POST['title']);

    $category =
    trim($_POST['category']);

    $isfree =
    $_POST['isfree'];

    $amount =
    intval($_POST['amount']);

    $description =
    trim($_POST['description']);

    $image = "";

    $uploadError = "";

    $imageFile = handleCroppedOrRawUpload(
        'cropped_image',
        'image',
        "../app/uploads/casting",
        ['jpg','jpeg','png','webp'],
        $uploadError
    );

    if($uploadError != ""){

        $error = $uploadError;

    }else if($imageFile){

        $image =
        "uploads/casting/".$imageFile;
    }

    if(empty($error)){

    $stmt =
    $pdo->prepare(

    "INSERT INTO casting

    (
    title,
    category,
    image,
    isfree,
    amount,
    description
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

    $insert =
    $stmt->execute([

        $title,
        $category,
        $image,
        $isfree,
        $amount,
        $description
    ]);

    if($insert){

        $success =
        "Casting added successfully";

    }else{

        $error =
        "Failed";
    }

    }
}
?>

<!DOCTYPE html>
<html>
<head>

<title>Add Casting</title>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.6.2/cropper.min.css">

<link rel="stylesheet" href="../assets/css/image-crop.css">

<script src="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.6.2/cropper.min.js"></script>

<script src="../assets/js/image-crop.js"></script>

<style>

body{
    background:#0f172a;
    color:#fff;
    font-family:Arial;
}

.main{
    margin-left:240px;
    padding:30px;
}

.card{
    background:#111827;
    padding:25px;
    border-radius:20px;
    max-width:800px;
}

input,
select,
textarea{
    width:100%;
    border:none;
    border-radius:14px;
    background:#1e293b;
    color:#fff;
    padding:15px;
    margin-bottom:18px;
}

textarea{
    height:180px;
    resize:none;
}

button{
    width:100%;
    height:55px;
    border:none;
    border-radius:14px;
    background:#7c3aed;
    color:#fff;
    font-weight:bold;
    cursor:pointer;
}

</style>

</head>
<body>

<?php include 'nav2.php'; ?>

<div class="main">

<div class="card">

<h2>Add Casting</h2>

<br>

<?php if($success!=""){ ?>

<p style="color:#4ade80;">

<?php echo $success; ?>

</p>

<br>

<?php } ?>

<form
method="POST"
enctype="multipart/form-data">

<input
type="text"
name="title"
placeholder="Casting Title"
required>

<input
type="text"
name="category"
placeholder="Category"
required>

<select
name="isfree">

<option value="yes">
Free
</option>

<option value="no">
Paid
</option>

</select>

<input
type="number"
name="amount"
placeholder="Amount">

<input
type="file"
name="image"
id="imageInput"
accept="image/*"
onchange="ImageCrop.open(this,'croppedImageData')"
required>

<input type="hidden" name="cropped_image" id="croppedImageData">

<textarea
name="description"
placeholder="Casting Description"></textarea>

<button
type="submit"
name="add_casting">

Add Casting

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