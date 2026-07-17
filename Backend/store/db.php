<?php
// db.php

$host = getenv("DB_HOST") ?: "localhost";
$dbname = getenv("DB_NAME") ?: "zipzapcart";
$username = getenv("DB_USER") ?: "zipzapcart_user";
$password = getenv("DB_PASS") ?: "YourStrongPassword";
$port = getenv("DB_PORT") ?: 3306;

try{

    $pdo = new PDO(
        "mysql:host=$host;port=$port;dbname=$dbname;charset=utf8mb4",
        $username,
        $password
    );

    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);

}catch(PDOException $e){

    die("Database Connection Failed");

}
?>