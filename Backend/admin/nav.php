<!-- nav.php -->

<?php
$current_page = basename($_SERVER['PHP_SELF']);

function isActive($page){
    global $current_page;
    return $current_page == $page ? 'submenu-active' : '';
}
?>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">

<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet">

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

/* Sidebar */

.sidebar{
    width:240px;
    height:100vh;
    background:#111827;
    position:fixed;
    left:0;
    top:0;
    padding:18px 14px;
    overflow-y:auto;
    border-right:1px solid rgba(255,255,255,0.05);
    transition:.3s;
    z-index:999;
}

/* Logo */

.logo-box{
    display:flex;
    align-items:center;
    gap:10px;
    padding:10px 8px 24px;
    border-bottom:1px solid rgba(255,255,255,0.05);
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

/* Menu */

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

/* Main Active */

.menu > li.active > a{
    background:linear-gradient(135deg,#06b6d4,#7c3aed);
    color:#fff;
}

/* Submenu */

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

/* Active Submenu */

.submenu a.submenu-active{
    background:#1e293b;
    color:#fff;
}

/* Mobile Toggle */

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
    box-shadow:0 10px 25px rgba(0,0,0,0.3);
}

/* Overlay */

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

/* Main Content */

.main-content{
    margin-left:240px;
    padding:25px;
    transition:.3s;
}

/* Scrollbar */

.sidebar::-webkit-scrollbar{
    width:5px;
}

.sidebar::-webkit-scrollbar-thumb{
    background:#1e293b;
    border-radius:20px;
}

/* Responsive */

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

    .main-content{
        margin-left:0;
        padding:80px 18px 20px;
    }

}

</style>

<!-- Mobile Button -->

<button class="mobile-toggle" onclick="toggleSidebar()">
    <i class="fa-solid fa-bars"></i>
</button>

<!-- Overlay -->

<div class="overlay" id="overlay" onclick="toggleSidebar()"></div>

<!-- Sidebar -->

<div class="sidebar" id="sidebar">

    <!-- Logo -->

    <div class="logo-box">

        <img src="logo.png">

        <div class="logo-text">
            <h2>Admin Panel</h2>
            <p>Management System</p>
        </div>

    </div>

    <!-- Menu -->

    <div class="menu-title">
        Navigation
    </div>

<?php

$product_pages = ['add-product.php','all-products.php','categories.php','product-requests.php'];

$franchise_pages = ['add-franchise.php','all-franchises.php','franchise-payouts.php'];

$delivery_pages = ['add-delivery-boy.php','all-delivery-boys.php','delivery-boy-payouts.php'];

$post_pages = ['addpost.php','allpost.php'];

$order_pages = ['veg-orders.php','food-orders.php','order-history.php','cancelled-orders.php'];

$offline_pages = ['offline-veg-orders.php','offline-food-orders.php','offline-history.php'];

$user_pages = ['all-users.php','offline-customers.php','saved-address.php'];

$area_pages = ['add-pincode.php','all-pincodes.php','requested_pincodes.php'];

$payment_pages = ['razorpay-settings.php','smtp-settings.php'];

$settings_pages = ['app-settings.php','change-password.php'];

?>

<ul class="menu">

    <!-- Dashboard -->

    <li class="<?= ($current_page == 'home.php') ? 'active' : '' ?>">

        <a href="home.php">

            <div class="menu-left">
                <i class="fa-solid fa-house"></i>
                Dashboard
            </div>

        </a>

    </li>

    <!-- Notifications -->

    <li class="<?= ($current_page == 'send-notification.php') ? 'active' : '' ?>">

        <a href="send-notification.php">

            <div class="menu-left">
                <i class="fa-solid fa-bullhorn"></i>
                Send Notification
            </div>

        </a>

    </li>

    <!-- Products -->

    <li class="<?= in_array($current_page,$product_pages) ? 'active' : '' ?>">

        <a href="javascript:void(0)" onclick="toggleSubmenu('productMenu')">

            <div class="menu-left">
                <i class="fa-solid fa-box"></i>
                Products
            </div>

            <i class="fa-solid fa-angle-down"></i>

        </a>

        <ul class="submenu <?= in_array($current_page,$product_pages) ? 'show' : '' ?>" id="productMenu">

            <li><a class="<?= isActive('add-product.php') ?>" href="add-product.php">Add Product</a></li>

            <li><a class="<?= isActive('all-products.php') ?>" href="all-products.php">All Products</a></li>

            <li><a class="<?= isActive('categories.php') ?>" href="categories.php">Categories</a></li>

            <li><a class="<?= isActive('product-requests.php') ?>" href="product-requests.php">Product Requests</a></li>

        </ul>

    </li>

    <!-- Franchises -->

    <li class="<?= in_array($current_page,$franchise_pages) ? 'active' : '' ?>">

        <a href="javascript:void(0)" onclick="toggleSubmenu('franchiseMenu')">

            <div class="menu-left">
                <i class="fa-solid fa-store"></i>
                Sellers
            </div>

            <i class="fa-solid fa-angle-down"></i>

        </a>

        <ul class="submenu <?= in_array($current_page,$franchise_pages) ? 'show' : '' ?>" id="franchiseMenu">

            <li><a class="<?= isActive('add-franchise.php') ?>" href="add-franchise.php">Add Sellers</a></li>

            <li><a class="<?= isActive('all-franchises.php') ?>" href="all-franchises.php">All Sellers</a></li>

            <li><a class="<?= isActive('franchise-payouts.php') ?>" href="franchise-payouts.php">Sellers Payouts</a></li>

        </ul>

    </li>

    <!-- Posts -->

    <li class="<?= in_array($current_page,$post_pages) ? 'active' : '' ?>">

        <a href="javascript:void(0)" onclick="toggleSubmenu('postMenu')">

            <div class="menu-left">
                <i class="fa-solid fa-image"></i>
                Posts
            </div>

            <i class="fa-solid fa-angle-down"></i>

        </a>

        <ul class="submenu <?= in_array($current_page,$post_pages) ? 'show' : '' ?>" id="postMenu">

            <li><a class="<?= isActive('addpost.php') ?>" href="addpost.php">Add Post</a></li>

            <li><a class="<?= isActive('allpost.php') ?>" href="allpost.php">All Posts</a></li>

        </ul>

    </li>

    <!-- Delivery Boys -->

    <li class="<?= in_array($current_page,$delivery_pages) ? 'active' : '' ?>">

        <a href="javascript:void(0)" onclick="toggleSubmenu('deliveryBoyMenu')">

            <div class="menu-left">
                <i class="fa-solid fa-motorcycle"></i>
                Delivery Boys
            </div>

            <i class="fa-solid fa-angle-down"></i>

        </a>

        <ul class="submenu <?= in_array($current_page,$delivery_pages) ? 'show' : '' ?>" id="deliveryBoyMenu">

            <li><a class="<?= isActive('add-delivery-boy.php') ?>" href="add-delivery-boy.php">Add Delivery Boy</a></li>

            <li><a class="<?= isActive('all-delivery-boys.php') ?>" href="all-delivery-boys.php">All Delivery Boys</a></li>

            <li><a class="<?= isActive('delivery-boy-payouts.php') ?>" href="delivery-boy-payouts.php">Delivery Boy Payouts</a></li>

        </ul>

    </li>

    <!-- Orders -->

    <li class="<?= in_array($current_page,$order_pages) ? 'active' : '' ?>">

        <a href="javascript:void(0)" onclick="toggleSubmenu('orderMenu')">

            <div class="menu-left">
                <i class="fa-solid fa-cart-shopping"></i>
                App Orders
            </div>

            <i class="fa-solid fa-angle-down"></i>

        </a>

        <ul class="submenu <?= in_array($current_page,$order_pages) ? 'show' : '' ?>" id="orderMenu">

       
            <li><a class="<?= isActive('order-history.php') ?>" href="order-history.php">Order History</a></li>

            <li><a class="<?= isActive('cancelled-orders.php') ?>" href="cancelled-orders.php">Cancelled Orders</a></li>

        </ul>

    </li>

    <!-- Offline Orders -->

    

    <!-- Users -->

    <li class="<?= in_array($current_page,$user_pages) ? 'active' : '' ?>">

        <a href="javascript:void(0)" onclick="toggleSubmenu('usersMenu')">

            <div class="menu-left">
                <i class="fa-solid fa-users"></i>
                Users
            </div>

            <i class="fa-solid fa-angle-down"></i>

        </a>

        <ul class="submenu <?= in_array($current_page,$user_pages) ? 'show' : '' ?>" id="usersMenu">

            <li><a class="<?= isActive('all-users.php') ?>" href="all-users.php">All App Users</a></li>

     
            <li><a class="<?= isActive('saved-address.php') ?>" href="saved-address.php">User Saved Address</a></li>

        </ul>

    </li>

    <!-- Service Areas -->

    <li class="<?= in_array($current_page,$area_pages) ? 'active' : '' ?>">

        <a href="javascript:void(0)" onclick="toggleSubmenu('areaMenu')">

            <div class="menu-left">
                <i class="fa-solid fa-location-dot"></i>
                Service Areas
            </div>

            <i class="fa-solid fa-angle-down"></i>

        </a>

        <ul class="submenu <?= in_array($current_page,$area_pages) ? 'show' : '' ?>" id="areaMenu">

            <li><a class="<?= isActive('add-pincode.php') ?>" href="add-pincode.php">Add Pincode</a></li>

            <li><a class="<?= isActive('all-pincodes.php') ?>" href="all-pincodes.php">All Service Pincodes</a></li>

           

        </ul>

    </li>

    <!-- Razorpay -->

    <li class="<?= in_array($current_page,$payment_pages) ? 'active' : '' ?>">

        <a href="javascript:void(0)" onclick="toggleSubmenu('paymentMenu')">

            <div class="menu-left">
                <i class="fa-solid fa-credit-card"></i>
                Razorpay Settings
            </div>

            <i class="fa-solid fa-angle-down"></i>

        </a>

        <ul class="submenu <?= in_array($current_page,$payment_pages) ? 'show' : '' ?>" id="paymentMenu">

            <li><a class="<?= isActive('razorpay-settings.php') ?>" href="razorpay-settings.php">Razorpay Keys</a></li>

            <li><a class="<?= isActive('smtp-settings.php') ?>" href="smtp-settings.php">SMTP (Email) Settings</a></li>

        </ul>

    </li>

    <!-- Settings -->

    <li class="<?= in_array($current_page,$settings_pages) ? 'active' : '' ?>">

        <a href="javascript:void(0)" onclick="toggleSubmenu('settingsMenu')">

            <div class="menu-left">
                <i class="fa-solid fa-gear"></i>
                Settings
            </div>

            <i class="fa-solid fa-angle-down"></i>

        </a>

        <ul class="submenu <?= in_array($current_page,$settings_pages) ? 'show' : '' ?>" id="settingsMenu">
  <li><a class="<?= isActive('appsetting.php') ?>" href="appsetting.php">App Settings</a></li>
            <li><a class="<?= isActive('app-settings.php') ?>" href="app-settings.php">App Home Banner Settings</a></li>
              <li><a class="<?= isActive('app-settings-onbording.php') ?>" href="app-settings-onbording.php">App Onboarding Settings</a></li>
            <li><a class="<?= isActive('change-password.php') ?>" href="change-password.php">Change Password</a></li>

        </ul>

    </li>

    <!-- Logout -->

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

    document.getElementById(id).classList.toggle('show');

}

function toggleSidebar(){

    document.getElementById('sidebar').classList.toggle('show');

    document.getElementById('overlay').classList.toggle('show');

}

</script>