<?php

$host = "localhost";        // your server (usually localhost)
$user = "root";     // DB username
$pass = ""; // DB password
$db   = "u272105386_zipzapcart";     // DB name

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