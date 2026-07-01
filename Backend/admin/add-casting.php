<?php
session_start();

require_once 'db.php';

if(!isset($_SESSION['admin_id'])){

    header("Location:index.php");
    exit;
}

if(!is_dir("../app/uploads/casting")){

    mkdir(
        "../app/uploads/casting",
        0777,
        true
    );
}

$success = "";
$error = "";

if(isset($_POST['add_casting'])){

    $title =
    trim($_POST['title']);

    $category =
    trim($_POST['category']);

    $isfree =
    $_POST['isfree'];

    $amount =
    intval($_POST['amount']);

    $description =
    trim($_POST['description']);

    $image = "";

    if(isset($_FILES['image']) &&
       $_FILES['image']['error'] == 0){

        $file_name =
        time().'_'.
        $_FILES['image']['name'];

        move_uploaded_file(

            $_FILES['image']['tmp_name'],

            "../app/uploads/casting/".$file_name
        );

        $image =
        "uploads/casting/".$file_name;
    }

    $stmt =
    $pdo->prepare(

    "INSERT INTO casting

    (
    title,
    category,
    image,
    isfree,
    amount,
    description
    )

    VALUES

    (
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

        $title,
        $category,
        $image,
        $isfree,
        $amount,
        $description
    ]);

    if($insert){

        $success =
        "Casting added successfully";

    }else{

        $error =
        "Failed";
    }
}
?>

<!DOCTYPE html>
<html>
<head>

<title>Add Casting</title>

<style>

body{
    background:#0f172a;
    color:#fff;
    font-family:Arial;
}

.main{
    margin-left:240px;
    padding:30px;
}

.card{
    background:#111827;
    padding:25px;
    border-radius:20px;
    max-width:800px;
}

input,
select,
textarea{
    width:100%;
    border:none;
    border-radius:14px;
    background:#1e293b;
    color:#fff;
    padding:15px;
    margin-bottom:18px;
}

textarea{
    height:180px;
    resize:none;
}

button{
    width:100%;
    height:55px;
    border:none;
    border-radius:14px;
    background:#7c3aed;
    color:#fff;
    font-weight:bold;
    cursor:pointer;
}

</style>

</head>
<body>

<?php include 'nav2.php'; ?>

<div class="main">

<div class="card">

<h2>Add Casting</h2>

<br>

<?php if($success!=""){ ?>

<p style="color:#4ade80;">

<?php echo $success; ?>

</p>

<br>

<?php } ?>

<form
method="POST"
enctype="multipart/form-data">

<input
type="text"
name="title"
placeholder="Casting Title"
required>

<input
type="text"
name="category"
placeholder="Category"
required>

<select
name="isfree">

<option value="yes">
Free
</option>

<option value="no">
Paid
</option>

</select>

<input
type="number"
name="amount"
placeholder="Amount">

<input
type="file"
name="image"
required>

<textarea
name="description"
placeholder="Casting Description"></textarea>

<button
type="submit"
name="add_casting">

Add Casting

</button>

</form>

</div>

</div>

</body>
</html>