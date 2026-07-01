<?php
session_start();

require_once 'db.php';

/* Login Check */

if(!isset($_SESSION['admin_id'])){
?>
<!DOCTYPE html>
<html lang="en">
<head>

<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>Redirecting...</title>

<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&display=swap" rel="stylesheet">

<style>

*{
    margin:0;
    padding:0;
    box-sizing:border-box;
    font-family:'Inter',sans-serif;
}

body{
    background:#0f172a;
    overflow:hidden;
}

.toast{
    position:fixed;
    top:25px;
    right:25px;
    min-width:320px;
    background:#ef4444;
    color:#fff;
    padding:16px 20px;
    border-radius:16px;
    display:flex;
    align-items:center;
    gap:14px;
}

.toast-icon{
    width:40px;
    height:40px;
    border-radius:50%;
    background:rgba(255,255,255,0.15);
    display:flex;
    align-items:center;
    justify-content:center;
}

</style>

</head>
<body>

<div class="toast">

    <div class="toast-icon">!</div>

    <div>
        <h3>Login Required</h3>
        <p>Please login to continue</p>
    </div>

</div>

<script>

setTimeout(function(){

    window.location.href = "index.php";

},2000);

</script>

</body>
</html>
<?php
exit;
}

/* Toggle Status */

if(isset($_GET['toggle'])){

    $id = intval($_GET['toggle']);

    $stmt = $pdo->prepare("SELECT is_active FROM users WHERE id=?");

    $stmt->execute([$id]);

    $user = $stmt->fetch();

    if($user){

        $newStatus = $user['is_active'] == 1 ? 0 : 1;

        $update = $pdo->prepare("UPDATE users SET is_active=? WHERE id=?");

        $update->execute([$newStatus,$id]);

    }

    header("Location:all-users.php");
    exit;
}

/* Delete User */

if(isset($_GET['delete'])){

    $id = intval($_GET['delete']);

    $delete = $pdo->prepare("DELETE FROM users WHERE id=?");

    $delete->execute([$id]);

    header("Location:all-users.php");
    exit;
}

/* Search */

$search = isset($_GET['search']) ? trim($_GET['search']) : "";

/* Query */

$sql = "SELECT * FROM users WHERE 1";

$params = [];

if(!empty($search)){

    $sql .= " AND (
        name LIKE ?
        OR
        phone LIKE ?
        OR
        email LIKE ?
    )";

    $params[] = "%".$search."%";
    $params[] = "%".$search."%";
    $params[] = "%".$search."%";
}

$sql .= " ORDER BY id DESC";

$stmt = $pdo->prepare($sql);

$stmt->execute($params);

$users = $stmt->fetchAll();

?>

<!DOCTYPE html>
<html lang="en">
<head>

<meta charset="UTF-8">

<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>All Users</title>

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
    font-size:13px;
}

.search-btn{
    width:130px;
    border:none;
    border-radius:14px;
    background:linear-gradient(135deg,#06b6d4,#7c3aed);
    color:#fff;
    font-size:13px;
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
    70px
    90px
    1.2fr
    1fr
    1.2fr
    130px
    130px
    160px
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
    70px
    90px
    1.2fr
    1fr
    1.2fr
    130px
    130px
    160px
    120px;
    gap:15px;
    align-items:center;
    padding:18px 20px;
    border-bottom:1px solid rgba(255,255,255,0.05);
    transition:.3s;
}

.table-row:hover{
    background:#18212f;
}

/* User */

.user-photo{
    width:58px;
    height:58px;
    border-radius:16px;
    overflow:hidden;
    background:#1e293b;
    display:flex;
    align-items:center;
    justify-content:center;
}

.user-photo img{
    width:100%;
    height:100%;
    object-fit:cover;
}

.user-photo i{
    font-size:20px;
    color:#64748b;
}

/* Text */

.table-text{
    font-size:13px;
    color:#e2e8f0;
    line-height:1.5;
}

.name{
    font-weight:600;
}

.login-type{
    display:inline-flex;
    align-items:center;
    justify-content:center;
    padding:8px 12px;
    border-radius:30px;
    font-size:11px;
    font-weight:600;
}

.phone{
    background:#06b6d420;
    color:#67e8f9;
}

.google{
    background:#db277720;
    color:#f9a8d4;
}

/* Status */

.status{
    display:inline-flex;
    align-items:center;
    justify-content:center;
    padding:8px 12px;
    border-radius:30px;
    font-size:11px;
    font-weight:600;
}

.active{
    background:#16a34a20;
    color:#4ade80;
}

.inactive{
    background:#ef444420;
    color:#f87171;
}

/* Actions */

.action-buttons{
    display:flex;
    gap:10px;
}

.toggle-btn,
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

.toggle-btn{
    background:#06b6d420;
    color:#22d3ee;
}

.toggle-btn:hover{
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

<!-- Sidebar -->

<?php include 'nav.php'; ?>

<!-- Main -->

<div class="main-content">

    <!-- Header -->

    <div class="page-header">

        <h1>All Users</h1>

        <p>
            Manage app users and account status
        </p>

    </div>

    <!-- Search -->

    <div class="search-box">

        <form method="GET">

            <input 
                type="text"
                name="search"
                placeholder="Search name, phone or email"
                value="<?php echo htmlspecialchars($search); ?>"
            >

            <button type="submit" class="search-btn">

                <i class="fa-solid fa-magnifying-glass"></i>
                Search

            </button>

        </form>

    </div>

    <!-- Table -->

    <?php if(count($users) > 0){ ?>

    <div class="table-box">

        <!-- Head -->

        <div class="table-head">

            <div>ID</div>
            <div>Photo</div>
            <div>Name</div>
            <div>Phone</div>
            <div>Email</div>
            <div>Login Type</div>
            <div>Status</div>
            <div>Created</div>
            <div>Actions</div>

        </div>

        <!-- Rows -->

        <?php foreach($users as $user){ ?>

        <div class="table-row">

            <!-- ID -->

            <div class="table-text">

                #<?php echo $user['id']; ?>

            </div>

            <!-- Photo -->

            <div>

                <div class="user-photo">

                    <?php if(!empty($user['photo'])){ ?>

                        <img src="<?php echo $user['photo']; ?>">

                    <?php }else{ ?>

                        <i class="fa-solid fa-user"></i>

                    <?php } ?>

                </div>

            </div>

            <!-- Name -->

            <div class="table-text name">

                <?php echo htmlspecialchars($user['name']); ?>

            </div>

            <!-- Phone -->

            <div class="table-text">

                <?php echo htmlspecialchars($user['phone']); ?>

            </div>

            <!-- Email -->

            <div class="table-text">

                <?php echo htmlspecialchars($user['email']); ?>

            </div>

            <!-- Login Type -->

            <div>

                <div class="login-type <?php echo $user['login_type']; ?>">

                    <?php echo strtoupper($user['login_type']); ?>

                </div>

            </div>

            <!-- Status -->

            <div>

                <?php if($user['is_active'] == 1){ ?>

                    <div class="status active">
                        Active
                    </div>

                <?php }else{ ?>

                    <div class="status inactive">
                        Blocked
                    </div>

                <?php } ?>

            </div>

            <!-- Date -->

            <div class="table-text">

                <?php echo date('d M Y',strtotime($user['created_at'])); ?>

            </div>

            <!-- Actions -->

            <div class="action-buttons">

                <a 
                    href="all-users.php?toggle=<?php echo $user['id']; ?>"
                    class="toggle-btn"
                    title="Toggle Status"
                >

                    <i class="fa-solid fa-power-off"></i>

                </a>

                <a 
                    href="all-users.php?delete=<?php echo $user['id']; ?>"
                    class="delete-btn"
                    title="Delete User"
                    onclick="return confirm('Delete this user?')"
                >

                    <i class="fa-solid fa-trash"></i>

                </a>

            </div>

        </div>

        <?php } ?>

    </div>

    <?php }else{ ?>

    <div class="empty-box">

        <i class="fa-solid fa-users"></i>

        <h2>No Users Found</h2>

        <p>
            No user records available
        </p>

    </div>

    <?php } ?>

</div>

</body>
</html>