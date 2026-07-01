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

$series =
$pdo->query(

"SELECT *
FROM zhatpat
ORDER BY title ASC"

)->fetchAll();

$success = "";

if(isset($_POST['add_video'])){

    $zhatpat_id =
    intval($_POST['zhatpat_id']);

    $videolink = "";

    if(isset($_FILES['video']) &&
       $_FILES['video']['error'] == 0){

        $file_name =
        time().'_'.
        $_FILES['video']['name'];

        move_uploaded_file(

            $_FILES['video']['tmp_name'],

            "../app/uploads/zhatpat/".$file_name
        );

        $videolink =
        "uploads/zhatpat/".$file_name;
    }

    $stmt =
    $pdo->prepare(

    "INSERT INTO zhatpat_videos

    (
    zhatpat_id,
    videolink
    )

    VALUES

    (
    ?,
    ?
    )"

    );

    $stmt->execute([

        $zhatpat_id,
        $videolink
    ]);

    $success =
    "Episode added";
}
?>

<!DOCTYPE html>
<html>
<head>

<title>Add Episode</title>

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
    max-width:700px;
}

select,
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
    font-weight:bold;
}

</style>

</head>
<body>

<?php include 'nav2.php'; ?>

<div class="main">

<div class="card">

<h2>Add Episode</h2>

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

<select
name="zhatpat_id"
required>

<option value="">
Select Series
</option>

<?php foreach($series as $s){ ?>

<option
value="<?php echo $s['id']; ?>">

<?php echo $s['title']; ?>

</option>

<?php } ?>

</select>

<input
type="file"
name="video"
required>

<button
type="submit"
name="add_video">

Upload Episode

</button>

</form>

</div>

</div>

</body>
</html>