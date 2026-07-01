<?php
session_start();

require_once 'db.php';

/* LOGIN CHECK */

if(!isset($_SESSION['admin_id'])){

    header("Location:index.php");
    exit;
}

/* CREATE FOLDER */

if(!is_dir("../app/uploads/cast")){

    mkdir(
        "../app/uploads/cast",
        0777,
        true
    );
}

$success = "";
$error = "";

/* ADD CAST */

if(isset($_POST['add_cast'])){

    $name =
    trim($_POST['name']);

    $imagelink = "";

    /* IMAGE */

    if(isset($_FILES['image']) &&
       $_FILES['image']['error'] == 0){

        $ext =
        strtolower(

        pathinfo(

            $_FILES['image']['name'],
            PATHINFO_EXTENSION

        ));

        $allowed =
        ['jpg','jpeg','png','webp'];

        if(in_array($ext,$allowed)){

            $file_name =
            time().'_'.
            $_FILES['image']['name'];

            move_uploaded_file(

                $_FILES['image']['tmp_name'],

                "../app/uploads/cast/".$file_name
            );

            $imagelink =
            "uploads/cast/".$file_name;

        }else{

            $error =
            "Invalid image format";
        }

    }else{

        $error =
        "Please upload image";
    }

    /* INSERT */

    if($error == ""){

        $stmt =
        $pdo->prepare(

        "INSERT INTO cast

        (
        name,
        imagelink
        )

        VALUES

        (
        ?,
        ?
        )"

        );

        $insert =
        $stmt->execute([

            $name,
            $imagelink
        ]);

        if($insert){

            $success =
            "Cast member added successfully";

        }else{

            $error =
            "Failed to add cast member";
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
Add Cast
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
    padding:14px 16px;
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

        Add Cast

    </div>

    <div class="page-sub">

        Add actors and actresses
        for OTT movies

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

    <!-- FORM -->

    <form
    method="POST"
    enctype="multipart/form-data">

        <!-- NAME -->

        <div class="input-box">

            <label>
                Cast Name
            </label>

            <input
            type="text"
            name="name"
            required>

        </div>

        <!-- IMAGE -->

        <div class="input-box">

            <label>
                Cast Image
            </label>

            <input
            type="file"
            name="image"
            required>

        </div>

        <!-- BUTTON -->

        <button
        type="submit"
        name="add_cast"
        class="submit-btn">

            <i class="fa-solid fa-plus"></i>

            Add Cast Member

        </button>

    </form>

</div>

</div>

</body>
</html>