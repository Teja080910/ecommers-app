<?php
session_start();

require_once 'db.php';

if(!isset($_SESSION['admin_id'])){

    header("Location:index.php");
    exit;
}

$success = "";

if(isset($_POST['add_subscription'])){

    $title =
    trim($_POST['title']);

    $amount =
    trim($_POST['amount']);

    $days =
    intval($_POST['days']);

    $stmt =
    $pdo->prepare(

    "INSERT INTO subscription

    (
    title,
    amount,
    days
    )

    VALUES

    (
    ?,
    ?,
    ?
    )"

    );

    $stmt->execute([

        $title,
        $amount,
        $days
    ]);

    $success =
    "Subscription added";
}
?>

<!DOCTYPE html>
<html>
<head>

<title>Add Subscription</title>

<style>

body{
    background:#0f172a;
    color:#fff;
    font-family:Arial;
}

.main{
    margin-left:240px;
    padding:30px;
}

.card{
    background:#111827;
    padding:25px;
    border-radius:20px;
    max-width:700px;
}

input{
    width:100%;
    height:55px;
    border:none;
    border-radius:14px;
    background:#1e293b;
    color:#fff;
    padding:0 15px;
    margin-bottom:18px;
}

button{
    width:100%;
    height:55px;
    border:none;
    border-radius:14px;
    background:#7c3aed;
    color:#fff;
    font-weight:bold;
}

</style>

</head>
<body>

<?php include 'nav2.php'; ?>

<div class="main">

<div class="card">

<h2>Add Subscription</h2>

<br>

<?php if($success!=""){ ?>

<p style="color:#4ade80;">

<?php echo $success; ?>

</p>

<br>

<?php } ?>

<form method="POST">

<input
type="text"
name="title"
placeholder="Plan Title"
required>

<input
type="number"
step="0.01"
name="amount"
placeholder="Amount"
required>

<input
type="number"
name="days"
placeholder="Days"
required>

<button
type="submit"
name="add_subscription">

Add Subscription

</button>

</form>

</div>

</div>

</body>
</html>