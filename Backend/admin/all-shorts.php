<?php
session_start();

require_once 'db.php';

/* LOGIN CHECK */

if(!isset($_SESSION['admin_id'])){

    header("Location:index.php");
    exit;
}

/* DELETE SHORT */

if(isset($_GET['delete'])){

    $delete_id =
    intval($_GET['delete']);

    /* GET VIDEO */

    $get =
    $pdo->prepare(

    "SELECT video
    FROM shorts
    WHERE id=?"

    );

    $get->execute([
    $delete_id
    ]);

    $short =
    $get->fetch();

    if($short){

        if($short['video'] != ""){

            $path =
            "../app/".
            $short['video'];

            if(file_exists($path)){

                unlink($path);
            }
        }
    }

    /* DELETE */

    $delete =
    $pdo->prepare(

    "DELETE FROM shorts
    WHERE id=?"

    );

    $delete->execute([
    $delete_id
    ]);

    header(
    "Location:all-shorts.php"
    );

    exit;
}

/* UPDATE SHORT */

if(isset($_POST['update_short'])){

    $id =
    intval($_POST['id']);

    /* FETCH OLD */

    $oldQuery =
    $pdo->prepare(

    "SELECT video
    FROM shorts
    WHERE id=?"

    );

    $oldQuery->execute([$id]);

    $old =
    $oldQuery->fetch();

    $video =
    $old['video'];

    /* NEW VIDEO */

    if(isset($_FILES['video']) &&
       $_FILES['video']['error'] == 0){

        /* SIZE */

        $max_size =
        20 * 1024 * 1024;

        if($_FILES['video']['size'] <= $max_size){

            if($old['video'] != ""){

                $oldPath =
                "../app/".
                $old['video'];

                if(file_exists($oldPath)){

                    unlink($oldPath);
                }
            }

            $file_name =
            time().'_'.
            $_FILES['video']['name'];

            move_uploaded_file(

                $_FILES['video']['tmp_name'],

                "../app/uploads/shorts/".$file_name
            );

            $video =
            "uploads/shorts/".$file_name;
        }
    }

    /* UPDATE */

    $update =
    $pdo->prepare(

    "UPDATE shorts SET

    video=?

    WHERE id=?"

    );

    $update->execute([

        $video,
        $id
    ]);

    header(
    "Location:all-shorts.php"
    );

    exit;
}

/* FETCH SHORTS */

$stmt =
$pdo->prepare(

"SELECT *
FROM shorts
ORDER BY id DESC"

);

$stmt->execute();

$shorts =
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
All Shorts
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

/* GRID */

.short-grid{
    display:grid;
    grid-template-columns:
    repeat(auto-fill,minmax(260px,1fr));
    gap:22px;
}

/* CARD */

.short-card{
    background:#111827;
    border-radius:24px;
    overflow:hidden;
    box-shadow:
    0 15px 35px rgba(0,0,0,0.28);
}

/* VIDEO */

.short-video{
    width:100%;
    height:460px;
    object-fit:cover;
    background:#000;
}

/* CONTENT */

.short-content{
    padding:18px;
}

.short-id{
    font-size:15px;
    font-weight:700;
    color:#22d3ee;
    margin-bottom:8px;
}

.short-date{
    font-size:12px;
    color:#94a3b8;
}

/* ACTIONS */

.actions{
    display:flex;
    gap:10px;
    margin-top:18px;
}

.edit-btn,
.delete-btn{
    flex:1;
    height:46px;
    border:none;
    border-radius:14px;
    display:flex;
    align-items:center;
    justify-content:center;
    gap:8px;
    text-decoration:none;
    cursor:pointer;
    font-size:13px;
    font-weight:600;
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
    border-radius:24px;
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

/* MODAL */

.modal{
    position:fixed;
    inset:0;
    background:rgba(0,0,0,0.75);
    display:none;
    align-items:center;
    justify-content:center;
    padding:20px;
    z-index:9999;
}

.modal.show{
    display:flex;
}

.modal-box{
    width:100%;
    max-width:500px;
    background:#111827;
    border-radius:24px;
    padding:24px;
}

.modal-title{
    font-size:22px;
    font-weight:700;
    margin-bottom:20px;
}

/* INPUT */

.input-box{
    display:flex;
    flex-direction:column;
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

/* BUTTONS */

.modal-actions{
    display:flex;
    gap:12px;
    margin-top:22px;
}

.save-btn,
.close-btn{
    flex:1;
    height:52px;
    border:none;
    border-radius:16px;
    font-size:14px;
    font-weight:700;
    cursor:pointer;
}

.save-btn{
    background:
    linear-gradient(
    135deg,
    #ef4444,
    #7c3aed
    );
    color:#fff;
}

.close-btn{
    background:#1e293b;
    color:#fff;
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

    <!-- HEADER -->

    <div class="page-header">

        <h1>
            All Shorts
        </h1>

        <p>
            Manage uploaded OTT short videos
        </p>

    </div>

    <?php if(count($shorts) > 0){ ?>

    <div class="short-grid">

        <?php foreach($shorts as $short){ ?>

        <div class="short-card">

            <!-- VIDEO -->

            <video
            class="short-video"
            controls>

                <source

                src="../app/<?php echo $short['video']; ?>">

            </video>

            <!-- CONTENT -->

            <div class="short-content">

                <div class="short-id">

                    Short #<?php echo $short['id']; ?>

                </div>

                <div class="short-date">

                    Uploaded on

                    <?php echo date(

                    "d M Y",

                    strtotime(
                    $short['created_at']
                    )

                    ); ?>

                </div>

                <!-- ACTIONS -->

                <div class="actions">

                    <!-- EDIT -->

                    <button

                    class="edit-btn"

                    onclick="openModal(

                    '<?php echo $short['id']; ?>'

                    )">

                        <i class="fa-solid fa-pen"></i>

                        Edit

                    </button>

                    <!-- DELETE -->

                    <a

                    href="all-shorts.php?delete=<?php echo $short['id']; ?>"

                    class="delete-btn"

                    onclick="
                    return confirm(
                    'Delete this short video?'
                    )
                    ">

                        <i class="fa-solid fa-trash"></i>

                        Delete

                    </a>

                </div>

            </div>

        </div>

        <?php } ?>

    </div>

    <?php }else{ ?>

    <div class="empty-box">

        <i class="fa-solid fa-video"></i>

        <h2>
            No Shorts Found
        </h2>

        <p>
            No short videos uploaded yet
        </p>

    </div>

    <?php } ?>

</div>

<!-- MODAL -->

<div
class="modal"
id="editModal">

    <div class="modal-box">

        <div class="modal-title">

            Update Short Video

        </div>

        <form
        method="POST"
        enctype="multipart/form-data">

            <input
            type="hidden"
            name="id"
            id="edit_id">

            <!-- VIDEO -->

            <div class="input-box">

                <label>
                    Upload New Video
                </label>

                <input
                type="file"
                name="video"
                accept="video/*">

            </div>

            <!-- BUTTONS -->

            <div class="modal-actions">

                <button
                type="submit"
                name="update_short"
                class="save-btn">

                    Update Video

                </button>

                <button
                type="button"
                class="close-btn"
                onclick="closeModal()">

                    Cancel

                </button>

            </div>

        </form>

    </div>

</div>

<script>

function openModal(id){

    document
    .getElementById('editModal')
    .classList.add('show');

    document
    .getElementById('edit_id')
    .value = id;
}

function closeModal(){

    document
    .getElementById('editModal')
    .classList.remove('show');
}

</script>

</body>
</html>