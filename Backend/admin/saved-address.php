<?php
session_start();

require_once 'db.php';

/* LOGIN CHECK */

if(!isset($_SESSION['admin_id'])){

    header("Location:index.php");
    exit;
}

/* QUERY */

$sql = "

SELECT

user_addresses.*,

users.name
AS user_name,

users.phone
AS user_phone,

users.email,
users.paidstatus

FROM user_addresses

LEFT JOIN users
ON users.id =
user_addresses.user_id

ORDER BY user_addresses.id DESC

";

$stmt =
$pdo->prepare($sql);

$stmt->execute();

$addresses =
$stmt->fetchAll();

?>

<!DOCTYPE html>
<html lang="en">
<head>

<meta charset="UTF-8">

<meta name="viewport"
content="width=device-width,
initial-scale=1.0">

<title>
Saved Addresses
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
    font-size:26px;
    margin-bottom:5px;
}

.page-header p{
    font-size:13px;
    color:#94a3b8;
}

/* TABLE */

.address-table{
    background:#111827;
    border-radius:24px;
    overflow:hidden;
}

/* HEAD */

.table-head{
    display:grid;

    grid-template-columns:

    90px
    1.4fr
    1.4fr
    1.7fr
    120px
    120px
    150px;

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
    1.4fr
    1.4fr
    1.7fr
    120px
    120px
    150px;

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

.address-id{
    font-size:15px;
    font-weight:700;
    color:#22d3ee;
}

.user-name{
    font-size:14px;
    font-weight:600;
    margin-bottom:4px;
}

.small-text{
    font-size:12px;
    color:#94a3b8;
    line-height:1.5;
}

.address-box{
    font-size:13px;
    color:#e2e8f0;
    line-height:1.7;
}

/* BADGES */

.badge{
    display:inline-block;
    padding:7px 14px;
    border-radius:30px;
    font-size:11px;
    font-weight:600;
    text-transform:uppercase;
}

.default{
    background:#16a34a20;
    color:#4ade80;
}

.no{
    background:#47556920;
    color:#cbd5e1;
}

.paid{
    background:#06b6d420;
    color:#22d3ee;
}

.free{
    background:#7c3aed20;
    color:#c084fc;
}

/* DATE */

.date-box{
    font-size:12px;
    color:#94a3b8;
    line-height:1.6;
}

/* EMPTY */

.empty-box{
    background:#111827;
    padding:70px 20px;
    border-radius:24px;
    text-align:center;
}

.empty-box i{
    font-size:60px;
    color:#475569;
    margin-bottom:15px;
}

.empty-box h2{
    margin-bottom:6px;
}

.empty-box p{
    color:#94a3b8;
    font-size:13px;
}

/* RESPONSIVE */

@media(max-width:1400px){

    .address-table{
        overflow-x:auto;
    }

    .table-head,
    .table-row{
        min-width:1350px;
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

<?php include 'nav.php'; ?>

<div class="main-content">

    <!-- HEADER -->

    <div class="page-header">

        <h1>
            Saved Addresses
        </h1>

        <p>
            View all saved user delivery addresses
        </p>

    </div>

    <?php if(count($addresses) > 0){ ?>

    <div class="address-table">

        <!-- HEAD -->

        <div class="table-head">

            <div>
                ID
            </div>

            <div>
                User
            </div>

            <div>
                Contact
            </div>

            <div>
                Address
            </div>

            <div>
                Default
            </div>

            <div>
                User Type
            </div>

            <div>
                Date
            </div>

        </div>

        <!-- ROWS -->

        <?php foreach($addresses as $address){ ?>

        <div class="table-row">

            <!-- ID -->

            <div class="address-id">

                #<?php echo $address['id']; ?>

            </div>

            <!-- USER -->

            <div>

                <div class="user-name">

                    <?php echo htmlspecialchars($address['user_name']); ?>

                </div>

                <div class="small-text">

                    User ID :
                    <?php echo $address['user_id']; ?>

                </div>

            </div>

            <!-- CONTACT -->

            <div>

                <div class="small-text">

                    <strong>
                    Mobile :
                    </strong>

                    <?php echo htmlspecialchars($address['mobile']); ?>

                </div>

                <div class="small-text"
                style="margin-top:6px;">

                    <strong>
                    Email :
                    </strong>

                    <?php echo htmlspecialchars($address['email']); ?>

                </div>

            </div>

            <!-- ADDRESS -->

            <div class="address-box">

                <?php echo htmlspecialchars($address['full_name']); ?>

                <br><br>

                <?php echo htmlspecialchars($address['address']); ?>

                <br>

                <?php echo htmlspecialchars($address['city']); ?>,
                <?php echo htmlspecialchars($address['state']); ?>

                -
                <?php echo htmlspecialchars($address['pincode']); ?>

            </div>

            <!-- DEFAULT -->

            <div>

                <span class="badge <?php echo strtolower($address['is_default']); ?>">

                    <?php echo $address['is_default']; ?>

                </span>

            </div>

            <!-- USER TYPE -->

            <div>

                <span class="badge <?php echo strtolower($address['paidstatus']); ?>">

                    <?php echo $address['paidstatus']; ?>

                </span>

            </div>

            <!-- DATE -->

            <div class="date-box">

                <?php echo date(

                "d M Y",

                strtotime(
                $address['created_at']
                )

                ); ?>

                <br>

                <?php echo date(

                "h:i A",

                strtotime(
                $address['created_at']
                )

                ); ?>

            </div>

        </div>

        <?php } ?>

    </div>

    <?php }else{ ?>

    <div class="empty-box">

        <i class="fa-solid fa-location-dot"></i>

        <h2>
            No Saved Addresses
        </h2>

        <p>
            No user saved addresses found
        </p>

    </div>

    <?php } ?>

</div>

</body>
</html>