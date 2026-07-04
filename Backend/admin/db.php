<?php
// db.php

$host = "localhost";
$dbname = "zipzapcart";
$username = "zipzapcart_user";
$password = "YourStrongPassword";

try{

    $pdo = new PDO(
        "mysql:host=$host;dbname=$dbname;charset=utf8mb4",
        $username,
        $password
    );

    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);

}catch(PDOException $e){

    die("Database Connection Failed");

}
?>