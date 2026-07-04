<?php

$host = "localhost";        // your server (usually localhost)
$user = "zipzapcart_user";     // DB username
$pass = "YourStrongPassword"; // DB password
$db   = "zipzapcart";     // DB name

$conn = mysqli_connect($host, $user, $pass, $db);

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