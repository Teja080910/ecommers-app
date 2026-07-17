<?php
session_start();

require_once 'db.php';
require_once '../includes/image_upload.php';

if(!isset($_SESSION['admin_id'])){
    header("Location:index.php");
    exit;
}

/* =========================
   CREATE FOLDERS
========================= */

if(!is_dir("../app/uploads/category")){
    mkdir("../app/uploads/category",0777,true);
}

if(!is_dir("../app/uploads/subcategory")){
    mkdir("../app/uploads/subcategory",0777,true);
}

/* =========================
   ADD CATEGORY
========================= */

if(isset($_POST['add_category'])){

    $name =
    trim($_POST['name']);

    $homecategory =
    $_POST['homecategory'];

    $image = "";

    $uploadError = "";

    $imageFile = handleCroppedOrRawUpload(
        'cropped_image',
        'image',
        "../app/uploads/category",
        ['jpg','jpeg','png','webp'],
        $uploadError
    );

    if($imageFile){

        $image = "uploads/category/".$imageFile;
    }

    $stmt = $pdo->prepare(

        "INSERT INTO categories

        (
        name,
        image,
        homecategory
        )

        VALUES(?,?,?)"
    );

    $stmt->execute([
        $name,
        $image,
        $homecategory
    ]);

    header("Location:categories.php");
    exit;
}

/* =========================
   EDIT CATEGORY
========================= */

if(isset($_POST['edit_category'])){

    $id =
    $_POST['edit_id'];

    $name =
    trim($_POST['edit_name']);

    $homecategory =
    $_POST['edit_homecategory'];

    $image =
    $_POST['old_image'];

    $uploadError = "";

    $editImageFile = handleCroppedOrRawUpload(
        'cropped_edit_image',
        'edit_image',
        "../app/uploads/category",
        ['jpg','jpeg','png','webp'],
        $uploadError
    );

    if($editImageFile){

        $image = "uploads/category/".$editImageFile;
    }

    $stmt = $pdo->prepare(

        "UPDATE categories

        SET
        name=?,
        image=?,
        homecategory=?

        WHERE id=?"
    );

    $stmt->execute([
        $name,
        $image,
        $homecategory,
        $id
    ]);

    header("Location:categories.php");
    exit;
}

/* =========================
   ADD SUBCATEGORY
========================= */

if(isset($_POST['add_subcategory'])){

    $category_id =
    $_POST['category_id'];

    $name =
    trim($_POST['sub_name']);

    $image = "";

    $uploadError = "";

    $subImageFile = handleCroppedOrRawUpload(
        'cropped_sub_image',
        'sub_image',
        "../app/uploads/subcategory",
        ['jpg','jpeg','png','webp'],
        $uploadError
    );

    if($subImageFile){

        $image = "uploads/subcategory/".$subImageFile;
    }

    $stmt = $pdo->prepare(

        "INSERT INTO subcategories

        (
        category_id,
        name,
        image
        )

        VALUES(?,?,?)"
    );

    $stmt->execute([

        $category_id,
        $name,
        $image
    ]);

    header("Location:categories.php");
    exit;
}

/* =========================
   EDIT SUBCATEGORY
========================= */

if(isset($_POST['edit_subcategory'])){

    $id =
    $_POST['sub_edit_id'];

    $category_id =
    $_POST['edit_category_id'];

    $name =
    trim($_POST['edit_sub_name']);

    $image =
    $_POST['sub_old_image'];

    $uploadError = "";

    $editSubImageFile = handleCroppedOrRawUpload(
        'cropped_edit_sub_image',
        'edit_sub_image',
        "../app/uploads/subcategory",
        ['jpg','jpeg','png','webp'],
        $uploadError
    );

    if($editSubImageFile){

        $image = "uploads/subcategory/".$editSubImageFile;
    }

    $stmt = $pdo->prepare(

        "UPDATE subcategories

        SET
        category_id=?,
        name=?,
        image=?

        WHERE id=?"
    );

    $stmt->execute([

        $category_id,
        $name,
        $image,
        $id
    ]);

    header("Location:categories.php");
    exit;
}

/* =========================
   DELETE CATEGORY
========================= */

if(isset($_GET['delete_cat'])){

    $id =
    intval($_GET['delete_cat']);

    $pdo->prepare(

        "DELETE FROM categories
        WHERE id=?"

    )->execute([$id]);

    header("Location:categories.php");
    exit;
}

/* =========================
   DELETE SUBCATEGORY
========================= */

if(isset($_GET['delete_sub'])){

    $id =
    intval($_GET['delete_sub']);

    $pdo->prepare(

        "DELETE FROM subcategories
        WHERE id=?"

    )->execute([$id]);

    header("Location:categories.php");
    exit;
}

/* =========================
   FETCH DATA
========================= */

$categories = $pdo->query(

    "SELECT * FROM categories
     ORDER BY id DESC"

)->fetchAll();

$subcategories = $pdo->query(

    "SELECT
    subcategories.*,
    categories.name AS category_name

    FROM subcategories

    LEFT JOIN categories
    ON categories.id =
    subcategories.category_id

    ORDER BY subcategories.id DESC"

)->fetchAll();
?>

<!DOCTYPE html>
<html>
<head>

<meta charset="UTF-8">

<meta name="viewport"
content="width=device-width, initial-scale=1.0">

<title>
Categories
</title>

<link rel="stylesheet"
href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">

<link rel="stylesheet"
href="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.6.2/cropper.min.css">

<link rel="stylesheet" href="../assets/css/image-crop.css">

<script
src="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.6.2/cropper.min.js"></script>

<script src="../assets/js/image-crop.js"></script>

<style>

*{
    margin:0;
    padding:0;
    box-sizing:border-box;
    font-family:Arial;
}

body{
    background:#0f172a;
    color:#fff;
}

.main{
    margin-left:240px;
    padding:25px;
}

.header{
    display:flex;
    align-items:center;
    justify-content:space-between;
    margin-bottom:30px;
}

.header h1{
    font-size:26px;
}

.btn{
    height:48px;
    border:none;
    padding:0 20px;
    border-radius:14px;
    background:linear-gradient(
        135deg,
        #06b6d4,
        #7c3aed
    );
    color:#fff;
    font-weight:600;
    cursor:pointer;
}

.btn-group{
    display:flex;
    gap:12px;
}

.section{
    margin-top:40px;
}

.section h2{
    margin-bottom:20px;
    font-size:22px;
}

.list-item{
    background:#111827;
    border-radius:20px;
    padding:15px;
    display:flex;
    align-items:center;
    justify-content:space-between;
    margin-bottom:16px;
}

.list-left{
    display:flex;
    align-items:center;
    gap:14px;
}

.list-left img{
    width:80px;
    height:80px;
    border-radius:18px;
    object-fit:cover;
    background:#1e293b;
}

.list-info h3{
    font-size:16px;
    margin-bottom:6px;
}

.list-info p{
    font-size:13px;
    color:#94a3b8;
}

.actions{
    display:flex;
    gap:10px;
}

.action-btn{
    width:44px;
    height:44px;
    border:none;
    border-radius:14px;
    cursor:pointer;
    display:flex;
    align-items:center;
    justify-content:center;
    text-decoration:none;
}

.edit-btn{
    background:#06b6d420;
    color:#22d3ee;
}

.delete-btn{
    background:#ef444420;
    color:#f87171;
}

.modal{
    position:fixed;
    inset:0;
    background:rgba(0,0,0,0.7);
    display:none;
    align-items:center;
    justify-content:center;
    z-index:999;
}

.modal.show{
    display:flex;
}

.modal-box{
    width:100%;
    max-width:480px;
    background:#111827;
    border-radius:26px;
    padding:28px;
}

.modal-title{
    font-size:22px;
    font-weight:700;
    margin-bottom:22px;
}

.input{
    margin-bottom:18px;
}

.input label{
    display:block;
    margin-bottom:8px;
    font-size:13px;
}

.input input,
.input select{
    width:100%;
    height:52px;
    border:none;
    outline:none;
    background:#1e293b;
    border-radius:14px;
    padding:0 14px;
    color:#fff;
}

.input input[type="file"]{
    padding:14px;
}

.modal-actions{
    display:flex;
    gap:12px;
    margin-top:24px;
}

.close-btn{
    background:#1e293b;
}

.preview{
    width:100px;
    height:100px;
    border-radius:16px;
    object-fit:cover;
    margin-top:10px;
}

.badge{
    display:inline-block;
    padding:7px 14px;
    border-radius:30px;
    font-size:12px;
    margin-top:10px;
}

.home{
    background:#16a34a20;
    color:#4ade80;
}

.not-home{
    background:#ef444420;
    color:#f87171;
}

@media(max-width:900px){

    .main{
        margin-left:0;
        padding:85px 15px;
    }

    .header{
        flex-direction:column;
        align-items:flex-start;
        gap:15px;
    }

    .list-item{
        flex-direction:column;
        align-items:flex-start;
        gap:18px;
    }

    .actions{
        width:100%;
    }
}

</style>
</head>
<body>

<?php include 'nav.php'; ?>

<div class="main">

    <div class="header">

        <h1>
            Categories &
            Subcategories
        </h1>

        <div class="btn-group">

            <button
            class="btn"
            onclick="openModal('catModal')">

                <i class="fa fa-plus"></i>
                Category

            </button>

            <button
            class="btn"
            onclick="openModal('subModal')">

                <i class="fa fa-plus"></i>
                Subcategory

            </button>

        </div>

    </div>

    <!-- CATEGORIES -->

    <div class="section">

        <h2>
            Categories
        </h2>

        <?php foreach($categories as $cat){ ?>

        <div class="list-item">

            <div class="list-left">

                <img
                src="../app/<?php echo $cat['image']; ?>">

                <div class="list-info">

                    <h3>
                        <?php echo $cat['name']; ?>
                    </h3>

                    <p>
                        Category ID :
                        <?php echo $cat['id']; ?>
                    </p>

                    <?php if($cat['homecategory']=="yes"){ ?>

                        <div class="badge home">

                            HOME CATEGORY

                        </div>

                    <?php }else{ ?>

                        <div class="badge not-home">

                            HIDDEN FROM HOME

                        </div>

                    <?php } ?>

                </div>

            </div>

            <div class="actions">

                <button
                class="action-btn edit-btn"

                onclick='openEditCategory(

                    "<?php echo $cat['id']; ?>",

                    "<?php echo htmlspecialchars($cat['name'], ENT_QUOTES); ?>",

                    "<?php echo $cat['image']; ?>",

                    "<?php echo $cat['homecategory']; ?>"
                )'>

                    <i class="fa fa-pen"></i>

                </button>

                <a
                class="action-btn delete-btn"

                href="?delete_cat=<?php echo $cat['id']; ?>"

                onclick="return confirm('Delete category?')">

                    <i class="fa fa-trash"></i>

                </a>

            </div>

        </div>

        <?php } ?>

    </div>

<!-- SUBCATEGORIES -->

<div class="section">

<h2>
Subcategories
</h2>

<?php foreach($subcategories as $sub){ ?>

<div class="list-item">

<div class="list-left">

<img
src="../app/<?php echo $sub['image']; ?>">

<div class="list-info">

<h3>

<?php
echo $sub['name'];
?>

</h3>

<p>

Category :
<?php
echo $sub['category_name'];
?>

</p>

</div>

</div>

<div class="actions">

<button
class="action-btn edit-btn"

onclick='openEditSub(

"<?php echo $sub["id"]; ?>",

"<?php echo $sub["category_id"]; ?>",

"<?php echo htmlspecialchars($sub["name"], ENT_QUOTES); ?>",

"<?php echo $sub["image"]; ?>"

)'>

<i class="fa fa-pen"></i>

</button>

<a
class="action-btn delete-btn"

href="?delete_sub=<?php
echo $sub['id'];
?>"

onclick="
return confirm(
'Delete subcategory?'
)
">

<i class="fa fa-trash"></i>

</a>

</div>

</div>

<?php } ?>

</div>
<!-- ADD CATEGORY -->

<div class="modal"
id="catModal">

    <div class="modal-box">

        <div class="modal-title">
            Add Category
        </div>

        <form
        method="POST"
        enctype="multipart/form-data">

            <div class="input">

                <label>
                    Category Name
                </label>

                <input
                type="text"
                name="name"
                required>

            </div>

            <div class="input">

                <label>
                    Show In Home
                </label>

                <select
                name="homecategory"
                required>

                    <option value="yes">
                        Yes
                    </option>

                    <option value="no">
                        No
                    </option>

                </select>

            </div>

            <div class="input">

                <label>
                    Category Image
                </label>

                <input
                type="file"
                name="image"
                id="catImageInput"
                accept="image/*"
                onchange="ImageCrop.open(this,'croppedImageData')"
                required>

                <input type="hidden" name="cropped_image" id="croppedImageData">

            </div>

            <div class="modal-actions">

                <button
                class="btn"
                type="submit"
                name="add_category">

                    Add Category

                </button>

                <button
                type="button"
                class="btn close-btn"
                onclick="closeModal('catModal')">

                    Close

                </button>

            </div>

        </form>

    </div>

</div>

<!-- EDIT CATEGORY -->

<div class="modal"
id="editCatModal">

    <div class="modal-box">

        <div class="modal-title">
            Edit Category
        </div>

        <form
        method="POST"
        enctype="multipart/form-data">

            <input
            type="hidden"
            name="edit_id"
            id="edit_id">

            <input
            type="hidden"
            name="old_image"
            id="old_image">

            <div class="input">

                <label>
                    Category Name
                </label>

                <input
                type="text"
                name="edit_name"
                id="edit_name"
                required>

            </div>

            <div class="input">

                <label>
                    Show In Home
                </label>

                <select
                name="edit_homecategory"
                id="edit_homecategory"
                required>

                    <option value="yes">
                        Yes
                    </option>

                    <option value="no">
                        No
                    </option>

                </select>

            </div>

            <div class="input">

                <label>
                    Category Image
                </label>

                <input
                type="file"
                name="edit_image"
                id="editImageInput"
                accept="image/*"
                onchange="ImageCrop.open(this,'croppedEditImageData')">

                <input type="hidden" name="cropped_edit_image" id="croppedEditImageData">

                <img
                id="edit_preview"
                class="preview">

            </div>

            <div class="modal-actions">

                <button
                class="btn"
                type="submit"
                name="edit_category">

                    Update

                </button>

                <button
                type="button"
                class="btn close-btn"
                onclick="closeModal('editCatModal')">

                    Close

                </button>

            </div>

        </form>

    </div>

</div>
<!-- ADD SUBCATEGORY -->

<div
class="modal"
id="subModal">

<div class="modal-box">

<div class="modal-title">
Add Subcategory
</div>

<form
method="POST"
enctype="multipart/form-data">

<div class="input">

<label>
Select Category
</label>

<select
name="category_id"
required>

<option value="">
Choose Category
</option>

<?php
foreach(
$categories
as $cat
){
?>

<option
value="<?php echo $cat['id']; ?>">

<?php
echo
$cat['name'];
?>

</option>

<?php } ?>

</select>

</div>

<div class="input">

<label>
Subcategory Name
</label>

<input
type="text"
name="sub_name"
required>

</div>

<div class="input">

<label>
Subcategory Image
</label>

<input
type="file"
name="sub_image"
id="subImageInput"
accept="image/*"
onchange="ImageCrop.open(this,'croppedSubImageData')"
required>

<input type="hidden" name="cropped_sub_image" id="croppedSubImageData">

</div>

<div class="modal-actions">

<button
class="btn"
type="submit"
name="add_subcategory">

Add Subcategory

</button>

<button
type="button"
class="btn close-btn"
onclick="closeModal('subModal')">

Close

</button>

</div>

</form>

</div>

</div>

<div
class="modal"
id="editSubModal">

<div class="modal-box">

<div class="modal-title">
Edit Subcategory
</div>

<form
method="POST"
enctype="multipart/form-data">

<input
type="hidden"
name="sub_edit_id"
id="sub_edit_id">

<input
type="hidden"
name="sub_old_image"
id="sub_old_image">

<div class="input">

<label>
Category
</label>

<select
name="edit_category_id"
id="edit_category_id"
required>

<?php foreach($categories as $cat){ ?>

<option
value="<?php
echo $cat['id'];
?>">

<?php
echo $cat['name'];
?>

</option>

<?php } ?>

</select>

</div>

<div class="input">

<label>
Subcategory Name
</label>

<input
type="text"
name="edit_sub_name"
id="edit_sub_name"
required>

</div>

<div class="input">

<label>
Image
</label>

<input
type="file"
name="edit_sub_image"
id="editSubImageInput"
accept="image/*"
onchange="ImageCrop.open(this,'croppedEditSubImageData')">

<input type="hidden" name="cropped_edit_sub_image" id="croppedEditSubImageData">

<img
id="edit_sub_preview"
class="preview">

</div>

<div class="modal-actions">

<button
class="btn"
type="submit"
name="edit_subcategory">

Update

</button>

<button
type="button"
class="btn close-btn"
onclick="
closeModal(
'editSubModal'
)
">

Close

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

function openModal(id){

    document
    .getElementById(id)
    .classList.add("show");
}

function closeModal(id){

    document
    .getElementById(id)
    .classList.remove("show");
}

function openEditCategory(
    id,
    name,
    image,
    homecategory
){

    document
    .getElementById("edit_id")
    .value = id;

    document
    .getElementById("edit_name")
    .value = name;

    document
    .getElementById("old_image")
    .value = image;

    document
    .getElementById("edit_homecategory")
    .value = homecategory;

    document
    .getElementById("edit_preview")
    .src =
    "../app/" + image;

    openModal(
        "editCatModal"
    );
}
function openEditSub(
id,
category,
name,
image
){

document
.getElementById(
"sub_edit_id"
).value=id;

document
.getElementById(
"edit_category_id"
).value=category;

document
.getElementById(
"edit_sub_name"
).value=name;

document
.getElementById(
"sub_old_image"
).value=image;

document
.getElementById(
"edit_sub_preview"
).src=
"../app/"+image;

openModal(
"editSubModal"
);

}

</script>

</body>
</html>