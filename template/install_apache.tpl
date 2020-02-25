#! /bin/bash
sudo apt-get update
sudo apt-get install -y apache2
sudo cat <<EOF > /var/www/html/index.html
<html><body><h1>Hello World</h1>
<p>This page was created from a simple startup script!</p>
</body></html>