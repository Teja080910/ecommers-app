<?php

session_start();

require_once 'db.php';

if(!isset($_SESSION['admin_id'])){
    header("Location:index.php");
    exit;
}

header('Content-Type: text/plain');

try{
    $pdo->exec("ALTER TABLE smtp_settings ADD COLUMN brevo_api_key VARCHAR(255) NULL AFTER id");
    echo "Added brevo_api_key column.\n";
}catch(PDOException $e){
    echo "brevo_api_key column (may already exist): ".$e->getMessage()."\n";
}

echo "Done.\n";
