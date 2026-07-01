<?php
session_start();

require_once 'db.php';

/* Login Check */

if(!isset($_SESSION['admin_id'])){
?>
<!DOCTYPE html>
<html lang="en">
<head>

<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>Redirecting...</title>

<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&display=swap" rel="stylesheet">

<style>

*{
    margin:0;
    padding:0;
    box-sizing:border-box;
    font-family:'Inter',sans-serif;
}

body{
    background:#0f172a;
    overflow:hidden;
}

.toast{
    position:fixed;
    top:25px;
    right:25px;
    min-width:320px;
    background:#ef4444;
    color:#fff;
    padding:16px 20px;
    border-radius:16px;
    display:flex;
    align-items:center;
    gap:14px;
}

.toast-icon{
    width:40px;
    height:40px;
    border-radius:50%;
    background:rgba(255,255,255,0.15);
    display:flex;
    align-items:center;
    justify-content:center;
}

</style>

</head>
<body>

<div class="toast">

    <div class="toast-icon">!</div>

    <div>
        <h3>Login Required</h3>
        <p>Please login to continue</p>
    </div>

</div>

<script>

setTimeout(function(){

    window.location.href = "index.php";

},2000);

</script>

</body>
</html>
<?php
exit;
}

/* Delete Franchise */

if(isset($_GET['delete'])){

    $id = intval($_GET['delete']);

    $delete = $pdo->prepare("DELETE FROM seller WHERE id=?");

    $delete->execute([$id]);

    header("Location:all-franchises.php");
    exit;
}

/* Add Franchise */

$success = "";
$error = "";

if(isset($_POST['add_franchise'])){

    $name = trim($_POST['name']);
    $username = trim($_POST['username']);
    $password = password_hash($_POST['password'],PASSWORD_DEFAULT);
    $phone = trim($_POST['phone']);
    $email = trim($_POST['email']);
    $address = trim($_POST['address']);
    $service_pincodes = trim($_POST['service_pincodes']);

    /* Check Username */

    $check = $pdo->prepare("SELECT id FROM seller WHERE username=?");
    $check->execute([$username]);

    if($check->rowCount() > 0){

        $error = "Username already exists";

    }else{

        $insert = $pdo->prepare("INSERT INTO seller
        (
            name,
            username,
            password,
            phone,
            email,
            address,
            service_pincodes
        )
        VALUES
        (
            ?,
            ?,
            ?,
            ?,
            ?,
            ?,
            ?
        )");

        $run = $insert->execute([
            $name,
            $username,
            $password,
            $phone,
            $email,
            $address,
            $service_pincodes
        ]);

        if($run){

            $success = "seller Added Successfully";

        }else{

            $error = "Failed To Add Franchise";

        }

    }

}

/* Search */

$search = isset($_GET['search']) ? trim($_GET['search']) : "";

/* Query */

$sql = "SELECT * FROM seller WHERE 1";

$params = [];

if(!empty($search)){

    $sql .= " AND (
        name LIKE ?
        OR
        username LIKE ?
        OR
        phone LIKE ?
        OR
        email LIKE ?
    )";

    $params[] = "%".$search."%";
    $params[] = "%".$search."%";
    $params[] = "%".$search."%";
    $params[] = "%".$search."%";
}

$sql .= " ORDER BY id DESC";

$stmt = $pdo->prepare($sql);

$stmt->execute($params);

$franchises = $stmt->fetchAll();

?>

<!DOCTYPE html>
<html lang="en">
<head>

<meta charset="UTF-8">

<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>All Franchises</title>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">

<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">

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

/* Main */

.main-content{
    margin-left:240px;
    padding:28px;
}

/* Header */

.page-header{
    display:flex;
    align-items:center;
    justify-content:space-between;
    margin-bottom:22px;
}

.page-title h1{
    font-size:24px;
    margin-bottom:5px;
}

.page-title p{
    font-size:13px;
    color:#94a3b8;
}

/* Button */

.add-btn{
    height:48px;
    padding:0 20px;
    border:none;
    border-radius:14px;
    background:linear-gradient(135deg,#06b6d4,#7c3aed);
    color:#fff;
    font-size:13px;
    font-weight:600;
    cursor:pointer;
}

/* Alerts */

.alert{
    padding:14px 16px;
    border-radius:14px;
    margin-bottom:18px;
    font-size:13px;
}

.success{
    background:#16a34a20;
    color:#4ade80;
}

.error{
    background:#dc262620;
    color:#f87171;
}

/* Search */

.search-box{
    background:#111827;
    padding:18px;
    border-radius:20px;
    margin-bottom:22px;
}

.search-box form{
    display:flex;
    gap:14px;
}

.search-box input{
    flex:1;
    height:50px;
    border:none;
    outline:none;
    background:#1e293b;
    border-radius:14px;
    padding:0 16px;
    color:#fff;
}

.search-btn{
    width:140px;
    border:none;
    border-radius:14px;
    background:linear-gradient(135deg,#06b6d4,#7c3aed);
    color:#fff;
    cursor:pointer;
    font-weight:600;
}

/* Table */

.table-box{
    background:#111827;
    border-radius:22px;
    overflow:hidden;
}

.table-head{
    display:grid;
    grid-template-columns:
    70px
    1.3fr
    1fr
    1fr
    1fr
    1.5fr
    1.5fr
    150px;
    gap:14px;
    padding:18px 20px;
    background:#1e293b;
    font-size:13px;
    font-weight:600;
}

.table-row{
    display:grid;
    grid-template-columns:
    70px
    1.3fr
    1fr
    1fr
    1fr
    1.5fr
    1.5fr
    150px;
    gap:14px;
    align-items:center;
    padding:18px 20px;
    border-bottom:1px solid rgba(255,255,255,0.05);
    transition:.3s;
}

.table-row:hover{
    background:#18212f;
}

/* Text */

.table-text{
    font-size:13px;
    color:#e2e8f0;
    line-height:1.5;
}

.username{
    color:#38bdf8;
    font-weight:600;
}

/* Pincode Tags */

.pincode-wrap{
    display:flex;
    flex-wrap:wrap;
    gap:8px;
}

.pincode{
    background:#06b6d420;
    color:#67e8f9;
    font-size:11px;
    padding:6px 10px;
    border-radius:30px;
}

/* Actions */

.action-buttons{
    display:flex;
    gap:10px;
}

.edit-btn,
.delete-btn{
    width:40px;
    height:40px;
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

/* Modal */

.modal{
    position:fixed;
    inset:0;
    background:rgba(0,0,0,0.75);
    display:none;
    align-items:center;
    justify-content:center;
    z-index:9999;
    padding:20px;
}

.modal.show{
    display:flex;
}

.modal-box{
    width:100%;
    max-width:650px;
    background:#111827;
    border-radius:24px;
    padding:28px;
    max-height:90vh;
    overflow-y:auto;
}

.modal-title{
    font-size:22px;
    font-weight:600;
    margin-bottom:24px;
}

/* Form */

.form-grid{
    display:grid;
    grid-template-columns:repeat(2,1fr);
    gap:18px;
}

.input-box{
    display:flex;
    flex-direction:column;
}

.full-width{
    grid-column:1/3;
}

.input-box label{
    font-size:13px;
    margin-bottom:8px;
    color:#cbd5e1;
}

.input-box input,
.input-box textarea{
    width:100%;
    border:none;
    outline:none;
    background:#1e293b;
    border-radius:14px;
    padding:14px 16px;
    color:#fff;
    font-size:13px;
}

.input-box textarea{
    min-height:100px;
    resize:none;
}

/* Modal Buttons */

.modal-buttons{
    display:flex;
    gap:12px;
    margin-top:22px;
}

.submit-btn,
.close-btn{
    flex:1;
    height:52px;
    border:none;
    border-radius:14px;
    cursor:pointer;
    font-size:13px;
    font-weight:600;
}

.submit-btn{
    background:linear-gradient(135deg,#06b6d4,#7c3aed);
    color:#fff;
}

.close-btn{
    background:#1e293b;
    color:#fff;
}

/* Empty */

.empty-box{
    background:#111827;
    border-radius:22px;
    padding:70px 20px;
    text-align:center;
}

.empty-box i{
    font-size:55px;
    color:#475569;
    margin-bottom:14px;
}

.empty-box h2{
    font-size:22px;
    margin-bottom:5px;
}

.empty-box p{
    color:#94a3b8;
    font-size:13px;
}

/* Responsive */

@media(max-width:1200px){

    .table-box{
        overflow-x:auto;
    }

    .table-head,
    .table-row{
        min-width:1250px;
    }

}

@media(max-width:900px){

    .main-content{
        margin-left:0;
        padding:85px 15px 20px;
    }

    .page-header{
        flex-direction:column;
        align-items:flex-start;
        gap:15px;
    }

    .search-box form{
        flex-direction:column;
    }

    .search-btn{
        width:100%;
        height:50px;
    }

    .form-grid{
        grid-template-columns:1fr;
    }

    .full-width{
        grid-column:auto;
    }

}

</style>

</head>
<body>

<!-- Sidebar -->

<?php include 'nav.php'; ?>

<!-- Main -->

<div class="main-content">

    <!-- Header -->

    <div class="page-header">

        <div class="page-title">

            <h1>All seller</h1>

            <p>
                Manage seller accounts and service pincodes
            </p>

        </div>

        <button class="add-btn" onclick="openModal()">

            <i class="fa-solid fa-plus"></i>
            Add seller

        </button>

    </div>

    <!-- Alerts -->

    <?php if($success != ""){ ?>

        <div class="alert success">
            <?php echo $success; ?>
        </div>

    <?php } ?>

    <?php if($error != ""){ ?>

        <div class="alert error">
            <?php echo $error; ?>
        </div>

    <?php } ?>

    <!-- Search -->

    <div class="search-box">

        <form method="GET">

            <input 
                type="text"
                name="search"
                placeholder="Search seller, username, email or phone"
                value="<?php echo htmlspecialchars($search); ?>"
            >

            <button type="submit" class="search-btn">

                <i class="fa-solid fa-magnifying-glass"></i>
                Search

            </button>

        </form>

    </div>

    <!-- Table -->

    <?php if(count($franchises) > 0){ ?>

    <div class="table-box">

        <!-- Head -->

        <div class="table-head">

            <div>ID</div>
            <div>Name</div>
            <div>Username</div>
            <div>Phone</div>
            <div>Email</div>
            <div>Address</div>
            <div>Service Pincodes</div>
            <div>Actions</div>

        </div>

        <!-- Rows -->

        <?php foreach($franchises as $f){ ?>

        <div class="table-row">

            <!-- ID -->

            <div class="table-text">

                #<?php echo $f['id']; ?>

            </div>

            <!-- Name -->

            <div class="table-text">

                <?php echo htmlspecialchars($f['name']); ?>

            </div>

            <!-- Username -->

            <div class="table-text username">

                @<?php echo htmlspecialchars($f['username']); ?>

            </div>

            <!-- Phone -->

            <div class="table-text">

                <?php echo htmlspecialchars($f['phone']); ?>

            </div>

            <!-- Email -->

            <div class="table-text">

                <?php echo htmlspecialchars($f['email']); ?>

            </div>

            <!-- Address -->

            <div class="table-text">

                <?php echo htmlspecialchars($f['address']); ?>

            </div>

            <!-- Pincodes -->

            <div class="pincode-wrap">

                <?php

                $pins = explode(",",$f['service_pincodes']);

                foreach($pins as $pin){

                    $pin = trim($pin);

                    if(!empty($pin)){
                ?>

                <div class="pincode">

                    <?php echo htmlspecialchars($pin); ?>

                </div>

                <?php } } ?>

            </div>

            <!-- Actions -->

            <div class="action-buttons">

                <a 
                    href="edit-franchise.php?id=<?php echo $f['id']; ?>"
                    class="edit-btn"
                >

                    <i class="fa-solid fa-pen"></i>

                </a>

                <a 
                    href="all-franchises.php?delete=<?php echo $f['id']; ?>"
                    class="delete-btn"
                    onclick="return confirm('Delete this franchise?')"
                >

                    <i class="fa-solid fa-trash"></i>

                </a>

            </div>

        </div>

        <?php } ?>

    </div>

    <?php }else{ ?>

    <div class="empty-box">

        <i class="fa-solid fa-store"></i>

        <h2>No Franchises Found</h2>

        <p>
            No franchise records available
        </p>

    </div>

    <?php } ?>

</div>

<!-- Modal -->

<div class="modal" id="franchiseModal">

    <div class="modal-box">

        <div class="modal-title">
            Add Franchise
        </div>

        <form method="POST">

            <div class="form-grid">

                <!-- Name -->

                <div class="input-box">

                    <label>Franchise Name</label>

                    <input 
                        type="text"
                        name="name"
                        required
                    >

                </div>

                <!-- Username -->

                <div class="input-box">

                    <label>Username</label>

                    <input 
                        type="text"
                        name="username"
                        required
                    >

                </div>

                <!-- Password -->

                <div class="input-box">

                    <label>Password</label>

                    <input 
                        type="password"
                        name="password"
                        required
                    >

                </div>

                <!-- Phone -->

                <div class="input-box">

                    <label>Phone</label>

                    <input 
                        type="text"
                        name="phone"
                    >

                </div>

                <!-- Email -->

                <div class="input-box full-width">

                    <label>Email</label>

                    <input 
                        type="email"
                        name="email"
                    >

                </div>

                <!-- Address -->

                <div class="input-box full-width">

                    <label>Address</label>

                    <textarea 
                        name="address"
                    ></textarea>

                </div>

                <!-- Pincodes -->

                <div class="input-box full-width">

                    <label>
                        Service Pincodes
                    </label>

                    <textarea 
                        name="service_pincodes"
                        placeholder="221001,221002,221003"
                        required
                    ></textarea>

                </div>

            </div>

            <!-- Buttons -->

            <div class="modal-buttons">

                <button 
                    type="submit"
                    name="add_franchise"
                    class="submit-btn"
                >

                    Add Franchise

                </button>

                <button 
                    type="button"
                    class="close-btn"
                    onclick="closeModal()"
                >

                    Cancel

                </button>

            </div>

        </form>

    </div>

</div>

<script>

function openModal(){

    document.getElementById("franchiseModal").classList.add("show");

}

function closeModal(){

    document.getElementById("franchiseModal").classList.remove("show");

}

</script>

</body>
</html>