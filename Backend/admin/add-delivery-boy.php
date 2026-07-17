<?php
session_start();

require_once 'db.php';
require_once '../includes/image_upload.php';

if(!isset($_SESSION['admin_id'])){
    header("Location:index.php");
    exit;
}

/* Add Delivery Boy */

if(isset($_POST['add_delivery_boy'])){

    $franchise_id = $_POST['franchise_id'];
    $name = trim($_POST['name']);
    $phone = trim($_POST['phone']);
    $email = trim($_POST['email']);
    $password = password_hash($_POST['password'], PASSWORD_DEFAULT);
    $address = trim($_POST['address']);
    $aadhaar_number = trim($_POST['aadhaar_number']);
    $pan_number = trim($_POST['pan_number']);
    $vehicle_type = trim($_POST['vehicle_type']);
    $vehicle_name = trim($_POST['vehicle_name']);
    $vehicle_number = trim($_POST['vehicle_number']);

    /* Uploads */

    $uploadError = "";
    $uploadDir = "../app/uploads/deliveryboys";
    $allowedExts = ['jpg','jpeg','png','webp'];

    $profile_photo = handleCroppedOrRawUpload('cropped_profile_photo', 'profile_photo', $uploadDir, $allowedExts, $uploadError) ?? "";
    $aadhaar_photo = handleCroppedOrRawUpload('cropped_aadhaar_photo', 'aadhaar_photo', $uploadDir, $allowedExts, $uploadError) ?? "";
    $pan_photo = handleCroppedOrRawUpload('cropped_pan_photo', 'pan_photo', $uploadDir, $allowedExts, $uploadError) ?? "";

    $stmt = $pdo->prepare("
        INSERT INTO delivery_boys
        (
            franchise_id,
            name,
            phone,
            email,
            password,
            address,
            aadhaar_number,
            aadhaar_photo,
            pan_number,
            pan_photo,
            profile_photo,
            vehicle_type,
            vehicle_name,
            vehicle_number
        )
        VALUES
        (
            ?,?,?,?,?,?,?,?,?,?,?,?,?,?
        )
    ");

    $stmt->execute([
        $franchise_id,
        $name,
        $phone,
        $email,
        $password,
        $address,
        $aadhaar_number,
        $aadhaar_photo,
        $pan_number,
        $pan_photo,
        $profile_photo,
        $vehicle_type,
        $vehicle_name,
        $vehicle_number
    ]);

    header("Location:all-delivery-boys.php");
    exit;
}

/* Franchises */

$franchises = $pdo->query("
    SELECT * FROM seller ORDER BY name ASC
")->fetchAll();

?>

<!DOCTYPE html>
<html lang="en">
<head>

<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>Add Delivery Boy</title>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">

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

.main-content{
    margin-left:240px;
    padding:30px;
}

.form-box{
    background:#111827;
    padding:25px;
    border-radius:20px;
}

.form-grid{
    display:grid;
    grid-template-columns:repeat(2,1fr);
    gap:18px;
}

.input-box input,
.input-box select,
.input-box textarea{
    width:100%;
    background:#1e293b;
    border:none;
    outline:none;
    padding:14px;
    border-radius:14px;
    color:#fff;
}

.input-box textarea{
    height:120px;
    resize:none;
}

.submit-btn{
    margin-top:20px;
    width:220px;
    height:50px;
    border:none;
    border-radius:14px;
    background:#06b6d4;
    color:#fff;
    font-weight:bold;
    cursor:pointer;
}

</style>

</head>
<body>

<?php include 'nav.php'; ?>

<div class="main-content">

    <div class="form-box">

        <h2>Add Delivery Boy</h2>

        <br>

        <form method="POST" enctype="multipart/form-data">

            <div class="form-grid">

                <div class="input-box">
                    <select name="franchise_id" required>

                        <option value="">
                            Select seller
                        </option>

                        <?php foreach($franchises as $f){ ?>

                        <option value="<?php echo $f['id']; ?>">

                            <?php echo $f['name']; ?>

                        </option>

                        <?php } ?>

                    </select>
                </div>

                <div class="input-box">
                    <input type="text" name="name" placeholder="Name" required>
                </div>

                <div class="input-box">
                    <input type="text" name="phone" placeholder="Phone" required>
                </div>

                <div class="input-box">
                    <input type="email" name="email" placeholder="Email">
                </div>

                <div class="input-box">
                    <input type="password" name="password" placeholder="Password" required>
                </div>

                <div class="input-box">
                    <input type="text" name="aadhaar_number" placeholder="Aadhaar Number">
                </div>

                <div class="input-box">
                    <input type="text" name="pan_number" placeholder="PAN Number">
                </div>

                <div class="input-box">
                    <input type="text" name="vehicle_type" placeholder="Vehicle Type">
                </div>

                <div class="input-box">
                    <input type="text" name="vehicle_name" placeholder="Vehicle Name">
                </div>

                <div class="input-box">
                    <input type="text" name="vehicle_number" placeholder="Vehicle Number">
                </div>

                <div class="input-box">
                    <input type="file" name="profile_photo" id="profilePhotoInput" accept="image/*" onchange="ImageCrop.open(this,'croppedProfilePhotoData')">
                    <input type="hidden" name="cropped_profile_photo" id="croppedProfilePhotoData">
                </div>

                <div class="input-box">
                    <input type="file" name="aadhaar_photo" id="aadhaarPhotoInput" accept="image/*" onchange="ImageCrop.open(this,'croppedAadhaarPhotoData')">
                    <input type="hidden" name="cropped_aadhaar_photo" id="croppedAadhaarPhotoData">
                </div>

                <div class="input-box">
                    <input type="file" name="pan_photo" id="panPhotoInput" accept="image/*" onchange="ImageCrop.open(this,'croppedPanPhotoData')">
                    <input type="hidden" name="cropped_pan_photo" id="croppedPanPhotoData">
                </div>

                <div class="input-box" style="grid-column:span 2;">
                    <textarea name="address" placeholder="Address"></textarea>
                </div>

            </div>

            <button type="submit" name="add_delivery_boy" class="submit-btn">

                Add Delivery Boy

            </button>

        </form>

    </div>

</div>

<div class="crop-modal" id="cropModal">
    <div class="crop-box">
        <div class="crop-image-wrap"><img id="cropperImage"></div>
        <div class="crop-actions">
            <button type="button" class="crop-skip-btn" onclick="ImageCrop.skip()">Skip Crop</button>
            <button type="button" class="crop-use-btn" onclick="ImageCrop.apply()">Crop &amp; Use</button>
        </div>
    </div>
</div>

</body>
</html>