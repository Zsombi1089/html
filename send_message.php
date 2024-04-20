<?php
date_default_timezone_set('Europe/Budapest'); // Beállítjuk a magyar időzónát

// Az üzenet küldése
if (isset($_POST['message']) && isset($_POST['username'])) {
    $message = $_POST['message'];
    $username = $_POST['username'];

    // Az üzeneteket el lehetne menteni adatbázisban, de most csak kiírjuk a fájlba
    $file = fopen('messages.txt', 'a');
    fwrite($file, '[' . date('Y-m-d H:i:s') . '] ' . $username . ': ' . $message . "\n");
    fclose($file);
}
?>

