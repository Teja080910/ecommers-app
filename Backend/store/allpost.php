<?php

session_start();

require_once "db.php";

if(
!isset(
$_SESSION["seller_id"]
)
){

header(
"Location:index.php"
);

exit;

}

$seller_id=
$_SESSION["seller_id"];

/* DELETE */

if(
isset(
$_POST["delete_post"]
)
){

$id=
intval(
$_POST["post_id"]
);

$get=

$pdo->prepare(

"

SELECT media

FROM posts

WHERE id=?

AND seller_id=?

LIMIT 1

"

);

$get->execute([

$id,

$seller_id

]);

$post=
$get->fetch();

if(
$post
){

if(
!empty(
$post["media"]
)
){

$file=

"../app/".
$post["media"];

if(
file_exists(
$file
)
){

unlink(
$file
);

}

}

$pdo
->prepare(

"

DELETE

FROM post_comments

WHERE post_id=?

"

)
->execute([
$id
]);

$pdo
->prepare(

"

DELETE

FROM post_likes

WHERE post_id=?

"

)
->execute([
$id
]);

$pdo
->prepare(

"

DELETE

FROM posts

WHERE id=?

"

)
->execute([
$id
]);

echo
1;

}

exit;

}

/* AJAX COMMENTS */

if(
isset(
$_POST["comments"]
)
){

$id=
intval(
$_POST["post_id"]
);

$q=

$pdo->prepare(

"

SELECT

post_comments.*,

users.name

FROM post_comments

LEFT JOIN users

ON users.id=
post_comments.user_id

WHERE post_id=?

ORDER BY id DESC

"

);

$q->execute([
$id
]);

while(
$c=
$q->fetch()
){

?>

<div class="comment">

<div class="cname">

<?=htmlspecialchars(

$c["name"]

??

"User"

)?>

</div>

<div>

<?=htmlspecialchars(

$c["comment"]

)?>

</div>

</div>

<?php

}

exit;

}

/* POSTS */

$q=

$pdo->prepare(

"

SELECT

posts.*,

(

SELECT COUNT(*)

FROM post_comments

WHERE post_id=
posts.id

)

comments

FROM posts

WHERE seller_id=?

ORDER BY id DESC

"

);

$q->execute([
$seller_id
]);

?>

<!DOCTYPE html>

<html>

<head>

<title>

All Posts

</title>

<script src=
"https://code.jquery.com/jquery-3.7.1.min.js">

</script>

<style>

body{

margin:0;

background:#0f172a;

font-family:Inter;

color:white;

}

.main{

margin-left:240px;

padding:30px;

}

.grid{

display:grid;

grid-template-columns:

repeat(
auto-fill,
minmax(
360px,
1fr
)
);

gap:22px;

}

.card{

background:#111827;

border-radius:26px;

overflow:hidden;

}

.media{

width:100%;

height:260px;

object-fit:cover;

background:black;

}

.content{

padding:18px;

}

.caption{

margin-bottom:18px;

color:#dbeafe;

}

.stats{

display:flex;

gap:20px;

margin-bottom:18px;

color:#94a3b8;

}

.btn{

width:100%;

height:50px;

border:none;

border-radius:16px;

cursor:pointer;

color:white;

}

.view{

background:

linear-gradient(
135deg,
#06b6d4,
#7c3aed
);

margin-bottom:12px;

}

.delete{

background:

linear-gradient(
135deg,
#ef4444,
#dc2626
);

}

.modal{

position:fixed;

inset:0;

display:none;

justify-content:center;

align-items:center;

background:#0008;

}

.modalbox{

width:95%;

max-width:650px;

background:#111827;

padding:22px;

border-radius:24px;

max-height:80vh;

overflow:auto;

}

.comment{

background:#1e293b;

padding:14px;

border-radius:16px;

margin-bottom:12px;

}

.cname{

font-weight:700;

margin-bottom:6px;

}

.close{

float:right;

cursor:pointer;

font-size:28px;

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

<h1>

All Posts

</h1>

<br>

<div class="grid">

<?php
while(
$p=
$q->fetch()
){
?>

<div
class="card">

<?php
if(
$p["type"]==
"image"
){
?>

<img
class="media"
src="../app/<?= $p["media"] ?>">

<?php
}
?>

<?php
if(
$p["type"]==
"video"
){
?>

<video
class="media"
controls>

<source
src="../app/<?= $p["media"] ?>">

</video>

<?php
}
?>

<div
class="content">

<div
class="caption">

<?=nl2br(

htmlspecialchars(

$p[
"text_content"
]

)

)?>

</div>

<div
class="stats">

<div>

❤️

<?=intval(

$p[
"likes_count"
]

)?>

</div>

<div>

💬

<?=intval(

$p[
"comments"
]

)?>

</div>

</div>

<button

class="btn view"

onclick=

"comments(

<?= $p['id'] ?>

)"

>

View Comments

</button>

<button

class="btn delete"

onclick=

"removePost(

<?= $p['id'] ?>

)"

>

Delete

</button>

</div>

</div>

<?php
}
?>

</div>

</div>

<div
class="modal"
id="modal">

<div
class="modalbox">

<div
class="close"

onclick=
"closeModal()"

>

×

</div>

<h2>

Comments

</h2>

<br>

<div
id="commentArea">

</div>

</div>

</div>

<script>

function
comments(
id
){

$("#modal")
.css(
"display",
"flex"
);

$("#commentArea")
.html(
"Loading..."
);

$.post(

"",

{

comments:1,

post_id:id

},

function(
r
){

$("#commentArea")
.html(
r
);

}

);

}

function
closeModal(){

$("#modal")
.hide();

}

function
removePost(
id
){

if(

confirm(

"Delete Post?"

)

){

$.post(

"",

{

delete_post:1,

post_id:id

},

function(){

location.reload();

}

);

}

}

</script>

</body>

</html>
