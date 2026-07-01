<?php
session_start();

require_once 'db.php';

/* LOGIN CHECK */

if(!isset($_SESSION['admin_id'])){

    header("Location:index.php");
    exit;
}

/* DELETE PINCODE */

if(isset($_GET['delete'])){

    $delete_id =
    intval($_GET['delete']);

    $delete =
    $pdo->prepare(

    "DELETE FROM service_pincodes
    WHERE id=?"

    );

    $delete->execute([
    $delete_id
    ]);

    header(
    "Location:all-pincodes.php"
    );

    exit;
}

/* FETCH PINCODES */

$stmt =
$pdo->prepare(

"SELECT *
FROM service_pincodes
ORDER BY id DESC"

);

$stmt->execute();

$pincodes =
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
All Pincodes
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

.pincode-table{
    background:#111827;
    border-radius:24px;
    overflow:hidden;
}

/* HEAD */

.table-head{
    display:grid;

    grid-template-columns:

    120px
    1.5fr
    1.5fr
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

    120px
    1.5fr
    1.5fr
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

.pincode-id{
    font-size:15px;
    font-weight:700;
    color:#22d3ee;
}

.pincode-text{
    font-size:14px;
    font-weight:600;
    color:#fff;
}

.charge{
    font-size:15px;
    font-weight:700;
    color:#4ade80;
}

/* ACTIONS */

.action-buttons{
    display:flex;
    align-items:center;
    gap:10px;
}

.edit-btn,
.delete-btn{
    width:42px;
    height:42px;
    border-radius:12px;
    display:flex;
    align-items:center;
    justify-content:center;
    text-decoration:none;
    transition:.3s;
}

.edit-btn{
    background:#06b6d420;
    color:#22d3ee;
}

.edit-btn:hover{
    background:#06b6d4;
    color:#fff;
}

.delete-btn{
    background:#ef444420;
    color:#f87171;
}

.delete-btn:hover{
    background:#ef4444;
    color:#fff;
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

@media(max-width:900px){

    .main-content{
        margin-left:0;
        padding:85px 15px 20px;
    }

    .pincode-table{
        overflow-x:auto;
    }

    .table-head,
    .table-row{
        min-width:700px;
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
            Service Pincodes
        </h1>

        <p>
            Manage all delivery service pincodes
        </p>

    </div>

    <?php if(count($pincodes) > 0){ ?>

    <div class="pincode-table">

        <!-- HEAD -->

        <div class="table-head">

            <div>
                ID
            </div>

            <div>
                Pincode
            </div>

            <div>
                Delivery Charge
            </div>

            <div>
                Actions
            </div>

        </div>

        <!-- ROWS -->

        <?php foreach($pincodes as $pin){ ?>

        <div class="table-row">

            <!-- ID -->

            <div class="pincode-id">

                #<?php echo $pin['id']; ?>

            </div>

            <!-- PINCODE -->

            <div class="pincode-text">

                <?php echo htmlspecialchars($pin['pincode']); ?>

            </div>

            <!-- CHARGE -->

            <div class="charge">

                ₹<?php echo $pin['delivery_charge']; ?>

            </div>

            <!-- ACTIONS -->

            <div class="action-buttons">

                <!-- EDIT -->

                <a

                href="edit-pincode.php?id=<?php echo $pin['id']; ?>"

                class="edit-btn">

                    <i class="fa fa-pen"></i>

                </a>

                <!-- DELETE -->

                <a

                href="all-pincodes.php?delete=<?php echo $pin['id']; ?>"

                class="delete-btn"

                onclick="
                return confirm(
                'Delete this pincode?'
                )
                ">

                    <i class="fa fa-trash"></i>

                </a>

            </div>

        </div>

        <?php } ?>

    </div>

    <?php }else{ ?>

    <div class="empty-box">

        <i class="fa-solid fa-location-dot"></i>

        <h2>
            No Pincodes Found
        </h2>

        <p>
            No delivery service pincodes available
        </p>

    </div>

    <?php } ?>

</div>

</body>
</html>