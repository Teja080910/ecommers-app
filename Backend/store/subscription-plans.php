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
   Page render (single page, both categories shown together)
============================================================ */

/* Category summary */

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
    gap:14px;
}

.icon-btn-back{
    width:40px;
    height:40px;
    border-radius:12px;
    background:#111827;
    border:1px solid #1e293b;
    display:flex;
    align-items:center;
    justify-content:center;
    color:#cbd5e1;
    text-decoration:none;
}

.page-header h1{
    font-size:24px;
    font-weight:800;
    margin-bottom:4px;
}

.page-header p{
    font-size:13.5px;
    color:#94a3b8;
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

.cat-grid{
    display:flex;
    flex-direction:column;
    gap:22px;
    max-width:760px;
    margin-bottom:36px;
}

.cat-card{
    background:#111827;
    border-radius:22px;
    padding:24px 26px;
    position:relative;
}

.cat-card.blocked{
    opacity:0.55;
}

.cat-card-head{
    display:flex;
    align-items:flex-start;
    gap:16px;
    margin-bottom:18px;
}

.cat-icon{
    width:56px;
    height:56px;
    border-radius:16px;
    display:flex;
    align-items:center;
    justify-content:center;
    font-size:24px;
    flex-shrink:0;
}

.cat-icon.city{
    background:#16a34a20;
    color:#4ade80;
}

.cat-icon.national{
    background:#06b6d420;
    color:#22d3ee;
}

.cat-info{
    flex:1;
}

.cat-info h2{
    font-size:19px;
    font-weight:800;
    margin-bottom:3px;
    color:#fff;
}

.cat-info p{
    font-size:13px;
    color:#94a3b8;
}

.reach-badge{
    display:inline-flex;
    align-items:center;
    gap:6px;
    padding:8px 14px;
    border-radius:30px;
    font-size:12.5px;
    font-weight:700;
    white-space:nowrap;
}

.reach-badge.city{
    background:#16a34a20;
    color:#4ade80;
}

.reach-badge.national{
    background:#06b6d420;
    color:#22d3ee;
}

.divider{
    height:1px;
    background:rgba(255,255,255,0.06);
    margin-bottom:18px;
}

.option-grid{
    display:grid;
    grid-template-columns:1fr 1fr;
    gap:14px;
}

@media(max-width:640px){
    .option-grid{
        grid-template-columns:1fr;
    }
}

.option-box{
    position:relative;
    background:#0b1120;
    border:1.5px solid #1e293b;
    border-radius:16px;
    padding:16px 16px 16px 46px;
    cursor:pointer;
    transition:.15s;
}

.option-box.disabled{
    cursor:not-allowed;
    opacity:0.6;
}

.option-box.done{
    cursor:default;
}

.pop-badge{
    position:absolute;
    top:-11px;
    left:16px;
    background:#16a34a;
    color:#fff;
    font-size:10px;
    font-weight:800;
    letter-spacing:.4px;
    padding:4px 10px;
    border-radius:20px;
}

.pop-badge.national{
    background:#0891b2;
}

.option-radio{
    position:absolute;
    top:16px;
    left:16px;
    width:20px;
    height:20px;
    border-radius:50%;
    border:2px solid #334155;
    display:flex;
    align-items:center;
    justify-content:center;
    background:#0b1120;
}

.option-radio.checked{
    border-color:#16a34a;
    background:#16a34a;
    color:#fff;
    font-size:11px;
}

.option-radio.checked.national{
    border-color:#06b6d4;
    background:#06b6d4;
}

.option-box.selected.city{
    border-color:#16a34a;
    background:#16a34a14;
}

.option-box.selected.national{
    border-color:#06b6d4;
    background:#06b6d414;
}

.option-label{
    font-size:12px;
    font-weight:700;
    color:#94a3b8;
    margin-bottom:8px;
}

.option-price{
    font-size:21px;
    font-weight:800;
    color:#fff;
}

.option-price span{
    font-size:12.5px;
    font-weight:500;
    color:#94a3b8;
}

.option-hint{
    font-size:11.5px;
    color:#94a3b8;
    margin-top:6px;
}

.section-title{
    font-size:16px;
    font-weight:700;
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
    color:#94a3b8;
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

        <a href="home.php" class="icon-btn-back"><i class="fa-solid fa-arrow-left"></i></a>

        <div>
            <h1>Subscription Plans</h1>
            <p>Choose a plan that fits your business and unlock premium features.</p>
        </div>

    </div>

    <?php if(!$paymentConfigured){ ?>
        <div class="alert warn">
            Payment is not configured yet. Enrollment will be available as soon as it is.
        </div>
    <?php } ?>

    <div id="alertBox"></div>

    <div class="cat-grid">

        <?php foreach(['city'=>['label'=>'City Seller','icon'=>'fa-store','desc'=>'Sell within your city or local service area.','reach'=>'Local Reach','reachIcon'=>'fa-location-dot'],
                        'national'=>['label'=>'National Seller','icon'=>'fa-earth-asia','desc'=>'Sell across multiple states in India.','reach'=>'Nationwide Reach','reachIcon'=>'fa-building']] as $catKey => $meta){

            $enrollment = $categorySummary[$catKey]['enrollment'];
            $monthly = $categorySummary[$catKey]['monthly'];

            if(!$enrollment || !$monthly){
                continue;
            }

            $isBlocked = ($myActiveCategory && $myActiveCategory != $catKey);

            $enrollmentActive = in_array($enrollment['id'], $activeSubIds);
            $monthlyActive = in_array($monthly['id'], $activeSubIds);

            $monthlyEndDate = '';
            foreach($myEnrollments as $e){
                if($e['sub_id']==$monthly['id'] && $e['status']=='active'){
                    $monthlyEndDate = date('d M Y', strtotime($e['end_date']));
                    break;
                }
            }
        ?>

        <div class="cat-card <?php echo $isBlocked ? 'blocked' : ''; ?>">

            <div class="cat-card-head">

                <div class="cat-icon <?php echo $catKey; ?>"><i class="fa-solid <?php echo $meta['icon']; ?>"></i></div>

                <div class="cat-info">
                    <h2><?php echo $meta['label']; ?></h2>
                    <p><?php echo $meta['desc']; ?></p>
                </div>

                <div class="reach-badge <?php echo $catKey; ?>">
                    <i class="fa-solid <?php echo $meta['reachIcon']; ?>"></i>
                    <?php echo $meta['reach']; ?>
                </div>

            </div>

            <div class="divider"></div>

            <?php if($isBlocked){ ?>

                <div class="alert error" style="margin-bottom:0;">
                    You're currently on the <?php echo ucfirst($myActiveCategory); ?> Seller plan. Wait for it to expire before switching categories.
                </div>

            <?php }else{ ?>

            <div class="option-grid">

                <!-- ENROLLMENT -->
                <div class="option-box <?php echo $enrollmentActive ? 'selected done '.$catKey : ($paymentConfigured ? '' : 'disabled'); ?>"
                     <?php if(!$enrollmentActive && $paymentConfigured){ ?>onclick="payFor(<?php echo $enrollment['id']; ?>, this)"<?php } ?>>

                    <div class="option-radio <?php echo $enrollmentActive ? 'checked '.$catKey : ''; ?>">
                        <?php if($enrollmentActive){ ?><i class="fa-solid fa-check"></i><?php } ?>
                    </div>

                    <div class="option-label">One-time Enrollment</div>
                    <div class="option-price">&#8377;<?php echo number_format($enrollment['amount'],0); ?> <span>one-time</span></div>

                    <?php if($enrollmentActive){ ?>
                        <div class="option-hint">Enrolled</div>
                    <?php }elseif(!$paymentConfigured){ ?>
                        <div class="option-hint">Payment not configured</div>
                    <?php } ?>

                </div>

                <!-- MONTHLY -->
                <?php
                    $monthlyClickable = !$monthlyActive && $enrollmentActive && $paymentConfigured;
                ?>
                <div class="option-box <?php echo $monthlyActive ? 'selected done '.$catKey : (!$monthlyClickable ? 'disabled' : ''); ?>"
                     <?php if($monthlyClickable){ ?>onclick="payFor(<?php echo $monthly['id']; ?>, this)"<?php } ?>>

                    <?php if(!$monthlyActive){ ?>
                        <div class="pop-badge <?php echo $catKey == 'national' ? 'national' : ''; ?>">MOST POPULAR</div>
                    <?php } ?>

                    <div class="option-radio <?php echo $monthlyActive ? 'checked '.$catKey : ''; ?>">
                        <?php if($monthlyActive){ ?><i class="fa-solid fa-check"></i><?php } ?>
                    </div>

                    <div class="option-label">Monthly Subscription</div>
                    <div class="option-price">&#8377;<?php echo number_format($monthly['amount'],0); ?> <span>/month</span></div>

                    <?php if($monthlyActive){ ?>
                        <div class="option-hint">Active until <?php echo $monthlyEndDate; ?></div>
                    <?php }elseif(!$enrollmentActive){ ?>
                        <div class="option-hint">Complete enrollment first</div>
                    <?php } ?>

                </div>

            </div>

            <?php } ?>

        </div>

        <?php } ?>

    </div>

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
    window.scrollTo({top:0, behavior:'smooth'});
}

function payFor(subId, boxEl){

    if(boxEl.classList.contains('disabled') || boxEl.classList.contains('done')){
        return;
    }

    boxEl.style.pointerEvents = 'none';
    boxEl.style.opacity = '0.6';

    fetch('', {
        method: 'POST',
        headers: {'Content-Type':'application/x-www-form-urlencoded'},
        body: 'action=create_order&sub_id=' + encodeURIComponent(subId)
    })
    .then(r => r.json())
    .then(data => {

        if(!data.status){
            showAlert('error', data.message || 'Could not start payment');
            boxEl.style.pointerEvents = '';
            boxEl.style.opacity = '';
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
                        boxEl.style.pointerEvents = '';
                        boxEl.style.opacity = '';
                    }
                });
            },
            modal: {
                ondismiss: function(){
                    boxEl.style.pointerEvents = '';
                    boxEl.style.opacity = '';
                }
            },
            theme: { color: '#16a34a' }
        };

        const rzp = new Razorpay(options);
        rzp.open();
    })
    .catch(() => {
        showAlert('error', 'Something went wrong. Please try again.');
        boxEl.style.pointerEvents = '';
        boxEl.style.opacity = '';
    });
}

</script>

</body>
</html>
