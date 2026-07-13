<?php
session_start();

require_once 'db.php';

/* Login */

if(!isset($_SESSION['admin_id'])){

    header("Location:index.php");
    exit;
}

/* Check Existing */

$stmt = $pdo->query("SELECT * FROM razorpay_settings LIMIT 1");

$settings = $stmt->fetch();

$success = "";
$error = "";

/* Save Settings */

if(isset($_POST['save_settings'])){

    $razorpay_key = trim($_POST['razorpay_key']);
    $razorpay_secret = trim($_POST['razorpay_secret']);

    /* Blank secret means "keep the existing one" once a value is already saved */

    if(empty($razorpay_secret) && $settings){
        $razorpay_secret = $settings['razorpay_secret'];
    }

    if(empty($razorpay_key) || empty($razorpay_secret)){

        $error = "All Fields Required";

    }else{

        /* Update */

        if($settings){

            $update = $pdo->prepare("UPDATE razorpay_settings
            SET
            razorpay_key=?,
            razorpay_secret=?
            WHERE id=?");

            $run = $update->execute([

                $razorpay_key,
                $razorpay_secret,
                $settings['id']

            ]);

        }else{

            /* Insert */

            $insert = $pdo->prepare("INSERT INTO razorpay_settings
            (
                razorpay_key,
                razorpay_secret
            )
            VALUES
            (
                ?,
                ?
            )");

            $run = $insert->execute([

                $razorpay_key,
                $razorpay_secret

            ]);

        }

        if($run){

            $success = "Razorpay Settings Saved Successfully";

            $stmt = $pdo->query("SELECT * FROM razorpay_settings LIMIT 1");

            $settings = $stmt->fetch();

        }else{

            $error = "Failed To Save Settings";

        }

    }

}

?>

<!DOCTYPE html>
<html lang="en">
<head>

<meta charset="UTF-8">

<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>Razorpay Settings</title>

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
    margin-bottom:25px;
}

.page-header h1{
    font-size:24px;
    margin-bottom:5px;
}

.page-header p{
    color:#94a3b8;
    font-size:13px;
}

/* Form Box */

.form-box{
    width:100%;
    max-width:650px;
    background:#111827;
    border-radius:24px;
    padding:30px;
}

/* Alerts */

.alert{
    padding:14px 16px;
    border-radius:14px;
    margin-bottom:20px;
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

/* Inputs */

.input-box{
    margin-bottom:22px;
}

.input-box label{
    display:block;
    margin-bottom:8px;
    font-size:13px;
    color:#cbd5e1;
    font-weight:500;
}

.input-box input{
    width:100%;
    height:55px;
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
    height:56px;
    border:none;
    border-radius:16px;
    background:linear-gradient(135deg,#06b6d4,#7c3aed);
    color:#fff;
    font-size:14px;
    font-weight:600;
    cursor:pointer;
    transition:.3s;
}

.submit-btn:hover{
    transform:translateY(-2px);
}

/* Info Box */

.info-box{
    margin-top:20px;
    background:#06b6d410;
    border:1px solid #06b6d430;
    border-radius:18px;
    padding:18px;
}

.info-box h3{
    font-size:14px;
    margin-bottom:8px;
    color:#67e8f9;
}

.info-box p{
    font-size:13px;
    color:#cbd5e1;
    line-height:1.7;
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

    <!-- Header -->

    <div class="page-header">

        <h1>Razorpay Settings</h1>

        <p>
            Manage Razorpay API credentials securely
        </p>

    </div>

    <!-- Form -->

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

            <!-- Razorpay Key -->

            <div class="input-box">

                <label>
                    Razorpay Key ID
                </label>

                <input 
                    type="text"
                    name="razorpay_key"
                    placeholder="rzp_live_xxxxxxxxx"
                    value="<?php echo htmlspecialchars($settings['razorpay_key'] ?? ''); ?>"
                    required
                >

            </div>

            <!-- Secret -->

            <div class="input-box">

                <label>
                    Razorpay Secret Key
                </label>

                <input
                    type="password"
                    name="razorpay_secret"
                    placeholder="<?php echo !empty($settings['razorpay_secret']) ? 'Leave blank to keep existing secret' : 'Enter Razorpay Secret'; ?>"
                    autocomplete="new-password"
                    <?php echo empty($settings['razorpay_secret']) ? 'required' : ''; ?>
                >

            </div>

            <!-- Submit -->

            <button 
                type="submit"
                name="save_settings"
                class="submit-btn"
            >

                <i class="fa-solid fa-floppy-disk"></i>
                Save Razorpay Settings

            </button>

        </form>

        <!-- Info -->

        <div class="info-box">

            <h3>
                Razorpay Integration
            </h3>

            <p>
                Add your Razorpay Live/Test API credentials here.
                These keys will be used for payment gateway integration
                in your mobile application and website checkout.
            </p>

        </div>

    </div>

</div>

</body>
</html>