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
        CREATE TABLE IF NOT EXISTS email_otp_verifications (
            id INT AUTO_INCREMENT PRIMARY KEY,
            email VARCHAR(255) NOT NULL,
            otp_code VARCHAR(6) NOT NULL,
            expires_at DATETIME NOT NULL,
            verified TINYINT(1) NOT NULL DEFAULT 0,
            created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            INDEX idx_email (email)
        )
    ");
    echo "email_otp_verifications table ready.\n";
}catch(PDOException $e){
    echo "email_otp_verifications: ".$e->getMessage()."\n";
}

try{
    $pdo->exec("
        CREATE TABLE IF NOT EXISTS smtp_settings (
            id INT AUTO_INCREMENT PRIMARY KEY,
            smtp_host VARCHAR(255) DEFAULT NULL,
            smtp_port VARCHAR(10) DEFAULT NULL,
            smtp_username VARCHAR(255) DEFAULT NULL,
            smtp_password VARCHAR(255) DEFAULT NULL,
            from_email VARCHAR(255) DEFAULT NULL,
            from_name VARCHAR(255) DEFAULT NULL,
            created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        )
    ");
    echo "smtp_settings table ready.\n";
}catch(PDOException $e){
    echo "smtp_settings: ".$e->getMessage()."\n";
}

try{
    $pdo->exec("UPDATE users SET email=NULL WHERE email=''");
    echo "Normalized blank emails to NULL.\n";
}catch(PDOException $e){
    echo "normalize email: ".$e->getMessage()."\n";
}

try{
    $pdo->exec("ALTER TABLE users MODIFY email VARCHAR(255) NULL");
    echo "users.email is nullable.\n";
}catch(PDOException $e){
    echo "modify email column: ".$e->getMessage()."\n";
}

try{
    $pdo->exec("ALTER TABLE users ADD UNIQUE INDEX idx_users_email (email)");
    echo "Added unique index on users.email.\n";
}catch(PDOException $e){
    echo "unique index (may already exist): ".$e->getMessage()."\n";
}

echo "\nDone.\n";
