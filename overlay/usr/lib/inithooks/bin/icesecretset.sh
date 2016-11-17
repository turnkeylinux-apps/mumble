#!/bin/bash -e

#Password Passed via argument in python subprocess call

#Assign Command Line Argument to Variable Password
password=$1

#Default icesecretwrite in mumble-server.ini
sed -i 51s$'\001'.*$'\001''icesecretwrite="defaultpassword"'$'\001''g' /etc/mumble-server.ini
#Replace icesecretwrite in mumble-server.ini
sed -i s$'\001'defaultpassword$'\001'$password$'\001''g' /etc/mumble-server.ini
#Default the MyMumb Web Interface icesecretwrite
sed -i 09s$'\001'.*$'\001'"\$MyConfig['ICE_Password'] = 'icesecretwrite';"$'\001''g' /var/www/MyMumb/inc/config.inc.php
#Replace MyMumb Web Interface icesecretwrite
sed -i s$'\001'icesecretwrite$'\001'$password$'\001''g' /var/www/MyMumb/inc/config.inc.php
#Default icesecretwrite in phpMumbleAdmin Config
sed -i 13s$'\001'.*$'\001'"	'secret' => 'secretsetatfirstboot',"$'\001''g' /var/www/phpMumbleAdmin/config/profiles.php
#Replace phpMumbleAdmin icesecretwrite in profiles.php
sed -i s$'\001'secretsetatfirstboot$'\001'$password$'\001''g' /var/www/phpMumbleAdmin/config/profiles.php


#Restart Mumble after mumble-server.ini changes
systemctl restart mumble-server.service

#Restart Apache
systemctl restart apache2.service
