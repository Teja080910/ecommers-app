<?php
/* Shared OTP-email helper. Sends via Brevo's HTTP API (https://api.brevo.com)
   rather than a raw SMTP socket — Render blocks outbound SMTP ports on this
   tier, but plain HTTPS (which this uses) is unaffected. Reads the API key
   from the smtp_settings table (configured via admin/smtp-settings.php).
   Returns true on success, or a string error message on failure. */

if(!function_exists('sendOtpEmail')){

    function sendOtpEmail($conn, $toEmail, $otpCode){

        $result = mysqli_query($conn, "SELECT * FROM smtp_settings LIMIT 1");
        $settings = $result ? mysqli_fetch_assoc($result) : null;

        if(!$settings || empty($settings['brevo_api_key']) || empty($settings['from_email'])){
            return 'Email service not configured';
        }

        $payload = [
            'sender' => [
                'name' => $settings['from_name'] ?: 'Zipzapcart',
                'email' => $settings['from_email']
            ],
            'to' => [
                ['email' => $toEmail]
            ],
            'subject' => 'Your Zipzapcart verification code',
            'htmlContent' => '<p>Your verification code is:</p><h2 style="letter-spacing:4px;">'.htmlspecialchars($otpCode).'</h2><p>This code expires in 10 minutes. If you didn\'t request this, you can ignore this email.</p>'
        ];

        $ch = curl_init('https://api.brevo.com/v3/smtp/email');
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'accept: application/json',
            'api-key: '.$settings['brevo_api_key'],
            'content-type: application/json'
        ]);
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_TIMEOUT, 20);

        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $curlError = curl_error($ch);
        curl_close($ch);

        if($curlError){
            return 'Could not send email: '.$curlError;
        }

        if($httpCode >= 200 && $httpCode < 300){
            return true;
        }

        $decoded = json_decode($response, true);
        $message = $decoded['message'] ?? $response;

        return 'Could not send email: '.$message;
    }
}
