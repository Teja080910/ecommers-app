<?php
session_start();

require_once 'db.php';
require_once '../includes/image_upload.php';

/* LOGIN CHECK */

if(!isset($_SESSION['admin_id'])){

    header("Location:index.php");
    exit;
}

/* CREATE FOLDER */

if(!is_dir("../app/uploads/onboarding")){

    mkdir(
        "../app/uploads/onboarding",
        0777,
        true
    );
}

$success = "";
$error = "";

/* DELETE BANNER */

if(isset($_GET['delete'])){

    $delete_id =
    intval($_GET['delete']);

    $get =
    $pdo->prepare(

    "SELECT image
    FROM onboarding_banners
    WHERE id=?"

    );

    $get->execute([
    $delete_id
    ]);

    $banner =
    $get->fetch();

    if($banner){

        $path =
        "../app/" .
        $banner['image'];

        if(file_exists($path)){

            unlink($path);
        }

        $delete =
        $pdo->prepare(

        "DELETE FROM onboarding_banners
        WHERE id=?"

        );

        $delete->execute([
        $delete_id
        ]);

        header(
        "Location:app-settings-onbording.php"
        );

        exit;
    }
}

/* ADD BANNER */

if(isset($_POST['add_banner'])){

    $title =
    trim($_POST['title']);

    $image = "";

    /* IMAGE */

    $uploadError = "";

    $imageFile = handleCroppedOrRawUpload(
        'cropped_image',
        'image',
        "../app/uploads/onboarding",
        ['jpg','jpeg','png','webp'],
        $uploadError
    );

    if($uploadError != ""){

        $error = $uploadError;

    }else if($imageFile){

        $image =
        "uploads/onboarding/".$imageFile;

    }else{

        $error =
        "Please upload image";
    }

    /* INSERT */

    if($error == ""){

        $stmt =
        $pdo->prepare(

        "INSERT INTO onboarding_banners

        (
        title,
        image
        )

        VALUES

        (
        ?,
        ?
        )"

        );

        $insert =
        $stmt->execute([

            $title,
            $image
        ]);

        if($insert){

            $success =
            "Onboarding banner added successfully";

        }else{

            $error =
            "Failed to add banner";
        }
    }
}

/* FETCH BANNERS */

$stmt =
$pdo->prepare(

"SELECT *
FROM onboarding_banners
ORDER BY id DESC"

);

$stmt->execute();

$banners =
$stmt->fetchAll();

?>

<!DOCTYPE html>
<html lang="en">
<head>

<meta charset="UTF-8">

<meta name="viewport"
content="width=device-width,
initial-scale=1.0">

<title>
Onboarding Settings
</title>

<link rel="stylesheet"
href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.6.2/cropper.min.css">

<link rel="stylesheet" href="../assets/css/image-crop.css">

<script src="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.6.2/cropper.min.js"></script>

<script src="../assets/js/image-crop.js"></script>

<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap"
rel="stylesheet">

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

/* MAIN */

.main-content{
    margin-left:240px;
    padding:28px;
}

/* GRID */

.page-grid{
    display:grid;
    grid-template-columns:
    420px 1fr;
    gap:22px;
}

/* CARD */

.card{
    background:#111827;
    border-radius:28px;
    padding:28px;
}

/* HEADER */

.page-title{
    font-size:26px;
    font-weight:700;
    margin-bottom:6px;
}

.page-sub{
    font-size:13px;
    color:#94a3b8;
    margin-bottom:28px;
}

/* ALERT */

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
    background:#ef444420;
    color:#f87171;
}

/* INPUT */

.input-box{
    margin-bottom:20px;
}

.input-box label{
    display:block;
    margin-bottom:8px;
    font-size:13px;
    color:#cbd5e1;
}

.input-box input{
    width:100%;
    height:55px;
    border:none;
    outline:none;
    background:#1e293b;
    border-radius:16px;
    padding:0 18px;
    color:#fff;
    font-size:14px;
}

.input-box input[type="file"]{
    padding:15px;
}

/* BUTTON */

.submit-btn{
    width:100%;
    height:58px;
    border:none;
    border-radius:18px;
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

/* TABLE */

.banner-table{
    overflow:hidden;
    border-radius:22px;
}

/* HEAD */

.table-head{
    display:grid;

    grid-template-columns:

    90px
    1.5fr
    140px
    120px;

    gap:14px;

    padding:18px 20px;

    background:#1e293b;

    font-size:13px;
    font-weight:600;
}

/* ROW */

.table-row{
    display:grid;

    grid-template-columns:

    90px
    1.5fr
    140px
    120px;

    gap:14px;

    align-items:center;

    padding:18px 20px;

    border-bottom:
    1px solid rgba(255,255,255,0.05);
}

/* IMAGE */

.banner-image{
    width:120px;
    height:70px;
    border-radius:14px;
    overflow:hidden;
    background:#1e293b;
}

.banner-image img{
    width:100%;
    height:100%;
    object-fit:cover;
}

/* TEXT */

.banner-id{
    font-size:15px;
    font-weight:700;
    color:#22d3ee;
}

.banner-title{
    font-size:14px;
    font-weight:600;
}

/* ACTION */

.action-btn{
    width:42px;
    height:42px;
    border-radius:12px;
    display:flex;
    align-items:center;
    justify-content:center;
    background:#ef444420;
    color:#f87171;
    text-decoration:none;
    transition:.3s;
}

.action-btn:hover{
    background:#ef4444;
    color:#fff;
}

/* EMPTY */

.empty-box{
    padding:70px 20px;
    text-align:center;
}

.empty-box i{
    font-size:60px;
    color:#475569;
    margin-bottom:15px;
}

.empty-box h2{
    margin-bottom:6px;
}

.empty-box p{
    color:#94a3b8;
    font-size:13px;
}

/* RESPONSIVE */

@media(max-width:1100px){

    .page-grid{
        grid-template-columns:1fr;
    }
}

@media(max-width:900px){

    .main-content{
        margin-left:0;
        padding:85px 15px 20px;
    }

    .banner-table{
        overflow-x:auto;
    }

    .table-head,
    .table-row{
        min-width:650px;
    }
}

</style>

</head>
<body>

<?php include 'nav.php'; ?>

<div class="main-content">

<div class="page-grid">

    <!-- LEFT -->

    <div class="card">

        <div class="page-title">

            Onboarding Banners

        </div>

        <div class="page-sub">

            Add onboarding slider banners
            for mobile app

        </div>

        <!-- ALERTS -->

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

        <!-- FORM -->

        <form
        method="POST"
        enctype="multipart/form-data">

            <!-- TITLE -->

            <div class="input-box">

                <label>
                    Banner Title
                </label>

                <input

                type="text"

                name="title"

                placeholder="Enter banner title"

                required>

            </div>

            <!-- IMAGE -->

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

                required>

                <input type="hidden" name="cropped_image" id="croppedImageData">

            </div>

            <!-- BUTTON -->

            <button
            type="submit"
            name="add_banner"
            class="submit-btn">

                <i class="fa-solid fa-plus"></i>

                Add Banner

            </button>

        </form>

    </div>

    <!-- RIGHT -->

    <div class="card">

        <div class="page-title">

            All Banners

        </div>

        <div class="page-sub">

            Manage onboarding banners

        </div>

        <?php if(count($banners) > 0){ ?>

        <div class="banner-table">

            <!-- HEAD -->

            <div class="table-head">

                <div>
                    ID
                </div>

                <div>
                    Title
                </div>

                <div>
                    Image
                </div>

                <div>
                    Action
                </div>

            </div>

            <!-- ROWS -->

            <?php foreach($banners as $banner){ ?>

            <div class="table-row">

                <!-- ID -->

                <div class="banner-id">

                    #<?php echo $banner['id']; ?>

                </div>

                <!-- TITLE -->

                <div class="banner-title">

                    <?php echo htmlspecialchars($banner['title']); ?>

                </div>

                <!-- IMAGE -->

                <div class="banner-image">

                    <img

                    src="../app/<?php echo $banner['image']; ?>"

                    alt="">

                </div>

                <!-- ACTION -->

                <div>

                    <a

                    href="app-settings-onbording.php?delete=<?php echo $banner['id']; ?>"

                    class="action-btn"

                    onclick="
                    return confirm(
                    'Delete this banner?'
                    )
                    ">

                        <i class="fa fa-trash"></i>

                    </a>

                </div>

            </div>

            <?php } ?>

        </div>

        <?php }else{ ?>

        <div class="empty-box">

            <i class="fa-solid fa-image"></i>

            <h2>
                No Banners Found
            </h2>

            <p>
                No onboarding banners added
            </p>

        </div>

        <?php } ?>

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

</body>
</html>