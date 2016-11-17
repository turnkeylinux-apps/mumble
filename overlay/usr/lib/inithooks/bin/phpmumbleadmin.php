<?php

    $pw = $argv[1];
    $seed = '';
    for($i = 0; $i < 16; $i++) {
        $seed .= chr(mt_rand(0, 255));
    }
    /* GenSalt */
    $salt = substr(strtr(base64_encode($seed), '+', '.'), 0, 22);
    $hash = crypt($pw, '$2a$08$'.$salt.'$');
    #Execute bash script to replace password
    $hash = escapeshellarg($hash);
    shell_exec("bash /usr/lib/inithooks/bin/phpmumbleadmin.sh $hash");
    
?>
