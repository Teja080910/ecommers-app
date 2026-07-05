<?php
session_start();

require_once 'db.php';

/* Login Check */

if(!isset($_SESSION['seller_id'])){

    header("Location:index.php");
    exit;
}

$seller_id = intval($_SESSION['seller_id']);

/* Razorpay settings */

$rzpStmt = $pdo->query("SELECT * FROM razorpay_settings LIMIT 1");
$rzpSettings = $rzpStmt->fetch();

$paymentConfigured = !empty($rzpSettings['razorpay_key']) && !empty($rzpSettings['razorpay_secret']);

/* Seller's current active category (if any) — drives mutual exclusivity */

$activeCategoryStmt = $pdo->prepare("
    SELECT DISTINCT subscription.category
    FROM seller_subscription
    INNER JOIN subscription ON subscription.id = seller_subscription.sub_id
    WHERE seller_subscription.seller_id = ?
    AND seller_subscription.status = 'active'
    AND seller_subscription.end_date >= CURDATE()
    AND subscription.category IS NOT NULL
");
$activeCategoryStmt->execute([$seller_id]);
$activeCategories = $activeCategoryStmt->fetchAll(PDO::FETCH_COLUMN);
$myActiveCategory = $activeCategories[0] ?? null;

/* ============================================================
   AJAX: create a Razorpay order for a given plan
============================================================ */
if(isset($_POST['action']) && $_POST['action'] == 'create_order'){

    header('Content-Type: application/json');

    if(!$paymentConfigured){
        echo json_encode(['status'=>false,'message'=>'Payment not configured yet. Please contact support.']);
        exit;
    }

    $sub_id = intval($_POST['sub_id'] ?? 0);

    $planStmt = $pdo->prepare("
        SELECT * FROM subscription
        WHERE id=? AND audience IN ('seller','both')
        AND category IS NOT NULL AND plan_type IS NOT NULL
    ");
    $planStmt->execute([$sub_id]);
    $plan = $planStmt->fetch();

    if(!$plan){
        echo json_encode(['status'=>false,'message'=>'Invalid subscription plan']);
        exit;
    }

    /* Mutual exclusivity: block a different category while one is active */

    if($myActiveCategory && $myActiveCategory !== $plan['category']){
        echo json_encode(['status'=>false,'message'=>'You already have an active '.ucfirst($myActiveCategory).' Seller plan. Wait for it to expire before switching categories.']);
        exit;
    }

    /* Monthly requires an active enrollment in the same category first */

    if($plan['plan_type'] == 'monthly'){

        $enrollCheck = $pdo->prepare("
            SELECT seller_subscription.id
            FROM seller_subscription
            INNER JOIN subscription ON subscription.id = seller_subscription.sub_id
            WHERE seller_subscription.seller_id=?
            AND subscription.category=?
            AND subscription.plan_type='enrollment'
            AND seller_subscription.status='active'
            AND seller_subscription.end_date >= CURDATE()
        ");
        $enrollCheck->execute([$seller_id, $plan['category']]);

        if($enrollCheck->rowCount() == 0){
            echo json_encode(['status'=>false,'message'=>'Complete the one-time Enrollment first.']);
            exit;
        }
    }

    /* Don't allow re-buying a plan that's already active */

    $existingStmt = $pdo->prepare("
        SELECT id FROM seller_subscription
        WHERE seller_id=? AND sub_id=? AND status='active' AND end_date >= CURDATE()
    ");
    $existingStmt->execute([$seller_id, $sub_id]);

    if($existingStmt->rowCount() > 0){
        echo json_encode(['status'=>false,'message'=>'You are already enrolled in this plan']);
        exit;
    }

    /* Create the Razorpay order (raw cURL — no SDK vendored anywhere in this codebase) */

    $amountPaise = intval(round($plan['amount'] * 100));

    $ch = curl_init('https://api.razorpay.com/v1/orders');
    curl_setopt($ch, CURLOPT_USERPWD, $rzpSettings['razorpay_key'].':'.$rzpSettings['razorpay_secret']);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode([
        'amount' => $amountPaise,
        'currency' => 'INR',
        'payment_capture' => 1,
        'receipt' => 'sub_'.$sub_id.'_'.$seller_id.'_'.time()
    ]));
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    $order = json_decode($response, true);

    if($httpCode != 200 || empty($order['id'])){
        echo json_encode(['status'=>false,'message'=>'Could not start payment. Please try again.']);
        exit;
    }

    echo json_encode([
        'status' => true,
        'order_id' => $order['id'],
        'amount' => $amountPaise,
        'key_id' => $rzpSettings['razorpay_key'],
        'sub_id' => $sub_id,
        'plan_title' => $plan['title']
    ]);
    exit;
}

/* ============================================================
   AJAX: verify payment signature and activate the plan
============================================================ */
if(isset($_POST['action']) && $_POST['action'] == 'verify_payment'){

    header('Content-Type: application/json');

    $sub_id = intval($_POST['sub_id'] ?? 0);
    $razorpay_order_id = trim($_POST['razorpay_order_id'] ?? '');
    $razorpay_payment_id = trim($_POST['razorpay_payment_id'] ?? '');
    $razorpay_signature = trim($_POST['razorpay_signature'] ?? '');

    if(!$paymentConfigured || !$sub_id || !$razorpay_order_id || !$razorpay_payment_id || !$razorpay_signature){
        echo json_encode(['status'=>false,'message'=>'Missing payment details']);
        exit;
    }

    $expectedSignature = hash_hmac(
        'sha256',
        $razorpay_order_id.'|'.$razorpay_payment_id,
        $rzpSettings['razorpay_secret']
    );

    if(!hash_equals($expectedSignature, $razorpay_signature)){
        echo json_encode(['status'=>false,'message'=>'Payment verification failed']);
        exit;
    }

    $planStmt = $pdo->prepare("SELECT * FROM subscription WHERE id=?");
    $planStmt->execute([$sub_id]);
    $plan = $planStmt->fetch();

    if(!$plan){
        echo json_encode(['status'=>false,'message'=>'Invalid plan']);
        exit;
    }

    $start_date = date('Y-m-d');
    $end_date = date('Y-m-d', strtotime("+{$plan['days']} days"));

    $insert = $pdo->prepare("
        INSERT INTO seller_subscription
        (seller_id, sub_id, amount, status, start_date, end_date)
        VALUES (?, ?, ?, 'active', ?, ?)
    ");

    $run = $insert->execute([$seller_id, $sub_id, $plan['amount'], $start_date, $end_date]);

    echo json_encode(['status'=>$run, 'message'=>$run ? 'Payment successful' : 'Could not activate plan']);
    exit;
}

/* ============================================================
   Page render
============================================================ */

$viewCategory = $_GET['category'] ?? null;

if($viewCategory && !in_array($viewCategory, ['city','national'])){
    $viewCategory = null;
}

/* Category summary (for the picker) */

$categoryPlans = $pdo->query("
    SELECT * FROM subscription
    WHERE audience IN ('seller','both')
    AND category IS NOT NULL AND plan_type IS NOT NULL
    ORDER BY category, plan_type
")->fetchAll();

$categorySummary = ['city'=>['enrollment'=>null,'monthly'=>null], 'national'=>['enrollment'=>null,'monthly'=>null]];

foreach($categoryPlans as $p){
    if(isset($categorySummary[$p['category']])){
        $categorySummary[$p['category']][$p['plan_type']] = $p;
    }
}

/* My enrollments (all, for the history table at the bottom) */

$myEnrollments = $pdo->prepare("
    SELECT seller_subscription.*, subscription.title, subscription.category, subscription.plan_type
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

<script src="https://checkout.razorpay.com/v1/checkout.js"></script>

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
    display:flex;
    align-items:center;
    justify-content:space-between;
    gap:16px;
    flex-wrap:wrap;
}

.page-header h1{
    font-size:24px;
    margin-bottom:5px;
}

.page-header p{
    font-size:13px;
    color:#94a3b8;
}

.back-link{
    color:#22d3ee;
    text-decoration:none;
    font-size:13px;
    font-weight:600;
}

.alert{
    padding:14px 16px;
    border-radius:14px;
    margin-bottom:18px;
    font-size:13px;
    max-width:650px;
}

.success{
    background:#16a34a20;
    color:#4ade80;
}

.error{
    background:#dc262620;
    color:#f87171;
}

.warn{
    background:#eab30820;
    color:#facc15;
}

.grid{
    display:grid;
    grid-template-columns:repeat(auto-fill,minmax(300px,1fr));
    gap:20px;
    margin-bottom:36px;
}

.card{
    background:#111827;
    border-radius:24px;
    padding:26px;
    position:relative;
    overflow:hidden;
}

.card.featured{
    border:1px solid #7c3aed60;
}

.category-icon{
    width:52px;
    height:52px;
    border-radius:16px;
    display:flex;
    align-items:center;
    justify-content:center;
    font-size:22px;
    margin-bottom:16px;
    background:linear-gradient(135deg,#06b6d4,#7c3aed);
}

.card h2{
    font-size:19px;
    margin-bottom:6px;
}

.card .desc{
    font-size:13px;
    color:#94a3b8;
    margin-bottom:18px;
}

.price-breakdown{
    display:flex;
    flex-direction:column;
    gap:6px;
    margin-bottom:20px;
}

.price-line{
    display:flex;
    justify-content:space-between;
    font-size:13px;
    color:#cbd5e1;
}

.price-line b{
    color:#fff;
    font-size:15px;
}

.price{
    font-size:30px;
    font-weight:800;
    margin-bottom:6px;
}

.price small{
    font-size:13px;
    font-weight:500;
    color:#94a3b8;
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

.enroll-btn:disabled{
    opacity:0.5;
    cursor:not-allowed;
}

.enroll-btn.active-plan{
    background:#16a34a20;
    color:#4ade80;
    cursor:default;
}

.plan-block{
    background:#0b1120;
    border-radius:18px;
    padding:18px;
    margin-bottom:16px;
}

.plan-block:last-child{
    margin-bottom:0;
}

.plan-block .plan-name{
    font-size:13px;
    color:#94a3b8;
    margin-bottom:6px;
    text-transform:uppercase;
    letter-spacing:.5px;
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

        <div>
            <h1>Subscription Plans</h1>
            <p>
                <?php echo $viewCategory ? "Complete your ".ucfirst($viewCategory)." Seller subscription" : "Choose a seller plan to unlock benefits"; ?>
            </p>
        </div>

        <?php if($viewCategory){ ?>
            <a href="subscription-plans.php" class="back-link">
                <i class="fa-solid fa-arrow-left"></i> Change Category
            </a>
        <?php } ?>

    </div>

    <?php if(!$paymentConfigured){ ?>
        <div class="alert warn">
            Payment is not configured yet. Enrollment will be available as soon as it is.
        </div>
    <?php } ?>

    <div id="alertBox"></div>

    <?php if(!$viewCategory){ ?>

        <!-- ===================== CATEGORY PICKER ===================== -->

        <div class="grid">

            <?php foreach(['city'=>['label'=>'City Seller','icon'=>'fa-city','desc'=>'Sell within your local city / service area.'],
                            'national'=>['label'=>'National Seller','icon'=>'fa-earth-asia','desc'=>'Sell across India (PAN India).']] as $catKey => $meta){

                $enrollment = $categorySummary[$catKey]['enrollment'];
                $monthly = $categorySummary[$catKey]['monthly'];

                $isMyCategory = ($myActiveCategory == $catKey);
                $isBlocked = ($myActiveCategory && $myActiveCategory != $catKey);
            ?>

            <div class="card <?php echo $isMyCategory ? 'featured' : ''; ?>">

                <div class="category-icon"><i class="fa-solid <?php echo $meta['icon']; ?>"></i></div>

                <h2><?php echo $meta['label']; ?></h2>
                <div class="desc"><?php echo $meta['desc']; ?></div>

                <?php if($enrollment && $monthly){ ?>

                <div class="price-breakdown">
                    <div class="price-line">
                        <span>One-time Enrollment</span>
                        <b>&#8377;<?php echo number_format($enrollment['amount'],0); ?></b>
                    </div>
                    <div class="price-line">
                        <span>Monthly</span>
                        <b>&#8377;<?php echo number_format($monthly['amount'],0); ?>/mo</b>
                    </div>
                </div>

                <?php if($isMyCategory){ ?>

                    <button class="enroll-btn active-plan" disabled>
                        <i class="fa-solid fa-check"></i> Currently Active
                    </button>

                <?php }else{ ?>

                    <a href="subscription-plans.php?category=<?php echo $catKey; ?>" style="text-decoration:none;">
                        <button class="enroll-btn" <?php echo $isBlocked ? 'disabled' : ''; ?>>
                            <?php echo $isBlocked ? 'Unavailable while another plan is active' : 'Choose This Plan'; ?>
                        </button>
                    </a>

                <?php } ?>

                <?php }else{ ?>

                    <div class="empty-state">Plans coming soon.</div>

                <?php } ?>

            </div>

            <?php } ?>

        </div>

    <?php }else{

        $enrollment = $categorySummary[$viewCategory]['enrollment'];
        $monthly = $categorySummary[$viewCategory]['monthly'];

        $isBlocked = ($myActiveCategory && $myActiveCategory != $viewCategory);

        $enrollmentActive = $enrollment && in_array($enrollment['id'], $activeSubIds);
        $monthlyActive = $monthly && in_array($monthly['id'], $activeSubIds);
    ?>

        <!-- ===================== CATEGORY DETAIL + PAYMENT ===================== -->

        <?php if($isBlocked){ ?>

            <div class="alert error">
                You already have an active <?php echo ucfirst($myActiveCategory); ?> Seller plan. Wait for it to expire before switching categories.
            </div>

        <?php }else{ ?>

        <div class="grid" style="max-width:640px;">

            <?php if($enrollment){ ?>

            <div class="plan-block">
                <div class="plan-name">One-time Enrollment</div>
                <div class="price">&#8377;<?php echo number_format($enrollment['amount'],0); ?> <small>one-time</small></div>

                <?php if($enrollmentActive){ ?>
                    <button class="enroll-btn active-plan" disabled><i class="fa-solid fa-check"></i> Already Enrolled</button>
                <?php }else{ ?>
                    <button class="enroll-btn" onclick="payFor(<?php echo $enrollment['id']; ?>, this)" <?php echo $paymentConfigured ? '' : 'disabled'; ?>>
                        <i class="fa-solid fa-crown"></i> Pay &amp; Enroll
                    </button>
                <?php } ?>
            </div>

            <?php } ?>

            <?php if($monthly){ ?>

            <div class="plan-block">
                <div class="plan-name">Monthly Subscription</div>
                <div class="price">&#8377;<?php echo number_format($monthly['amount'],0); ?> <small>/month</small></div>

                <?php if($monthlyActive){ ?>
                    <button class="enroll-btn active-plan" disabled><i class="fa-solid fa-check"></i> Active until <?php
                        foreach($myEnrollments as $e){ if($e['sub_id']==$monthly['id'] && $e['status']=='active'){ echo date('d M Y', strtotime($e['end_date'])); break; } }
                    ?></button>
                <?php }elseif(!$enrollmentActive){ ?>
                    <button class="enroll-btn" disabled>Complete Enrollment First</button>
                <?php }else{ ?>
                    <button class="enroll-btn" onclick="payFor(<?php echo $monthly['id']; ?>, this)" <?php echo $paymentConfigured ? '' : 'disabled'; ?>>
                        <i class="fa-solid fa-calendar-check"></i> Pay Monthly
                    </button>
                <?php } ?>
            </div>

            <?php } ?>

        </div>

        <?php } ?>

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

<script>

function showAlert(type, message){
    const box = document.getElementById('alertBox');
    box.innerHTML = '<div class="alert '+type+'">'+message+'</div>';
}

function payFor(subId, btnEl){

    btnEl.disabled = true;

    fetch('', {
        method: 'POST',
        headers: {'Content-Type':'application/x-www-form-urlencoded'},
        body: 'action=create_order&sub_id=' + encodeURIComponent(subId)
    })
    .then(r => r.json())
    .then(data => {

        if(!data.status){
            showAlert('error', data.message || 'Could not start payment');
            btnEl.disabled = false;
            return;
        }

        const options = {
            key: data.key_id,
            amount: data.amount,
            currency: 'INR',
            name: 'Zipzapcart Seller Subscription',
            description: data.plan_title,
            order_id: data.order_id,
            handler: function(response){

                fetch('', {
                    method: 'POST',
                    headers: {'Content-Type':'application/x-www-form-urlencoded'},
                    body: 'action=verify_payment'
                        + '&sub_id=' + encodeURIComponent(subId)
                        + '&razorpay_order_id=' + encodeURIComponent(response.razorpay_order_id)
                        + '&razorpay_payment_id=' + encodeURIComponent(response.razorpay_payment_id)
                        + '&razorpay_signature=' + encodeURIComponent(response.razorpay_signature)
                })
                .then(r => r.json())
                .then(result => {

                    if(result.status){
                        showAlert('success', result.message);
                        setTimeout(() => location.reload(), 1200);
                    }else{
                        showAlert('error', result.message || 'Payment verification failed');
                        btnEl.disabled = false;
                    }
                });
            },
            modal: {
                ondismiss: function(){
                    btnEl.disabled = false;
                }
            },
            theme: { color: '#7c3aed' }
        };

        const rzp = new Razorpay(options);
        rzp.open();
    })
    .catch(() => {
        showAlert('error', 'Something went wrong. Please try again.');
        btnEl.disabled = false;
    });
}

</script>

</body>
</html>
