<?php
session_start();

require_once 'db.php';

/* Login */

if(!isset($_SESSION['seller_id'])){

    header("Location:index.php");
    exit;
}

/* Logged Franchise */

$franchise_id = $_SESSION['seller_id'];

/* Delete */

if(isset($_GET['delete'])){

    $delete_pin = trim($_GET['delete']);

    /* Franchise Pincodes */

    $stmt = $pdo->prepare("
        SELECT service_pincodes 
        FROM seller 
        WHERE id=?
    ");

    $stmt->execute([$franchise_id]);

    $franchise = $stmt->fetch();

    $pins = [];

    if(!empty($franchise['service_pincodes'])){

        $pins = explode(",",$franchise['service_pincodes']);

        $pins = array_map('trim',$pins);

    }

    /* Remove Pincode */

    $pins = array_diff($pins,[$delete_pin]);

    $updated = implode(",",$pins);

    /* Update Franchise */

    $update = $pdo->prepare("
        UPDATE seller 
        SET service_pincodes=? 
        WHERE id=?
    ");

    $update->execute([

        $updated,
        $franchise_id

    ]);

    header("Location:all-pincodes.php");
    exit;
}

/* Search */

$search = isset($_GET['search']) 
? trim($_GET['search']) 
: "";

/* Get Franchise Pincodes */

$stmt = $pdo->prepare("
    SELECT service_pincodes 
    FROM seller 
    WHERE id=?
");

$stmt->execute([$franchise_id]);

$franchise = $stmt->fetch();

$all_pincodes = [];

if(!empty($franchise['service_pincodes'])){

    $pins = explode(",",$franchise['service_pincodes']);

    foreach($pins as $pin){

        $pin = trim($pin);

        if($pin != ""){

            $all_pincodes[] = $pin;

        }

    }

}

/* Unique */

$all_pincodes = array_unique($all_pincodes);

/* Search */

if(!empty($search)){

    $all_pincodes = array_filter($all_pincodes,function($pin) use ($search){

        return stripos($pin,$search) !== false;

    });

}

/* Sort */

rsort($all_pincodes);

?>

<!DOCTYPE html>
<html lang="en">
<head>

<meta charset="UTF-8">

<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>All Pincodes</title>

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

/* Header */

.page-header{
    margin-bottom:22px;
}

.page-header h1{
    font-size:24px;
    margin-bottom:5px;
}

.page-header p{
    color:#94a3b8;
    font-size:13px;
}

/* Search */

.search-box{
    background:#111827;
    padding:18px;
    border-radius:20px;
    margin-bottom:22px;
}

.search-box form{
    display:flex;
    gap:14px;
}

.search-box input{
    flex:1;
    height:50px;
    border:none;
    outline:none;
    background:#1e293b;
    border-radius:14px;
    padding:0 16px;
    color:#fff;
}

.search-btn{
    width:130px;
    border:none;
    border-radius:14px;
    background:linear-gradient(135deg,#06b6d4,#7c3aed);
    color:#fff;
    font-weight:600;
    cursor:pointer;
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
    120px
    1fr
    120px;
    gap:15px;
    padding:18px 20px;
    background:#1e293b;
    font-size:13px;
    font-weight:600;
}

.table-row{
    display:grid;
    grid-template-columns:
    120px
    1fr
    120px;
    gap:15px;
    align-items:center;
    padding:18px 20px;
    border-bottom:1px solid rgba(255,255,255,0.05);
}

.table-row:hover{
    background:#18212f;
}

.table-text{
    font-size:14px;
    color:#e2e8f0;
}

/* Badge */

.pin-badge{
    display:inline-flex;
    align-items:center;
    justify-content:center;
    padding:10px 16px;
    border-radius:30px;
    background:#06b6d420;
    color:#67e8f9;
    font-size:13px;
    font-weight:600;
    width:max-content;
}

/* Delete */

.delete-btn{
    width:42px;
    height:42px;
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

@media(max-width:900px){

    .main-content{
        margin-left:0;
        padding:85px 15px 20px;
    }

    .search-box form{
        flex-direction:column;
    }

    .search-btn{
        width:100%;
        height:50px;
    }

}

</style>

</head>
<body>

<?php include 'nav.php'; ?>

<div class="main-content">

    <div class="page-header">

        <h1>My Service Pincodes</h1>

        <p>
            Manage your delivery service areas
        </p>

    </div>

    <!-- Search -->

    <div class="search-box">

        <form method="GET">

            <input 
                type="text"
                name="search"
                placeholder="Search Pincode"
                value="<?php echo htmlspecialchars($search); ?>"
            >

            <button type="submit" class="search-btn">

                <i class="fa-solid fa-magnifying-glass"></i>
                Search

            </button>

        </form>

    </div>

    <!-- Table -->

    <?php if(count($all_pincodes) > 0){ ?>

    <div class="table-box">

        <div class="table-head">

            <div>#</div>
            <div>Pincode</div>
            <div>Action</div>

        </div>

        <?php $i=1; foreach($all_pincodes as $pin){ ?>

        <div class="table-row">

            <div class="table-text">

                #<?php echo $i++; ?>

            </div>

            <div>

                <div class="pin-badge">

                    <?php echo htmlspecialchars($pin); ?>

                </div>

            </div>

            <div>

                <a 
                    href="all-pincodes.php?delete=<?php echo urlencode($pin); ?>"
                    class="delete-btn"
                    onclick="return confirm('Delete this pincode?')"
                >

                    <i class="fa-solid fa-trash"></i>

                </a>

            </div>

        </div>

        <?php } ?>

    </div>

    <?php }else{ ?>

    <div class="empty-box">

        <i class="fa-solid fa-location-dot"></i>

        <h2>No Pincodes Found</h2>

        <p>
            No service pincodes available
        </p>

    </div>

    <?php } ?>

</div>

</body>
</html>