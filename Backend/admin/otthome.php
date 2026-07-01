<?php
session_start();

require_once 'db.php';

/* LOGIN CHECK */

if(!isset($_SESSION['admin_id'])){

    header("Location:index.php");
    exit;
}

/* TOTAL MOVIES */

$totalMovies =
$pdo->query(

"SELECT COUNT(*)
FROM movies"

)->fetchColumn();

/* TOTAL MOVIE VIEWS */

$totalViews =
$pdo->query(

"SELECT IFNULL(
SUM(views),
0
)
FROM movies"

)->fetchColumn();

/* TOTAL CAST */

$totalCast =
$pdo->query(

"SELECT COUNT(*)
FROM cast"

)->fetchColumn();

/* TOTAL SHORTS */

$totalShorts =
$pdo->query(

"SELECT COUNT(*)
FROM shorts"

)->fetchColumn();

/* TOTAL ZHATPAT */

$totalZhatpat =
$pdo->query(

"SELECT COUNT(*)
FROM zhatpat"

)->fetchColumn();

/* TOTAL ZHATPAT VIDEOS */

$totalZhatpatVideos =
$pdo->query(

"SELECT COUNT(*)
FROM zhatpat_videos"

)->fetchColumn();

/* TOTAL SUBSCRIPTIONS */

$totalSubscriptions =
$pdo->query(

"SELECT COUNT(*)
FROM subscription"

)->fetchColumn();

/* TOTAL USERS */

$totalUsers =
$pdo->query(

"SELECT COUNT(*)
FROM users"

)->fetchColumn();

/* TOTAL PAID USERS */

$totalPaidUsers =
$pdo->query(

"SELECT COUNT(*)
FROM users
WHERE paidstatus='paid'"

)->fetchColumn();

/* TOTAL FREE USERS */

$totalFreeUsers =
$pdo->query(

"SELECT COUNT(*)
FROM users
WHERE paidstatus='free'"

)->fetchColumn();

/* TOTAL WATCHLIST */

$totalWatchlist =
$pdo->query(

"SELECT COUNT(*)
FROM watchlist"

)->fetchColumn();

/* TOTAL CASTING */

$totalCasting =
$pdo->query(

"SELECT COUNT(*)
FROM casting"

)->fetchColumn();

/* TOTAL CASTING APPLICATIONS */

$totalCastingApplications =
$pdo->query(

"SELECT COUNT(*)
FROM casting_application"

)->fetchColumn();

/* TOTAL USER SUBSCRIPTIONS */

$totalUserSubscriptions =
$pdo->query(

"SELECT COUNT(*)
FROM user_subscription"

)->fetchColumn();

/* TOTAL FREE MOVIES */

$totalFreeMovies =
$pdo->query(

"SELECT COUNT(*)
FROM movies
WHERE isfree='yes'"

)->fetchColumn();

/* TOTAL PREMIUM MOVIES */

$totalPremiumMovies =
$pdo->query(

"SELECT COUNT(*)
FROM movies
WHERE isfree='no'"

)->fetchColumn();

?>

<!DOCTYPE html>
<html lang="en">
<head>

<meta charset="UTF-8">

<meta name="viewport"
content="width=device-width,
initial-scale=1.0">

<title>
OTT Dashboard
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
    min-height:100vh;
}

/* HEADER */

.dashboard-header{
    margin-bottom:28px;
}

.dashboard-header h1{
    font-size:28px;
    margin-bottom:6px;
}

.dashboard-header p{
    font-size:13px;
    color:#94a3b8;
}

/* CARDS */

.cards{
    display:grid;
    grid-template-columns:
    repeat(auto-fit,minmax(240px,1fr));
    gap:18px;
}

.card{
    position:relative;
    overflow:hidden;
    border-radius:24px;
    padding:24px;
    min-height:145px;
    transition:.35s;
    box-shadow:
    0 15px 35px rgba(0,0,0,0.28);
}

.card:hover{
    transform:translateY(-6px);
}

.card::before{
    content:'';
    position:absolute;
    width:130px;
    height:130px;
    background:rgba(255,255,255,0.08);
    border-radius:50%;
    top:-40px;
    right:-40px;
}

.card-top{
    display:flex;
    justify-content:space-between;
    align-items:center;
    margin-bottom:18px;
}

.card-top span{
    font-size:13px;
    font-weight:500;
}

.card-top i{
    font-size:20px;
}

.card h2{
    font-size:30px;
    font-weight:700;
    margin-bottom:10px;
}

.card-bottom{
    font-size:12px;
    color:rgba(255,255,255,0.85);
}

/* GRADIENTS */

.gradient1{
    background:
    linear-gradient(
    135deg,
    #2563eb,
    #1d4ed8
    );
}

.gradient2{
    background:
    linear-gradient(
    135deg,
    #7c3aed,
    #5b21b6
    );
}

.gradient3{
    background:
    linear-gradient(
    135deg,
    #059669,
    #047857
    );
}

.gradient4{
    background:
    linear-gradient(
    135deg,
    #ea580c,
    #c2410c
    );
}

.gradient5{
    background:
    linear-gradient(
    135deg,
    #db2777,
    #9d174d
    );
}

.gradient6{
    background:
    linear-gradient(
    135deg,
    #16a34a,
    #166534
    );
}

.gradient7{
    background:
    linear-gradient(
    135deg,
    #0891b2,
    #155e75
    );
}

.gradient8{
    background:
    linear-gradient(
    135deg,
    #dc2626,
    #991b1b
    );
}

.gradient9{
    background:
    linear-gradient(
    135deg,
    #9333ea,
    #6b21a8
    );
}

.gradient10{
    background:
    linear-gradient(
    135deg,
    #f59e0b,
    #b45309
    );
}

.gradient11{
    background:
    linear-gradient(
    135deg,
    #14b8a6,
    #0f766e
    );
}

.gradient12{
    background:
    linear-gradient(
    135deg,
    #6366f1,
    #4338ca
    );
}

.gradient13{
    background:
    linear-gradient(
    135deg,
    #be123c,
    #881337
    );
}

.gradient14{
    background:
    linear-gradient(
    135deg,
    #0f766e,
    #115e59
    );
}

.gradient15{
    background:
    linear-gradient(
    135deg,
    #4f46e5,
    #312e81
    );
}

.gradient16{
    background:
    linear-gradient(
    135deg,
    #65a30d,
    #3f6212
    );
}

/* RESPONSIVE */

@media(max-width:900px){

    .main-content{
        margin-left:0;
        padding:85px 15px 20px;
    }
}

</style>

</head>

<body>

<?php include 'nav2.php'; ?>

<div class="main-content">

    <!-- HEADER -->

    <div class="dashboard-header">

        <h1>

            OTT Dashboard

        </h1>

        <p>

            Monitor OTT platform
            analytics and performance

        </p>

    </div>

    <!-- CARDS -->

    <div class="cards">

        <!-- MOVIES -->

        <div class="card gradient1">

            <div class="card-top">

                <span>
                    Total Movies
                </span>

                <i class="fa-solid fa-film"></i>

            </div>

            <h2>

                <?php echo $totalMovies; ?>

            </h2>

            <div class="card-bottom">

                Uploaded OTT movies

            </div>

        </div>

        <!-- VIEWS -->

        <div class="card gradient2">

            <div class="card-top">

                <span>
                    Total Views
                </span>

                <i class="fa-solid fa-eye"></i>

            </div>

            <h2>

                <?php echo number_format($totalViews); ?>

            </h2>

            <div class="card-bottom">

                Movie watch views

            </div>

        </div>

        <!-- CAST -->

        <div class="card gradient3">

            <div class="card-top">

                <span>
                    Cast Members
                </span>

                <i class="fa-solid fa-user-group"></i>

            </div>

            <h2>

                <?php echo $totalCast; ?>

            </h2>

            <div class="card-bottom">

                Actors and actresses

            </div>

        </div>

        <!-- SHORTS -->

        <div class="card gradient4">

            <div class="card-top">

                <span>
                    Shorts Videos
                </span>

                <i class="fa-solid fa-video"></i>

            </div>

            <h2>

                <?php echo $totalShorts; ?>

            </h2>

            <div class="card-bottom">

                Shorts uploaded

            </div>

        </div>

        <!-- ZHATPAT -->

        <div class="card gradient5">

            <div class="card-top">

                <span>
                    Zhatpat Series
                </span>

                <i class="fa-solid fa-clapperboard"></i>

            </div>

            <h2>

                <?php echo $totalZhatpat; ?>

            </h2>

            <div class="card-bottom">

                Mini OTT series

            </div>

        </div>

        <!-- ZHATPAT VIDEOS -->

        <div class="card gradient6">

            <div class="card-top">

                <span>
                    Episodes
                </span>

                <i class="fa-solid fa-play"></i>

            </div>

            <h2>

                <?php echo $totalZhatpatVideos; ?>

            </h2>

            <div class="card-bottom">

                Total episodes

            </div>

        </div>

        <!-- SUBSCRIPTIONS -->

        <div class="card gradient7">

            <div class="card-top">

                <span>
                    Subscription Plans
                </span>

                <i class="fa-solid fa-crown"></i>

            </div>

            <h2>

                <?php echo $totalSubscriptions; ?>

            </h2>

            <div class="card-bottom">

                Premium plans

            </div>

        </div>

        <!-- USERS -->

        <div class="card gradient8">

            <div class="card-top">

                <span>
                    OTT Users
                </span>

                <i class="fa-solid fa-users"></i>

            </div>

            <h2>

                <?php echo $totalUsers; ?>

            </h2>

            <div class="card-bottom">

                Registered OTT users

            </div>

        </div>

        <!-- PAID USERS -->

        <div class="card gradient9">

            <div class="card-top">

                <span>
                    Paid Users
                </span>

                <i class="fa-solid fa-gem"></i>

            </div>

            <h2>

                <?php echo $totalPaidUsers; ?>

            </h2>

            <div class="card-bottom">

                Premium subscribers

            </div>

        </div>

        <!-- FREE USERS -->

        <div class="card gradient10">

            <div class="card-top">

                <span>
                    Free Users
                </span>

                <i class="fa-solid fa-user"></i>

            </div>

            <h2>

                <?php echo $totalFreeUsers; ?>

            </h2>

            <div class="card-bottom">

                Free viewers

            </div>

        </div>

        <!-- WATCHLIST -->

        <div class="card gradient11">

            <div class="card-top">

                <span>
                    Watchlist
                </span>

                <i class="fa-solid fa-bookmark"></i>

            </div>

            <h2>

                <?php echo $totalWatchlist; ?>

            </h2>

            <div class="card-bottom">

                Saved watchlist items

            </div>

        </div>

        <!-- CASTING -->

        <div class="card gradient12">

            <div class="card-top">

                <span>
                    Casting Jobs
                </span>

                <i class="fa-solid fa-masks-theater"></i>

            </div>

            <h2>

                <?php echo $totalCasting; ?>

            </h2>

            <div class="card-bottom">

                Casting opportunities

            </div>

        </div>

        <!-- CASTING APPLICATION -->

        <div class="card gradient13">

            <div class="card-top">

                <span>
                    Casting Applications
                </span>

                <i class="fa-solid fa-file-signature"></i>

            </div>

            <h2>

                <?php echo $totalCastingApplications; ?>

            </h2>

            <div class="card-bottom">

                Submitted auditions

            </div>

        </div>

        <!-- USER SUBSCRIPTIONS -->

        <div class="card gradient14">

            <div class="card-top">

                <span>
                    User Subscriptions
                </span>

                <i class="fa-solid fa-wallet"></i>

            </div>

            <h2>

                <?php echo $totalUserSubscriptions; ?>

            </h2>

            <div class="card-bottom">

                Active subscriptions

            </div>

        </div>

        <!-- FREE MOVIES -->

        <div class="card gradient15">

            <div class="card-top">

                <span>
                    Free Movies
                </span>

                <i class="fa-solid fa-unlock"></i>

            </div>

            <h2>

                <?php echo $totalFreeMovies; ?>

            </h2>

            <div class="card-bottom">

                Free content

            </div>

        </div>

        <!-- PREMIUM MOVIES -->

        <div class="card gradient16">

            <div class="card-top">

                <span>
                    Premium Movies
                </span>

                <i class="fa-solid fa-lock"></i>

            </div>

            <h2>

                <?php echo $totalPremiumMovies; ?>

            </h2>

            <div class="card-bottom">

                Paid OTT content

            </div>

        </div>

    </div>

</div>

</body>
</html>