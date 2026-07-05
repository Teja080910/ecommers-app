<?php

session_start();

require_once 'db.php';

if(!isset($_SESSION['admin_id'])){
    header("Location:index.php");
    exit;
}

header('Content-Type: text/plain');

try{

    $pdo->exec("
        ALTER TABLE subscription
        ADD COLUMN category ENUM('city','national') NULL,
        ADD COLUMN plan_type ENUM('enrollment','monthly') NULL
    ");

    echo "Columns added.\n";

}catch(PDOException $e){

    echo "ALTER skipped (".$e->getMessage().")\n";
}

$backfill = [
    ['City Seller - Enrollment', 'city', 'enrollment'],
    ['City Seller - Monthly', 'city', 'monthly'],
    ['National Seller - Enrollment', 'national', 'enrollment'],
    ['National Seller - Monthly', 'national', 'monthly'],
];

$upd = $pdo->prepare("UPDATE subscription SET category=?, plan_type=? WHERE title=?");

foreach($backfill as $row){

    $upd->execute([$row[1], $row[2], $row[0]]);

    echo "Backfilled \"{$row[0]}\" -> category={$row[1]}, plan_type={$row[2]} (rows affected: ".$upd->rowCount().")\n";
}

echo "\n--- Current subscription rows ---\n";

$rows = $pdo->query("SELECT id, title, amount, days, audience, category, plan_type FROM subscription ORDER BY id DESC")->fetchAll();

foreach($rows as $r){
    echo json_encode($r)."\n";
}
