<?php

session_start();

require_once "db.php";

if(!isset($_SESSION["admin_id"])){

    header("Location:index.php");
    exit;
}

/* Sellers (for the "post as" picker) */

$sellers = $pdo->query("SELECT id, name FROM seller ORDER BY name ASC")->fetchAll();

$success = "";
$error = "";

if(isset($_POST["add_post"])){

    $seller_id = intval($_POST["seller_id"] ?? 0);

    $type = trim($_POST["type"] ?? "text");

    $text = trim($_POST["text_content"] ?? "");

    $media = "";

    if($seller_id <= 0){

        $error = "Please select a seller";

    }else{

        /* MEDIA */

        if(($type == "image" || $type == "video")
            && isset($_FILES["media"])
            && $_FILES["media"]["name"] != ""){

            $uploadDir = "../app/uploads/posts";

            if(!is_dir($uploadDir)){
                mkdir($uploadDir, 0777, true);
            }

            $ext = strtolower(pathinfo($_FILES["media"]["name"], PATHINFO_EXTENSION));

            if($type == "image"){
                $allowed = ["jpg","jpeg","png","webp"];
            }else{
                $allowed = ["mp4","mov","avi","mkv"];
            }

            if(!in_array($ext, $allowed)){

                $error = "Invalid media";

            }else{

                $filename = time().rand(1000,9999).".".$ext;

                $realPath = $uploadDir."/".$filename;

                $dbPath = "uploads/posts/".$filename;

                if(move_uploaded_file($_FILES["media"]["tmp_name"], $realPath)){

                    $media = $dbPath;

                }else{

                    $error = "Upload Failed";
                }

            }

        }

        /* SAVE */

        if($error == ""){

            $insert = $pdo->prepare("
                INSERT INTO posts
                (seller_id, type, text_content, media)
                VALUES (?, ?, ?, ?)
            ");

            $run = $insert->execute([
                $seller_id,
                $type,
                $text,
                $media
            ]);

            if($run){

                $success = "Post Added Successfully";

            }else{

                $error = "Database Error";
            }

        }

    }

}

?>

<!DOCTYPE html>
<html>
<head>

<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">

<title>Add Post</title>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">

<style>

*{
    margin:0;
    padding:0;
    box-sizing:border-box;
    font-family:Inter;
}

body{
    background:#0f172a;
    color:white;
}

.main{
    margin-left:240px;
    padding:30px;
}

.card{
    max-width:700px;
    background:#111827;
    padding:30px;
    border-radius:26px;
}

.title{
    font-size:26px;
    font-weight:700;
    margin-bottom:10px;
}

.subtitle{
    color:#94a3b8;
    margin-bottom:24px;
}

.alert{
    padding:14px;
    border-radius:14px;
    margin-bottom:20px;
}

.success{
    background:#22c55e20;
    color:#4ade80;
}

.error{
    background:#ef444420;
    color:#f87171;
}

.group{
    margin-bottom:22px;
}

label{
    display:block;
    margin-bottom:8px;
    color:#cbd5e1;
}

input,
textarea,
select{
    width:100%;
    background:#1e293b;
    border:none;
    color:white;
    padding:16px;
    border-radius:16px;
    outline:none;
}

textarea{
    height:140px;
    resize:none;
}

button{
    width:100%;
    height:56px;
    border:none;
    border-radius:18px;
    background:linear-gradient(135deg,#06b6d4,#7c3aed);
    color:white;
    font-size:15px;
    font-weight:700;
    cursor:pointer;
}

.preview{
    margin-top:16px;
}

.preview img{
    width:100%;
    border-radius:18px;
}

.preview video{
    width:100%;
    border-radius:18px;
}

@media(max-width:900px){

    .main{
        margin-left:0;
        padding:85px 14px;
    }

}

</style>

</head>
<body>

<?php include "nav.php"; ?>

<div class="main">

<div class="card">

<div class="title">Create New Post</div>

<div class="subtitle">Post as a seller — share text, image or video</div>

<?php if($success != ""){ ?>
<div class="alert success"><?= $success ?></div>
<?php } ?>

<?php if($error != ""){ ?>
<div class="alert error"><?= $error ?></div>
<?php } ?>

<form method="POST" enctype="multipart/form-data">

<div class="group">
<label>Post As (Seller)</label>
<select name="seller_id" required>
    <option value="">Select seller</option>
    <?php foreach($sellers as $s){ ?>
    <option value="<?php echo $s['id']; ?>"><?php echo htmlspecialchars($s['name']); ?></option>
    <?php } ?>
</select>
</div>

<div class="group">
<label>Post Type</label>
<select name="type" id="type">
    <option value="text">Text</option>
    <option value="image">Image</option>
    <option value="video">Video</option>
</select>
</div>

<div class="group">
<label>Caption</label>
<textarea name="text_content" placeholder="Write something..."></textarea>
</div>

<div class="group">
<label>Media</label>
<input type="file" name="media" id="media" accept="image/*,video/*">
<div class="preview" id="preview"></div>
</div>

<button name="add_post">
<i class="fa-solid fa-paper-plane"></i>
Publish Post
</button>

</form>

</div>

</div>

<script>

media.onchange = (e) => {

    let f = e.target.files[0];

    if(!f) return;

    let url = URL.createObjectURL(f);

    if(f.type.includes("image")){
        preview.innerHTML = `<img src="${url}">`;
    }else{
        preview.innerHTML = `<video controls src="${url}"></video>`;
    }

};

</script>

</body>
</html>
