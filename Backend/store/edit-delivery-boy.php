<?php

session_start();

require_once "db.php";
require_once "../includes/image_upload.php";

if(!isset($_SESSION["seller_id"])){

    header("Location:index.php");
    exit;
}

$seller_id = intval($_SESSION["seller_id"]);

$id = intval($_GET["id"] ?? 0);

$stmt = $pdo->prepare("
    SELECT * FROM delivery_boys
    WHERE id=? AND seller_id=?
    LIMIT 1
");

$stmt->execute([$id, $seller_id]);

$boy = $stmt->fetch();

if(!$boy){

    header("Location:all-delivery-boys.php");
    exit;
}

$success = "";
$error = "";

if(isset($_POST["save"])){

    $name = trim($_POST["name"]);
    $phone = trim($_POST["phone"]);
    $email = trim($_POST["email"]);
    $vehicle_type = trim($_POST["vehicle_type"]);
    $vehicle_number = trim($_POST["vehicle_number"]);
    $is_active = intval($_POST["is_active"]);

    $dir = "../app/uploads/delivery";
    $allowedExts = ['jpg','jpeg','png','webp'];
    $uploadError = "";

    $profileFile = handleCroppedOrRawUpload('cropped_profile', 'profile', $dir, $allowedExts, $uploadError);
    $profile = $profileFile ? "uploads/delivery/".$profileFile : $boy["profile_photo"];

    $aadhaarFile = handleCroppedOrRawUpload('cropped_aadhaar', 'aadhaar', $dir, $allowedExts, $uploadError);
    $aadhaar = $aadhaarFile ? "uploads/delivery/".$aadhaarFile : $boy["aadhaar_photo"];

    $panFile = handleCroppedOrRawUpload('cropped_pan', 'pan', $dir, $allowedExts, $uploadError);
    $pan = $panFile ? "uploads/delivery/".$panFile : $boy["pan_photo"];

    $update = $pdo->prepare("
        UPDATE delivery_boys
        SET
            name=?,
            phone=?,
            email=?,
            vehicle_type=?,
            vehicle_number=?,
            profile_photo=?,
            aadhaar_photo=?,
            pan_photo=?,
            is_active=?
        WHERE id=? AND seller_id=?
    ");

    $run = $update->execute([
        $name,
        $phone,
        $email,
        $vehicle_type,
        $vehicle_number,
        $profile,
        $aadhaar,
        $pan,
        $is_active,
        $id,
        $seller_id
    ]);

    if($run){
        header("Location:all-delivery-boys.php");
        exit;
    }

    $error = "Update Failed";
}

?>

<!DOCTYPE html>
<html>
<head>

<title>Edit Delivery Boy</title>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.6.2/cropper.min.css">
<link rel="stylesheet" href="../assets/css/image-crop.css">
<script src="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.6.2/cropper.min.js"></script>
<script src="../assets/js/image-crop.js"></script>

<style>

body{
    background:#0f172a;
    color:white;
    font-family:Inter;
}

.main{
    margin-left:240px;
    padding:30px;
}

.card{
    max-width:850px;
    background:#111827;
    padding:28px;
    border-radius:24px;
}

.group{
    margin-bottom:18px;
}

label{
    display:block;
    margin-bottom:8px;
}

input,
select{
    width:100%;
    height:54px;
    background:#1e293b;
    border:none;
    color:white;
    padding:0 15px;
    border-radius:14px;
}

img{
    width:120px;
    height:120px;
    border-radius:18px;
    object-fit:cover;
    margin-bottom:12px;
}

button{
    width:100%;
    height:56px;
    background:linear-gradient(135deg,#06b6d4,#7c3aed);
    border:none;
    color:white;
    border-radius:18px;
}

@media(max-width:900px){

    .main{
        margin-left:0;
        padding:80px 14px;
    }

}

</style>

</head>
<body>

<?php include "nav.php"; ?>

<div class="main">

<div class="card">

<h2>Edit Delivery Boy</h2>

<br>

<?php if($error != ""){ ?>
<p style="color:#f87171;"><?php echo $error; ?></p>
<br>
<?php } ?>

<form method="POST" enctype="multipart/form-data">

<div class="group">
<label>Name</label>
<input name="name" value="<?=htmlspecialchars($boy["name"])?>">
</div>

<div class="group">
<label>Phone</label>
<input name="phone" value="<?=htmlspecialchars($boy["phone"])?>">
</div>

<div class="group">
<label>Email</label>
<input name="email" value="<?=htmlspecialchars($boy["email"])?>">
</div>

<div class="group">
<label>Vehicle Type</label>
<input name="vehicle_type" value="<?=htmlspecialchars($boy["vehicle_type"])?>">
</div>

<div class="group">
<label>Vehicle Number</label>
<input name="vehicle_number" value="<?=htmlspecialchars($boy["vehicle_number"])?>">
</div>

<div class="group">
<label>Profile Photo</label>
<img src="../app/<?= $boy["profile_photo"] ?>">
<input type="file" name="profile" id="profileInput" accept="image/*" onchange="ImageCrop.open(this,'croppedProfileData')">
<input type="hidden" name="cropped_profile" id="croppedProfileData">
</div>

<div class="group">
<label>Aadhaar</label>
<input type="file" name="aadhaar" id="aadhaarInput" accept="image/*" onchange="ImageCrop.open(this,'croppedAadhaarData')">
<input type="hidden" name="cropped_aadhaar" id="croppedAadhaarData">
</div>

<div class="group">
<label>PAN</label>
<input type="file" name="pan" id="panInput" accept="image/*" onchange="ImageCrop.open(this,'croppedPanData')">
<input type="hidden" name="cropped_pan" id="croppedPanData">
</div>

<div class="group">
<label>Status</label>
<select name="is_active">
<option value="1" <?= $boy["is_active"]?"selected":"" ?>>Active</option>
<option value="0" <?= !$boy["is_active"]?"selected":"" ?>>Inactive</option>
</select>
</div>

<button name="save">Update Delivery Boy</button>

</form>

</div>

</div>

</body>
</html>
