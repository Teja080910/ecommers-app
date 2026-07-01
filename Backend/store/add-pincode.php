<?php
session_start();

require_once 'db.php';

/* Login Check */

if(!isset($_SESSION['seller_id'])){

    header("Location:index.php");
    exit;
}

/* Logged Franchise */

$franchise_id = $_SESSION['seller_id'];

$success = "";
$error = "";

/* Add Pincode */

if(isset($_POST['add_pincode'])){

    $pincode = trim($_POST['pincode']);

    if(empty($pincode)){

        $error = "Pincode Required";

    }else{

        /* Check In Main Table */

        $check = $pdo->prepare("
            SELECT id 
            FROM service_pincodes 
            WHERE pincode=?
        ");

        $check->execute([$pincode]);

        /* Insert If Not Exists */

        if($check->rowCount() == 0){

            $insert = $pdo->prepare("
                INSERT INTO service_pincodes(pincode) 
                VALUES(?)
            ");

            $insert->execute([$pincode]);

        }

        /* Franchise Pincodes */

        $fstmt = $pdo->prepare("
            SELECT service_pincodes 
            FROM seller_id 
            WHERE id=?
        ");

        $fstmt->execute([$franchise_id]);

        $franchise = $fstmt->fetch();

        $existing_pincodes = [];

        if(!empty($franchise['service_pincodes'])){

            $existing_pincodes = explode(",",$franchise['service_pincodes']);

            $existing_pincodes = array_map('trim',$existing_pincodes);

        }

        /* Check Already Exists */

        if(in_array($pincode,$existing_pincodes)){

            $error = "Pincode Already Added";

        }else{

            $existing_pincodes[] = $pincode;

            $updated_pincodes = implode(",",$existing_pincodes);

            $update = $pdo->prepare("
                UPDATE seller 
                SET service_pincodes=? 
                WHERE id=?
            ");

            $run = $update->execute([

                $updated_pincodes,
                $franchise_id

            ]);

            if($run){

                $success = "Pincode Added Successfully";

            }else{

                $error = "Failed To Add Pincode";

            }

        }

    }

}

?>

<!DOCTYPE html>
<html lang="en">
<head>

<meta charset="UTF-8">

<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>Add Pincode</title>

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

/* Header */

.page-header{
    margin-bottom:25px;
}

.page-header h1{
    font-size:24px;
    margin-bottom:5px;
}

.page-header p{
    font-size:13px;
    color:#94a3b8;
}

/* Form Box */

.form-box{
    width:100%;
    max-width:550px;
    background:#111827;
    border-radius:24px;
    padding:28px;
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

/* Input */

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
    height:54px;
    border:none;
    outline:none;
    background:#1e293b;
    border-radius:16px;
    padding:0 16px;
    color:#fff;
    font-size:14px;
}

/* Button */

.submit-btn{
    width:100%;
    height:54px;
    border:none;
    border-radius:16px;
    background:linear-gradient(135deg,#06b6d4,#7c3aed);
    color:#fff;
    font-size:14px;
    font-weight:600;
    cursor:pointer;
}

/* Responsive */

@media(max-width:900px){

    .main-content{
        margin-left:0;
        padding:85px 15px 20px;
    }

}

</style>

</head>
<body>

<?php include 'nav.php'; ?>

<div class="main-content">

    <div class="page-header">

        <h1>Add Service Pincode</h1>

        <p>
            Add delivery service pincodes
        </p>

    </div>

    <div class="form-box">

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

            <div class="input-box">

                <label>Pincode</label>

                <input 
                    type="text"
                    name="pincode"
                    maxlength="10"
                    placeholder="Enter Service Pincode"
                    required
                >

            </div>

            <button 
                type="submit"
                name="add_pincode"
                class="submit-btn"
            >

                <i class="fa-solid fa-plus"></i>
                Add Pincode

            </button>

        </form>

    </div>

</div>

</body>
</html>