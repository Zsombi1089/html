<?php
$ipAddress = $_SERVER['REMOTE_ADDR'];
$userAgent = $_SERVER['HTTP_USER_AGENT'];
$date = date('Y-m-d H:i:s');
$data = "IP cím: $ipAddress\nUser-Agent: $userAgent\nDátum: $date\n\n";

$file = 'helyadatok.txt'; // Az elérési útvonalat módosítsd a saját környezetedhez

file_put_contents($file, $data, FILE_APPEND | LOCK_EX);

echo 'success';
?>
