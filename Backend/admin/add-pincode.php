<?php
session_start();

require_once 'db.php';

/* LOGIN CHECK */

if(!isset($_SESSION['admin_id'])){

    header("Location:index.php");
    exit;
}

$success = "";
$error = "";

/* ADD PINCODE */

if(isset($_POST['add_pincode'])){

    $pincode =
    trim($_POST['pincode']);

    $delivery_charge =
    trim($_POST['delivery_charge']);

    /* VALIDATION */

    if($pincode == "" ||
       $delivery_charge == ""){

        $error =
        "All fields are required";

    }else{

        /* CHECK EXIST */

        $check =
        $pdo->prepare(

        "SELECT id
        FROM service_pincodes
        WHERE pincode=?"

        );

        $check->execute([
        $pincode
        ]);

        if($check->rowCount() > 0){

            $error =
            "Pincode already exists";

        }else{

            /* INSERT */

            $stmt =
            $pdo->prepare(

            "INSERT INTO service_pincodes

            (
            pincode,
            delivery_charge
            )

            VALUES

            (
            ?,
            ?
            )"

            );

            $insert =
            $stmt->execute([

                $pincode,
                $delivery_charge
            ]);

            if($insert){

                $success =
                "Service pincode added successfully";

            }else{

                $error =
                "Failed to add pincode";
            }
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
Add Pincode
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

/* CARD */

.form-card{
    background:#111827;
    border-radius:28px;
    padding:30px;
    max-width:650px;
}

/* HEADER */

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

/* ALERT */

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

/* INPUT */

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

/* BUTTON */

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

/* RESPONSIVE */

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

        <!-- HEADER -->

        <div class="page-title">

            Add Service Pincode

        </div>

        <div class="page-sub">

            Add delivery service areas
            with delivery charges

        </div>

        <!-- ALERTS -->

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

        <!-- FORM -->

        <form method="POST">

            <!-- PINCODE -->

            <div class="input-box">

                <label>
                    Pincode
                </label>

                <input

                type="text"

                name="pincode"

                maxlength="10"

                placeholder="Enter service pincode"

                required>

            </div>

            <!-- DELIVERY CHARGE -->

            <div class="input-box">

                <label>
                    Delivery Charge
                </label>

                <input

                type="number"

                name="delivery_charge"

                placeholder="Enter delivery charge"

                required>

            </div>

            <!-- BUTTON -->

            <button
            type="submit"
            name="add_pincode"
            class="submit-btn">

                <i class="fa-solid fa-plus"></i>

                Add Pincode

            </button>

        </form>

    </div>

</div>

</body>
</html>