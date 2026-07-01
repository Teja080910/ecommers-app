<?php

$host = "localhost";        // your server (usually localhost)
$user = "u272105386_zipzapcart";     // DB username
$pass = "Heritage@3205"; // DB password
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