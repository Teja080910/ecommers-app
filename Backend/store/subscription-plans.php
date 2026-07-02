<?php
session_start();

require_once 'db.php';

/* Login Check */

if(!isset($_SESSION['seller_id'])){

    header("Location:index.php");
    exit;
}

$seller_id = intval($_SESSION['seller_id']);

$success = "";
$error = "";

/* Enroll */

if(isset($_POST['enroll_subscription'])){

    $sub_id = intval($_POST['sub_id']);

    /* Fetch Plan (must be seller/both audience) */

    $planStmt = $pdo->prepare("
        SELECT *
        FROM subscription
        WHERE id=?
        AND audience IN ('seller','both')
    ");

    $planStmt->execute([$sub_id]);

    $plan = $planStmt->fetch();

    if(!$plan){

        $error = "Invalid Subscription Plan";

    }else{

        /* Prevent duplicate active enrollment in the same plan */

        $existingStmt = $pdo->prepare("
            SELECT id
            FROM seller_subscription
            WHERE seller_id=?
            AND sub_id=?
            AND status='active'
            AND end_date >= CURDATE()
        ");

        $existingStmt->execute([$seller_id, $sub_id]);

        if($existingStmt->rowCount() > 0){

            $error = "You are already enrolled in this plan";

        }else{

            $start_date = date('Y-m-d');
            $end_date = date('Y-m-d', strtotime("+{$plan['days']} days"));

            $insert = $pdo->prepare("
                INSERT INTO seller_subscription
                (seller_id, sub_id, amount, status, start_date, end_date)
                VALUES (?, ?, ?, 'active', ?, ?)
            ");

            $run = $insert->execute([

                $seller_id,
                $sub_id,
                $plan['amount'],
                $start_date,
                $end_date
            ]);

            if($run){

                $success = "Enrolled in \"" . $plan['title'] . "\" successfully";

            }else{

                $error = "Failed To Enroll";
            }

        }

    }

}

/* Fetch Available Plans */

$plans = $pdo->query("
    SELECT *
    FROM subscription
    WHERE audience IN ('seller','both')
    ORDER BY id DESC
")->fetchAll();

/* Fetch My Enrollments */

$myEnrollments = $pdo->prepare("
    SELECT seller_subscription.*, subscription.title
    FROM seller_subscription
    LEFT JOIN subscription ON subscription.id = seller_subscription.sub_id
    WHERE seller_subscription.seller_id=?
    ORDER BY seller_subscription.id DESC
");

$myEnrollments->execute([$seller_id]);

$myEnrollments = $myEnrollments->fetchAll();

$activeSubIds = [];

foreach($myEnrollments as $e){

    if($e['status'] == 'active' && $e['end_date'] >= date('Y-m-d')){

        $activeSubIds[] = $e['sub_id'];
    }
}

?>

<!DOCTYPE html>
<html lang="en">
<head>

<meta charset="UTF-8">

<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>Subscription Plans</title>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">

<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">

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
}

.page-header{
    margin-bottom:25px;
}

.page-header h1{
    font-size:24px;
    margin-bottom:5px;
}

.page-header p{
    font-size:13px;
    color:#94a3b8;
}

.alert{
    padding:14px 16px;
    border-radius:14px;
    margin-bottom:18px;
    font-size:13px;
    max-width:550px;
}

.success{
    background:#16a34a20;
    color:#4ade80;
}

.error{
    background:#dc262620;
    color:#f87171;
}

.grid{
    display:grid;
    grid-template-columns:repeat(auto-fill,minmax(280px,1fr));
    gap:20px;
    margin-bottom:36px;
}

.card{
    background:#111827;
    border-radius:20px;
    padding:22px;
}

.card h2{
    font-size:18px;
    margin-bottom:12px;
}

.price{
    font-size:32px;
    font-weight:bold;
    margin-bottom:14px;
}

.days{
    display:inline-block;
    padding:8px 14px;
    border-radius:30px;
    background:#1e293b;
    font-size:12px;
    color:#cbd5e1;
    margin-bottom:18px;
}

.enroll-btn{
    width:100%;
    height:50px;
    border:none;
    border-radius:14px;
    background:linear-gradient(135deg,#06b6d4,#7c3aed);
    color:#fff;
    font-size:14px;
    font-weight:600;
    cursor:pointer;
}

.enroll-btn.active-plan{
    background:#16a34a20;
    color:#4ade80;
    cursor:default;
}

.section-title{
    font-size:16px;
    margin-bottom:16px;
    color:#cbd5e1;
}

.table-wrap{
    background:#111827;
    border-radius:20px;
    padding:10px 22px;
    overflow-x:auto;
}

table{
    width:100%;
    border-collapse:collapse;
    font-size:13px;
}

th, td{
    text-align:left;
    padding:14px 10px;
    border-bottom:1px solid rgba(255,255,255,0.05);
}

th{
    color:#64748b;
    font-weight:500;
    font-size:12px;
    text-transform:uppercase;
}

.status-badge{
    padding:6px 12px;
    border-radius:30px;
    font-size:11px;
    font-weight:600;
}

.status-active{
    background:#16a34a20;
    color:#4ade80;
}

.status-expired{
    background:#dc262620;
    color:#f87171;
}

.status-pending{
    background:#eab30820;
    color:#facc15;
}

.empty-state{
    padding:30px;
    text-align:center;
    color:#64748b;
    font-size:13px;
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

        <h1>Subscription Plans</h1>

        <p>
            Enroll in a subscription plan to unlock seller benefits
        </p>

    </div>

    <?php if($success != ""){ ?>

        <div class="alert success">
            <?php echo $success; ?>
        </div>

    <?php } ?>

    <?php if($error != ""){ ?>

        <div class="alert error">
            <?php echo $error; ?>
        </div>

    <?php } ?>

    <?php if(count($plans) == 0){ ?>

        <div class="empty-state">
            No subscription plans available right now.
        </div>

    <?php }else{ ?>

    <div class="grid">

        <?php foreach($plans as $p){

            $isActive = in_array($p['id'], $activeSubIds);

        ?>

        <div class="card">

            <h2><?php echo htmlspecialchars($p['title']); ?></h2>

            <div class="price">
                &#8377;<?php echo $p['amount']; ?>
            </div>

            <div class="days">
                <?php echo $p['days']; ?> Days
            </div>

            <?php if($isActive){ ?>

                <button class="enroll-btn active-plan" disabled>
                    <i class="fa-solid fa-check"></i>
                    Already Enrolled
                </button>

            <?php }else{ ?>

                <form method="POST">

                    <input type="hidden" name="sub_id" value="<?php echo $p['id']; ?>">

                    <button type="submit" name="enroll_subscription" class="enroll-btn">
                        <i class="fa-solid fa-crown"></i>
                        Enroll Now
                    </button>

                </form>

            <?php } ?>

        </div>

        <?php } ?>

    </div>

    <?php } ?>

    <div class="section-title">My Enrollments</div>

    <div class="table-wrap">

        <?php if(count($myEnrollments) == 0){ ?>

            <div class="empty-state">
                You haven't enrolled in any subscription plan yet.
            </div>

        <?php }else{ ?>

        <table>

            <tr>
                <th>Plan</th>
                <th>Amount</th>
                <th>Start Date</th>
                <th>End Date</th>
                <th>Status</th>
            </tr>

            <?php foreach($myEnrollments as $e){

                $displayStatus = $e['status'];

                if($displayStatus == 'active' && $e['end_date'] < date('Y-m-d')){
                    $displayStatus = 'expired';
                }

            ?>

            <tr>
                <td><?php echo htmlspecialchars($e['title']); ?></td>
                <td>&#8377;<?php echo $e['amount']; ?></td>
                <td><?php echo $e['start_date']; ?></td>
                <td><?php echo $e['end_date']; ?></td>
                <td>
                    <span class="status-badge status-<?php echo $displayStatus; ?>">
                        <?php echo ucfirst($displayStatus); ?>
                    </span>
                </td>
            </tr>

            <?php } ?>

        </table>

        <?php } ?>

    </div>

</div>

</body>
</html>
