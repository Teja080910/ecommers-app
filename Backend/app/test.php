<?php

$token=

trim(

file_get_contents(

"https://zipzapcart.com/app/addaccess_token.php"

)

);

$fcm=

"d22uQEPJShO7uFwl3l1y3i:APA91bHgjhz4QsrLdz1OL9OwOTEegy5tH8RAKn8rHVttY6HypTQZ6EY83oAR2uz491Xa_8nh1Ju6lN_2S41sDdUfRWcOTakIzLMA8rD6jrS8C0HAMqOVe9s";

$project=

"ftnews-79e5c";

$payload=[

"message"=>[

"token"=>$fcm,

"notification"=>[

"title"=>"Order Placed 🎉",

"body"=>"FCM HTTP v1 Working"

],

"data"=>[

"screen"=>"orders"

]

]

];

$ch=
curl_init();

curl_setopt(

$ch,

CURLOPT_URL,

"https://fcm.googleapis.com/v1/projects/"

.$project.

"/messages:send"

);

curl_setopt(

$ch,

CURLOPT_POST,

true

);

curl_setopt(

$ch,

CURLOPT_RETURNTRANSFER,

true

);

curl_setopt(

$ch,

CURLOPT_HTTPHEADER,

[

"Authorization: Bearer ".$token,

"Content-Type: application/json"

]

);

curl_setopt(

$ch,

CURLOPT_POSTFIELDS,

json_encode(
$payload
)

);

$response=

curl_exec(
$ch
);

$http=

curl_getinfo(

$ch,

CURLINFO_HTTP_CODE

);

curl_close(
$ch
);

echo
"HTTP=".$http;

echo
"<br><br>";

print_r(
$response
);

?>
