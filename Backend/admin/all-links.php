<?php
session_start();

require_once 'db.php';

/* LOGIN CHECK */

if(!isset($_SESSION['admin_id'])){

    header("Location:index.php");
    exit;
}

/* DELETE */

if(isset($_GET['delete'])){

    $id =
    intval($_GET['delete']);

    /* GET FILE */

    $get =
    $pdo->prepare(

    "SELECT filelink
    FROM movies_files
    WHERE id=?"

    );

    $get->execute([$id]);

    $file =
    $get->fetch();

    if($file){

        $url =
        $file['filelink'];

        $path =
        parse_url(
        $url,
        PHP_URL_PATH
        );

        if($path){

            $real_path =
            $_SERVER['DOCUMENT_ROOT'].
            $path;

            if(file_exists($real_path)){

                unlink($real_path);
            }
        }
    }

    /* DELETE DB */

    $delete =
    $pdo->prepare(

    "DELETE FROM movies_files
    WHERE id=?"

    );

    $delete->execute([$id]);

    header(
    "Location:all-links.php"
    );

    exit;
}

/* FETCH FILES */

$stmt =
$pdo->prepare(

"SELECT *
FROM movies_files
ORDER BY id DESC"

);

$stmt->execute();

$files =
$stmt->fetchAll();

/* STORAGE */

$total_limit_gb =
100;

$total_used_bytes = 0;

foreach($files as $f){

    $size =
    trim($f['filesize']);

    if(strpos($size,'GB') !== false){

        $value =
        floatval($size);

        $total_used_bytes +=
        ($value * 1024 * 1024 * 1024);

    }else{

        $value =
        floatval($size);

        $total_used_bytes +=
        ($value * 1024 * 1024);
    }
}

$total_used_gb =
round(
$total_used_bytes /
(1024 * 1024 * 1024),
2
);

$percentage =
min(

    100,

    round(
    ($total_used_gb /
    $total_limit_gb) * 100,
    2
    )
);

?>

<!DOCTYPE html>
<html lang="en">
<head>

<meta charset="UTF-8">

<meta name="viewport"
content="width=device-width,
initial-scale=1.0">

<title>
All Links
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

/* MAIN */

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

/* STORAGE CARD */

.storage-card{
    background:#111827;
    border-radius:28px;
    padding:26px;
    margin-bottom:30px;
    overflow:hidden;
    position:relative;
}

.storage-top{
    display:flex;
    align-items:center;
    justify-content:space-between;
    margin-bottom:18px;
    gap:15px;
}

.storage-title{
    font-size:22px;
    font-weight:700;
}

.storage-value{
    font-size:16px;
    font-weight:600;
    color:#22d3ee;
}

/* PROGRESS */

.progress-wrap{
    width:100%;
    height:26px;
    background:#1e293b;
    border-radius:50px;
    overflow:hidden;
    position:relative;
}

.progress-bar{
    height:100%;
    width:0%;
    border-radius:50px;

    background:
    linear-gradient(
    90deg,
    #06b6d4,
    #7c3aed,
    #ec4899
    );

    animation:
    fillBar 2s ease forwards;
}

@keyframes fillBar{

    from{
        width:0%;
    }

    to{
        width:<?php echo $percentage; ?>%;
    }
}

/* TEXT */

.progress-text{
    margin-top:12px;
    font-size:14px;
    color:#cbd5e1;
}

/* TABLE */

.files-table{
    background:#111827;
    border-radius:24px;
    overflow:hidden;
}

/* HEAD */

.table-head{
    display:grid;

    grid-template-columns:

    90px
    1.8fr
    160px
    160px
    140px;

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

    90px
    1.8fr
    160px
    160px
    140px;

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

/* TEXT */

.file-id{
    font-size:15px;
    font-weight:700;
    color:#22d3ee;
}

.file-link{
    font-size:13px;
    word-break:break-all;
}

.file-link a{
    color:#60a5fa;
    text-decoration:none;
}

.file-link a:hover{
    text-decoration:underline;
}

.file-size{
    font-size:15px;
    font-weight:700;
    color:#4ade80;
}

.small-text{
    font-size:12px;
    color:#94a3b8;
}

/* DELETE */

.delete-btn{
    height:44px;
    border:none;
    border-radius:14px;
    background:#ef444420;
    color:#f87171;
    font-size:13px;
    font-weight:700;
    cursor:pointer;
    text-decoration:none;

    display:flex;
    align-items:center;
    justify-content:center;

    transition:.3s;
}

.delete-btn:hover{
    background:#ef4444;
    color:#fff;
}

/* EMPTY */

.empty-box{
    background:#111827;
    padding:80px 20px;
    border-radius:24px;
    text-align:center;
}

.empty-box i{
    font-size:65px;
    color:#475569;
    margin-bottom:15px;
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

    .files-table{
        overflow-x:auto;
    }

    .table-head,
    .table-row{
        min-width:1200px;
    }
}

@media(max-width:900px){

    .main-content{
        margin-left:0;
        padding:85px 15px 20px;
    }

    .storage-top{
        flex-direction:column;
        align-items:flex-start;
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
            All Uploaded Links
        </h1>

        <p>
            Manage uploaded movie files
        </p>

    </div>

    <!-- STORAGE -->

    <div class="storage-card">

        <div class="storage-top">

            <div class="storage-title">

                Storage Usage

            </div>

            <div class="storage-value">

                <?php echo $total_used_gb; ?> GB
                /
                <?php echo $total_limit_gb; ?> GB

            </div>

        </div>

        <div class="progress-wrap">

            <div class="progress-bar"></div>

        </div>

        <div class="progress-text">

            <?php echo $percentage; ?>%
            storage used

        </div>

    </div>

    <?php if(count($files) > 0){ ?>

    <div class="files-table">

        <!-- HEAD -->

        <div class="table-head">

            <div>ID</div>

            <div>Video Link</div>

            <div>File Size</div>

            <div>Created</div>

            <div>Action</div>

        </div>

        <!-- ROWS -->

        <?php foreach($files as $f){ ?>

        <div class="table-row">

            <!-- ID -->

            <div class="file-id">

                #<?php echo $f['id']; ?>

            </div>

            <!-- LINK -->

            <div class="file-link">

                <a
                href="<?php echo $f['filelink']; ?>"
                target="_blank">

                    <?php echo $f['filelink']; ?>

                </a>

            </div>

            <!-- SIZE -->

            <div class="file-size">

                <?php echo $f['filesize']; ?>

            </div>

            <!-- DATE -->

            <div class="small-text">

                <?php

                if(isset($f['created_at'])){

                    echo date(

                    "d M Y",

                    strtotime(
                    $f['created_at']
                    )

                    );

                }else{

                    echo "-";
                }

                ?>

            </div>

            <!-- DELETE -->

            <div>

                <a

                href="all-links.php?delete=<?php echo $f['id']; ?>"

                class="delete-btn"

                onclick="
                return confirm(
                'Delete this file?'
                )
                ">

                    <i class="fa-solid fa-trash"></i>

                    &nbsp;

                    Delete

                </a>

            </div>

        </div>

        <?php } ?>

    </div>

    <?php }else{ ?>

    <div class="empty-box">

        <i class="fa-solid fa-video"></i>

        <h2>
            No Files Found
        </h2>

        <p>
            No uploaded movie files available
        </p>

    </div>

    <?php } ?>

</div>

</body>
</html>