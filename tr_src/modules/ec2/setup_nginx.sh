#!/bin/bash

# Update packages and install a web server 
sudo apt update -y
sudo apt install -y nginx

# Create index.html with H1 tag in the default NGINX web directory
echo "
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Document Title</title>
            <!-- Link to CSS -->
            <link rel="stylesheet" href="style.css">
        </head>
        <body>
            <h1>Hello From Ubuntu EC2 Instance!!!</h1>
            
            <h2>This is a NGINX webserver.</h2>

            <p>This website setup by Terraform and GitHub-Action.</p>
        </body>
        </html>" | sudo tee /var/www/html/index.html

# Restart NGINX to apply the changes
sudo systemctl restart nginx
