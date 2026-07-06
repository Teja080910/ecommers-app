<?php

session_start();

require_once 'db.php';

if(!isset($_SESSION['admin_id'])){
    header("Location:index.php");
    exit;
}

header('Content-Type: text/plain');

$email = $_GET['email'] ?? '';

$stmt = $pdo->prepare("SELECT id, email, otp_code, verified, expires_at, created_at, NOW() as server_now FROM email_otp_verifications WHERE email=? ORDER BY id DESC LIMIT 10");
$stmt->execute([$email]);
$rows = $stmt->fetchAll();

foreach($rows as $r){
    echo json_encode($r)."\n";
}

if(count($rows) === 0){
    echo "No rows found for email: [$email]\n";
}
