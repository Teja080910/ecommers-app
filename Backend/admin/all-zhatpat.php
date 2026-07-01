<?php
session_start();

require_once 'db.php';

if(!isset($_SESSION['admin_id'])){

    header("Location:index.php");
    exit;
}

/* DELETE */

if(isset($_GET['delete'])){

    $id =
    intval($_GET['delete']);

    $get =
    $pdo->prepare(

    "SELECT verticalposter
    FROM zhatpat
    WHERE id=?"

    );

    $get->execute([$id]);

    $series =
    $get->fetch();

    if($series){

        $path =
        "../app/".
        $series['verticalposter'];

        if(file_exists($path)){

            unlink($path);
        }
    }

    $delete =
    $pdo->prepare(

    "DELETE FROM zhatpat
    WHERE id=?"

    );

    $delete->execute([$id]);

    header(
    "Location:all-zhatpat.php"
    );

    exit;
}

$series =
$pdo->query(

"SELECT *
FROM zhatpat
ORDER BY id DESC"

)->fetchAll();

?>

<!DOCTYPE html>
<html>
<head>

<title>All Zhatpat</title>

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
    repeat(auto-fill,minmax(240px,1fr));
    gap:20px;
}

.card{
    background:#111827;
    border-radius:20px;
    overflow:hidden;
}

.card img{
    width:100%;
    height:330px;
    object-fit:cover;
}

.content{
    padding:18px;
}

h3{
    margin-bottom:10px;
}

.btn{
    display:inline-block;
    padding:10px 18px;
    border-radius:12px;
    text-decoration:none;
    margin-top:10px;
}

.delete{
    background:#ef444420;
    color:#f87171;
}

</style>

</head>
<body>

<?php include 'nav2.php'; ?>

<div class="main">

<div class="grid">

<?php foreach($series as $row){ ?>

<div class="card">

<img
src="../app/<?php echo $row['verticalposter']; ?>">

<div class="content">

<h3>

<?php echo $row['title']; ?>

</h3>

<p>

Episodes:
<?php echo $row['no_of_episode']; ?>

</p>

<br>

<a

href="all-zhatpat.php?delete=<?php echo $row['id']; ?>"

class="btn delete"

onclick="
return confirm(
'Delete series?'
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