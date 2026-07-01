<?php
session_start();

require_once 'db.php';

/* Login Check */

if(!isset($_SESSION['admin_id'])){
    header("Location:index.php");
    exit;
}

/* Add Payout */

if(isset($_POST['add_payout'])){

    $delivery_boy_id = $_POST['delivery_boy_id'];
    $amount = $_POST['amount'];
    $payment_method = trim($_POST['payment_method']);
    $transaction_id = trim($_POST['transaction_id']);
    $note = trim($_POST['note']);
    $payout_date = $_POST['payout_date'];

    /* Delivery Boy */

    $boyStmt = $pdo->prepare("
        SELECT * FROM delivery_boys 
        WHERE id=?
    ");

    $boyStmt->execute([$delivery_boy_id]);

    $boy = $boyStmt->fetch();

    if($boy){

        /* Insert Payout */

        $insert = $pdo->prepare("
            INSERT INTO delivery_boy_payouts
            (
                delivery_boy_id,
                seller_id,
                amount,
                payment_method,
                transaction_id,
                note,
                payout_date
            )
            VALUES
            (
                ?,?,?,?,?,?,?
            )
        ");

        $insert->execute([
            $delivery_boy_id,
            $boy['seller_id'],
            $amount,
            $payment_method,
            $transaction_id,
            $note,
            $payout_date
        ]);

        /* Deduct Wallet */

        $wallet = $boy['wallet_balance'] - $amount;

        if($wallet < 0){
            $wallet = 0;
        }

        $update = $pdo->prepare("
            UPDATE delivery_boys 
            SET wallet_balance=?
            WHERE id=?
        ");

        $update->execute([
            $wallet,
            $delivery_boy_id
        ]);

    }

    header("Location:delivery-boy-payouts.php");
    exit;
}

/* Delivery Boys */

$boys = $pdo->query("
    SELECT * FROM delivery_boys
    ORDER BY name ASC
")->fetchAll();

/* Payouts */

$stmt = $pdo->prepare("
    SELECT 
        delivery_boy_payouts.*,
        delivery_boys.name AS delivery_boy_name,
        delivery_boys.phone AS delivery_boy_phone,
        seller.name AS franchise_name
    FROM delivery_boy_payouts
    LEFT JOIN delivery_boys
    ON delivery_boys.id = delivery_boy_payouts.delivery_boy_id
    LEFT JOIN seller
    ON seller.id = delivery_boy_payouts.seller_id
    ORDER BY delivery_boy_payouts.id DESC
");

$stmt->execute();

$payouts = $stmt->fetchAll();

?>

<!DOCTYPE html>
<html lang="en">
<head>

<meta charset="UTF-8">

<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>Delivery Boy Payouts</title>

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

/* Form */

.form-box{
    background:#111827;
    padding:22px;
    border-radius:22px;
    margin-bottom:25px;
}

.form-grid{
    display:grid;
    grid-template-columns:repeat(3,1fr);
    gap:16px;
}

.input-box input,
.input-box select,
.input-box textarea{
    width:100%;
    background:#1e293b;
    border:none;
    outline:none;
    height:50px;
    border-radius:14px;
    padding:0 15px;
    color:#fff;
}

.input-box textarea{
    height:110px;
    padding-top:14px;
    resize:none;
}

.submit-btn{
    width:220px;
    height:50px;
    border:none;
    border-radius:14px;
    background:linear-gradient(135deg,#06b6d4,#3b82f6);
    color:#fff;
    font-weight:600;
    cursor:pointer;
    margin-top:18px;
}

/* Table */

.payout-table{
    background:#111827;
    border-radius:22px;
    overflow:hidden;
}

/* Head */

.table-head{
    display:grid;
    grid-template-columns:
    90px
    1.3fr
    1.2fr
    120px
    120px
    160px
    160px
    170px;
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
    1.3fr
    1.2fr
    120px
    120px
    160px
    160px
    170px;
    gap:15px;
    align-items:center;
    padding:16px 20px;
    border-bottom:1px solid rgba(255,255,255,0.05);
}

.table-row:hover{
    background:#18212f;
}

/* Text */

.payout-id{
    font-size:15px;
    font-weight:700;
    color:#22d3ee;
}

.name{
    font-size:14px;
    font-weight:600;
    margin-bottom:4px;
}

.small-text{
    font-size:12px;
    color:#94a3b8;
    line-height:1.5;
}

.amount{
    font-size:16px;
    font-weight:700;
    color:#4ade80;
}

/* Badge */

.badge{
    display:inline-block;
    padding:7px 14px;
    border-radius:30px;
    background:#16a34a20;
    color:#4ade80;
    font-size:11px;
    font-weight:600;
    text-transform:uppercase;
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
    color:#94a3b8;
    font-size:13px;
}

/* Responsive */

@media(max-width:1400px){

    .payout-table{
        overflow-x:auto;
    }

    .table-head,
    .table-row{
        min-width:1350px;
    }

}

@media(max-width:1000px){

    .form-grid{
        grid-template-columns:1fr;
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
            Delivery Boy Payouts
        </h1>

        <p>
            Manage delivery partner payouts and wallet settlements
        </p>

    </div>

    <!-- Form -->

    <div class="form-box">

        <form method="POST">

            <div class="form-grid">

                <!-- Delivery Boy -->

                <div class="input-box">

                    <select name="delivery_boy_id" required>

                        <option value="">
                            Select Delivery Boy
                        </option>

                        <?php foreach($boys as $boy){ ?>

                        <option value="<?php echo $boy['id']; ?>">

                            <?php echo $boy['name']; ?>
                            (₹<?php echo $boy['wallet_balance']; ?>)

                        </option>

                        <?php } ?>

                    </select>

                </div>

                <!-- Amount -->

                <div class="input-box">

                    <input 
                        type="number"
                        name="amount"
                        placeholder="Payout Amount"
                        required
                    >

                </div>

                <!-- Payment Method -->

                <div class="input-box">

                    <select name="payment_method" required>

                        <option value="">
                            Payment Method
                        </option>

                        <option value="Cash">
                            Cash
                        </option>

                        <option value="UPI">
                            UPI
                        </option>

                        <option value="Bank Transfer">
                            Bank Transfer
                        </option>

                    </select>

                </div>

                <!-- Transaction -->

                <div class="input-box">

                    <input 
                        type="text"
                        name="transaction_id"
                        placeholder="Transaction ID"
                    >

                </div>

                <!-- Date -->

                <div class="input-box">

                    <input 
                        type="date"
                        name="payout_date"
                        required
                    >

                </div>

                <!-- Note -->

                <div class="input-box">

                    <textarea 
                        name="note"
                        placeholder="Note"
                    ></textarea>

                </div>

            </div>

            <button type="submit" name="add_payout" class="submit-btn">

                Add Payout

            </button>

        </form>

    </div>

    <!-- Table -->

    <?php if(count($payouts) > 0){ ?>

    <div class="payout-table">

        <!-- Head -->

        <div class="table-head">

            <div>ID</div>
            <div>Delivery Boy</div>
            <div>Franchise</div>
            <div>Amount</div>
            <div>Status</div>
            <div>Method</div>
            <div>Transaction</div>
            <div>Date</div>

        </div>

        <!-- Rows -->

        <?php foreach($payouts as $payout){ ?>

        <div class="table-row">

            <!-- ID -->

            <div class="payout-id">

                #<?php echo $payout['id']; ?>

            </div>

            <!-- Delivery Boy -->

            <div>

                <div class="name">

                    <?php echo htmlspecialchars($payout['delivery_boy_name']); ?>

                </div>

                <div class="small-text">

                    <?php echo htmlspecialchars($payout['delivery_boy_phone']); ?>

                </div>

            </div>

            <!-- Franchise -->

            <div class="small-text">

                <?php echo htmlspecialchars($payout['franchise_name']); ?>

            </div>

            <!-- Amount -->

            <div class="amount">

                ₹<?php echo $payout['amount']; ?>

            </div>

            <!-- Status -->

            <div>

                <span class="badge">

                    <?php echo $payout['status']; ?>

                </span>

            </div>

            <!-- Method -->

            <div class="small-text">

                <?php echo htmlspecialchars($payout['payment_method']); ?>

            </div>

            <!-- Transaction -->

            <div class="small-text">

                <?php echo !empty($payout['transaction_id']) 
                    ? htmlspecialchars($payout['transaction_id']) 
                    : 'N/A'; 
                ?>

            </div>

            <!-- Date -->

            <div class="small-text">

                <?php echo date("d M Y",strtotime($payout['payout_date'])); ?>

            </div>

        </div>

        <?php } ?>

    </div>

    <?php }else{ ?>

    <div class="empty-box">

        <i class="fa-solid fa-wallet"></i>

        <h2>No Payouts Found</h2>

        <p>
            No delivery boy payouts available
        </p>

    </div>

    <?php } ?>

</div>

</body>
</html>