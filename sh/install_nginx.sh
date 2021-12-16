#!/bin/bash

HTML="
<!DOCTYPE html>
<html>
    <head>
        <title>Welcome to nginx!</title>
        <style>
            body {
                width: 35em;
                margin: 0 auto;
                font-family: Tahoma, Verdana, Arial, sans-serif;
            }
        </style>
    </head>
    <body>
        <h1>Deployed via TF Hello World</h1>
    </body>
</html>
"

sudo apt-get update -y
sudo apt-get install -y nginx

sudo systemctl start nginx
sudo systemctl enable nginx

echo $HTML | sudo tee /var/www/html/index.nginx-debian.html
