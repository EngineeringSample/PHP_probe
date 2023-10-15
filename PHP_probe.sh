#!/bin/bash

# Welcome message
echo "Welcome to the Automated PHP Probe Installation Script"
echo

# Prompt for the web server choice
echo "Choose a web server to install:"
echo "1. Nginx (recommended, lower resource consumption)"
echo "2. Apache (higher resource consumption)"
read -p "Enter the number (1 or 2): " web_server_choice

# Validate the choice
if [ "$web_server_choice" != "1" ] && [ "$web_server_choice" != "2" ]; then
    echo "Invalid choice. Please enter 1 for Nginx or 2 for Apache."
    exit 1
fi

# Prompt for the port
read -p "Enter the desired port number (default is 8080): " port
port=${port:-8080}

# Check if PHP is installed
if ! command -v php &> /dev/null; then
    echo "PHP is not installed. Please install PHP before continuing."
    exit 1
fi

# Install the selected web server (Nginx or Apache)
if [ "$web_server_choice" = "1" ]; then
    # Install Nginx
    if ! command -v nginx &> /dev/null; then
        echo "Nginx is not installed. Installing Nginx..."
        sudo apt update
        sudo apt install -y nginx
    fi
    web_server="Nginx"
else
    # Install Apache
    if ! command -v apache2 &> /dev/null; then
        echo "Apache is not installed. Installing Apache..."
        sudo apt update
        sudo apt install -y apache2
    fi
    web_server="Apache"
fi

# Create the PHP probe directory
sudo mkdir -p /var/www/html

# Download the PHP probe script
echo "Downloading the PHP probe script..."
sudo wget -O /var/www/html/PHP_probe.php https://raw.githubusercontent.com/YuanLiuchang/PHP_probe/main/PHP_probe.php

# Configure Nginx or Apache based on the choice
if [ "$web_server_choice" = "1" ]; then
    # Create an Nginx server block configuration
    sudo tee /etc/nginx/sites-available/probe <<EOF
server {
    listen $port;
    server_name localhost;

    location / {
        root /var/www/html;
        index PHP_probe.php;
    }

    access_log /var/log/nginx/probe_access.log;
    error_log /var/log/nginx/probe_error.log;
}
EOF

    # Create a symbolic link to enable the Nginx server block
    sudo ln -s /etc/nginx/sites-available/probe /etc/nginx/sites-enabled/
else
    # Create an Apache virtual host configuration
    sudo tee /etc/apache2/sites-available/probe.conf <<EOF
<VirtualHost *:$port>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

    # Enable the Apache virtual host
    sudo a2ensite probe.conf
fi

# Test the web server configuration and reload
if [ "$web_server_choice" = "1" ]; then
    sudo nginx -t
    sudo systemctl reload nginx
else
    sudo apache2ctl configtest
    sudo systemctl reload apache2
fi

# Display the access link
echo
echo "PHP probe has been installed successfully with $web_server."
echo "You can access it at: http://your_server_ip:$port/PHP_probe.php"
