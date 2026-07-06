<?php
session_start();

require_once 'db.php';

/* LOGIN CHECK */

if(!isset($_SESSION['admin_id'])){

    header("Location:index.php");
    exit;
}

$id = intval($_GET['id'] ?? 0);

$stmt = $pdo->prepare("SELECT * FROM service_pincodes WHERE id=?");
$stmt->execute([$id]);
$pincode = $stmt->fetch();

if(!$pincode){

    header("Location:all-pincodes.php");
    exit;
}

$success = "";
$error = "";

/* UPDATE PINCODE */

if(isset($_POST['edit_pincode'])){

    $pincode_val = trim($_POST['pincode']);
    $delivery_charge = trim($_POST['delivery_charge']);
    $city = trim($_POST['city']);
    $is_express = isset($_POST['is_express']) ? 1 : 0;

    if($pincode_val == "" || $delivery_charge == ""){

        $error = "All fields are required";

    }else{

        $update = $pdo->prepare("
            UPDATE service_pincodes
            SET pincode=?, delivery_charge=?, city=?, is_express=?
            WHERE id=?
        ");

        $run = $update->execute([
            $pincode_val,
            $delivery_charge,
            $city,
            $is_express,
            $id
        ]);

        if($run){

            $success = "Pincode updated successfully";

            $stmt = $pdo->prepare("SELECT * FROM service_pincodes WHERE id=?");
            $stmt->execute([$id]);
            $pincode = $stmt->fetch();

        }else{

            $error = "Failed to update pincode";
        }
    }
}
?>

<!DOCTYPE html>
<html lang="en">
<head>

<meta charset="UTF-8">

<meta name="viewport"
content="width=device-width,
initial-scale=1.0">

<title>
Edit Pincode
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

.form-card{
    background:#111827;
    border-radius:28px;
    padding:30px;
    max-width:650px;
}

.page-title{
    font-size:28px;
    font-weight:700;
    margin-bottom:6px;
}

.page-sub{
    font-size:13px;
    color:#94a3b8;
    margin-bottom:28px;
}

.alert{
    padding:15px 18px;
    border-radius:14px;
    margin-bottom:20px;
    font-size:13px;
    font-weight:500;
}

.success{
    background:#16a34a20;
    color:#4ade80;
}

.error{
    background:#ef444420;
    color:#f87171;
}

.input-box{
    margin-bottom:20px;
}

.input-box label{
    display:block;
    margin-bottom:8px;
    font-size:13px;
    color:#cbd5e1;
}

.input-box input{
    width:100%;
    height:55px;
    border:none;
    outline:none;
    background:#1e293b;
    border-radius:16px;
    padding:0 18px;
    color:#fff;
    font-size:14px;
}

.submit-btn{
    width:100%;
    height:58px;
    border:none;
    border-radius:18px;
    background:linear-gradient(
        135deg,
        #06b6d4,
        #7c3aed
    );
    color:#fff;
    font-size:15px;
    font-weight:700;
    cursor:pointer;
    transition:.3s;
}

.submit-btn:hover{
    opacity:.92;
}

@media(max-width:900px){

    .main-content{
        margin-left:0;
        padding:85px 15px 20px;
    }

    .form-card{
        padding:24px;
    }
}

</style>

</head>
<body>

<?php include 'nav.php'; ?>

<div class="main-content">

    <div class="form-card">

        <div class="page-title">
            Edit Service Pincode
        </div>

        <div class="page-sub">
            Update delivery service area details
        </div>

        <?php if($success != ""){ ?>
        <div class="alert success"><?php echo $success; ?></div>
        <?php } ?>

        <?php if($error != ""){ ?>
        <div class="alert error"><?php echo $error; ?></div>
        <?php } ?>

        <form method="POST">

            <div class="input-box">

                <label>Pincode</label>

                <input
                type="text"
                name="pincode"
                maxlength="10"
                value="<?php echo htmlspecialchars($pincode['pincode']); ?>"
                required>

            </div>

            <div class="input-box">

                <label>Delivery Charge</label>

                <input
                type="number"
                name="delivery_charge"
                value="<?php echo htmlspecialchars($pincode['delivery_charge']); ?>"
                required>

            </div>

            <div class="input-box">

                <label>City</label>

                <input
                type="text"
                name="city"
                value="<?php echo htmlspecialchars($pincode['city'] ?? ''); ?>">

            </div>

            <div class="input-box" style="display:flex;align-items:center;gap:12px;">

                <input
                type="checkbox"
                name="is_express"
                id="is_express"
                style="width:20px;height:20px;"
                <?php echo !empty($pincode['is_express']) ? 'checked' : ''; ?>>

                <label for="is_express" style="margin:0;">
                    Enable 24-Hour Express Delivery
                </label>

            </div>

            <button
            type="submit"
            name="edit_pincode"
            class="submit-btn">

                <i class="fa-solid fa-floppy-disk"></i>
                Save Changes

            </button>

        </form>

    </div>

</div>

</body>
</html>
