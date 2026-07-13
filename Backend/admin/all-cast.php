<?php
session_start();

require_once 'db.php';
require_once '../includes/image_upload.php';

/* LOGIN CHECK */

if(!isset($_SESSION['admin_id'])){

    header("Location:index.php");
    exit;
}

/* CREATE FOLDER */

if(!is_dir("../app/uploads/cast")){

    mkdir(
        "../app/uploads/cast",
        0777,
        true
    );
}

/* DELETE */

if(isset($_GET['delete'])){

    $delete_id =
    intval($_GET['delete']);

    /* GET IMAGE */

    $get =
    $pdo->prepare(

    "SELECT imagelink
    FROM cast
    WHERE id=?"

    );

    $get->execute([
    $delete_id
    ]);

    $cast =
    $get->fetch();

    if($cast){

        if($cast['imagelink'] != ""){

            $path =
            "../app/".
            $cast['imagelink'];

            if(file_exists($path)){

                unlink($path);
            }
        }
    }

    /* DELETE */

    $delete =
    $pdo->prepare(

    "DELETE FROM cast
    WHERE id=?"

    );

    $delete->execute([
    $delete_id
    ]);

    header(
    "Location:all-cast.php"
    );

    exit;
}

/* UPDATE */

if(isset($_POST['update_cast'])){

    $id =
    intval($_POST['id']);

    $name =
    trim($_POST['name']);

    /* FETCH OLD */

    $oldQuery =
    $pdo->prepare(

    "SELECT imagelink
    FROM cast
    WHERE id=?"

    );

    $oldQuery->execute([$id]);

    $old =
    $oldQuery->fetch();

    $imagelink =
    $old['imagelink'];

    /* NEW IMAGE */

    $uploadError = "";

    $imageFile = handleCroppedOrRawUpload(
        'cropped_image',
        'image',
        "../app/uploads/cast",
        ['jpg','jpeg','png','webp'],
        $uploadError
    );

    if($imageFile){

        if($old['imagelink'] != ""){

            $oldPath =
            "../app/".
            $old['imagelink'];

            if(file_exists($oldPath)){

                unlink($oldPath);
            }
        }

        $imagelink =
        "uploads/cast/".$imageFile;
    }

    /* UPDATE */

    $update =
    $pdo->prepare(

    "UPDATE cast SET

    name=?,
    imagelink=?

    WHERE id=?"

    );

    $update->execute([

        $name,
        $imagelink,
        $id
    ]);

    header(
    "Location:all-cast.php"
    );

    exit;
}

/* FETCH CAST */

$stmt =
$pdo->prepare(

"SELECT *
FROM cast
ORDER BY id DESC"

);

$stmt->execute();

$casts =
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
All Cast
</title>

<link rel="stylesheet"
href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.6.2/cropper.min.css">

<link rel="stylesheet" href="../assets/css/image-crop.css">

<script src="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.6.2/cropper.min.js"></script>

<script src="../assets/js/image-crop.js"></script>

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

.cast-grid{
    display:grid;
    grid-template-columns:
    repeat(auto-fill,minmax(240px,1fr));
    gap:20px;
}

/* CARD */

.cast-card{
    background:#111827;
    border-radius:24px;
    overflow:hidden;
    transition:.3s;
    box-shadow:
    0 15px 35px rgba(0,0,0,0.28);
}

.cast-card:hover{
    transform:translateY(-5px);
}

.cast-image{
    width:100%;
    height:280px;
    object-fit:cover;
    background:#1e293b;
}

.cast-content{
    padding:18px;
}

.cast-name{
    font-size:17px;
    font-weight:700;
    margin-bottom:8px;
}

.cast-date{
    font-size:12px;
    color:#94a3b8;
}

/* ACTIONS */

.actions{
    display:flex;
    align-items:center;
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
    background:rgba(0,0,0,0.7);
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
    margin-bottom:18px;
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

.preview{
    width:100px;
    height:100px;
    border-radius:18px;
    overflow:hidden;
    margin-top:12px;
}

.preview img{
    width:100%;
    height:100%;
    object-fit:cover;
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
            All Cast
        </h1>

        <p>
            Manage OTT cast members
        </p>

    </div>

    <?php if(count($casts) > 0){ ?>

    <div class="cast-grid">

        <?php foreach($casts as $cast){ ?>

        <div class="cast-card">

            <!-- IMAGE -->

            <img

            src="../app/<?php echo $cast['imagelink']; ?>"

            class="cast-image">

            <!-- CONTENT -->

            <div class="cast-content">

                <div class="cast-name">

                    <?php echo htmlspecialchars($cast['name']); ?>

                </div>

                <div class="cast-date">

                    Added on

                    <?php echo date(

                    "d M Y",

                    strtotime(
                    $cast['created_at']
                    )

                    ); ?>

                </div>

                <!-- ACTIONS -->

                <div class="actions">

                    <!-- EDIT -->

                    <button

                    class="edit-btn"

                    onclick="openModal(

                    '<?php echo $cast['id']; ?>',

                    '<?php echo htmlspecialchars($cast['name'],ENT_QUOTES); ?>',

                    '<?php echo $cast['imagelink']; ?>'

                    )">

                        <i class="fa-solid fa-pen"></i>

                        Edit

                    </button>

                    <!-- DELETE -->

                    <a

                    href="all-cast.php?delete=<?php echo $cast['id']; ?>"

                    class="delete-btn"

                    onclick="
                    return confirm(
                    'Delete this cast member?'
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

        <i class="fa-solid fa-user-group"></i>

        <h2>
            No Cast Found
        </h2>

        <p>
            No cast members added yet
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

            Edit Cast

        </div>

        <form
        method="POST"
        enctype="multipart/form-data">

            <input
            type="hidden"
            name="id"
            id="edit_id">

            <!-- NAME -->

            <div class="input-box">

                <label>
                    Cast Name
                </label>

                <input
                type="text"
                name="name"
                id="edit_name"
                required>

            </div>

            <!-- IMAGE -->

            <div class="input-box">

                <label>
                    Cast Image
                </label>

                <input
                type="file"
                name="image"
                id="editImageInput"
                accept="image/*"
                onchange="ImageCrop.open(this,'croppedImageData')">

                <input type="hidden" name="cropped_image" id="croppedImageData">

                <div class="preview">

                    <img
                    id="preview_img">

                </div>

            </div>

            <!-- BUTTONS -->

            <div class="modal-actions">

                <button
                type="submit"
                name="update_cast"
                class="save-btn">

                    Update Cast

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

<!-- CROP MODAL -->
<div class="crop-modal" id="cropModal">

    <div class="crop-box">

        <div class="crop-image-wrap">
            <img id="cropperImage">
        </div>

        <div class="crop-actions">
            <button type="button" class="crop-skip-btn" onclick="ImageCrop.skip()">Skip Crop</button>
            <button type="button" class="crop-use-btn" onclick="ImageCrop.apply()">Crop &amp; Use</button>
        </div>

    </div>

</div>

<script>

function openModal(
id,
name,
image
){

    document
    .getElementById('editModal')
    .classList.add('show');

    document
    .getElementById('edit_id')
    .value = id;

    document
    .getElementById('edit_name')
    .value = name;

    document
    .getElementById('preview_img')
    .src =
    '../app/' + image;
}

function closeModal(){

    document
    .getElementById('editModal')
    .classList.remove('show');
}

</script>

</body>
</html>