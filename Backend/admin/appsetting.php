<?php

session_start();

require_once "db.php";

if(
!isset(
$_SESSION["admin_id"]
)
){

header(
"Location:index.php"
);

exit;

}

/* GET SETTINGS */

$stmt=

$pdo->query(

"

SELECT *

FROM appsetting

ORDER BY id DESC

LIMIT 1

"

);

$setting=
$stmt->fetch();

if(
!$setting
){

$pdo->exec(

"

INSERT INTO appsetting

(

cashbackper,

supportnumber,

supportemail

)

VALUES

(

0,

'',

''

)

"

);

$stmt=

$pdo->query(

"

SELECT *

FROM appsetting

ORDER BY id DESC

LIMIT 1

"

);

$setting=
$stmt->fetch();

}

$success="";
$error="";

/* SAVE */

if(
isset(
$_POST["save"]
)
){

$cashback=

intval(

$_POST[
"cashbackper"
]

?? 0

);

$number=

trim(

$_POST[
"supportnumber"
]

?? ""

);

$email=

trim(

$_POST[
"supportemail"
]

?? ""

);

$update=

$pdo->prepare(

"

UPDATE appsetting

SET

cashbackper=?,

supportnumber=?,

supportemail=?

WHERE id=?

"

);

$run=

$update->execute([

$cashback,

$number,

$email,

$setting[
"id"
]

]);

if(
$run
){

$success=
"Settings Updated";

$stmt=
$pdo->query(

"

SELECT *

FROM appsetting

ORDER BY id DESC

LIMIT 1

"

);

$setting=
$stmt->fetch();

}else{

$error=
"Update Failed";

}

}

?>

<!DOCTYPE html>

<html>

<head>

<meta charset="UTF-8">

<meta
name="viewport"
content=
"width=device-width,initial-scale=1">

<title>

App Settings

</title>

<link
rel="stylesheet"
href=
"https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">

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

max-width:720px;

background:#111827;

padding:30px;

border-radius:28px;

}

.title{

font-size:28px;

font-weight:700;

margin-bottom:6px;

}

.subtitle{

color:#94a3b8;

margin-bottom:26px;

}

.group{

margin-bottom:22px;

}

label{

display:block;

margin-bottom:8px;

color:#cbd5e1;

}

input{

width:100%;

height:56px;

background:#1e293b;

border:none;

outline:none;

color:white;

padding:0 18px;

border-radius:16px;

}

button{

width:100%;

height:58px;

border:none;

border-radius:18px;

cursor:pointer;

font-size:15px;

font-weight:700;

color:white;

background:

linear-gradient(

135deg,

#06b6d4,

#7c3aed

);

}

.alert{

padding:14px;

border-radius:14px;

margin-bottom:20px;

}

.success{

background:#16a34a20;

color:#4ade80;

}

.error{

background:#ef444420;

color:#f87171;

}

@media(max-width:900px){

.main{

margin-left:0;

padding:85px 15px;

}

}

</style>

</head>

<body>

<?php include "nav.php"; ?>

<div class="main">

<div class="card">

<div class="title">

App Settings

</div>

<div class="subtitle">

Manage cashback and support information

</div>

<?php if($success!=""){ ?>

<div class="alert success">

<?= $success ?>

</div>

<?php } ?>

<?php if($error!=""){ ?>

<div class="alert error">

<?= $error ?>

</div>

<?php } ?>

<form
method="POST">

<div class="group">

<label>

Cashback %

</label>

<input

type="number"

name="cashbackper"

value="<?= $setting["cashbackper"] ?>"

required

>

</div>

<div class="group">

<label>

Support Number

</label>

<input

type="text"

name="supportnumber"

value="<?= htmlspecialchars($setting["supportnumber"]) ?>"

>

</div>

<div class="group">

<label>

Support Email

</label>

<input

type="email"

name="supportemail"

value="<?= htmlspecialchars($setting["supportemail"]) ?>"

>

</div>

<button
name="save">

<i class="fa-solid fa-floppy-disk"></i>

Save Settings

</button>

</form>

</div>

</div>

</body>

</html>
