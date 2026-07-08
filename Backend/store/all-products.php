<?php
session_start();

require_once 'db.php';
require_once '../includes/image_upload.php';

/* LOGIN CHECK */

if(!isset($_SESSION['seller_id'])){
?>
<!DOCTYPE html>
<html>
<head>

<meta charset="UTF-8">

<title>
Redirecting
</title>

<style>

body{
    background:#0f172a;
    font-family:Arial;
}

.toast{
    position:fixed;
    top:25px;
    right:25px;
    background:#ef4444;
    color:#fff;
    padding:18px 22px;
    border-radius:18px;
    font-size:14px;
}

</style>

</head>
<body>

<div class="toast">
    Please Login First
</div>

<script>

setTimeout(function(){

    window.location.href =
    "index.php";

},2000);

</script>

</body>
</html>
<?php
exit;
}

/* DELETE / STOP SELLING
   Mapping-backed listings: remove only this seller's own mapping row --
   the master product and other sellers' listings of it are untouched.
   Legacy variant listings: this seller fully owns the product row, so it
   (and its image) can be deleted outright, same as before. Both paths
   check ownership so a seller can never touch another seller's listing. */

if(isset($_GET['delete'])){

    $delete_id = intval($_GET['delete']);
    $seller_id_for_delete = intval($_SESSION['seller_id']);

    if(($_GET['type'] ?? '') === 'mapping'){

        $pdo->prepare(
            "DELETE FROM seller_product_mapping WHERE id=? AND seller_id=?"
        )->execute([$delete_id, $seller_id_for_delete]);

    }else{

        $getImage = $pdo->prepare(
            "SELECT image FROM products
             WHERE id=? AND seller_id=? AND hasvarients='yes'"
        );

        $getImage->execute([$delete_id, $seller_id_for_delete]);

        $img = $getImage->fetch();

        if($img){

            if(!empty($img['image'])){

                $path = "../app/" . $img['image'];

                if(file_exists($path)){
                    unlink($path);
                }
            }

            $pdo->prepare(
                "DELETE FROM products WHERE id=? AND seller_id=? AND hasvarients='yes'"
            )->execute([$delete_id, $seller_id_for_delete]);
        }
    }

    header(
        "Location:all-products.php"
    );

    exit;
}

/* FILTERS */

$search =
isset($_GET['search'])
? trim($_GET['search'])
: "";

$category_id =
isset($_GET['category_id'])
? trim($_GET['category_id'])
: "";

$seller_id =
$_SESSION['seller_id'];

/* CATEGORIES */

$categories =
$pdo->query(

"SELECT *
FROM categories
ORDER BY name ASC"

)->fetchAll();

/* SELLERS */

$sellers =
$pdo->query(

"SELECT *
FROM seller
ORDER BY name ASC"

)->fetchAll();

/* MY LISTINGS
   Two shapes to merge: mapping-backed (shared catalog, non-variant) and
   legacy variant products (still fully single-seller, unchanged). */

$my_seller_name =
$pdo->prepare("SELECT name FROM seller WHERE id=?");
$my_seller_name->execute([$seller_id]);
$my_seller_name = $my_seller_name->fetchColumn() ?: '';

/* MAPPED (non-variant) LISTINGS */

$sql = "

SELECT

products.id,
products.name,
products.image,
products.hasvarients,
products.status,

categories.name AS category_name,
subcategories.name AS subcategory_name,

spm.id AS mapping_id,
spm.saleprice,
spm.stock

FROM seller_product_mapping spm

JOIN products ON products.id = spm.product_id

LEFT JOIN categories ON categories.id = products.cat_id
LEFT JOIN subcategories ON subcategories.id = products.subcat_id

WHERE spm.seller_id = ?
";

$params = [$seller_id];

if(!empty($search)){
    $sql .= " AND products.name LIKE ?";
    $params[] = "%".$search."%";
}

if(!empty($category_id)){
    $sql .= " AND products.cat_id=?";
    $params[] = $category_id;
}

$sql .= " ORDER BY products.id DESC";

$stmt = $pdo->prepare($sql);
$stmt->execute($params);
$mapped_products = $stmt->fetchAll();

foreach($mapped_products as &$mp){
    $mp['is_mapping'] = true;
    $mp['seller_name'] = $my_seller_name;
}
unset($mp);

/* LEGACY VARIANT LISTINGS (single-seller, unchanged) */

$sql = "

SELECT

products.id,
products.name,
products.image,
products.hasvarients,
products.status,
products.saleprice,
products.stock,

categories.name AS category_name,
subcategories.name AS subcategory_name

FROM products

LEFT JOIN categories ON categories.id = products.cat_id
LEFT JOIN subcategories ON subcategories.id = products.subcat_id

WHERE products.hasvarients = 'yes' AND products.seller_id = ?
";

$params = [$seller_id];

if(!empty($search)){
    $sql .= " AND products.name LIKE ?";
    $params[] = "%".$search."%";
}

if(!empty($category_id)){
    $sql .= " AND products.cat_id=?";
    $params[] = $category_id;
}

$sql .= " ORDER BY products.id DESC";

$stmt = $pdo->prepare($sql);
$stmt->execute($params);
$variant_products = $stmt->fetchAll();

foreach($variant_products as &$vp){
    $vp['is_mapping'] = false;
    $vp['mapping_id'] = null;
    $vp['seller_name'] = $my_seller_name;
}
unset($vp);

$products = array_merge($mapped_products, $variant_products);

usort($products, function($a, $b){
    return $b['id'] <=> $a['id'];
});
?>

<!DOCTYPE html>
<html lang="en">
<head>

<meta charset="UTF-8">

<meta name="viewport"
content="width=device-width,
initial-scale=1.0">

<title>
All Products
</title>

<link rel="stylesheet"
href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">

<style>

*{
    margin:0;
    padding:0;
    box-sizing:border-box;
    font-family:Arial;
}

body{
    background:#0f172a;
    color:#fff;
}

/* MAIN */

.main-content{
    margin-left:240px;
    padding:28px;
}

/* HEADER */

.page-header{
    margin-bottom:24px;
}

.page-header h1{
    font-size:28px;
    margin-bottom:6px;
}

.page-header p{
    color:#94a3b8;
    font-size:13px;
}

/* FILTER */

.filter-box{
    background:#111827;
    padding:20px;
    border-radius:22px;
    margin-bottom:22px;
}

.filter-grid{
    display:grid;
    grid-template-columns:
    repeat(4,1fr);
    gap:14px;
}

.input-box input,
.input-box select{
    width:100%;
    height:50px;
    border:none;
    outline:none;
    background:#1e293b;
    border-radius:14px;
    padding:0 15px;
    color:#fff;
    font-size:13px;
}

.filter-btn{
    width:100%;
    height:50px;
    border:none;
    border-radius:14px;
    background:linear-gradient(
        135deg,
        #06b6d4,
        #7c3aed
    );
    color:#fff;
    font-weight:700;
    cursor:pointer;
}

/* TABLE */

.products-table{
    background:#111827;
    border-radius:24px;
    overflow:hidden;
}

.table-head{
    display:grid;

    grid-template-columns:

    90px
    2fr
    1.2fr
    1.2fr
    1.2fr
    120px
    150px
    170px;

    gap:15px;

    padding:18px 20px;

    background:#1e293b;

    font-size:13px;
    font-weight:700;
}

.table-row{
    display:grid;

    grid-template-columns:

    90px
    2fr
    1.2fr
    1.2fr
    1.2fr
    120px
    150px
    170px;

    gap:15px;

    align-items:center;

    padding:16px 20px;

    border-bottom:
    1px solid rgba(255,255,255,0.05);

    transition:.3s;
}

.table-row:hover{
    background:#18212f;
}

/* IMAGE */

.product-image{
    width:70px;
    height:70px;
    background:#1e293b;
    border-radius:18px;
    overflow:hidden;
    padding:8px;
}

.product-image img{
    width:100%;
    height:100%;
    object-fit:contain;
}

/* TEXT */

.product-name{
    font-size:14px;
    font-weight:700;
    margin-bottom:4px;
}

.table-text{
    font-size:13px;
    color:#cbd5e1;
}

/* PRICE */

.product-price{
    color:#4ade80;
    font-size:15px;
    font-weight:700;
}

/* BADGE */

.badge{
    display:inline-block;
    padding:7px 12px;
    border-radius:30px;
    font-size:11px;
    font-weight:700;
}

.fixed{
    background:#16a34a20;
    color:#4ade80;
}

/* ACTION */

.action-buttons{
    display:flex;
    align-items:center;
    gap:10px;
}

.edit-btn,
.delete-btn{
    width:42px;
    height:42px;
    border-radius:12px;
    display:flex;
    align-items:center;
    justify-content:center;
    text-decoration:none;
    transition:.3s;
}

.edit-btn{
    background:#06b6d420;
    color:#22d3ee;
}

.edit-btn:hover{
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

/* VARIANT BUTTON */

.variant-btn{
    height:40px;
    border:none;
    padding:0 15px;
    border-radius:12px;
    background:#7c3aed20;
    color:#c084fc;
    font-size:12px;
    font-weight:700;
    cursor:pointer;
}

/* EMPTY */

.empty-box{
    background:#111827;
    padding:70px 20px;
    border-radius:24px;
    text-align:center;
}

.empty-box i{
    font-size:55px;
    color:#475569;
    margin-bottom:15px;
}

.empty-box h2{
    font-size:22px;
    margin-bottom:5px;
}

.empty-box p{
    font-size:13px;
    color:#94a3b8;
}

/* MODAL */

.variant-modal{
    position:fixed;
    inset:0;
    background:rgba(0,0,0,0.75);
    display:none;
    align-items:center;
    justify-content:center;
    z-index:999;
}

.variant-box{
    width:100%;
    max-width:650px;
    background:#111827;
    border-radius:28px;
    padding:24px;
}

.variant-header{
    display:flex;
    align-items:center;
    justify-content:space-between;
    margin-bottom:20px;
}

.close-modal{
    width:42px;
    height:42px;
    border:none;
    border-radius:12px;
    background:#ef444420;
    color:#f87171;
    font-size:20px;
    cursor:pointer;
}

.variant-item{
    background:#1e293b;
    border-radius:18px;
    padding:16px;
    margin-bottom:14px;
}

.variant-name{
    font-size:16px;
    font-weight:700;
    margin-bottom:8px;
}

.variant-price{
    color:#4ade80;
    font-size:15px;
    font-weight:700;
    margin-bottom:8px;
}

.variant-stock{
    color:#94a3b8;
    font-size:13px;
}

/* RESPONSIVE */

@media(max-width:1200px){

    .products-table{
        overflow-x:auto;
    }

    .table-head,
    .table-row{
        min-width:1300px;
    }
}

@media(max-width:900px){

    .main-content{
        margin-left:0;
        padding:85px 15px 20px;
    }

    .filter-grid{
        grid-template-columns:1fr;
    }
}

</style>

</head>
<body>

<?php include 'nav.php'; ?>

<div class="main-content">

    <!-- HEADER -->

    <div class="page-header">

        <h1>
            All Products
        </h1>

        <p>
            Manage products,
            variants and sellers
        </p>

    </div>

    <!-- FILTER -->

    <div class="filter-box">

        <form method="GET">

            <div class="filter-grid">

                <!-- SEARCH -->

                <div class="input-box">

                    <input
                    type="text"

                    name="search"

                    placeholder="Search Product"

                    value="<?php echo htmlspecialchars($search); ?>">

                </div>

                <!-- CATEGORY -->

                <div class="input-box">

                    <select
                    name="category_id">

                        <option value="">
                            All Categories
                        </option>

                        <?php foreach($categories as $cat){ ?>

                        <option

                        value="<?php echo $cat['id']; ?>"

                        <?php if($category_id == $cat['id']) echo 'selected'; ?>

                        >

                            <?php echo $cat['name']; ?>

                        </option>

                        <?php } ?>

                    </select>

                </div>

                <!-- SELLER -->

                

               

                <!-- BUTTON -->

                <div>

                    <button
                    type="submit"
                    class="filter-btn">

                        <i class="fa fa-filter"></i>

                        Filter

                    </button>

                </div>

            </div>

        </form>

    </div>

    <!-- PRODUCTS -->

    <?php if(count($products) > 0){ ?>

    <div class="products-table">

        <!-- HEAD -->

        <div class="table-head">

            <div>
                Image
            </div>

            <div>
                Product
            </div>

            <div>
                Category
            </div>

            <div>
                Subcategory
            </div>

            <div>
                Seller
            </div>

            <div>
                Price
            </div>

            <div>
                Variants
            </div>

            <div>
                Actions
            </div>

        </div>

        <!-- ROWS -->

        <?php foreach($products as $product){ ?>

        <div class="table-row">

            <!-- IMAGE -->

            <div class="product-image">

                <img

                src="<?php echo resolveProductImageSrc($product['image']); ?>"

                alt="">

            </div>

            <!-- PRODUCT -->

            <div>

                <div class="product-name">

                    <?php echo htmlspecialchars($product['name']); ?>

                </div>

                <div class="table-text">

                    Stock :
                    <?php echo $product['stock'] ?? 0; ?>

                </div>

                <?php if($product['status'] === 'pending'){ ?>

                <div class="badge" style="background:#eab30820;color:#facc15;margin-top:6px;">
                    Pending Approval
                </div>

                <?php } ?>

            </div>

            <!-- CATEGORY -->

            <div class="table-text">

                <?php echo htmlspecialchars($product['category_name']); ?>

            </div>

            <!-- SUBCATEGORY -->

            <div class="table-text">

                <?php echo htmlspecialchars($product['subcategory_name']); ?>

            </div>

            <!-- SELLER -->

            <div class="table-text">

                <?php echo htmlspecialchars($product['seller_name']); ?>

            </div>

            <!-- PRICE -->

            <div class="product-price">

                ₹<?php echo $product['saleprice'] ?? 0; ?>

            </div>

            <!-- VARIANTS -->

            <div>

                <?php if(
                $product['hasvarients']
                == "yes"
                ){ ?>

                <button

                class="variant-btn"

                onclick="
                openVariants(
                <?php echo $product['id']; ?>
                )
                ">

                    View Variants

                </button>

                <?php }else{ ?>

                <div class="badge fixed">

                    No Variants

                </div>

                <?php } ?>

            </div>

            <!-- ACTIONS -->

            <div class="action-buttons">

                <!-- EDIT -->

                <a

                href="edit-product.php?id=<?php echo $product['id']; ?><?php echo $product['is_mapping'] ? '&mapping_id='.$product['mapping_id'] : ''; ?>"

                class="edit-btn">

                    <i class="fa fa-pen"></i>

                </a>

                <!-- DELETE / STOP SELLING -->

                <?php if($product['is_mapping']){ ?>

                <a

                href="all-products.php?delete=<?php echo $product['mapping_id']; ?>&type=mapping"

                class="delete-btn"

                onclick="
                return confirm(
                'Stop selling this product? (Only your listing is removed -- the product itself stays if other sellers carry it.)'
                )
                ">

                    <i class="fa fa-trash"></i>

                </a>

                <?php }else{ ?>

                <a

                href="all-products.php?delete=<?php echo $product['id']; ?>&type=product"

                class="delete-btn"

                onclick="
                return confirm(
                'Delete this product?'
                )
                ">

                    <i class="fa fa-trash"></i>

                </a>

                <?php } ?>

            </div>

        </div>

        <?php } ?>

    </div>

    <?php }else{ ?>

    <!-- EMPTY -->

    <div class="empty-box">

        <i class="fa fa-box-open"></i>

        <h2>
            No Products Found
        </h2>

        <p>
            No products matched
            your filters
        </p>

    </div>

    <?php } ?>

</div>

<!-- VARIANT MODAL -->

<div
class="variant-modal"
id="variantModal">

    <div
    class="variant-box">

        <div
        class="variant-header">

            <h2>
                Product Variants
            </h2>

            <button

            onclick="
            closeVariantModal()
            "

            class="close-modal">

                ×

            </button>

        </div>

        <div
        id="variantContent">

            Loading...

        </div>

    </div>

</div>

<script>

function openVariants(
productId
){

    document
    .getElementById(
    "variantModal"
    )

    .style.display =
    "flex";

    fetch(
    "get-variants.php?product_id="
    + productId
    )

    .then(res => res.text())

    .then(data => {

        document
        .getElementById(
        "variantContent"
        )

        .innerHTML = data;
    });
}

function closeVariantModal(){

    document
    .getElementById(
    "variantModal"
    )

    .style.display =
    "none";
}

</script>

</body>
</html>