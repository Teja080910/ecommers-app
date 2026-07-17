<?php

$host = getenv("DB_HOST") ?: "localhost";
$user = getenv("DB_USER") ?: "zipzapcart_user";
$pass = getenv("DB_PASS") ?: "YourStrongPassword";
$db   = getenv("DB_NAME") ?: "zipzapcart";
$port = getenv("DB_PORT") ?: 3306;

$conn = mysqli_connect($host, $user, $pass, $db, $port);

// ❌ Connection failed
if (!$conn) {
    die(json_encode([
        "status" => false,
        "message" => "Database connection failed"
    ]));
}

// ✅ Set UTF-8 (IMPORTANT for text, emoji, etc.)
mysqli_set_charset($conn, "utf8mb4");

?>