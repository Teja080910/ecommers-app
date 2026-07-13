<?php
/* Shared image upload handler used across admin/store forms. Accepts either a
   cropped base64 data URI (from the shared assets/js/image-crop.js flow) or a
   raw uploaded file, and saves it under the given upload directory. */

if(!function_exists('imageUploadMimeIsValid')){

    /* Verifies the actual file content (not just its extension/declared name)
       is really one of the allowed image types, using the fileinfo extension —
       blocks a malicious file (e.g. a .php script) renamed with an image extension. */
    function imageUploadMimeIsValid($path, $allowedExts){

        $mimeMap = [
            'jpg'  => ['image/jpeg'],
            'jpeg' => ['image/jpeg'],
            'png'  => ['image/png'],
            'webp' => ['image/webp'],
            'gif'  => ['image/gif'],
        ];

        $allowedMimes = [];

        foreach($allowedExts as $ext){
            if(isset($mimeMap[$ext])){
                $allowedMimes = array_merge($allowedMimes, $mimeMap[$ext]);
            }
        }

        if(empty($allowedMimes)){
            return false;
        }

        $finfo = finfo_open(FILEINFO_MIME_TYPE);
        $mime = finfo_file($finfo, $path);
        finfo_close($finfo);

        return in_array($mime, $allowedMimes);
    }
}

if(!function_exists('uploadToCloudinary')){

    /* Uploads a local file to Cloudinary and returns its secure_url, or null
       on failure (see $error by reference). Render's filesystem is wiped on
       every redeploy, so anything saved only to local disk is lost — this is
       what makes uploaded images actually persist. */
    function uploadToCloudinary($localPath, &$error){

        $cloudName = getenv('CLOUDINARY_CLOUD_NAME');
        $apiKey = getenv('CLOUDINARY_API_KEY');
        $apiSecret = getenv('CLOUDINARY_API_SECRET');

        if(empty($cloudName) || empty($apiKey) || empty($apiSecret)){
            return null; // not configured — caller falls back to local storage
        }

        $timestamp = time();
        $signature = sha1('timestamp='.$timestamp.$apiSecret);

        $postFields = [
            'file' => new CURLFile($localPath),
            'api_key' => $apiKey,
            'timestamp' => $timestamp,
            'signature' => $signature,
        ];

        $ch = curl_init("https://api.cloudinary.com/v1_1/{$cloudName}/image/upload");
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, $postFields);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_TIMEOUT, 30);

        $response = curl_exec($ch);
        $curlError = curl_error($ch);
        curl_close($ch);

        if($response === false){
            $error = 'Image upload failed: '.$curlError;
            return null;
        }

        $result = json_decode($response, true);

        if(!empty($result['secure_url'])){
            return $result['secure_url'];
        }

        $error = 'Image upload failed: '.($result['error']['message'] ?? 'unknown error');
        return null;
    }
}

if(!function_exists('resolveUploadedImagePath')){

    /* handleCroppedOrRawUpload()/handleCroppedOrRawMultiUpload() now return a
       full Cloudinary URL when configured, or just a bare filename as a local
       dev fallback. Callers historically prefixed "uploads/products/" onto
       the returned value — do that only for the bare-filename case. */
    function resolveUploadedImagePath($file){

        if(preg_match('#^https?://#i', $file)){
            return $file;
        }

        return "uploads/products/".$file;
    }
}

if(!function_exists('resolveProductImageSrc')){

    /* Product image values are either a full Cloudinary URL (new uploads) or
       a relative path served from the backend (older/seed images) — this
       builds the correct <img src> for either case. */
    function resolveProductImageSrc($image){

        $image = (string)($image ?? '');

        if($image === ''){
            return '';
        }

        if(preg_match('#^https?://#i', $image)){
            return $image;
        }

        return "../app/".$image;
    }
}

if(!function_exists('handleCroppedOrRawUpload')){

    /* Returns the saved filename (not full path) on success, or null if there
       was nothing to upload / an error occurred (see $error by reference). */
    function handleCroppedOrRawUpload($postKey, $fileKey, $uploadDir, $allowedExts, &$error){

        if(!empty($_POST[$postKey])){

            $data = $_POST[$postKey];

            if(preg_match('/^data:image\/(jpeg|png|webp);base64,/', $data)){

                $decoded = base64_decode(substr($data, strpos($data, ',') + 1));

                if($decoded === false){
                    $error = 'Invalid cropped image';
                    return null;
                }

                if(!is_dir($uploadDir)){
                    mkdir($uploadDir, 0777, true);
                }

                $file = time().rand(1000,9999).'_cropped.jpg';
                $fullPath = rtrim($uploadDir,'/').'/'.$file;

                file_put_contents($fullPath, $decoded);

                /* Defense in depth: confirm the decoded bytes are really a JPEG,
                   even though the crop tool only ever produces one. */
                if(!imageUploadMimeIsValid($fullPath, ['jpg','jpeg'])){
                    unlink($fullPath);
                    $error = 'Invalid cropped image';
                    return null;
                }

                $cloudUrl = uploadToCloudinary($fullPath, $cloudError);

                if($cloudUrl){
                    @unlink($fullPath);
                    return $cloudUrl;
                }

                if(!empty($cloudError)){
                    @unlink($fullPath);
                    $error = $cloudError;
                    return null;
                }

                return $file; // Cloudinary not configured — local dev fallback
            }

            $error = 'Invalid cropped image';
            return null;
        }

        if(isset($_FILES[$fileKey]) && $_FILES[$fileKey]['error'] == 0){

            /* Block obviously dangerous filenames outright (double extensions etc). */
            if(preg_match('/\.(php\d?|phtml|phar|cgi|pl|py|sh|exe|asp|aspx|jsp)(\.|$)/i', $_FILES[$fileKey]['name'])){
                $error = 'Invalid file type';
                return null;
            }

            $ext = strtolower(pathinfo($_FILES[$fileKey]['name'], PATHINFO_EXTENSION));

            if(!in_array($ext, $allowedExts)){
                $error = 'Invalid file type';
                return null;
            }

            if(!imageUploadMimeIsValid($_FILES[$fileKey]['tmp_name'], $allowedExts)){
                $error = 'File content does not match an allowed image type';
                return null;
            }

            if(!is_dir($uploadDir)){
                mkdir($uploadDir, 0777, true);
            }

            $file = time().'_'.$_FILES[$fileKey]['name'];
            $fullPath = rtrim($uploadDir,'/').'/'.$file;

            if(move_uploaded_file($_FILES[$fileKey]['tmp_name'], $fullPath)){

                $cloudUrl = uploadToCloudinary($fullPath, $cloudError);

                if($cloudUrl){
                    @unlink($fullPath);
                    return $cloudUrl;
                }

                if(!empty($cloudError)){
                    @unlink($fullPath);
                    $error = $cloudError;
                    return null;
                }

                return $file; // Cloudinary not configured — local dev fallback
            }

            $error = 'Upload failed';
            return null;
        }

        return null; // nothing submitted — not an error, caller keeps the existing value
    }
}

if(!function_exists('handleCroppedOrRawMultiUpload')){

    /* Returns an array of saved filenames (not full paths). */
    function handleCroppedOrRawMultiUpload($postKey, $fileKey, $uploadDir, $allowedExts){

        $saved = [];

        if(!empty($_POST[$postKey])){

            $items = json_decode($_POST[$postKey], true);

            if(is_array($items)){

                if(!is_dir($uploadDir)){
                    mkdir($uploadDir, 0777, true);
                }

                foreach($items as $data){

                    if(preg_match('/^data:image\/(jpeg|png|webp);base64,/', $data)){

                        $decoded = base64_decode(substr($data, strpos($data, ',') + 1));

                        if($decoded !== false){

                            $file = time().rand(1000,9999).'_cropped.jpg';
                            $fullPath = rtrim($uploadDir,'/').'/'.$file;

                            file_put_contents($fullPath, $decoded);

                            if(imageUploadMimeIsValid($fullPath, ['jpg','jpeg'])){

                                $cloudUrl = uploadToCloudinary($fullPath, $cloudError);

                                if($cloudUrl){
                                    @unlink($fullPath);
                                    $saved[] = $cloudUrl;
                                }elseif(empty($cloudError)){
                                    $saved[] = $file; // Cloudinary not configured — local dev fallback
                                }else{
                                    @unlink($fullPath);
                                }
                            }else{
                                unlink($fullPath);
                            }
                        }
                    }
                }
            }

            return $saved;
        }

        if(isset($_FILES[$fileKey]) && is_array($_FILES[$fileKey]['name'])){

            if(!is_dir($uploadDir)){
                mkdir($uploadDir, 0777, true);
            }

            foreach($_FILES[$fileKey]['name'] as $i => $name){

                if($_FILES[$fileKey]['error'][$i] != 0){
                    continue;
                }

                if(preg_match('/\.(php\d?|phtml|phar|cgi|pl|py|sh|exe|asp|aspx|jsp)(\.|$)/i', $name)){
                    continue;
                }

                $ext = strtolower(pathinfo($name, PATHINFO_EXTENSION));

                if(!in_array($ext, $allowedExts)){
                    continue;
                }

                if(!imageUploadMimeIsValid($_FILES[$fileKey]['tmp_name'][$i], $allowedExts)){
                    continue;
                }

                $file = time().'_'.$i.'_'.$name;
                $fullPath = rtrim($uploadDir,'/').'/'.$file;

                if(move_uploaded_file($_FILES[$fileKey]['tmp_name'][$i], $fullPath)){

                    $cloudUrl = uploadToCloudinary($fullPath, $cloudError);

                    if($cloudUrl){
                        @unlink($fullPath);
                        $saved[] = $cloudUrl;
                    }elseif(empty($cloudError)){
                        $saved[] = $file; // Cloudinary not configured — local dev fallback
                    }else{
                        @unlink($fullPath);
                    }
                }
            }
        }

        return $saved;
    }
}
