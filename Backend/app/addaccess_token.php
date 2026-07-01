<?php

function base64url(
$data
){

return

rtrim(

strtr(

base64_encode(
$data
),

'+/',

'-_'

),

'='

);

}

$creds=

json_decode(

file_get_contents(

"firebase-service-account.json"

),

true

);

$private_key=

$creds[
"private_key"
];

$client_email=

$creds[
"client_email"
];

$scope=

"https://www.googleapis.com/auth/firebase.messaging";

$url=

"https://oauth2.googleapis.com/token";

$now=
time();

$header=[

"alg"=>"RS256",

"typ"=>"JWT"

];

$claim=[

"iss"=>$client_email,

"sub"=>$client_email,

"scope"=>$scope,

"aud"=>$url,

"iat"=>$now,

"exp"=>$now+3600

];

$unsigned=

base64url(

json_encode(
$header)
)

."."

.

base64url(

json_encode(
$claim)
);

openssl_sign(

$unsigned,

$signature,

$private_key,

"SHA256"

);

$jwt=

$unsigned

."."

.

base64url(
$signature
);

$post=[

"grant_type"=>

"urn:ietf:params:oauth:grant-type:jwt-bearer",

"assertion"=>$jwt

];

$ch=
curl_init();

curl_setopt(

$ch,

CURLOPT_URL,

$url

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

CURLOPT_POSTFIELDS,

http_build_query(
$post
)

);

$response=

curl_exec(
$ch
);

curl_close(
$ch
);

$data=

json_decode(

$response,

true

);

echo

$data[
"access_token"
]

??

"FAILED";

?>
