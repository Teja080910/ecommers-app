<?php
session_start();

require_once 'db.php';
require_once __DIR__ . '/../app/fcm_helper.php';

/* LOGIN CHECK */

if(!isset($_SESSION['admin_id'])){

    header("Location:index.php");
    exit;
}

/* SEND BROADCAST NOTIFICATION
   Delivered via Firebase Cloud Messaging (push) from this backend, plus
   an in-app row in user_notifications so it shows in the app's own
   Notifications screen even if the push never arrives (app closed,
   permission denied, etc). */

$sent = null;
$sentCount = 0;

if($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['send_broadcast'])){

    $title = trim($_POST['title'] ?? '');
    $message = trim($_POST['message'] ?? '');

    if(!empty($title) && !empty($message)){

        $usersStmt = $pdo->query("SELECT id, fcm_token FROM users WHERE is_active=1");
        $users = $usersStmt->fetchAll();

        $notifText = "$title: $message";

        $insertStmt = $pdo->prepare(
            "INSERT INTO user_notifications (user_id, notification_text) VALUES (?, ?)"
        );

        // fetch the FCM access token once for the whole batch, not per user
        $access = getFcmAccessToken();
        $project = "ftnews-79e5c";

        foreach($users as $user){

            $insertStmt->execute([$user['id'], $notifText]);
            $sentCount++;

            if(!empty($user['fcm_token'])){

                $payload = [
                    "message" => [
                        "token" => $user['fcm_token'],
                        "notification" => [
                            "title" => $title,
                            "body" => $message
                        ],
                        "data" => [
                            "type" => "offer",
                            "screen" => "home"
                        ]
                    ]
                ];

                $ch = curl_init();
                curl_setopt($ch, CURLOPT_URL, "https://fcm.googleapis.com/v1/projects/" . $project . "/messages:send");
                curl_setopt($ch, CURLOPT_POST, true);
                curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
                curl_setopt($ch, CURLOPT_HTTPHEADER, [
                    "Authorization: Bearer " . $access,
                    "Content-Type: application/json"
                ]);
                curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));
                curl_exec($ch);
                curl_close($ch);
            }
        }

        $sent = true;

    }else{

        $sent = false;
    }
}

?>

<!DOCTYPE html>
<html lang="en">
<head>

<meta charset="UTF-8">

<meta name="viewport"
content="width=device-width,
initial-scale=1.0">

<title>
Send Notification
</title>

<link rel="stylesheet"
href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">

<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap"
rel="stylesheet">

<style>

*{
    margin:0;
    padding:0;
    box-sizing:border-box;
    font-family:'Inter',sans-serif;
}

body{
    background:#0f172a;
    color:#fff;
}

.main-content{
    margin-left:240px;
    padding:28px;
    max-width:640px;
}

.page-header{
    margin-bottom:22px;
}

.page-header h1{
    font-size:26px;
    margin-bottom:5px;
}

.page-header p{
    font-size:13px;
    color:#94a3b8;
}

.form-card{
    background:#111827;
    border-radius:24px;
    padding:28px;
}

.field{
    margin-bottom:18px;
}

.field label{
    display:block;
    font-size:13px;
    font-weight:600;
    margin-bottom:8px;
    color:#cbd5e1;
}

.field input,
.field textarea{
    width:100%;
    padding:14px 16px;
    border-radius:12px;
    border:1px solid #334155;
    background:#0f172a;
    color:#fff;
    font-size:14px;
    font-family:'Inter',sans-serif;
}

.field textarea{
    resize:vertical;
    min-height:100px;
}

.submit-btn{
    width:100%;
    padding:16px;
    border-radius:12px;
    border:none;
    background:#ef4444;
    color:#fff;
    font-size:14px;
    font-weight:700;
    cursor:pointer;
}

.submit-btn:hover{
    background:#dc2626;
}

.success-banner{
    background:#16a34a20;
    color:#4ade80;
    padding:14px 20px;
    border-radius:16px;
    margin-bottom:18px;
    font-size:13px;
    font-weight:600;
}

.error-banner{
    background:#ef444420;
    color:#f87171;
    padding:14px 20px;
    border-radius:16px;
    margin-bottom:18px;
    font-size:13px;
    font-weight:600;
}

@media(max-width:900px){

    .main-content{
        margin-left:0;
        padding:85px 15px 20px;
    }
}

</style>

</head>
<body>

<?php include 'nav.php'; ?>

<div class="main-content">

    <div class="page-header">

        <h1>
            Send Notification
        </h1>

        <p>
            Broadcast an offer or announcement to every active user, in-app and via push
        </p>

    </div>

    <?php if($sent === true){ ?>

        <div class="success-banner">
            Sent to <?php echo $sentCount; ?> user<?php echo $sentCount == 1 ? '' : 's'; ?>.
        </div>

    <?php }elseif($sent === false){ ?>

        <div class="error-banner">
            Title and message are both required.
        </div>

    <?php } ?>

    <div class="form-card">

        <form method="post">

            <div class="field">
                <label>Title</label>
                <input type="text" name="title" placeholder="e.g. Flash Sale Today!" required>
            </div>

            <div class="field">
                <label>Message</label>
                <textarea name="message" placeholder="e.g. Get 20% off on all electronics, today only." required></textarea>
            </div>

            <button type="submit" name="send_broadcast" value="1" class="submit-btn"
                onclick="return confirm('Send this notification to every active user now?');">
                Send to All Users
            </button>

        </form>

    </div>

</div>

</body>
</html>
