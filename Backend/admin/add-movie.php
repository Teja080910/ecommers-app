<?php
session_start();

require_once 'db.php';
require_once '../includes/image_upload.php';

/* LOGIN CHECK */

if(!isset($_SESSION['admin_id'])){

    header("Location:index.php");
    exit;
}

/* CREATE UPLOAD FOLDER */

if(!is_dir("../app/uploads/movies")){

    mkdir(
        "../app/uploads/movies",
        0777,
        true
    );
}

/* FETCH CATEGORIES */

$categories =
$pdo->query(

"SELECT *
FROM ottcategory
ORDER BY name ASC"

)->fetchAll();

/* FETCH CAST */

$casts =
$pdo->query(

"SELECT *
FROM cast
ORDER BY name ASC"

)->fetchAll();

$success = "";
$error = "";

/* ADD MOVIE */

if(isset($_POST['add_movie'])){

    $cat_id =
    trim($_POST['cat_id']);

    $title =
    trim($_POST['title']);

    $about_html =
    trim($_POST['about_html']);

    $file =
    trim($_POST['file']);

    $filesize =
    trim($_POST['filesize']);

    $isfree =
    $_POST['isfree'];

    $castid =
    isset($_POST['castid'])
    ? implode(",",$_POST['castid'])
    : "";

    $mainposter = "";
    $verticalposter = "";

    /* MAIN POSTER */

    $uploadError = "";

    $mainposterFile = handleCroppedOrRawUpload(
        'cropped_mainposter',
        'mainposter',
        "../app/uploads/movies",
        ['jpg','jpeg','png','webp'],
        $uploadError
    );

    if($uploadError != ""){

        $error = $uploadError;

    }else if($mainposterFile){

        $mainposter =
        "uploads/movies/".$mainposterFile;
    }

    /* VERTICAL POSTER */

    if(empty($error)){

        $verticalposterFile = handleCroppedOrRawUpload(
            'cropped_verticalposter',
            'verticalposter',
            "../app/uploads/movies",
            ['jpg','jpeg','png','webp'],
            $uploadError
        );

        if($uploadError != ""){

            $error = $uploadError;

        }else if($verticalposterFile){

            $verticalposter =
            "uploads/movies/".$verticalposterFile;
        }
    }

    /* INSERT */

    if(empty($error)){

    $stmt =
    $pdo->prepare(

    "INSERT INTO movies

    (
    cat_id,
    title,
    mainposter,
    verticalposter,
    castid,
    about_html,
    file,
    filesize,
    isfree
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
    ?
    )"

    );

    $insert =
    $stmt->execute([

        $cat_id,
        $title,
        $mainposter,
        $verticalposter,
        $castid,
        $about_html,
        $file,
        $filesize,
        $isfree
    ]);

    if($insert){

        $success =
        "Movie added successfully";

    }else{

        $error =
        "Failed to add movie";
    }

    }
}

?>

<!DOCTYPE html>
<html lang="en">
<head>

<meta charset="UTF-8">

<meta name="viewport"
content="width=device-width,
initial-scale=1.0">

<title>
Add Movie
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

.main-content{
    margin-left:240px;
    padding:28px;
}

.page-card{
    background:#111827;
    border-radius:28px;
    padding:28px;
}

.page-title{
    font-size:28px;
    font-weight:700;
    margin-bottom:6px;
}

.page-sub{
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
    background:#ef444420;
    color:#f87171;
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
    font-size:14px;
}

.input-box textarea{
    height:180px;
    resize:none;
}

.full{
    grid-column:1/3;
}

.cast-box{
    background:#1e293b;
    border-radius:18px;
    padding:18px;
    max-height:220px;
    overflow-y:auto;
}

.cast-item{
    display:flex;
    align-items:center;
    gap:12px;
    margin-bottom:12px;
}

.cast-item input{
    width:18px;
    height:18px;
}

.cast-image{
    width:42px;
    height:42px;
    border-radius:50%;
    object-fit:cover;
}

.submit-btn{
    width:100%;
    height:58px;
    border:none;
    border-radius:18px;
    margin-top:24px;
    background:
    linear-gradient(
    135deg,
    #ef4444,
    #7c3aed
    );
    color:#fff;
    font-size:15px;
    font-weight:700;
    cursor:pointer;
}

.submit-btn:hover{
    opacity:.92;
}

@media(max-width:900px){

    .main-content{
        margin-left:0;
        padding:85px 15px 20px;
    }

    .grid{
        grid-template-columns:1fr;
    }

    .full{
        grid-column:auto;
    }
}

</style>

</head>
<body>

<?php include 'nav2.php'; ?>

<div class="main-content">

<div class="page-card">

    <div class="page-title">

        Add Movie

    </div>

    <div class="page-sub">

        Upload OTT movie details

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

            <!-- TITLE -->

            <div class="input-box">

                <label>
                    Movie Title
                </label>

                <input
                type="text"
                name="title"
                required>

            </div>

            <!-- CATEGORY -->

            <div class="input-box">

                <label>
                    Category
                </label>

                <select
                name="cat_id"
                required>

                    <option value="">
                        Select Category
                    </option>

                    <?php foreach($categories as $cat){ ?>

                    <option
                    value="<?php echo $cat['id']; ?>">

                        <?php echo htmlspecialchars($cat['name']); ?>

                    </option>

                    <?php } ?>

                </select>

            </div>

            <!-- FILE -->

            <div class="input-box full">

                <label>
                    Movie File URL
                </label>

                <input
                type="text"
                name="file"
                placeholder="https://domain.com/movie.mkv"
                required>

            </div>

            <!-- FILE SIZE -->

            <div class="input-box">

                <label>
                    File Size
                </label>

                <input
                type="text"
                name="filesize"
                placeholder="1.8 GB"
                required>

            </div>

            <!-- IS FREE -->

            <div class="input-box">

                <label>
                    Is Free
                </label>

                <select
                name="isfree">

                    <option value="yes">
                        Yes
                    </option>

                    <option value="no">
                        No
                    </option>

                </select>

            </div>

            <!-- MAIN POSTER -->

            <div class="input-box">

                <label>
                    Main Poster
                </label>

                <input
                type="file"
                name="mainposter"
                id="mainposterInput"
                accept="image/*"
                onchange="ImageCrop.open(this,'croppedMainposterData')"
                required>

                <input type="hidden" name="cropped_mainposter" id="croppedMainposterData">

            </div>

            <!-- VERTICAL POSTER -->

            <div class="input-box">

                <label>
                    Vertical Poster
                </label>

                <input
                type="file"
                name="verticalposter"
                id="verticalposterInput"
                accept="image/*"
                onchange="ImageCrop.open(this,'croppedVerticalposterData')"
                required>

                <input type="hidden" name="cropped_verticalposter" id="croppedVerticalposterData">

            </div>

            <!-- ABOUT -->

            <div class="input-box full">

                <label>
                    About Movie (HTML)
                </label>

                <textarea
                name="about_html"></textarea>

            </div>

            <!-- CAST -->

            <div class="input-box full">

                <label>
                    Select Cast
                </label>

                <div class="cast-box">

                    <?php foreach($casts as $cast){ ?>

                    <div class="cast-item">

                        <input

                        type="checkbox"

                        name="castid[]"

                        value="<?php echo $cast['id']; ?>">

                        <img

                        src="../app/<?php echo $cast['imagelink']; ?>"

                        class="cast-image">

                        <span>

                            <?php echo htmlspecialchars($cast['name']); ?>

                        </span>

                    </div>

                    <?php } ?>

                </div>

            </div>

        </div>

        <button
        type="submit"
        name="add_movie"
        class="submit-btn">

            <i class="fa-solid fa-plus"></i>

            Add Movie

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