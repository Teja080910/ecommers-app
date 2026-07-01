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

    "SELECT videolink
    FROM zhatpat_videos
    WHERE id=?"

    );

    $get->execute([$id]);

    $video =
    $get->fetch();

    if($video){

        $path =
        "../app/".
        $video['videolink'];

        if(file_exists($path)){

            unlink($path);
        }
    }

    $delete =
    $pdo->prepare(

    "DELETE FROM zhatpat_videos
    WHERE id=?"

    );

    $delete->execute([$id]);

    header(
    "Location:all-zhatpat-videos.php"
    );

    exit;
}

$videos =
$pdo->query(

"SELECT

zhatpat_videos.*,
zhatpat.title

FROM zhatpat_videos

LEFT JOIN zhatpat
ON zhatpat.id =
zhatpat_videos.zhatpat_id

ORDER BY zhatpat_videos.id DESC"

)->fetchAll();

?>

<!DOCTYPE html>
<html>
<head>

<title>All Episodes</title>

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

video{
    width:100%;
    height:400px;
    background:#000;
}

.content{
    padding:18px;
}

.btn{
    display:inline-block;
    padding:10px 18px;
    border-radius:12px;
    text-decoration:none;
    margin-top:12px;
    background:#ef444420;
    color:#f87171;
}

</style>

</head>
<body>

<?php include 'nav2.php'; ?>

<div class="main">

<div class="grid">

<?php foreach($videos as $v){ ?>

<div class="card">

<video controls>

<source
src="../app/<?php echo $v['videolink']; ?>">

</video>

<div class="content">

<h3>

<?php echo $v['title']; ?>

</h3>

<p>

Likes:
<?php echo $v['likes_count']; ?>

</p>

<br>

<a

href="all-zhatpat-videos.php?delete=<?php echo $v['id']; ?>"

class="btn"

onclick="
return confirm(
'Delete episode?'
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