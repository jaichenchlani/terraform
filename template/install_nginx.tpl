#!/bin/bash
#set -e
echo "*****     Installing Nginx     *****"
sudo apt update
sudo apt install -y nginx
#ufw allow '${ufw_allow_nginx}'
#systemctl enable nginx 
#systemctl restart nginx

echo "*****     Installation Completed!!     *****"

#echo "Welcome to Google Compute VM Instance deployed using Terraform!!!" > /var/www/html

echo "*****     Startup Script Completes!!     *****"
