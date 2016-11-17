#!/bin/bash -e

#Password Passed via argument in python subprocess call

#Assign Command Line Argument to Variable Password
password=$1

#Replace Default Server (Server 1) Password in mumble-server.ini
murmurd -ini /etc/mumble-server.ini -supw $password

#Restart Mumble after mumble-server.ini after changes
systemctl restart mumble-server.service

