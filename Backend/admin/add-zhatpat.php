<?php
session_start();

require_once 'db.php';

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

    if(isset($_FILES['verticalposter']) &&
       $_FILES['verticalposter']['error'] == 0){

        $file_name =
        time().'_'.
        $_FILES['verticalposter']['name'];

        move_uploaded_file(

            $_FILES['verticalposter']['tmp_name'],

            "../app/uploads/zhatpat/".$file_name
        );

        $verticalposter =
        "uploads/zhatpat/".$file_name;
    }

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
?>

<!DOCTYPE html>
<html>
<head>

<title>Add Zhatpat</title>

<link rel="stylesheet"
href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">

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
required>

<button
type="submit"
name="add_zhatpat">

Add Series

</button>

</form>

</div>

</div>

</body>
</html>