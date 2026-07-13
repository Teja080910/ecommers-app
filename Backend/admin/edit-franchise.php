<?php
session_start();

require_once 'db.php';

/* Login */

if(!isset($_SESSION['admin_id'])){

    header("Location:index.php");
    exit;
}

/* ID */

if(!isset($_GET['id'])){

    header("Location:all-franchises.php");
    exit;
}

$id = intval($_GET['id']);

/* Fetch Franchise */

$stmt = $pdo->prepare("SELECT * FROM seller WHERE id=?");

$stmt->execute([$id]);

$franchise = $stmt->fetch();

if(!$franchise){

    header("Location:all-franchises.php");
    exit;
}

/* Selected Pincodes */

$selectedPins = [];

if(!empty($franchise['service_pincodes'])){

    $selectedPins = explode(",",$franchise['service_pincodes']);

}

/* Fetch Pincodes */

$pincodeQuery = $pdo->query("SELECT * FROM service_pincodes ORDER BY pincode ASC");

$allPincodes = $pincodeQuery->fetchAll();

/* Update */

$success = "";
$error = "";

if(isset($_POST['update_franchise'])){

    $name = trim($_POST['name']);
    $username = trim($_POST['username']);
    $phone = trim($_POST['phone']);
    $email = trim($_POST['email']);
    $address = trim($_POST['address']);

    $service_pincodes = "";

    if(isset($_POST['service_pincodes'])){

        $service_pincodes = implode(",",$_POST['service_pincodes']);

    }

    /* Password */

    if(!empty($_POST['password'])){

        $password = password_hash($_POST['password'],PASSWORD_DEFAULT);

        $update = $pdo->prepare("UPDATE seller SET
        name=?,
        username=?,
        password=?,
        phone=?,
        email=?,
        address=?,
        service_pincodes=?
        WHERE id=?");

        $run = $update->execute([

            $name,
            $username,
            $password,
            $phone,
            $email,
            $address,
            $service_pincodes,
            $id

        ]);

    }else{

        $update = $pdo->prepare("UPDATE seller SET
        name=?,
        username=?,
        phone=?,
        email=?,
        address=?,
        service_pincodes=?
        WHERE id=?");

        $run = $update->execute([

            $name,
            $username,
            $phone,
            $email,
            $address,
            $service_pincodes,
            $id

        ]);

    }

    if($run){

        $success = "seller Updated Successfully";

        $stmt = $pdo->prepare("SELECT * FROM seller WHERE id=?");

        $stmt->execute([$id]);

        $franchise = $stmt->fetch();

        $selectedPins = explode(",",$franchise['service_pincodes']);

    }else{

        $error = "Failed To Update Franchise";

    }

}
?>

<!DOCTYPE html>
<html lang="en">
<head>

<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>Edit Franchise</title>

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

.main-content{
    margin-left:240px;
    padding:28px;
}

.form-card{
    background:#111827;
    border-radius:24px;
    padding:28px;
    max-width:900px;
    margin:auto;
}

.page-title{
    font-size:24px;
    font-weight:600;
    margin-bottom:6px;
}

.page-sub{
    color:#94a3b8;
    font-size:13px;
    margin-bottom:28px;
}

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

.form-grid{
    display:grid;
    grid-template-columns:repeat(2,1fr);
    gap:18px;
}

.full-width{
    grid-column:1/3;
}

.input-box{
    display:flex;
    flex-direction:column;
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

/* Multi Select */

.multi-select-box{
    width:100%;
    max-height:220px;
    overflow-y:auto;
    background:#1e293b;
    border-radius:16px;
    padding:14px;
    display:flex;
    flex-wrap:wrap;
    gap:10px;
}

.pin-item{
    position:relative;
    cursor:pointer;
}

.pin-item input{
    display:none;
}

.pin-item span{
    display:flex;
    align-items:center;
    justify-content:center;
    padding:10px 14px;
    border-radius:12px;
    background:#0f172a;
    color:#cbd5e1;
    font-size:13px;
    transition:.3s;
}

.pin-item input:checked + span{
    background:linear-gradient(135deg,#06b6d4,#7c3aed);
    color:#fff;
}

#pincodeFilter{
    width:100%;
    border:none;
    outline:none;
    background:#1e293b;
    border-radius:14px;
    padding:14px 16px;
    color:#fff;
    font-size:13px;
    margin-bottom:10px;
}

.submit-btn{
    width:100%;
    height:54px;
    border:none;
    border-radius:16px;
    margin-top:24px;
    background:linear-gradient(135deg,#06b6d4,#7c3aed);
    color:#fff;
    font-size:14px;
    font-weight:600;
    cursor:pointer;
}

@media(max-width:900px){

    .main-content{
        margin-left:0;
        padding:85px 15px 20px;
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

<?php include 'nav.php'; ?>

<div class="main-content">

    <div class="form-card">

        <div class="page-title">
            Edit seller
        </div>

        <div class="page-sub">
            Update seller details
        </div>

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

        <form method="POST">

            <div class="form-grid">

                <div class="input-box">

                    <label>seller Name</label>

                    <input 
                        type="text"
                        name="name"
                        value="<?php echo htmlspecialchars($franchise['name']); ?>"
                        required
                    >

                </div>

                <div class="input-box">

                    <label>Username</label>

                    <input 
                        type="text"
                        name="username"
                        value="<?php echo htmlspecialchars($franchise['username']); ?>"
                        required
                    >

                </div>

                <div class="input-box">

                    <label>New Password</label>

                    <input 
                        type="password"
                        name="password"
                        placeholder="Leave blank to keep old password"
                    >

                </div>

                <div class="input-box">

                    <label>Phone</label>

                    <input 
                        type="text"
                        name="phone"
                        value="<?php echo htmlspecialchars($franchise['phone']); ?>"
                    >

                </div>

                <div class="input-box full-width">

                    <label>Email</label>

                    <input 
                        type="email"
                        name="email"
                        value="<?php echo htmlspecialchars($franchise['email']); ?>"
                    >

                </div>

                <div class="input-box full-width">

                    <label>Address</label>

                    <textarea name="address"><?php echo htmlspecialchars($franchise['address']); ?></textarea>

                </div>

                <!-- Pincodes -->

                <div class="input-box full-width">

                    <label>
                        Service Pincodes
                    </label>

                    <input
                        type="text"
                        id="pincodeFilter"
                        placeholder="Search pincode..."
                        onkeyup="filterPincodes()"
                    >

                    <div class="multi-select-box" id="pincodeBox">

                        <?php foreach($allPincodes as $pin){ ?>

                            <label class="pin-item">

                                <input
                                    type="checkbox"
                                    name="service_pincodes[]"
                                    value="<?php echo $pin['pincode']; ?>"

                                    <?php
                                    if(in_array($pin['pincode'],$selectedPins)){
                                        echo 'checked';
                                    }
                                    ?>
                                >

                                <span>
                                    <?php echo $pin['pincode']; ?>
                                </span>

                            </label>

                        <?php } ?>

                    </div>

                </div>

            </div>

            <button type="submit" name="update_franchise" class="submit-btn">

                <i class="fa-solid fa-floppy-disk"></i>
                Update seller

            </button>

        </form>

        <script>
        function filterPincodes(){
            var query = document.getElementById('pincodeFilter').value.trim().toLowerCase();
            var items = document.getElementById('pincodeBox').getElementsByClassName('pin-item');
            for(var i=0;i<items.length;i++){
                var text = items[i].querySelector('span').textContent.toLowerCase();
                items[i].style.display = text.indexOf(query) !== -1 ? '' : 'none';
            }
        }
        </script>

    </div>

</div>

</body>
</html>