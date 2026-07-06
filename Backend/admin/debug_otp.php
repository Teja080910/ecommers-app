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

echo "\n--- users table structure ---\n";

$cols = $pdo->query("DESCRIBE users")->fetchAll();

foreach($cols as $c){
    echo json_encode($c)."\n";
}

echo "\n--- matching user rows ---\n";

$uStmt = $pdo->prepare("SELECT id, name, email, phone, wallet_balance, auth_token, created_at FROM users WHERE email=?");
$uStmt->execute([$email]);
$uRows = $uStmt->fetchAll();

foreach($uRows as $u){
    echo json_encode($u)."\n";
}

if(count($uRows) === 0){
    echo "No user row found for email: [$email]\n";
}

echo "\n--- test insert (dry run, rolled back) ---\n";

try{
    $pdo->beginTransaction();
    $test = $pdo->prepare("INSERT INTO users (name, email, referral_code, auth_token) VALUES (?, ?, ?, ?)");
    $test->execute(['debug_test_user', 'debug_test_'.time().'@example.com', 'DBG'.rand(1000,9999), bin2hex(random_bytes(8))]);
    echo "INSERT succeeded (would have worked)\n";
    $pdo->rollBack();
}catch(PDOException $e){
    echo "INSERT FAILED: ".$e->getMessage()."\n";
    if($pdo->inTransaction()){
        $pdo->rollBack();
    }
}
