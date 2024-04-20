<?php
// Az üzenetek lekérése
$messages = file('messages.txt', FILE_IGNORE_NEW_LINES);

// Az üzenetek száma
$messageCount = count($messages);

// Az utolsó 5 üzenet kiírása
$start = ($messageCount > 6) ? $messageCount - 6 : 0;
for ($i = $start; $i < $messageCount; $i++) {
    echo $messages[$i] . "<br>";
}
?>
