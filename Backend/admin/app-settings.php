<?php
session_start();

require_once 'db.php';
require_once '../includes/image_upload.php';

/* Login Check */

if(!isset($_SESSION['admin_id'])){

    header("Location:index.php");
    exit;
}

$success = "";
$error = "";

/* Upload Banner */

if(isset($_POST['add_banner'])){

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

        $db_image = "uploads/".$imageFile;

        $insert = $pdo->prepare("INSERT INTO banners(image) VALUES(?)");

        $run = $insert->execute([$db_image]);

        if($run){

            $success = "Banner Uploaded Successfully";

        }else{

            $error = "Database Insert Failed";

        }

    }else{

        $error = "Please Select Banner Image";

    }

}

/* Delete Banner */

if(isset($_GET['delete'])){

    $id = intval($_GET['delete']);

    $stmt = $pdo->prepare("SELECT * FROM banners WHERE id=?");

    $stmt->execute([$id]);

    $banner = $stmt->fetch();

    if($banner){

        $file = "../app/".$banner['image'];

        if(file_exists($file)){

            unlink($file);

        }

        $delete = $pdo->prepare("DELETE FROM banners WHERE id=?");

        $delete->execute([$id]);

    }

    header("Location:app-settings.php");
    exit;
}

/* Fetch Banners */

$query = $pdo->query("SELECT * FROM banners ORDER BY id DESC");

$banners = $query->fetchAll();

?>

<!DOCTYPE html>
<html lang="en">
<head>

<meta charset="UTF-8">

<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>App Settings</title>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.6.2/cropper.min.css">

<link rel="stylesheet" href="../assets/css/image-crop.css">

<script src="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.6.2/cropper.min.js"></script>

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

/* Main */

.main-content{
    margin-left:240px;
    padding:28px;
}

/* Header */

.page-header{
    margin-bottom:25px;
}

.page-header h1{
    font-size:24px;
    margin-bottom:5px;
}

.page-header p{
    color:#94a3b8;
    font-size:13px;
}

/* Upload Box */

.upload-box{
    width:100%;
    max-width:650px;
    background:#111827;
    border-radius:24px;
    padding:28px;
    margin-bottom:28px;
}

/* Alerts */

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

/* Inputs */

.input-box{
    margin-bottom:20px;
}

.input-box label{
    display:block;
    margin-bottom:8px;
    font-size:13px;
    color:#cbd5e1;
    font-weight:500;
}

.input-box input{
    width:100%;
    border:none;
    outline:none;
    background:#1e293b;
    border-radius:16px;
    padding:15px;
    color:#fff;
    font-size:14px;
}

/* Button */

.submit-btn{
    width:100%;
    height:56px;
    border:none;
    border-radius:16px;
    background:linear-gradient(135deg,#06b6d4,#7c3aed);
    color:#fff;
    font-size:14px;
    font-weight:600;
    cursor:pointer;
    transition:.3s;
}

.submit-btn:hover{
    transform:translateY(-2px);
}

/* Banner Grid */

.banner-grid{
    display:grid;
    grid-template-columns:repeat(auto-fit,minmax(280px,1fr));
    gap:22px;
}

/* Card */

.banner-card{
    background:#111827;
    border-radius:22px;
    overflow:hidden;
    border:1px solid rgba(255,255,255,0.05);
    transition:.3s;
}

.banner-card:hover{
    transform:translateY(-4px);
}

/* Image */

.banner-image{
    width:100%;
    height:190px;
    background:#1e293b;
}

.banner-image img{
    width:100%;
    height:100%;
    object-fit:cover;
}

/* Footer */

.banner-footer{
    padding:16px;
    display:flex;
    justify-content:space-between;
    align-items:center;
}

/* Text */

.banner-name{
    font-size:13px;
    color:#cbd5e1;
    overflow:hidden;
    text-overflow:ellipsis;
    white-space:nowrap;
    max-width:180px;
}

/* Delete */

.delete-btn{
    width:42px;
    height:42px;
    border-radius:12px;
    background:#ef444420;
    color:#f87171;
    display:flex;
    align-items:center;
    justify-content:center;
    text-decoration:none;
    transition:.3s;
}

.delete-btn:hover{
    background:#ef4444;
    color:#fff;
}

/* Empty */

.empty-box{
    background:#111827;
    border-radius:22px;
    padding:70px 20px;
    text-align:center;
}

.empty-box i{
    font-size:55px;
    color:#475569;
    margin-bottom:14px;
}

.empty-box h2{
    font-size:22px;
    margin-bottom:5px;
}

.empty-box p{
    color:#94a3b8;
    font-size:13px;
}

/* Responsive */

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

    <!-- Header -->

    <div class="page-header">

        <h1>App Settings</h1>

        <p>
            Upload and manage app home banners
        </p>

    </div>

    <!-- Upload Form -->

    <div class="upload-box">

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

        <form method="POST" enctype="multipart/form-data">

            <div class="input-box">

                <label>
                    Banner Image
                </label>

                <input
                    type="file"
                    name="image"
                    id="imageInput"
                    accept="image/*"
                    onchange="ImageCrop.open(this,'croppedImageData')"
                    required
                >

                <input type="hidden" name="cropped_image" id="croppedImageData">

            </div>

            <button 
                type="submit"
                name="add_banner"
                class="submit-btn"
            >

                <i class="fa-solid fa-cloud-arrow-up"></i>
                Upload Banner

            </button>

        </form>

    </div>

    <!-- Banner List -->

    <?php if(count($banners) > 0){ ?>

    <div class="banner-grid">

        <?php foreach($banners as $banner){ ?>

        <div class="banner-card">

            <!-- Image -->

            <div class="banner-image">

                <img 
                    src="../app/<?php echo $banner['image']; ?>"
                >

            </div>

            <!-- Footer -->

            <div class="banner-footer">

                <div class="banner-name">

                    <?php echo htmlspecialchars($banner['image']); ?>

                </div>

                <a 
                    href="app-settings.php?delete=<?php echo $banner['id']; ?>"
                    class="delete-btn"
                    onclick="return confirm('Delete this banner?')"
                >

                    <i class="fa-solid fa-trash"></i>

                </a>

            </div>

        </div>

        <?php } ?>

    </div>

    <?php }else{ ?>

    <div class="empty-box">

        <i class="fa-solid fa-image"></i>

        <h2>No Banners Found</h2>

        <p>
            Upload your first banner image
        </p>

    </div>

    <?php } ?>

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