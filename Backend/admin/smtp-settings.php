<?php
session_start();

require_once 'db.php';

/* Login */

if(!isset($_SESSION['admin_id'])){

    header("Location:index.php");
    exit;
}

/* Check Existing */

$stmt = $pdo->query("SELECT * FROM smtp_settings LIMIT 1");

$settings = $stmt->fetch();

$success = "";
$error = "";

/* Save Settings */

if(isset($_POST['save_settings'])){

    $smtp_host = trim($_POST['smtp_host']);
    $smtp_port = trim($_POST['smtp_port']);
    $smtp_username = trim($_POST['smtp_username']);
    $smtp_password = trim($_POST['smtp_password']);
    $from_email = trim($_POST['from_email']);
    $from_name = trim($_POST['from_name']);

    /* Blank password means "keep the existing one" once a value is already saved */

    if(empty($smtp_password) && $settings){
        $smtp_password = $settings['smtp_password'];
    }

    if(empty($smtp_host) || empty($smtp_port) || empty($smtp_username) || empty($smtp_password) || empty($from_email)){

        $error = "Host, Port, Username, Password and From Email are required";

    }else{

        /* Update */

        if($settings){

            $update = $pdo->prepare("UPDATE smtp_settings
            SET
            smtp_host=?,
            smtp_port=?,
            smtp_username=?,
            smtp_password=?,
            from_email=?,
            from_name=?
            WHERE id=?");

            $run = $update->execute([

                $smtp_host,
                $smtp_port,
                $smtp_username,
                $smtp_password,
                $from_email,
                $from_name,
                $settings['id']

            ]);

        }else{

            /* Insert */

            $insert = $pdo->prepare("INSERT INTO smtp_settings
            (
                smtp_host,
                smtp_port,
                smtp_username,
                smtp_password,
                from_email,
                from_name
            )
            VALUES
            (
                ?, ?, ?, ?, ?, ?
            )");

            $run = $insert->execute([

                $smtp_host,
                $smtp_port,
                $smtp_username,
                $smtp_password,
                $from_email,
                $from_name

            ]);

        }

        if($run){

            $success = "SMTP Settings Saved Successfully";

            $stmt = $pdo->query("SELECT * FROM smtp_settings LIMIT 1");

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

<title>SMTP Settings</title>

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

.grid-2{
    display:grid;
    grid-template-columns:1fr 1fr;
    gap:16px;
}

@media(max-width:640px){
    .grid-2{
        grid-template-columns:1fr;
    }
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

        <h1>SMTP Settings</h1>

        <p>
            Configure the sender account used to email OTP verification codes
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

            <div class="grid-2">

                <div class="input-box">

                    <label>
                        SMTP Host
                    </label>

                    <input
                        type="text"
                        name="smtp_host"
                        placeholder="smtp.gmail.com"
                        value="<?php echo htmlspecialchars($settings['smtp_host'] ?? ''); ?>"
                        required
                    >

                </div>

                <div class="input-box">

                    <label>
                        SMTP Port
                    </label>

                    <input
                        type="number"
                        name="smtp_port"
                        placeholder="587"
                        value="<?php echo htmlspecialchars($settings['smtp_port'] ?? '587'); ?>"
                        required
                    >

                </div>

            </div>

            <div class="input-box">

                <label>
                    SMTP Username
                </label>

                <input
                    type="text"
                    name="smtp_username"
                    placeholder="your@email.com"
                    value="<?php echo htmlspecialchars($settings['smtp_username'] ?? ''); ?>"
                    required
                >

            </div>

            <div class="input-box">

                <label>
                    SMTP Password
                </label>

                <input
                    type="password"
                    name="smtp_password"
                    placeholder="<?php echo !empty($settings['smtp_password']) ? 'Leave blank to keep existing password' : 'App password'; ?>"
                    autocomplete="new-password"
                    <?php echo empty($settings['smtp_password']) ? 'required' : ''; ?>
                >

            </div>

            <div class="grid-2">

                <div class="input-box">

                    <label>
                        From Email
                    </label>

                    <input
                        type="email"
                        name="from_email"
                        placeholder="noreply@zipzapcart.com"
                        value="<?php echo htmlspecialchars($settings['from_email'] ?? ''); ?>"
                        required
                    >

                </div>

                <div class="input-box">

                    <label>
                        From Name
                    </label>

                    <input
                        type="text"
                        name="from_name"
                        placeholder="Zipzapcart"
                        value="<?php echo htmlspecialchars($settings['from_name'] ?? 'Zipzapcart'); ?>"
                    >

                </div>

            </div>

            <!-- Submit -->

            <button
                type="submit"
                name="save_settings"
                class="submit-btn"
            >

                <i class="fa-solid fa-floppy-disk"></i>
                Save SMTP Settings

            </button>

        </form>

        <!-- Info -->

        <div class="info-box">

            <h3>
                Email OTP Verification
            </h3>

            <p>
                These credentials are used to send login verification codes to
                users' email addresses. For Gmail, use an App Password
                (not your regular password) with 2-Step Verification enabled.
            </p>

        </div>

    </div>

</div>

</body>
</html>
