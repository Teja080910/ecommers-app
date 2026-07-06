<?php
/* Shared OTP-email helper. Reads sender credentials from the smtp_settings
   table (configured via admin/smtp-settings.php) and sends via PHPMailer.
   Returns true on success, or a string error message on failure — never
   throws, so callers can surface a clean message instead of a fatal error. */

require_once __DIR__ . '/../vendor/autoload.php';

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

if(!function_exists('sendOtpEmail')){

    function sendOtpEmail($conn, $toEmail, $otpCode){

        $result = mysqli_query($conn, "SELECT * FROM smtp_settings LIMIT 1");
        $settings = $result ? mysqli_fetch_assoc($result) : null;

        if(!$settings || empty($settings['smtp_host']) || empty($settings['smtp_username']) || empty($settings['smtp_password'])){
            return 'Email service not configured';
        }

        $mail = new PHPMailer(true);

        try{
            $mail->isSMTP();
            $mail->Host = $settings['smtp_host'];
            $mail->SMTPAuth = true;
            $mail->Username = $settings['smtp_username'];
            $mail->Password = $settings['smtp_password'];
            $mail->SMTPSecure = intval($settings['smtp_port']) == 465 ? PHPMailer::ENCRYPTION_SMTPS : PHPMailer::ENCRYPTION_STARTTLS;
            $mail->Port = intval($settings['smtp_port']) ?: 587;

            $mail->setFrom($settings['from_email'] ?: $settings['smtp_username'], $settings['from_name'] ?: 'Zipzapcart');
            $mail->addAddress($toEmail);

            $mail->isHTML(true);
            $mail->Subject = 'Your Zipzapcart verification code';
            $mail->Body = '<p>Your verification code is:</p><h2 style="letter-spacing:4px;">'.htmlspecialchars($otpCode).'</h2><p>This code expires in 10 minutes. If you didn\'t request this, you can ignore this email.</p>';
            $mail->AltBody = "Your verification code is: {$otpCode}\nThis code expires in 10 minutes.";

            $mail->send();

            return true;

        }catch(Exception $e){
            return 'Could not send email: '.$mail->ErrorInfo;
        }
    }
}
