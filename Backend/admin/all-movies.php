<?php
session_start();

require_once 'db.php';

/* LOGIN CHECK */

if(!isset($_SESSION['admin_id'])){

    header("Location:index.php");
    exit;
}

/* DELETE MOVIE */

if(isset($_GET['delete'])){

    $delete_id =
    intval($_GET['delete']);

    /* GET IMAGES */

    $get =
    $pdo->prepare(

    "SELECT
    mainposter,
    verticalposter

    FROM movies

    WHERE id=?"

    );

    $get->execute([
    $delete_id
    ]);

    $movie =
    $get->fetch();

    if($movie){

        if($movie['mainposter'] != ""){

            $path =
            "../app/".
            $movie['mainposter'];

            if(file_exists($path)){

                unlink($path);
            }
        }

        if($movie['verticalposter'] != ""){

            $path =
            "../app/".
            $movie['verticalposter'];

            if(file_exists($path)){

                unlink($path);
            }
        }
    }

    /* DELETE */

    $delete =
    $pdo->prepare(

    "DELETE FROM movies
    WHERE id=?"

    );

    $delete->execute([
    $delete_id
    ]);

    header(
    "Location:all-movies.php"
    );

    exit;
}

/* FETCH MOVIES */

$stmt =
$pdo->prepare(

"SELECT

movies.*,

ottcategory.name
AS category_name

FROM movies

LEFT JOIN ottcategory
ON ottcategory.id =
movies.cat_id

ORDER BY movies.id DESC"

);

$stmt->execute();

$movies =
$stmt->fetchAll();

?>

<!DOCTYPE html>
<html lang="en">
<head>

<meta charset="UTF-8">

<meta name="viewport"
content="width=device-width,
initial-scale=1.0">

<title>
All Movies
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

/* HEADER */

.page-header{
    margin-bottom:24px;
}

.page-header h1{
    font-size:28px;
    margin-bottom:6px;
}

.page-header p{
    font-size:13px;
    color:#94a3b8;
}

/* TABLE */

.movie-table{
    background:#111827;
    border-radius:26px;
    overflow:hidden;
}

/* HEAD */

.table-head{
    display:grid;

    grid-template-columns:

    80px
    110px
    1.6fr
    140px
    100px
    120px
    140px
    150px;

    gap:14px;

    padding:18px 20px;

    background:#1e293b;

    font-size:13px;
    font-weight:600;
}

/* ROW */

.table-row{
    display:grid;

    grid-template-columns:

    80px
    110px
    1.6fr
    140px
    100px
    120px
    140px
    150px;

    gap:14px;

    align-items:center;

    padding:18px 20px;

    border-bottom:
    1px solid rgba(255,255,255,0.05);

    transition:.3s;
}

.table-row:hover{
    background:#18212f;
}

/* POSTER */

.poster{
    width:85px;
    height:110px;
    border-radius:14px;
    object-fit:cover;
    background:#1e293b;
}

/* TEXT */

.movie-id{
    font-size:15px;
    font-weight:700;
    color:#22d3ee;
}

.movie-title{
    font-size:15px;
    font-weight:600;
    margin-bottom:6px;
}

.small-text{
    font-size:12px;
    color:#94a3b8;
    line-height:1.6;
}

/* BADGES */

.badge{
    display:inline-block;
    padding:7px 14px;
    border-radius:30px;
    font-size:11px;
    font-weight:600;
    text-transform:uppercase;
}

.free{
    background:#16a34a20;
    color:#4ade80;
}

.no{
    background:#ef444420;
    color:#f87171;
}

/* CAST */

.cast-box{
    display:flex;
    flex-wrap:wrap;
    gap:6px;
}

.cast-chip{
    background:#1e293b;
    color:#cbd5e1;
    font-size:11px;
    padding:6px 10px;
    border-radius:30px;
}

/* ACTIONS */

.actions{
    display:flex;
    align-items:center;
    gap:10px;
}

.edit-btn,
.delete-btn{
    width:42px;
    height:42px;
    border-radius:12px;
    display:flex;
    align-items:center;
    justify-content:center;
    text-decoration:none;
    transition:.3s;
}

.edit-btn{
    background:#06b6d420;
    color:#22d3ee;
}

.edit-btn:hover{
    background:#06b6d4;
    color:#fff;
}

.delete-btn{
    background:#ef444420;
    color:#f87171;
}

.delete-btn:hover{
    background:#ef4444;
    color:#fff;
}

/* EMPTY */

.empty-box{
    background:#111827;
    border-radius:26px;
    padding:80px 20px;
    text-align:center;
}

.empty-box i{
    font-size:65px;
    color:#475569;
    margin-bottom:18px;
}

.empty-box h2{
    margin-bottom:8px;
}

.empty-box p{
    color:#94a3b8;
    font-size:13px;
}

/* RESPONSIVE */

@media(max-width:1400px){

    .movie-table{
        overflow-x:auto;
    }

    .table-head,
    .table-row{
        min-width:1450px;
    }
}

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

    <!-- HEADER -->

    <div class="page-header">

        <h1>
            All Movies
        </h1>

        <p>
            Manage uploaded OTT movies
        </p>

    </div>

    <?php if(count($movies) > 0){ ?>

    <div class="movie-table">

        <!-- HEAD -->

        <div class="table-head">

            <div>
                ID
            </div>

            <div>
                Poster
            </div>

            <div>
                Movie
            </div>

            <div>
                Category
            </div>

            <div>
                Views
            </div>

            <div>
                Premium
            </div>

            <div>
                Cast
            </div>

            <div>
                Actions
            </div>

        </div>

        <!-- ROWS -->

        <?php foreach($movies as $movie){ ?>

        <?php

        /* CAST */

        $cast_names = [];

        if($movie['castid'] != ""){

            $ids =
            explode(",",$movie['castid']);

            foreach($ids as $cid){

                $castQuery =
                $pdo->prepare(

                "SELECT name
                FROM cast
                WHERE id=?"

                );

                $castQuery->execute([
                $cid
                ]);

                $cast =
                $castQuery->fetch();

                if($cast){

                    $cast_names[] =
                    $cast['name'];
                }
            }
        }

        ?>

        <div class="table-row">

            <!-- ID -->

            <div class="movie-id">

                #<?php echo $movie['id']; ?>

            </div>

            <!-- POSTER -->

            <div>

                <img

                src="../app/<?php echo $movie['verticalposter']; ?>"

                class="poster">

            </div>

            <!-- MOVIE -->

            <div>

                <div class="movie-title">

                    <?php echo htmlspecialchars($movie['title']); ?>

                </div>

                <div class="small-text">

                    <?php echo htmlspecialchars($movie['filesize']); ?>

                </div>

                <div class="small-text"
                style="margin-top:5px;">

                    <?php echo date(

                    "d M Y",

                    strtotime(
                    $movie['created_at']
                    )

                    ); ?>

                </div>

            </div>

            <!-- CATEGORY -->

            <div>

                <div class="small-text">

                    <?php echo htmlspecialchars($movie['category_name']); ?>

                </div>

            </div>

            <!-- VIEWS -->

            <div>

                <div class="small-text">

                    <i class="fa-solid fa-eye"></i>

                    <?php echo number_format($movie['views']); ?>

                </div>

            </div>

            <!-- PREMIUM -->

            <div>

                <span class="badge <?php echo strtolower($movie['isfree']); ?>">

                    <?php

                    if($movie['isfree'] == "yes"){

                        echo "FREE";

                    }else{

                        echo "PREMIUM";
                    }

                    ?>

                </span>

            </div>

            <!-- CAST -->

            <div>

                <div class="cast-box">

                    <?php foreach($cast_names as $cast){ ?>

                    <div class="cast-chip">

                        <?php echo htmlspecialchars($cast); ?>

                    </div>

                    <?php } ?>

                </div>

            </div>

            <!-- ACTIONS -->

            <div class="actions">

                <!-- EDIT -->

                <a

                href="edit-movie.php?id=<?php echo $movie['id']; ?>"

                class="edit-btn">

                    <i class="fa-solid fa-pen"></i>

                </a>

                <!-- DELETE -->

                <a

                href="all-movies.php?delete=<?php echo $movie['id']; ?>"

                class="delete-btn"

                onclick="
                return confirm(
                'Delete this movie?'
                )
                ">

                    <i class="fa-solid fa-trash"></i>

                </a>

            </div>

        </div>

        <?php } ?>

    </div>

    <?php }else{ ?>

    <div class="empty-box">

        <i class="fa-solid fa-film"></i>

        <h2>
            No Movies Found
        </h2>

        <p>
            No OTT movies uploaded yet
        </p>

    </div>

    <?php } ?>

</div>

</body>
</html>