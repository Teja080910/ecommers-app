<?php
session_start();

require_once 'db.php';
require_once '../includes/image_upload.php';

if(!isset($_SESSION['admin_id'])){

    header("Location:index.php");
    exit;
}

if(!is_dir("../app/uploads/zhatpat")){

    mkdir(
        "../app/uploads/zhatpat",
        0777,
        true
    );
}

$success = "";
$error = "";

if(isset($_POST['add_zhatpat'])){

    $title =
    trim($_POST['title']);

    $no_of_episode =
    intval($_POST['no_of_episode']);

    $verticalposter = "";

    $uploadError = "";

    $verticalposterFile = handleCroppedOrRawUpload(
        'cropped_verticalposter',
        'verticalposter',
        "../app/uploads/zhatpat",
        ['jpg','jpeg','png','webp'],
        $uploadError
    );

    if($uploadError != ""){

        $error = $uploadError;

    }else if($verticalposterFile){

        $verticalposter =
        "uploads/zhatpat/".$verticalposterFile;
    }

    if(empty($error)){

    $stmt =
    $pdo->prepare(

    "INSERT INTO zhatpat

    (
    title,
    no_of_episode,
    verticalposter
    )

    VALUES

    (
    ?,
    ?,
    ?
    )"

    );

    $insert =
    $stmt->execute([

        $title,
        $no_of_episode,
        $verticalposter
    ]);

    if($insert){

        $success =
        "Series added successfully";

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

<title>Add Zhatpat</title>

<link rel="stylesheet"
href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.6.2/cropper.min.css">

<link rel="stylesheet" href="../assets/css/image-crop.css">

<script src="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.6.2/cropper.min.js"></script>

<script src="../assets/js/image-crop.js"></script>

<style>

body{
    background:#0f172a;
    font-family:Arial;
    color:#fff;
}

.main{
    margin-left:240px;
    padding:30px;
}

.card{
    background:#111827;
    padding:25px;
    border-radius:20px;
    max-width:700px;
}

input{
    width:100%;
    height:55px;
    border:none;
    border-radius:14px;
    background:#1e293b;
    color:#fff;
    padding:0 15px;
    margin-bottom:18px;
}

button{
    width:100%;
    height:55px;
    border:none;
    border-radius:14px;
    background:#7c3aed;
    color:#fff;
    font-size:15px;
    font-weight:bold;
    cursor:pointer;
}

.alert{
    padding:14px;
    border-radius:12px;
    margin-bottom:18px;
}

.success{
    background:#16a34a20;
    color:#4ade80;
}

.error{
    background:#ef444420;
    color:#f87171;
}

</style>

</head>
<body>

<?php include 'nav2.php'; ?>

<div class="main">

<div class="card">

<h2>Add Zhatpat</h2>

<br>

<?php if($success!=""){ ?>

<div class="alert success">

<?php echo $success; ?>

</div>

<?php } ?>

<?php if($error!=""){ ?>

<div class="alert error">

<?php echo $error; ?>

</div>

<?php } ?>

<form
method="POST"
enctype="multipart/form-data">

<input
type="text"
name="title"
placeholder="Series Title"
required>

<input
type="number"
name="no_of_episode"
placeholder="No of Episodes"
required>

<input
type="file"
name="verticalposter"
id="verticalposterInput"
accept="image/*"
onchange="ImageCrop.open(this,'croppedVerticalposterData')"
required>

<input type="hidden" name="cropped_verticalposter" id="croppedVerticalposterData">

<button
type="submit"
name="add_zhatpat">

Add Series

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