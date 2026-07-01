<?php
session_start();

require_once 'db.php';

if(!isset($_SESSION['admin_id'])){

    header("Location:index.php");
    exit;
}

$applications =
$pdo->query(

"SELECT

casting_application.*,

casting.title

FROM casting_application

LEFT JOIN casting
ON casting.id =
casting_application.casting_id

ORDER BY casting_application.id DESC"

)->fetchAll();

?>

<!DOCTYPE html>
<html>
<head>

<title>
Casting Applications
</title>

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
    repeat(auto-fill,minmax(340px,1fr));
    gap:20px;
}

.card{
    background:#111827;
    border-radius:20px;
    padding:20px;
}

.photos{
    display:flex;
    flex-wrap:wrap;
    gap:10px;
    margin-top:12px;
}

.photos img{
    width:90px;
    height:90px;
    object-fit:cover;
    border-radius:12px;
}

video{
    width:100%;
    height:220px;
    margin-top:15px;
    border-radius:16px;
    background:#000;
}

.tag{
    display:inline-block;
    padding:8px 14px;
    border-radius:30px;
    background:#1e293b;
    margin-top:10px;
    margin-right:8px;
    font-size:13px;
}

</style>

</head>
<body>

<?php include 'nav2.php'; ?>

<div class="main">

<div class="grid">

<?php foreach($applications as $a){ ?>

<?php

$photos =
$a['photos'] != ""
? explode(",",$a['photos'])
: [];

?>

<div class="card">

<h2>

<?php echo $a['name']; ?>

</h2>

<br>

<p>

Applied For:
<b>

<?php echo $a['title']; ?>

</b>

</p>

<br>

<div class="tag">

Height:
<?php echo $a['height']; ?>

</div>

<div class="tag">

Weight:
<?php echo $a['weight']; ?>

</div>

<br><br>

<p>

<?php echo nl2br($a['workexperience']); ?>

</p>

<div class="photos">

<?php foreach($photos as $p){ ?>

<img
src="../app/<?php echo $p; ?>">

<?php } ?>

</div>

<?php if($a['video']!=""){ ?>

<video controls>

<source
src="../app/<?php echo $a['video']; ?>">

</video>

<?php } ?>

</div>

<?php } ?>

</div>

</div>

</body>
</html>