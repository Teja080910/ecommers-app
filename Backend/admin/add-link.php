<?php
session_start();

require_once 'db.php';

/* LOGIN CHECK */

if(!isset($_SESSION['admin_id'])){

    header("Location:index.php");
    exit;
}

/* CREATE FOLDER */

if(!is_dir("../app/uploads")){

    mkdir(
        "../app/uploads",
        0777,
        true
    );
}

$success = "";
$error = "";

/* ADD VIDEO */

if(isset($_POST['add_video'])){

    $filelink = "";
    $filesize = "";

    if(isset($_FILES['video']) &&
       $_FILES['video']['error'] == 0){

        /* MAX 2GB */

        $max_size =
        2 * 1024 * 1024 * 1024;

        if($_FILES['video']['size'] > $max_size){

            $error =
            "Maximum upload size is 2GB";

        }else{

            $ext =
            strtolower(

                pathinfo(

                    $_FILES['video']['name'],
                    PATHINFO_EXTENSION
                )
            );

            $allowed = [

                'mp4',
                'mkv',
                'avi',
                'mov',
                'webm'
            ];

            if(in_array($ext,$allowed)){

                $file_name =
                time().'_'.
                basename(
                $_FILES['video']['name']
                );

                $upload_path =
                "../app/uploads/".
                $file_name;

                if(move_uploaded_file(

                    $_FILES['video']['tmp_name'],
                    $upload_path

                )){

                    /* FULL URL */

                    $base_url =
                    (
                        isset($_SERVER['HTTPS']) &&
                        $_SERVER['HTTPS'] === 'on'
                    ? "https://"
                    : "http://"
                    ) .
                    $_SERVER['HTTP_HOST'];

                    /* CHANGE admin IF NEEDED */

                    $folder =
                    dirname(
                    $_SERVER['PHP_SELF']
                    );

                    $folder =
                    str_replace(
                    "\\",
                    "/",
                    $folder
                    );

                    $folder =
                    rtrim(
                    dirname($folder),
                    "/"
                    );

                    $filelink =
                    $base_url .
                    $folder .
                    "/app/uploads/" .
                    $file_name;

                    /* FILE SIZE */

                    $size =
                    $_FILES['video']['size'];

                    if($size >= 1073741824){

                        $filesize =
                        round(
                        $size / 1073741824,
                        2
                        ) . " GB";

                    }else{

                        $filesize =
                        round(
                        $size / 1048576,
                        2
                        ) . " MB";
                    }

                    /* INSERT */

                    $stmt =
                    $pdo->prepare(

                    "INSERT INTO movies_files

                    (
                    filelink,
                    filesize
                    )

                    VALUES

                    (
                    ?,
                    ?
                    )"

                    );

                    $insert =
                    $stmt->execute([

                        $filelink,
                        $filesize
                    ]);

                    if($insert){

                        $success =
                        "Video uploaded successfully";

                    }else{

                        $error =
                        "Database insert failed";
                    }

                }else{

                    $error =
                    "Upload failed";
                }

            }else{

                $error =
                "Invalid video format";
            }
        }

    }else{

        $error =
        "Please select video";
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
Add Video Link
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
    max-width:750px;
}

/* TITLE */

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
    #06b6d4,
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

    <div class="page-title">

        Upload Video

    </div>

    <div class="page-sub">

        Upload movies upto 2GB

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

    <div class="info-box">

        <p>

            • Maximum upload size: 2GB

            <br><br>

            • Supported formats:
            MP4, MKV, AVI, MOV, WEBM

            <br><br>

            • Video URL and file size
            automatically saved

        </p>

    </div>

    <form
    method="POST"
    enctype="multipart/form-data">

        <div class="input-box">

            <label>
                Select Video
            </label>

            <input
            type="file"
            name="video"
            accept="video/*"
            required>

        </div>

        <button
        type="submit"
        name="add_video"
        class="submit-btn">

            <i class="fa-solid fa-upload"></i>

            Upload Video

        </button>

    </form>

</div>

</div>

</body>
</html>