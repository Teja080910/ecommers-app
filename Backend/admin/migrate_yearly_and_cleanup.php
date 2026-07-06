<?php

session_start();

require_once 'db.php';

if(!isset($_SESSION['admin_id'])){
    header("Location:index.php");
    exit;
}

header('Content-Type: text/plain');

/* plan_type is an ENUM('enrollment','monthly') — widen it to allow 'yearly' */

$pdo->exec("ALTER TABLE subscription MODIFY plan_type ENUM('enrollment','monthly','yearly') NULL");

echo "Widened plan_type enum to include 'yearly'.\n";

/* Convert the one-time Enrollment plans into Yearly plans (10x monthly, 365 days) */

$rows = $pdo->query("SELECT * FROM subscription WHERE plan_type='enrollment'")->fetchAll();

foreach($rows as $row){

    $monthlyStmt = $pdo->prepare("SELECT amount FROM subscription WHERE category=? AND plan_type='monthly' LIMIT 1");
    $monthlyStmt->execute([$row['category']]);
    $monthlyAmount = $monthlyStmt->fetchColumn();

    $yearlyAmount = $monthlyAmount * 10;

    $newTitle = ucfirst($row['category'])." Seller - Yearly";

    $upd = $pdo->prepare("
        UPDATE subscription
        SET title=?, amount=?, days=365, plan_type='yearly'
        WHERE id=?
    ");
    $upd->execute([$newTitle, $yearlyAmount, $row['id']]);

    echo "Converted plan #{$row['id']} -> {$newTitle}, amount={$yearlyAmount}, days=365\n";
}

echo "\n--- Current subscription rows ---\n";

$all = $pdo->query("SELECT id, title, amount, days, audience, category, plan_type FROM subscription ORDER BY id DESC")->fetchAll();

foreach($all as $r){
    echo json_encode($r)."\n";
}

/* Clear Amay123's test enrollments */

$sellerStmt = $pdo->prepare("SELECT id FROM seller WHERE username=?");
$sellerStmt->execute(['Amay123']);
$sellerId = $sellerStmt->fetchColumn();

echo "\n--- Amay123 cleanup ---\n";

if($sellerId){

    $del = $pdo->prepare("DELETE FROM seller_subscription WHERE seller_id=?");
    $del->execute([$sellerId]);

    echo "Deleted {$del->rowCount()} seller_subscription row(s) for seller_id={$sellerId} (Amay123)\n";

}else{
    echo "Seller 'Amay123' not found\n";
}
