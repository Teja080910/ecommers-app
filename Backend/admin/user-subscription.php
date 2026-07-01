<?php
session_start();

require_once 'db.php';

if(!isset($_SESSION['admin_id'])){

    header("Location:index.php");
    exit;
}

$subscriptions =
$pdo->query(

"SELECT

user_subscription.*,

users.name,
users.phone,
users.paidstatus,
users.startdate,
users.enddate,

subscription.title

FROM user_subscription

LEFT JOIN users
ON users.id =
user_subscription.user_id

LEFT JOIN subscription
ON subscription.id =
user_subscription.sub_id

ORDER BY user_subscription.id DESC"

)->fetchAll();

?>

<!DOCTYPE html>
<html lang="en">
<head>

<meta charset="UTF-8">

<meta name="viewport"
content="width=device-width,
initial-scale=1.0">

<title>
User Subscription
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

/* MAIN */

.main-content{
    margin-left:240px;
    padding:28px;
}

/* HEADER */

.page-header{
    margin-bottom:22px;
}

.page-header h1{
    font-size:28px;
    margin-bottom:5px;
}

.page-header p{
    font-size:13px;
    color:#94a3b8;
}

/* TABLE */

.subscription-table{
    background:#111827;
    border-radius:24px;
    overflow:hidden;
}

/* HEAD */

.table-head{
    display:grid;

    grid-template-columns:

    90px
    1.3fr
    1fr
    140px
    140px
    140px
    140px
    160px;

    gap:14px;

    padding:18px 20px;

    background:#1e293b;

    font-size:13px;
    font-weight:600;
}

/* ROW */

.table-row{
    display:grid;

    grid-template-columns:

    90px
    1.3fr
    1fr
    140px
    140px
    140px
    140px
    160px;

    gap:14px;

    align-items:center;

    padding:18px 20px;

    border-bottom:
    1px solid rgba(255,255,255,0.05);

    transition:.3s;
}

.table-row:hover{
    background:#18212f;
}

/* TEXT */

.user-id{
    font-size:15px;
    font-weight:700;
    color:#22d3ee;
}

.user-name{
    font-size:15px;
    font-weight:600;
    margin-bottom:5px;
}

.small-text{
    font-size:12px;
    color:#94a3b8;
}

.plan-name{
    font-size:14px;
    font-weight:600;
}

.amount{
    font-size:16px;
    font-weight:700;
    color:#4ade80;
}

/* STATUS */

.badge{
    display:inline-block;
    padding:8px 14px;
    border-radius:30px;
    font-size:11px;
    font-weight:700;
    text-transform:uppercase;
}

.paid{
    background:#16a34a20;
    color:#4ade80;
}

.free{
    background:#ef444420;
    color:#f87171;
}

/* EMPTY */

.empty-box{
    background:#111827;
    padding:80px 20px;
    border-radius:24px;
    text-align:center;
}

.empty-box i{
    font-size:65px;
    color:#475569;
    margin-bottom:15px;
}

.empty-box h2{
    margin-bottom:8px;
}

.empty-box p{
    color:#94a3b8;
    font-size:13px;
}

/* RESPONSIVE */

@media(max-width:1400px){

    .subscription-table{
        overflow-x:auto;
    }

    .table-head,
    .table-row{
        min-width:1300px;
    }
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

<?php include 'nav2.php'; ?>

<div class="main-content">

    <!-- HEADER -->

    <div class="page-header">

        <h1>
            User Subscriptions
        </h1>

        <p>
            View all active subscription plans
        </p>

    </div>

    <?php if(count($subscriptions) > 0){ ?>

    <div class="subscription-table">

        <!-- HEAD -->

        <div class="table-head">

            <div>ID</div>

            <div>User</div>

            <div>Plan</div>

            <div>Amount</div>

            <div>Status</div>

            <div>Start Date</div>

            <div>End Date</div>

            <div>Purchased On</div>

        </div>

        <!-- ROWS -->

        <?php foreach($subscriptions as $s){ ?>

        <div class="table-row">

            <!-- ID -->

            <div class="user-id">

                #<?php echo $s['id']; ?>

            </div>

            <!-- USER -->

            <div>

                <div class="user-name">

                    <?php echo htmlspecialchars($s['name']); ?>

                </div>

                <div class="small-text">

                    <?php echo htmlspecialchars($s['phone']); ?>

                </div>

            </div>

            <!-- PLAN -->

            <div class="plan-name">

                <?php echo htmlspecialchars($s['title']); ?>

            </div>

            <!-- AMOUNT -->

            <div class="amount">

                ₹<?php echo $s['amount']; ?>

            </div>

            <!-- STATUS -->

            <div>

                <span class="badge <?php echo $s['paidstatus']; ?>">

                    <?php echo strtoupper($s['paidstatus']); ?>

                </span>

            </div>

            <!-- START -->

            <div class="small-text">

                <?php

                echo $s['startdate']
                ? date(

                    "d M Y",

                    strtotime(
                    $s['startdate']
                    )

                )
                : "-";

                ?>

            </div>

            <!-- END -->

            <div class="small-text">

                <?php

                echo $s['enddate']
                ? date(

                    "d M Y",

                    strtotime(
                    $s['enddate']
                    )

                )
                : "-";

                ?>

            </div>

            <!-- CREATED -->

            <div class="small-text">

                <?php echo date(

                "d M Y",

                strtotime(
                $s['created_at']
                )

                ); ?>

                <br>

                <?php echo date(

                "h:i A",

                strtotime(
                $s['created_at']
                )

                ); ?>

            </div>

        </div>

        <?php } ?>

    </div>

    <?php }else{ ?>

    <div class="empty-box">

        <i class="fa-solid fa-crown"></i>

        <h2>
            No Subscription Found
        </h2>

        <p>
            No users purchased subscription yet
        </p>

    </div>

    <?php } ?>

</div>

</body>
</html>