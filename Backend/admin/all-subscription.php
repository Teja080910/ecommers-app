<?php
session_start();

require_once 'db.php';

if(!isset($_SESSION['admin_id'])){

    header("Location:index.php");
    exit;
}

/* DELETE */

if(isset($_GET['delete'])){

    $id =
    intval($_GET['delete']);

    $delete =
    $pdo->prepare(

    "DELETE FROM subscription
    WHERE id=?"

    );

    $delete->execute([$id]);

    header(
    "Location:all-subscription.php"
    );

    exit;
}

/* UPDATE */

if(isset($_POST['update_subscription'])){

    $id =
    intval($_POST['id']);

    $title =
    trim($_POST['title']);

    $amount =
    trim($_POST['amount']);

    $days =
    intval($_POST['days']);

    $update =
    $pdo->prepare(

    "UPDATE subscription SET

    title=?,
    amount=?,
    days=?

    WHERE id=?"

    );

    $update->execute([

        $title,
        $amount,
        $days,
        $id
    ]);

    header(
    "Location:all-subscription.php"
    );

    exit;
}

$plans =
$pdo->query(

"SELECT *
FROM subscription
ORDER BY id DESC"

)->fetchAll();

?>

<!DOCTYPE html>
<html>
<head>

<title>All Subscription</title>

<style>

body{
    background:#0f172a;
    color:#fff;
    font-family:Arial;
}

.main{
    margin-left:240px;
    padding:30px;
}

.grid{
    display:grid;
    grid-template-columns:
    repeat(auto-fill,minmax(280px,1fr));
    gap:20px;
}

.card{
    background:#111827;
    border-radius:20px;
    padding:22px;
}

.price{
    font-size:34px;
    font-weight:bold;
    margin:18px 0;
}

.days{
    display:inline-block;
    padding:10px 16px;
    border-radius:30px;
    background:#1e293b;
}

.actions{
    display:flex;
    gap:12px;
    margin-top:20px;
}

.btn{
    flex:1;
    height:45px;
    border:none;
    border-radius:12px;
    cursor:pointer;
    font-weight:bold;
}

.edit{
    background:#06b6d420;
    color:#22d3ee;
}

.delete{
    background:#ef444420;
    color:#f87171;
    text-decoration:none;
    display:flex;
    align-items:center;
    justify-content:center;
}

.modal{
    position:fixed;
    inset:0;
    background:rgba(0,0,0,0.7);
    display:none;
    align-items:center;
    justify-content:center;
}

.modal.show{
    display:flex;
}

.modal-box{
    width:100%;
    max-width:500px;
    background:#111827;
    border-radius:20px;
    padding:24px;
}

input{
    width:100%;
    height:55px;
    border:none;
    border-radius:14px;
    background:#1e293b;
    color:#fff;
    padding:0 15px;
    margin-bottom:18px;
}

.save{
    width:100%;
    height:55px;
    border:none;
    border-radius:14px;
    background:#7c3aed;
    color:#fff;
    font-weight:bold;
}

</style>

</head>
<body>

<?php include 'nav2.php'; ?>

<div class="main">

<div class="grid">

<?php foreach($plans as $p){ ?>

<div class="card">

<h2>

<?php echo $p['title']; ?>

</h2>

<div class="price">

₹<?php echo $p['amount']; ?>

</div>

<div class="days">

<?php echo $p['days']; ?> Days

</div>

<div class="actions">

<button

class="btn edit"

onclick="openModal(

'<?php echo $p['id']; ?>',

'<?php echo htmlspecialchars($p['title'],ENT_QUOTES); ?>',

'<?php echo $p['amount']; ?>',

'<?php echo $p['days']; ?>'

)">

Edit

</button>

<a

href="all-subscription.php?delete=<?php echo $p['id']; ?>"

class="btn delete"

onclick="
return confirm(
'Delete plan?'
)
">

Delete

</a>

</div>

</div>

<?php } ?>

</div>

</div>

<!-- MODAL -->

<div
class="modal"
id="editModal">

<div class="modal-box">

<h2>Edit Subscription</h2>

<br>

<form method="POST">

<input
type="hidden"
name="id"
id="edit_id">

<input
type="text"
name="title"
id="edit_title"
required>

<input
type="number"
step="0.01"
name="amount"
id="edit_amount"
required>

<input
type="number"
name="days"
id="edit_days"
required>

<button
type="submit"
name="update_subscription"
class="save">

Update Plan

</button>

</form>

</div>

</div>

<script>

function openModal(
id,
title,
amount,
days
){

    document
    .getElementById('editModal')
    .classList.add('show');

    document
    .getElementById('edit_id')
    .value = id;

    document
    .getElementById('edit_title')
    .value = title;

    document
    .getElementById('edit_amount')
    .value = amount;

    document
    .getElementById('edit_days')
    .value = days;
}

</script>

</body>
</html>