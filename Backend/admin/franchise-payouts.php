<?php
session_start();

require_once 'db.php';

/* Login */

if(!isset($_SESSION['admin_id'])){

    header("Location:index.php");
    exit;
}

/* Add Payout */

$success = "";
$error = "";

if(isset($_POST['add_payout'])){

    $seller_id = $_POST['seller_id'];
    $amount = $_POST['amount'];
    $payment_method = trim($_POST['payment_method']);
    $reference_no = trim($_POST['reference_no']);
    $notes = trim($_POST['notes']);
    $payment_date = $_POST['payment_date'];

    $insert = $pdo->prepare("INSERT INTO seller_payouts
    (
        seller_id,
        amount,
        payment_method,
        reference_no,
        notes,
        payment_date
    )
    VALUES
    (
        ?,
        ?,
        ?,
        ?,
        ?,
        ?
    )");

    $run = $insert->execute([

        $seller_id,
        $amount,
        $payment_method,
        $reference_no,
        $notes,
        $payment_date

    ]);

    if($run){

        $success = "Payout Recorded Successfully";

    }else{

        $error = "Failed To Record Payout";

    }

}

/* Delete */

if(isset($_GET['delete'])){

    $id = intval($_GET['delete']);

    $delete = $pdo->prepare("DELETE FROM seller_payouts WHERE id=?");

    $delete->execute([$id]);

    header("Location:franchise-payouts.php");
    exit;
}

/* Franchises */

$frQuery = $pdo->query("SELECT * FROM seller ORDER BY name ASC");

$franchises = $frQuery->fetchAll();

/* Fetch Payouts */

$sql = "SELECT 
seller_payouts.*,
seller.name AS franchise_name
FROM seller_payouts
LEFT JOIN seller ON seller.id = seller_payouts.seller_id
ORDER BY seller_payouts.id DESC";

$stmt = $pdo->query($sql);

$payouts = $stmt->fetchAll();

?>

<!DOCTYPE html>
<html lang="en">
<head>

<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>Franchise Payouts</title>

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
    display:flex;
    align-items:center;
    justify-content:space-between;
    margin-bottom:24px;
}

.page-title h1{
    font-size:24px;
    margin-bottom:5px;
}

.page-title p{
    color:#94a3b8;
    font-size:13px;
}

/* Button */

.add-btn{
    height:50px;
    padding:0 20px;
    border:none;
    border-radius:14px;
    background:linear-gradient(135deg,#06b6d4,#7c3aed);
    color:#fff;
    font-size:13px;
    font-weight:600;
    cursor:pointer;
}

/* Alerts */

.alert{
    padding:14px 16px;
    border-radius:14px;
    margin-bottom:20px;
    font-size:13px;
}

.success{
    background:#16a34a20;
    color:#4ade80;
}

.error{
    background:#dc262620;
    color:#f87171;
}

/* Table */

.table-box{
    background:#111827;
    border-radius:22px;
    overflow:hidden;
}

.table-head{
    display:grid;
    grid-template-columns:
    70px
    1.5fr
    120px
    140px
    180px
    1.5fr
    140px
    100px;
    gap:15px;
    padding:18px 20px;
    background:#1e293b;
    font-size:13px;
    font-weight:600;
}

.table-row{
    display:grid;
    grid-template-columns:
    70px
    1.5fr
    120px
    140px
    180px
    1.5fr
    140px
    100px;
    gap:15px;
    align-items:center;
    padding:18px 20px;
    border-bottom:1px solid rgba(255,255,255,0.05);
}

.table-row:hover{
    background:#18212f;
}

/* Text */

.table-text{
    font-size:13px;
    color:#e2e8f0;
    line-height:1.5;
}

.amount{
    color:#4ade80;
    font-size:15px;
    font-weight:700;
}

/* Badge */

.method{
    display:inline-flex;
    align-items:center;
    justify-content:center;
    padding:8px 12px;
    border-radius:30px;
    background:#06b6d420;
    color:#67e8f9;
    font-size:11px;
    font-weight:600;
    width:max-content;
}

/* Action */

.delete-btn{
    width:40px;
    height:40px;
    border-radius:12px;
    background:#ef444420;
    color:#f87171;
    display:flex;
    align-items:center;
    justify-content:center;
    text-decoration:none;
    transition:.3s;
}

.delete-btn:hover{
    background:#ef4444;
    color:#fff;
}

/* Modal */

.modal{
    position:fixed;
    inset:0;
    background:rgba(0,0,0,0.75);
    display:none;
    align-items:center;
    justify-content:center;
    z-index:9999;
    padding:20px;
}

.modal.show{
    display:flex;
}

.modal-box{
    width:100%;
    max-width:650px;
    background:#111827;
    border-radius:24px;
    padding:28px;
}

.modal-title{
    font-size:22px;
    font-weight:600;
    margin-bottom:24px;
}

/* Form */

.form-grid{
    display:grid;
    grid-template-columns:repeat(2,1fr);
    gap:18px;
}

.full-width{
    grid-column:1/3;
}

.input-box{
    display:flex;
    flex-direction:column;
}

.input-box label{
    font-size:13px;
    margin-bottom:8px;
    color:#cbd5e1;
}

.input-box input,
.input-box select,
.input-box textarea{
    width:100%;
    border:none;
    outline:none;
    background:#1e293b;
    border-radius:14px;
    padding:14px 16px;
    color:#fff;
    font-size:13px;
}

.input-box textarea{
    min-height:90px;
    resize:none;
}

/* Buttons */

.modal-buttons{
    display:flex;
    gap:12px;
    margin-top:22px;
}

.submit-btn,
.close-btn{
    flex:1;
    height:52px;
    border:none;
    border-radius:14px;
    cursor:pointer;
    font-size:13px;
    font-weight:600;
}

.submit-btn{
    background:linear-gradient(135deg,#06b6d4,#7c3aed);
    color:#fff;
}

.close-btn{
    background:#1e293b;
    color:#fff;
}

/* Empty */

.empty-box{
    background:#111827;
    border-radius:22px;
    padding:70px 20px;
    text-align:center;
}

.empty-box i{
    font-size:55px;
    color:#475569;
    margin-bottom:14px;
}

.empty-box h2{
    font-size:22px;
    margin-bottom:5px;
}

.empty-box p{
    color:#94a3b8;
    font-size:13px;
}

/* Responsive */

@media(max-width:1300px){

    .table-box{
        overflow-x:auto;
    }

    .table-head,
    .table-row{
        min-width:1200px;
    }

}

@media(max-width:900px){

    .main-content{
        margin-left:0;
        padding:85px 15px 20px;
    }

    .page-header{
        flex-direction:column;
        align-items:flex-start;
        gap:15px;
    }

    .form-grid{
        grid-template-columns:1fr;
    }

    .full-width{
        grid-column:auto;
    }

}

</style>

</head>
<body>

<?php include 'nav.php'; ?>

<div class="main-content">

    <!-- Header -->

    <div class="page-header">

        <div class="page-title">

            <h1>seller Payouts</h1>

            <p>
                Record and manage seller payout payments
            </p>

        </div>

        <button class="add-btn" onclick="openModal()">

            <i class="fa-solid fa-plus"></i>
            Add Payout

        </button>

    </div>

    <!-- Alerts -->

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

    <!-- Table -->

    <?php if(count($payouts) > 0){ ?>

    <div class="table-box">

        <!-- Head -->

        <div class="table-head">

            <div>ID</div>
            <div>seller</div>
            <div>Amount</div>
            <div>Method</div>
            <div>Reference</div>
            <div>Notes</div>
            <div>Date</div>
            <div>Action</div>

        </div>

        <!-- Rows -->

        <?php foreach($payouts as $p){ ?>

        <div class="table-row">

            <div class="table-text">

                #<?php echo $p['id']; ?>

            </div>

            <div class="table-text">

                <?php echo htmlspecialchars($p['franchise_name']); ?>

            </div>

            <div class="amount">

                ₹<?php echo number_format($p['amount'],2); ?>

            </div>

            <div>

                <div class="method">

                    <?php echo htmlspecialchars($p['payment_method']); ?>

                </div>

            </div>

            <div class="table-text">

                <?php echo htmlspecialchars($p['reference_no']); ?>

            </div>

            <div class="table-text">

                <?php echo htmlspecialchars($p['notes']); ?>

            </div>

            <div class="table-text">

                <?php echo date('d M Y',strtotime($p['payment_date'])); ?>

            </div>

            <div>

                <a 
                    href="franchise-payouts.php?delete=<?php echo $p['id']; ?>"
                    class="delete-btn"
                    onclick="return confirm('Delete this payout?')"
                >

                    <i class="fa-solid fa-trash"></i>

                </a>

            </div>

        </div>

        <?php } ?>

    </div>

    <?php }else{ ?>

    <div class="empty-box">

        <i class="fa-solid fa-money-bill-transfer"></i>

        <h2>No Payout Records</h2>

        <p>
            No payout entries found
        </p>

    </div>

    <?php } ?>

</div>

<!-- Modal -->

<div class="modal" id="payoutModal">

    <div class="modal-box">

        <div class="modal-title">
            Record seller Payout
        </div>

        <form method="POST">

            <div class="form-grid">

                <!-- Franchise -->

                <div class="input-box">

                    <label>seller</label>

                    <select name="seller_id" required>

                        <option value="">
                            Select seller
                        </option>

                        <?php foreach($franchises as $fr){ ?>

                            <option value="<?php echo $fr['id']; ?>">

                                <?php echo htmlspecialchars($fr['name']); ?>

                            </option>

                        <?php } ?>

                    </select>

                </div>

                <!-- Amount -->

                <div class="input-box">

                    <label>Amount</label>

                    <input 
                        type="number"
                        step="0.01"
                        name="amount"
                        required
                    >

                </div>

                <!-- Method -->

                <div class="input-box">

                    <label>Payment Method</label>

                    <select name="payment_method" required>

                        <option value="UPI">UPI</option>
                        <option value="Bank Transfer">Bank Transfer</option>
                        <option value="Cash">Cash</option>
                        <option value="Cheque">Cheque</option>

                    </select>

                </div>

                <!-- Reference -->

                <div class="input-box">

                    <label>Reference Number</label>

                    <input 
                        type="text"
                        name="reference_no"
                    >

                </div>

                <!-- Date -->

                <div class="input-box full-width">

                    <label>Payment Date</label>

                    <input 
                        type="date"
                        name="payment_date"
                        value="<?php echo date('Y-m-d'); ?>"
                        required
                    >

                </div>

                <!-- Notes -->

                <div class="input-box full-width">

                    <label>Notes</label>

                    <textarea name="notes"></textarea>

                </div>

            </div>

            <!-- Buttons -->

            <div class="modal-buttons">

                <button 
                    type="submit"
                    name="add_payout"
                    class="submit-btn"
                >

                    Record Payout

                </button>

                <button 
                    type="button"
                    class="close-btn"
                    onclick="closeModal()"
                >

                    Cancel

                </button>

            </div>

        </form>

    </div>

</div>

<script>

function openModal(){

    document.getElementById("payoutModal").classList.add("show");

}

function closeModal(){

    document.getElementById("payoutModal").classList.remove("show");

}

</script>

</body>
</html>