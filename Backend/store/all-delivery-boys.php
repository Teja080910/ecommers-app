<?php
session_start();

require_once 'db.php';

/* Login Check */

if(!isset($_SESSION['seller_id'])){
    header("Location:index.php");
    exit;
}

/* Logged Franchise */

$franchise_id = $_SESSION['seller_id'];

/* Delete Delivery Boy */

if(isset($_GET['delete'])){

    $id = intval($_GET['delete']);

    $get = $pdo->prepare("
        SELECT * FROM delivery_boys 
        WHERE id=? AND seller_id=?
    ");

    $get->execute([$id,$franchise_id]);

    $boy = $get->fetch();

    if($boy){

        if(!empty($boy['profile_photo'])){

            $path = "../app/uploads/delivery/".$boy['profile_photo'];

            if(file_exists($path)){
                unlink($path);
            }

        }

        if(!empty($boy['aadhaar_photo'])){

            $path = "../app/uploads/delivery/".$boy['aadhaar_photo'];

            if(file_exists($path)){
                unlink($path);
            }

        }

        if(!empty($boy['pan_photo'])){

            $path = "../app/uploads/delivery/".$boy['pan_photo'];

            if(file_exists($path)){
                unlink($path);
            }

        }

        $del = $pdo->prepare("
            DELETE FROM delivery_boys 
            WHERE id=? AND seller_id=?
        ");

        $del->execute([$id,$franchise_id]);

    }

    header("Location:all-delivery-boys.php");
    exit;
}

/* Delivery Boys */

$stmt = $pdo->prepare("
    SELECT 
        delivery_boys.*
    FROM delivery_boys
    WHERE delivery_boys.seller_id = ?
    ORDER BY delivery_boys.id DESC
");

$stmt->execute([$franchise_id]);

$boys = $stmt->fetchAll();

?>

<!DOCTYPE html>
<html lang="en">
<head>

<meta charset="UTF-8">

<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>All Delivery Boys</title>

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

/* Main */

.main-content{
    margin-left:240px;
    padding:28px;
}

/* Header */

.page-header{
    margin-bottom:20px;
}

.page-header h1{
    font-size:24px;
    margin-bottom:5px;
}

.page-header p{
    font-size:13px;
    color:#94a3b8;
}

/* Table */

.delivery-table{
    background:#111827;
    border-radius:22px;
    overflow:hidden;
}

/* Head */

.table-head{
    display:grid;
    grid-template-columns:
    90px
    1.7fr
    1.2fr
    1fr
    120px
    120px
    160px;
    gap:15px;
    padding:18px 20px;
    background:#1e293b;
    font-size:13px;
    font-weight:600;
}

/* Row */

.table-row{
    display:grid;
    grid-template-columns:
    90px
    1.7fr
    1.2fr
    1fr
    120px
    120px
    160px;
    gap:15px;
    align-items:center;
    padding:16px 20px;
    border-bottom:1px solid rgba(255,255,255,0.05);
    transition:.3s;
}

.table-row:hover{
    background:#18212f;
}

/* Image */

.profile-box{
    width:70px;
    height:70px;
    border-radius:18px;
    overflow:hidden;
    background:#1e293b;
}

.profile-box img{
    width:100%;
    height:100%;
    object-fit:cover;
}

/* Text */

.delivery-name{
    font-size:14px;
    font-weight:600;
    margin-bottom:4px;
}

.small-text{
    font-size:12px;
    color:#94a3b8;
    line-height:1.5;
}

.wallet{
    font-size:15px;
    font-weight:700;
    color:#4ade80;
}

/* Status */

.status-badge{
    display:inline-block;
    padding:7px 14px;
    border-radius:30px;
    font-size:11px;
    font-weight:600;
    text-transform:uppercase;
}

.active{
    background:#16a34a20;
    color:#4ade80;
}

.inactive{
    background:#ef444420;
    color:#f87171;
}

/* Buttons */

.action-buttons{
    display:flex;
    align-items:center;
    gap:10px;
}

.edit-btn,
.delete-btn{
    width:40px;
    height:40px;
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

/* Empty */

.empty-box{
    background:#111827;
    padding:70px 20px;
    border-radius:22px;
    text-align:center;
}

.empty-box i{
    font-size:60px;
    color:#475569;
    margin-bottom:15px;
}

.empty-box h2{
    margin-bottom:5px;
}

.empty-box p{
    font-size:13px;
    color:#94a3b8;
}

/* Responsive */

@media(max-width:1200px){

    .delivery-table{
        overflow-x:auto;
    }

    .table-head,
    .table-row{
        min-width:1100px;
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

    <!-- Header -->

    <div class="page-header">

        <h1>
            My Delivery Boys
        </h1>

        <p>
            Manage your franchise delivery partners
        </p>

    </div>

    <?php if(count($boys) > 0){ ?>

    <div class="delivery-table">

        <!-- Head -->

        <div class="table-head">

            <div>Photo</div>
            <div>Delivery Boy</div>
            <div>Vehicle</div>
            <div>Wallet</div>
            <div>Status</div>
            <div>Joined</div>
            <div>Actions</div>

        </div>

        <!-- Rows -->

        <?php foreach($boys as $boy){ ?>

        <div class="table-row">

            <!-- Photo -->

            <div class="profile-box">

                <?php if(!empty($boy['profile_photo'])){ ?>

                    <img 
                        src="../app/<?php echo $boy['profile_photo']; ?>"
                        alt=""
                    >

                <?php } ?>

            </div>

            <!-- Name -->

            <div>

                <div class="delivery-name">

                    <?php echo htmlspecialchars($boy['name']); ?>

                </div>

                <div class="small-text">

                    <?php echo htmlspecialchars($boy['phone']); ?>

                    <br>

                    <?php echo htmlspecialchars($boy['email']); ?>

                </div>

            </div>

            <!-- Vehicle -->

            <div class="small-text">

                <?php echo htmlspecialchars($boy['vehicle_type']); ?>

                <br>

                <?php echo htmlspecialchars($boy['vehicle_number']); ?>

            </div>

            <!-- Wallet -->

            <div class="wallet">

                ₹<?php echo $boy['wallet_balance']; ?>

            </div>

            <!-- Status -->

            <div>

                <span class="status-badge <?php echo $boy['is_active'] ? 'active' : 'inactive'; ?>">

                    <?php echo $boy['is_active'] ? 'Active' : 'Inactive'; ?>

                </span>

            </div>

            <!-- Joined -->

            <div class="small-text">

                <?php echo date("d M Y",strtotime($boy['created_at'])); ?>

            </div>

            <!-- Actions -->

          
        </div>

        <?php } ?>

    </div>

    <?php }else{ ?>

    <div class="empty-box">

        <i class="fa-solid fa-motorcycle"></i>

        <h2>No Delivery Boys Found</h2>

        <p>
            No delivery partners available for your franchise
        </p>

    </div>

    <?php } ?>

</div>

</body>
</html>