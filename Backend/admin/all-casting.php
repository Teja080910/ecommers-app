<?php
session_start();

require_once 'db.php';

if(!isset($_SESSION['admin_id'])){

    header("Location:index.php");
    exit;
}

if(isset($_GET['delete'])){

    $id =
    intval($_GET['delete']);

    $get =
    $pdo->prepare(

    "SELECT image
    FROM casting
    WHERE id=?"

    );

    $get->execute([$id]);

    $casting =
    $get->fetch();

    if($casting){

        $path =
        "../app/".
        $casting['image'];

        if(file_exists($path)){

            unlink($path);
        }
    }

    $delete =
    $pdo->prepare(

    "DELETE FROM casting
    WHERE id=?"

    );

    $delete->execute([$id]);

    header(
    "Location:all-casting.php"
    );

    exit;
}

$casting =
$pdo->query(

"SELECT *
FROM casting
ORDER BY id DESC"

)->fetchAll();

?>

<!DOCTYPE html>
<html>
<head>

<title>All Casting</title>

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

.grid{
    display:grid;
    grid-template-columns:
    repeat(auto-fill,minmax(280px,1fr));
    gap:20px;
}

.card{
    background:#111827;
    border-radius:20px;
    overflow:hidden;
}

.card img{
    width:100%;
    height:320px;
    object-fit:cover;
}

.content{
    padding:18px;
}

.badge{
    display:inline-block;
    padding:8px 14px;
    border-radius:30px;
    margin-top:12px;
}

.free{
    background:#16a34a20;
    color:#4ade80;
}

.paid{
    background:#ef444420;
    color:#f87171;
}

.btn{
    display:inline-block;
    padding:10px 18px;
    border-radius:12px;
    text-decoration:none;
    margin-top:15px;
    background:#ef444420;
    color:#f87171;
}

</style>

</head>
<body>

<?php include 'nav2.php'; ?>

<div class="main">

<div class="grid">

<?php foreach($casting as $c){ ?>

<div class="card">

<img
src="../app/<?php echo $c['image']; ?>">

<div class="content">

<h3>

<?php echo $c['title']; ?>

</h3>

<p>

<?php echo $c['category']; ?>

</p>

<?php if($c['isfree']=="yes"){ ?>

<div class="badge free">

FREE

</div>

<?php }else{ ?>

<div class="badge paid">

₹<?php echo $c['amount']; ?>

</div>

<?php } ?>

<br>

<a

href="all-casting.php?delete=<?php echo $c['id']; ?>"

class="btn"

onclick="
return confirm(
'Delete casting?'
)
">

Delete

</a>

</div>

</div>

<?php } ?>

</div>

</div>

</body>
</html>