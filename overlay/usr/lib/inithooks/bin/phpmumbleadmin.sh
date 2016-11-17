#!/bin/bash -e

#  phpmumbleadmin.sh
#
#
#  Created by MG on 11/16/16.
#

#Password Passed via argument in php subprocess call

#Assign Command Line Argument to Variable Password
password=$1

#Default icesecretwrite in phpMumbleAdmin Config
sed -i 7s$'\001''.*'$'\001'"    'SA_pw' => 'passwordsetatfirstboot',"$'\001''g' /var/www/phpMumbleAdmin/config/config.php
#Replace phpMumbleAdmin icesecretwrite in profiles.php
sed -i s$'\001''passwordsetatfirstboot'$'\001'$password$'\001''g' /var/www/phpMumbleAdmin/config/config.php

