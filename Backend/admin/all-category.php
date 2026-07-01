<?php
session_start();

require_once 'db.php';

/* LOGIN CHECK */

if(!isset($_SESSION['admin_id'])){

    header("Location:index.php");
    exit;
}

/* ADD CATEGORY */

if(isset($_POST['add_category'])){

    $name =
    trim($_POST['name']);

    if($name != ""){

        $check =
        $pdo->prepare(

        "SELECT id
        FROM ottcategory
        WHERE name=?"

        );

        $check->execute([$name]);

        if($check->rowCount() == 0){

            $insert =
            $pdo->prepare(

            "INSERT INTO ottcategory

            (
            name
            )

            VALUES

            (
            ?
            )"

            );

            $insert->execute([
            $name
            ]);
        }
    }

    header(
    "Location:all-category.php"
    );

    exit;
}

/* DELETE CATEGORY */

if(isset($_GET['delete'])){

    $delete_id =
    intval($_GET['delete']);

    $delete =
    $pdo->prepare(

    "DELETE FROM ottcategory
    WHERE id=?"

    );

    $delete->execute([
    $delete_id
    ]);

    header(
    "Location:all-category.php"
    );

    exit;
}

/* UPDATE CATEGORY */

if(isset($_POST['update_category'])){

    $id =
    intval($_POST['id']);

    $name =
    trim($_POST['name']);

    if($name != ""){

        $update =
        $pdo->prepare(

        "UPDATE ottcategory SET

        name=?

        WHERE id=?"

        );

        $update->execute([

            $name,
            $id
        ]);
    }

    header(
    "Location:all-category.php"
    );

    exit;
}

/* FETCH CATEGORY */

$stmt =
$pdo->prepare(

"SELECT *
FROM ottcategory
ORDER BY id DESC"

);

$stmt->execute();

$categories =
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
OTT Categories
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
    display:flex;
    align-items:center;
    justify-content:space-between;
    margin-bottom:24px;
    gap:15px;
}

.page-header h1{
    font-size:28px;
    margin-bottom:6px;
}

.page-header p{
    font-size:13px;
    color:#94a3b8;
}

/* ADD BUTTON */

.add-btn{
    height:50px;
    padding:0 22px;
    border:none;
    border-radius:16px;
    background:
    linear-gradient(
    135deg,
    #ef4444,
    #7c3aed
    );
    color:#fff;
    font-size:14px;
    font-weight:700;
    cursor:pointer;
    display:flex;
    align-items:center;
    gap:10px;
}

/* TABLE */

.category-table{
    background:#111827;
    border-radius:24px;
    overflow:hidden;
}

/* HEAD */

.table-head{
    display:grid;

    grid-template-columns:

    120px
    1.5fr
    180px;

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

    120px
    1.5fr
    180px;

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

.category-id{
    font-size:15px;
    font-weight:700;
    color:#22d3ee;
}

.category-name{
    font-size:15px;
    font-weight:600;
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
    border:none;
    border-radius:12px;
    display:flex;
    align-items:center;
    justify-content:center;
    cursor:pointer;
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
    max-width:450px;
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

    .page-header{
        flex-direction:column;
        align-items:flex-start;
    }

    .category-table{
        overflow-x:auto;
    }

    .table-head,
    .table-row{
        min-width:650px;
    }
}

</style>

</head>
<body>

<?php include 'nav2.php'; ?>

<div class="main-content">

    <!-- HEADER -->

    <div class="page-header">

        <div>

            <h1>
                OTT Categories
            </h1>

            <p>
                Manage movie categories
            </p>

        </div>

        <!-- ADD BUTTON -->

        <button
        class="add-btn"
        onclick="openAddModal()">

            <i class="fa-solid fa-plus"></i>

            Add Category

        </button>

    </div>

    <?php if(count($categories) > 0){ ?>

    <div class="category-table">

        <!-- HEAD -->

        <div class="table-head">

            <div>
                ID
            </div>

            <div>
                Category Name
            </div>

            <div>
                Actions
            </div>

        </div>

        <!-- ROWS -->

        <?php foreach($categories as $cat){ ?>

        <div class="table-row">

            <!-- ID -->

            <div class="category-id">

                #<?php echo $cat['id']; ?>

            </div>

            <!-- NAME -->

            <div class="category-name">

                <?php echo htmlspecialchars($cat['name']); ?>

            </div>

            <!-- ACTIONS -->

            <div class="actions">

                <!-- EDIT -->

                <button

                class="edit-btn"

                onclick="openEditModal(

                '<?php echo $cat['id']; ?>',

                '<?php echo htmlspecialchars($cat['name'],ENT_QUOTES); ?>'

                )">

                    <i class="fa-solid fa-pen"></i>

                </button>

                <!-- DELETE -->

                <a

                href="all-category.php?delete=<?php echo $cat['id']; ?>"

                class="delete-btn"

                onclick="
                return confirm(
                'Delete this category?'
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

        <i class="fa-solid fa-layer-group"></i>

        <h2>
            No Categories Found
        </h2>

        <p>
            No OTT categories added yet
        </p>

    </div>

    <?php } ?>

</div>

<!-- ADD MODAL -->

<div
class="modal"
id="addModal">

    <div class="modal-box">

        <div class="modal-title">

            Add Category

        </div>

        <form method="POST">

            <div class="input-box">

                <label>
                    Category Name
                </label>

                <input
                type="text"
                name="name"
                required>

            </div>

            <div class="modal-actions">

                <button
                type="submit"
                name="add_category"
                class="save-btn">

                    Add Category

                </button>

                <button
                type="button"
                class="close-btn"
                onclick="closeAddModal()">

                    Cancel

                </button>

            </div>

        </form>

    </div>

</div>

<!-- EDIT MODAL -->

<div
class="modal"
id="editModal">

    <div class="modal-box">

        <div class="modal-title">

            Edit Category

        </div>

        <form method="POST">

            <input
            type="hidden"
            name="id"
            id="edit_id">

            <div class="input-box">

                <label>
                    Category Name
                </label>

                <input
                type="text"
                name="name"
                id="edit_name"
                required>

            </div>

            <div class="modal-actions">

                <button
                type="submit"
                name="update_category"
                class="save-btn">

                    Update

                </button>

                <button
                type="button"
                class="close-btn"
                onclick="closeEditModal()">

                    Cancel

                </button>

            </div>

        </form>

    </div>

</div>

<script>

function openAddModal(){

    document
    .getElementById('addModal')
    .classList.add('show');
}

function closeAddModal(){

    document
    .getElementById('addModal')
    .classList.remove('show');
}

function openEditModal(
id,
name
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
}

function closeEditModal(){

    document
    .getElementById('editModal')
    .classList.remove('show');
}

</script>

</body>
</html>