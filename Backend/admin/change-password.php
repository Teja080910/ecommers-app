<?php
session_start();

require_once 'db.php';

/* Login Check */

if(!isset($_SESSION['admin_id'])){

    header("Location:index.php");
    exit;
}

$success = "";
$error = "";

/* Change Password */

if(isset($_POST['change_password'])){

    $current_password = trim($_POST['current_password']);
    $new_password = trim($_POST['new_password']);
    $confirm_password = trim($_POST['confirm_password']);

    /* Fetch Admin */

    $stmt = $pdo->prepare("SELECT * FROM admins WHERE id=?");

    $stmt->execute([$_SESSION['admin_id']]);

    $admin = $stmt->fetch();

    if(!$admin){

        $error = "Admin Not Found";

    }else{

        /* Verify Old Password */

        if(!password_verify($current_password,$admin['password'])){

            $error = "Current Password Incorrect";

        }else if(strlen($new_password) < 6){

            $error = "New Password Must Be Minimum 6 Characters";

        }else if($new_password != $confirm_password){

            $error = "Confirm Password Not Matched";

        }else{

            /* Hash Password */

            $hashed_password = password_hash($new_password,PASSWORD_DEFAULT);

            $update = $pdo->prepare("UPDATE admins SET password=? WHERE id=?");

            $run = $update->execute([

                $hashed_password,
                $_SESSION['admin_id']

            ]);

            if($run){

                $success = "Password Changed Successfully";

            }else{

                $error = "Failed To Change Password";

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

<title>Change Password</title>

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

/* Form */

.form-box{
    width:100%;
    max-width:550px;
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
    margin-bottom:20px;
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

/* Security Box */

.security-box{
    margin-top:20px;
    background:#06b6d410;
    border:1px solid #06b6d430;
    border-radius:18px;
    padding:18px;
}

.security-box h3{
    font-size:14px;
    margin-bottom:8px;
    color:#67e8f9;
}

.security-box p{
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

        <h1>Change Password</h1>

        <p>
            Update your admin account password securely
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

            <!-- Current Password -->

            <div class="input-box">

                <label>
                    Current Password
                </label>

                <input 
                    type="password"
                    name="current_password"
                    placeholder="Enter Current Password"
                    required
                >

            </div>

            <!-- New Password -->

            <div class="input-box">

                <label>
                    New Password
                </label>

                <input 
                    type="password"
                    name="new_password"
                    placeholder="Enter New Password"
                    required
                >

            </div>

            <!-- Confirm Password -->

            <div class="input-box">

                <label>
                    Confirm Password
                </label>

                <input 
                    type="password"
                    name="confirm_password"
                    placeholder="Confirm New Password"
                    required
                >

            </div>

            <!-- Submit -->

            <button 
                type="submit"
                name="change_password"
                class="submit-btn"
            >

                <i class="fa-solid fa-lock"></i>
                Change Password

            </button>

        </form>

        <!-- Security -->

        <div class="security-box">

            <h3>
                Security Tips
            </h3>

            <p>
                Use a strong password with letters, numbers and symbols.
                Never share your admin password with anyone.
            </p>

        </div>

    </div>

</div>

</body>
</html>