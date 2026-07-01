<?php
session_start();

require_once 'db.php';

/* LOGIN CHECK */

if(!isset($_SESSION['admin_id'])){

    header("Location:index.php");
    exit;
}

/* CREATE FOLDER */

if(!is_dir("../app/uploads/shorts")){

    mkdir(
        "../app/uploads/shorts",
        0777,
        true
    );
}

$success = "";
$error = "";

/* ADD SHORT */

if(isset($_POST['add_short'])){

    $video = "";

    /* CHECK VIDEO */

    if(isset($_FILES['video']) &&
       $_FILES['video']['error'] == 0){

        /* SIZE */

        $max_size =
        20 * 1024 * 1024;

        if($_FILES['video']['size'] > $max_size){

            $error =
            "Video size must be under 20MB";

        }else{

            $ext =
            strtolower(

            pathinfo(

                $_FILES['video']['name'],
                PATHINFO_EXTENSION

            ));

            $allowed = [

                'mp4',
                'mov',
                'avi',
                'mkv',
                'webm'
            ];

            if(in_array($ext,$allowed)){

                $file_name =
                time().'_'.
                $_FILES['video']['name'];

                move_uploaded_file(

                    $_FILES['video']['tmp_name'],

                    "../app/uploads/shorts/".$file_name
                );

                $video =
                "uploads/shorts/".$file_name;

            }else{

                $error =
                "Invalid video format";
            }
        }

    }else{

        $error =
        "Please upload video";
    }

    /* INSERT */

    if($error == ""){

        $stmt =
        $pdo->prepare(

        "INSERT INTO shorts

        (
        video
        )

        VALUES

        (
        ?
        )"

        );

        $insert =
        $stmt->execute([

            $video
        ]);

        if($insert){

            $success =
            "Short video uploaded successfully";

        }else{

            $error =
            "Failed to upload short";
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
Add Shorts
</title>

<link rel="stylesheet"
href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">

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
    max-width:700px;
}

/* HEADER */

.page-title{
    font-size:28px;
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
    display:flex;
    flex-direction:column;
    margin-bottom:20px;
}

.input-box label{
    margin-bottom:8px;
    font-size:13px;
    color:#cbd5e1;
}

.input-box input{
    width:100%;
    border:none;
    outline:none;
    background:#1e293b;
    border-radius:14px;
    padding:16px;
    color:#fff;
    font-size:14px;
}

/* INFO */

.info-box{
    background:#1e293b;
    border-radius:16px;
    padding:16px;
    margin-bottom:22px;
}

.info-box p{
    font-size:13px;
    color:#cbd5e1;
    line-height:1.7;
}

/* BUTTON */

.submit-btn{
    width:100%;
    height:58px;
    border:none;
    border-radius:18px;
    margin-top:10px;
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
    transition:.3s;
}

.submit-btn:hover{
    opacity:.92;
}

/* RESPONSIVE */

@media(max-width:900px){

    .main-content{
        margin-left:0;
        padding:85px 15px 20px;
    }
}

</style>

</head>
<body>

<?php include 'nav2.php'; ?>

<div class="main-content">

<div class="page-card">

    <!-- HEADER -->

    <div class="page-title">

        Add Shorts

    </div>

    <div class="page-sub">

        Upload OTT short videos

    </div>

    <!-- ALERT -->

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

    <!-- INFO -->

    <div class="info-box">

        <p>

            • Maximum upload size: 20MB

            <br><br>

            • Supported formats:
            MP4, MOV, AVI, MKV, WEBM

        </p>

    </div>

    <!-- FORM -->

    <form
    method="POST"
    enctype="multipart/form-data">

        <!-- VIDEO -->

        <div class="input-box">

            <label>
                Upload Short Video
            </label>

            <input
            type="file"
            name="video"
            accept="video/*"
            required>

        </div>

        <!-- BUTTON -->

        <button
        type="submit"
        name="add_short"
        class="submit-btn">

            <i class="fa-solid fa-upload"></i>

            Upload Short

        </button>

    </form>

</div>

</div>

</body>
</html>