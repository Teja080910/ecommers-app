<?php
session_start();

require_once 'db.php';

if(isset($_SESSION['admin_id'])){
    header("Location: home.php");
    exit;
}

$error = "";

if($_SERVER["REQUEST_METHOD"] == "POST"){

    $username = trim($_POST['username']);
    $password = trim($_POST['password']);

    if(empty($username) || empty($password)){

        $error = "All fields are required";

    }else{

        $stmt = $pdo->prepare("SELECT * FROM admin WHERE username = ?");
        $stmt->execute([$username]);

        $admin = $stmt->fetch();

        if($admin && password_verify($password, $admin['password'])){

            session_regenerate_id(true);

            $_SESSION['admin_id'] = $admin['id'];
            $_SESSION['admin_username'] = $admin['username'];

            header("Location: home.php");
            exit;

        }else{

            $error = "Invalid Username or Password";

        }

    }

}
?>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Admin Login</title>

<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">

<style>

*{
    margin:0;
    padding:0;
    box-sizing:border-box;
    font-family:'Poppins',sans-serif;
}

body{
    min-height:100vh;
    background:#040611;
    display:flex;
    justify-content:center;
    align-items:center;
    overflow:hidden;
    padding:20px;
    position:relative;
}

.circle{
    position:absolute;
    border-radius:50%;
    filter:blur(120px);
    animation:animate 8s infinite alternate ease-in-out;
}

.circle1{
    width:450px;
    height:450px;
    background:#7c3aed;
    top:-180px;
    left:-180px;
    opacity:0.22;
}

.circle2{
    width:450px;
    height:450px;
    background:#06b6d4;
    bottom:-180px;
    right:-180px;
    opacity:0.20;
}

@keyframes animate{
    0%{
        transform:translateY(0px) scale(1);
    }
    100%{
        transform:translateY(40px) scale(1.1);
    }
}

.admin-box{
    width:100%;
    max-width:950px;
    min-height:550px;
    background:rgba(12,14,28,0.72);
    backdrop-filter:blur(24px);
    border-radius:34px;
    overflow:hidden;
    display:flex;
    position:relative;
    z-index:5;
    box-shadow:0 25px 60px rgba(0,0,0,0.6);
}

.left{
    width:48%;
    padding:60px;
    display:flex;
    flex-direction:column;
    justify-content:center;
}

.logo{
    width:95px;
    margin-bottom:30px;
}

.logo img{
    width:100%;
}

.badge{
    width:max-content;
    padding:8px 18px;
    border-radius:50px;
    background:rgba(124,58,237,0.15);
    color:#c4b5fd;
    font-size:13px;
    margin-bottom:18px;
}

.heading{
    color:#fff;
    font-size:44px;
    line-height:1.2;
    font-weight:700;
    margin-bottom:16px;
}

.heading span{
    color:#06b6d4;
}

.text{
    color:#94a3b8;
    font-size:15px;
    line-height:1.8;
}

.right{
    width:52%;
    background:rgba(255,255,255,0.03);
    padding:55px;
    display:flex;
    align-items:center;
}

.form{
    width:100%;
}

.form-title{
    color:#fff;
    font-size:30px;
    font-weight:600;
    margin-bottom:8px;
}

.form-sub{
    color:#64748b;
    font-size:14px;
    margin-bottom:35px;
}

.input-box{
    margin-bottom:22px;
}

.input-box input{
    width:100%;
    height:60px;
    border:none;
    outline:none;
    border-radius:18px;
    background:rgba(255,255,255,0.05);
    padding:0 22px;
    color:#fff;
    font-size:15px;
}

.input-box input::placeholder{
    color:#64748b;
}

.login-btn{
    width:100%;
    height:60px;
    border:none;
    border-radius:18px;
    background:linear-gradient(135deg,#06b6d4,#7c3aed);
    color:#fff;
    font-size:15px;
    font-weight:600;
    cursor:pointer;
}

.footer{
    text-align:center;
    color:#64748b;
    margin-top:25px;
    font-size:13px;
}

.error{
    background:#ff000020;
    color:#ffb4b4;
    padding:14px;
    border-radius:14px;
    margin-bottom:18px;
    font-size:14px;
}

@media(max-width:900px){

    .admin-box{
        flex-direction:column;
        max-width:520px;
    }

    .left,
    .right{
        width:100%;
    }

}

</style>
</head>
<body>

<div class="circle circle1"></div>
<div class="circle circle2"></div>

<div class="admin-box">

    <div class="left">

        <div class="logo">
            <img src="logo.png">
        </div>

        <div class="badge">
            ADMIN PANEL
        </div>

        <div class="heading">
            Control Your <span>Business</span> Easily
        </div>

        <div class="text">
            Access admin dashboard, manage products, orders and analytics securely.
        </div>

    </div>

    <div class="right">

        <form class="form" method="POST">

            <div class="form-title">
                Admin Login
            </div>

            <div class="form-sub">
                Enter your admin credentials
            </div>

            <?php if(!empty($error)){ ?>
                <div class="error">
                    <?php echo $error; ?>
                </div>
            <?php } ?>

            <div class="input-box">
                <input 
                    type="text" 
                    name="username"
                    placeholder="Admin Username"
                    required
                >
            </div>

            <div class="input-box">
                <input 
                    type="password"
                    name="password"
                    placeholder="Admin Password"
                    required
                >
            </div>

            <button type="submit" class="login-btn">
                Secure Login
            </button>

            <div class="footer">
                Premium Admin Access
            </div>

        </form>

    </div>

</div>

</body>
</html>