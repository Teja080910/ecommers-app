<?php

session_start();

require_once 'db.php';

if(!isset($_SESSION['admin_id'])){
    header("Location:index.php");
    exit;
}

header('Content-Type: text/plain');

$count = $pdo->query("SELECT COUNT(*) FROM seller_subscription")->fetchColumn();

echo "Deleting {$count} seller_subscription row(s)...\n";

$pdo->exec("DELETE FROM seller_subscription");

echo "Done. seller_subscription is now empty. subscription (plans) table untouched.\n";
