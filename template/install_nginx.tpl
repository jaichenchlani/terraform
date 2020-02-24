#!/bin/bash
set -e
echo "*****     Installing Nginx     *****"
apt update
apt install -y Nginx
ufw allow '${ufw_allow_nginx}'
systemctl enable nginx 
systemctl restart nginx

echo "*****     Installation Completed!!     *****"

echo "Welcome to Google Compute VM Instance deployed using Terraform!!!" > /var/www/html

echo "*****     Startup Script Completes!!     *****"
