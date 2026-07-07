<?php

/* FCM ACCESS TOKEN HELPER
   Generates a Google OAuth2 access token directly from the bundled Firebase
   service account, in-process. This replaces the previous dependency on an
   external endpoint (zipzapcart.com/app/addaccess_token.php) which was
   unreliable (observed both 404s and auth failures) and added an extra
   network hop + point of failure for every single push notification. */

function getFcmAccessToken(){

    // This repo is public, so the credential is never committed -- in
    // production it's uploaded via Render's "Secret Files" feature, which
    // mounts it at /etc/secrets/<filename>. Fall back to a local copy
    // (gitignored) for local development.
    $renderSecretPath = "/etc/secrets/firebase-service-account.json";
    $localPath = __DIR__ . "/firebase-service-account.json";

    $credsPath = file_exists($renderSecretPath) ? $renderSecretPath : $localPath;

    $creds = json_decode(
        file_get_contents($credsPath),
        true
    );

    $private_key = $creds["private_key"];
    $client_email = $creds["client_email"];

    $scope = "https://www.googleapis.com/auth/firebase.messaging";
    $url = "https://oauth2.googleapis.com/token";
    $now = time();

    $header = ["alg" => "RS256", "typ" => "JWT"];

    $claim = [
        "iss" => $client_email,
        "sub" => $client_email,
        "scope" => $scope,
        "aud" => $url,
        "iat" => $now,
        "exp" => $now + 3600
    ];

    $base64url = function($data){
        return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
    };

    $unsigned = $base64url(json_encode($header)) . "." . $base64url(json_encode($claim));

    openssl_sign($unsigned, $signature, $private_key, "SHA256");

    $jwt = $unsigned . "." . $base64url($signature);

    $post = [
        "grant_type" => "urn:ietf:params:oauth:grant-type:jwt-bearer",
        "assertion" => $jwt
    ];

    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query($post));

    $response = curl_exec($ch);
    curl_close($ch);

    $data = json_decode($response, true);

    return $data["access_token"] ?? null;
}
