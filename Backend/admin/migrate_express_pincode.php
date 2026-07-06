<?php

session_start();

require_once 'db.php';

if(!isset($_SESSION['admin_id'])){
    header("Location:index.php");
    exit;
}

header('Content-Type: text/plain');

try{
    $pdo->exec("ALTER TABLE service_pincodes ADD COLUMN city VARCHAR(100) NULL, ADD COLUMN is_express TINYINT(1) NOT NULL DEFAULT 0");
    echo "Added city + is_express columns to service_pincodes.\n";
}catch(PDOException $e){
    echo "service_pincodes columns (may already exist): ".$e->getMessage()."\n";
}

echo "Done.\n";
