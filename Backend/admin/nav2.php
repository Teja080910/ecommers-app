<!-- nav2.php -->

<?php

$current_page =
basename($_SERVER['PHP_SELF']);

function isActive($page){

    global $current_page;

    return $current_page == $page
    ? 'submenu-active'
    : '';
}

?>

<link rel="stylesheet"
href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">

<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600&display=swap"
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
}

/* SIDEBAR */

.sidebar{
    width:240px;
    height:100vh;
    background:#111827;
    position:fixed;
    left:0;
    top:0;
    padding:18px 14px;
    overflow-y:auto;
    border-right:
    1px solid rgba(255,255,255,0.05);
    transition:.3s;
    z-index:999;
}

/* LOGO */

.logo-box{
    display:flex;
    align-items:center;
    gap:10px;
    padding:10px 8px 24px;
    border-bottom:
    1px solid rgba(255,255,255,0.05);
    margin-bottom:18px;
}

.logo-box img{
    width:42px;
    height:42px;
    object-fit:contain;
}

.logo-text h2{
    color:#fff;
    font-size:15px;
    font-weight:600;
    line-height:1.2;
}

.logo-text p{
    color:#64748b;
    font-size:11px;
    margin-top:2px;
}

/* MENU */

.menu-title{
    color:#64748b;
    font-size:10px;
    text-transform:uppercase;
    letter-spacing:1px;
    margin:18px 10px 12px;
}

.menu{
    list-style:none;
}

.menu li{
    margin-bottom:6px;
}

.menu li a{
    display:flex;
    align-items:center;
    justify-content:space-between;
    text-decoration:none;
    color:#d1d5db;
    padding:12px 14px;
    border-radius:12px;
    transition:.25s;
    font-size:13px;
    font-weight:500;
}

.menu li a:hover{
    background:#1e293b;
    color:#fff;
}

.menu-left{
    display:flex;
    align-items:center;
    gap:12px;
}

.menu-left i{
    width:18px;
    font-size:14px;
    color:#fff;
}

/* ACTIVE */

.menu > li.active > a{
    background:
    linear-gradient(
    135deg,
    #ef4444,
    #7c3aed
    );
    color:#fff;
}

/* SUBMENU */

.submenu{
    display:none;
    list-style:none;
    padding-left:12px;
    margin-top:6px;
}

.submenu.show{
    display:block;
}

.submenu li{
    margin-bottom:4px;
}

.submenu li a{
    background:#0f172a;
    padding:11px 14px;
    font-size:12px;
    border-radius:10px;
    color:#94a3b8;
}

.submenu li a:hover{
    background:#1e293b;
    color:#fff;
}

.submenu a.submenu-active{
    background:#1e293b;
    color:#fff;
}

/* MOBILE */

.mobile-toggle{
    position:fixed;
    top:16px;
    left:16px;
    width:42px;
    height:42px;
    border:none;
    border-radius:10px;
    background:#111827;
    color:#fff;
    font-size:18px;
    cursor:pointer;
    display:none;
    z-index:1001;
    box-shadow:
    0 10px 25px rgba(0,0,0,0.3);
}

/* OVERLAY */

.overlay{
    position:fixed;
    inset:0;
    background:rgba(0,0,0,0.6);
    display:none;
    z-index:998;
}

.overlay.show{
    display:block;
}

/* SCROLLBAR */

.sidebar::-webkit-scrollbar{
    width:5px;
}

.sidebar::-webkit-scrollbar-thumb{
    background:#1e293b;
    border-radius:20px;
}

/* RESPONSIVE */

@media(max-width:900px){

    .mobile-toggle{
        display:block;
    }

    .sidebar{
        left:-100%;
    }

    .sidebar.show{
        left:0;
    }
}

</style>

<!-- MOBILE BUTTON -->

<button
class="mobile-toggle"
onclick="toggleSidebar()">

    <i class="fa-solid fa-bars"></i>

</button>

<!-- OVERLAY -->

<div
class="overlay"
id="overlay"
onclick="toggleSidebar()"></div>

<!-- SIDEBAR -->

<div class="sidebar" id="sidebar">

    <!-- LOGO -->

    <div class="logo-box">

        <img src="logo.png">

        <div class="logo-text">

            <h2>
                OTT Admin
            </h2>

            <p>
                Streaming Panel
            </p>

        </div>

    </div>

    <!-- MENU TITLE -->

    <div class="menu-title">

        OTT Navigation

    </div>

<?php

$movie_pages = [

'add-movie.php',
'all-movies.php',
'add-cast.php',
'all-cast.php'

];

$shorts_pages = [

'add-shorts.php',
'all-shorts.php'

];

$zhatpat_pages = [

'add-zhatpat.php',
'all-zhatpat.php',
'add-zhatpat-video.php',
'all-zhatpat-videos.php'

];

$casting_pages = [

'add-casting.php',
'all-casting.php',
'casting-applications.php'

];

$subscription_pages = [

'add-subscription.php',
'all-subscription.php',
'user-subscription.php'

];

$user_pages = [

'ott-users.php',
'watchlist.php'

];

$settings_pages = [

'app-settings-onbording.php',
'change-password.php'

];

?>

<ul class="menu">
 <li class="<?= ($current_page == 'home.php') ? 'active' : '' ?>">

        <a href="home.php">

            <div class="menu-left">

                <i class="fa-solid fa-tv"></i>

               Zenvora Dashboard

            </div>

        </a>

    </li>

    <!-- DASHBOARD -->

    <li class="<?= ($current_page == 'otthome.php') ? 'active' : '' ?>">

        <a href="otthome.php">

            <div class="menu-left">

                <i class="fa-solid fa-tv"></i>

                OTT Dashboard

            </div>

        </a>

    </li>

    <!-- MOVIES -->

    <li class="<?= in_array($current_page,$movie_pages) ? 'active' : '' ?>">

        <a href="javascript:void(0)"
        onclick="toggleSubmenu('movieMenu')">

            <div class="menu-left">

                <i class="fa-solid fa-film"></i>

                Movies

            </div>

            <i class="fa-solid fa-angle-down"></i>

        </a>

        <ul class="submenu <?= in_array($current_page,$movie_pages) ? 'show' : '' ?>"
        id="movieMenu">

            <li>

                <a
                class="<?= isActive('add-movie.php') ?>"
                href="add-movie.php">

                    Add Movie

                </a>

            </li>

            <li>

                <a
                class="<?= isActive('all-movies.php') ?>"
                href="all-movies.php">

                    All Movies

                </a>

            </li>

            <li>

                <a
                class="<?= isActive('add-cast.php') ?>"
                href="add-cast.php">

                    Add Cast

                </a>

            </li>

            <li>

                <a
                class="<?= isActive('all-cast.php') ?>"
                href="all-cast.php">

                    All Cast

                </a>

            </li>
               <li>

                <a
                class="<?= isActive('all-category.php') ?>"
                href="all-category.php">

                    All Category

                </a>

            </li>

        </ul>

    </li>
 <li class="<?= in_array($current_page,$movie_pages) ? 'active' : '' ?>">

        <a href="javascript:void(0)"
        onclick="toggleSubmenu('movieMenu2')">

            <div class="menu-left">

                <i class="fa-solid fa-film"></i>
 
                Movies Files

            </div>

            <i class="fa-solid fa-angle-down"></i>

        </a>

        <ul class="submenu <?= in_array($current_page,$movie_pages) ? 'show' : '' ?>"
        id="movieMenu2">

           

            <li>

                <a
                class="<?= isActive('add-link.php') ?>"
                href="add-link.php">

                    Add Link

                </a>

            </li>

            <li>

                <a
                class="<?= isActive('all-links.php') ?>"
                href="all-links.php">

                    All Links

                </a>

            </li>
             

        </ul>

    </li>

    <!-- SHORTS -->

    <li class="<?= in_array($current_page,$shorts_pages) ? 'active' : '' ?>">

        <a href="javascript:void(0)"
        onclick="toggleSubmenu('shortsMenu')">

            <div class="menu-left">

                <i class="fa-solid fa-video"></i>

                Shorts

            </div>

            <i class="fa-solid fa-angle-down"></i>

        </a>

        <ul class="submenu <?= in_array($current_page,$shorts_pages) ? 'show' : '' ?>"
        id="shortsMenu">

            <li>

                <a
                class="<?= isActive('add-shorts.php') ?>"
                href="add-shorts.php">

                    Add Shorts

                </a>

            </li>

            <li>

                <a
                class="<?= isActive('all-shorts.php') ?>"
                href="all-shorts.php">

                    All Shorts

                </a>

            </li>

        </ul>

    </li>

    <!-- ZHATPAT -->

    <li class="<?= in_array($current_page,$zhatpat_pages) ? 'active' : '' ?>">

        <a href="javascript:void(0)"
        onclick="toggleSubmenu('zhatpatMenu')">

            <div class="menu-left">

                <i class="fa-solid fa-clapperboard"></i>

                Zhatpat

            </div>

            <i class="fa-solid fa-angle-down"></i>

        </a>

        <ul class="submenu <?= in_array($current_page,$zhatpat_pages) ? 'show' : '' ?>"
        id="zhatpatMenu">

            <li>

                <a
                class="<?= isActive('add-zhatpat.php') ?>"
                href="add-zhatpat.php">

                    Add Series

                </a>

            </li>

            <li>

                <a
                class="<?= isActive('all-zhatpat.php') ?>"
                href="all-zhatpat.php">

                    All Series

                </a>

            </li>

            <li>

                <a
                class="<?= isActive('add-zhatpat-video.php') ?>"
                href="add-zhatpat-video.php">

                    Add Episodes

                </a>

            </li>

            <li>

                <a
                class="<?= isActive('all-zhatpat-videos.php') ?>"
                href="all-zhatpat-videos.php">

                    All Episodes

                </a>

            </li>

        </ul>

    </li>

    <!-- CASTING -->

    <li class="<?= in_array($current_page,$casting_pages) ? 'active' : '' ?>">

        <a href="javascript:void(0)"
        onclick="toggleSubmenu('castingMenu')">

            <div class="menu-left">

                <i class="fa-solid fa-masks-theater"></i>

                Casting

            </div>

            <i class="fa-solid fa-angle-down"></i>

        </a>

        <ul class="submenu <?= in_array($current_page,$casting_pages) ? 'show' : '' ?>"
        id="castingMenu">

            <li>

                <a
                class="<?= isActive('add-casting.php') ?>"
                href="add-casting.php">

                    Add Casting

                </a>

            </li>

            <li>

                <a
                class="<?= isActive('all-casting.php') ?>"
                href="all-casting.php">

                    All Casting

                </a>

            </li>

            <li>

                <a
                class="<?= isActive('casting-applications.php') ?>"
                href="casting-applications.php">

                    Applications

                </a>

            </li>

        </ul>

    </li>

    <!-- SUBSCRIPTIONS -->

    <li class="<?= in_array($current_page,$subscription_pages) ? 'active' : '' ?>">

        <a href="javascript:void(0)"
        onclick="toggleSubmenu('subscriptionMenu')">

            <div class="menu-left">

                <i class="fa-solid fa-crown"></i>

                Subscription

            </div>

            <i class="fa-solid fa-angle-down"></i>

        </a>

        <ul class="submenu <?= in_array($current_page,$subscription_pages) ? 'show' : '' ?>"
        id="subscriptionMenu">

            <li>

                <a
                class="<?= isActive('add-subscription.php') ?>"
                href="add-subscription.php">

                    Add Plan

                </a>

            </li>

            <li>

                <a
                class="<?= isActive('all-subscription.php') ?>"
                href="all-subscription.php">

                    All Plans

                </a>

            </li>

            <li>

                <a
                class="<?= isActive('user-subscription.php') ?>"
                href="user-subscription.php">

                    User Subscription

                </a>

            </li>

        </ul>

    </li>

    <!-- USERS -->

   

    <!-- LOGOUT -->

    <li>

        <a href="logout.php">

            <div class="menu-left">

                <i class="fa-solid fa-right-from-bracket"></i>

                Logout

            </div>

        </a>

    </li>

</ul>

</div>

<script>

function toggleSubmenu(id){

    document
    .getElementById(id)
    .classList.toggle('show');
}

function toggleSidebar(){

    document
    .getElementById('sidebar')
    .classList.toggle('show');

    document
    .getElementById('overlay')
    .classList.toggle('show');
}

</script>