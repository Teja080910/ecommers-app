<?php
session_start();

require_once 'db.php';

if(isset($_SESSION['seller_id'])){
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

        $stmt = $pdo->prepare("SELECT * FROM seller WHERE username = ?");
        $stmt->execute([$username]);

        $franchise = $stmt->fetch();

        if($franchise && password_verify($password, $franchise['password'])){

            session_regenerate_id(true);

            $_SESSION['seller_id'] = $franchise['id'];
            $_SESSION['franchise_name'] = $franchise['name'];
            $_SESSION['franchise_username'] = $franchise['username'];

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
<title>Seller Store Login</title>

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
    background:#060816;
    display:flex;
    align-items:center;
    justify-content:center;
    overflow:hidden;
    padding:20px;
    position:relative;
}

/* Animated Background */

.bg{
    position:absolute;
    width:600px;
    height:600px;
    border-radius:50%;
    filter:blur(140px);
    animation:move 10s infinite alternate ease-in-out;
}

.bg1{
    background:#facc15;
    top:-250px;
    left:-200px;
    opacity:0.18;
}

.bg2{
    background:#3b82f6;
    bottom:-250px;
    right:-200px;
    opacity:0.18;
    animation-delay:2s;
}

@keyframes move{
    0%{
        transform:translateY(0px) translateX(0px) scale(1);
    }
    100%{
        transform:translateY(40px) translateX(20px) scale(1.1);
    }
}

.login-box{
    width:100%;
    max-width:900px;
    min-height:500px;
    background:rgba(16,18,35,0.75);
    backdrop-filter:blur(22px);
    border-radius:32px;
    overflow:hidden;
    display:flex;
    position:relative;
    z-index:5;
    box-shadow:
    0 20px 60px rgba(0,0,0,0.55);
    animation:showBox 1s ease;
}

@keyframes showBox{
    from{
        opacity:0;
        transform:translateY(40px) scale(.95);
    }
    to{
        opacity:1;
        transform:translateY(0) scale(1);
    }
}

/* Left Side */

.left{
    flex:1;
    padding:60px;
    display:flex;
    flex-direction:column;
    justify-content:center;
    position:relative;
}

.logo{
    width:90px;
    margin-bottom:30px;
    animation:float 4s infinite ease-in-out;
}

.logo img{
    width:100%;
    object-fit:contain;
}

@keyframes float{
    0%{
        transform:translateY(0px);
    }
    50%{
        transform:translateY(-10px);
    }
    100%{
        transform:translateY(0px);
    }
}

.title{
    color:#fff;
    font-size:42px;
    font-weight:700;
    line-height:1.2;
    margin-bottom:12px;
}

.title span{
    color:#facc15;
}

.desc{
    color:#94a3b8;
    font-size:15px;
    line-height:1.7;
    max-width:400px;
}

/* Right Side */

.right{
    width:420px;
    background:rgba(255,255,255,0.03);
    padding:50px 40px;
    display:flex;
    flex-direction:column;
    justify-content:center;
}

.form-title{
    color:#fff;
    font-size:28px;
    font-weight:600;
    margin-bottom:8px;
}

.form-sub{
    color:#64748b;
    font-size:14px;
    margin-bottom:28px;
}

.input-box{
    margin-bottom:22px;
}

.input-box input{
    width:100%;
    height:58px;
    border:none;
    outline:none;
    background:rgba(255,255,255,0.05);
    border-radius:18px;
    padding:0 20px;
    color:#fff;
    font-size:15px;
    transition:.3s;
}

.input-box input:focus{
    background:rgba(255,255,255,0.08);
    transform:scale(1.02);
}

.input-box input::placeholder{
    color:#64748b;
}

.login-btn{
    width:100%;
    height:58px;
    border:none;
    border-radius:18px;
    background:linear-gradient(135deg,#facc15,#f59e0b);
    color:#000;
    font-size:15px;
    font-weight:700;
    cursor:pointer;
    transition:.35s;
    margin-top:10px;
}

.login-btn:hover{
    transform:translateY(-3px);
    box-shadow:0 15px 30px rgba(250,204,21,0.35);
}

.bottom-text{
    color:#64748b;
    text-align:center;
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

/* Responsive */

@media(max-width:850px){

    .login-box{
        flex-direction:column;
        max-width:500px;
    }

    .left{
        padding:45px 35px 20px;
    }

    .right{
        width:100%;
        padding:35px;
    }

    .title{
        font-size:34px;
    }

}

@media(max-width:500px){

    .left,
    .right{
        padding:30px 22px;
    }

    .title{
        font-size:28px;
    }

    .form-title{
        font-size:24px;
    }

}

</style>
</head>
<body>

<div class="bg bg1"></div>
<div class="bg bg2"></div>

<div class="login-box">

    <div class="left">

        <div class="logo">
            <img src="logo.png">
        </div>

        <div class="title">
            Smart <span>Store</span><br>
            Franchise Panel
        </div>

        <div class="desc">
            Manage products, orders and customers with a modern premium dashboard experience.
        </div>

    </div>

    <div class="right">

        <form method="POST">

            <div class="form-title">
                Franchise Login
            </div>

            <div class="form-sub">
                Enter your franchise credentials
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
                    placeholder="Username"
                    required
                >
            </div>

            <div class="input-box">
                <input 
                    type="password"
                    name="password"
                    placeholder="Password"
                    required
                >
            </div>

            <button type="submit" class="login-btn">
                Login Now
            </button>

            <div class="bottom-text">
                Secure Premium Franchise Access
            </div>

        </form>

    </div>

</div>

</body>
</html>