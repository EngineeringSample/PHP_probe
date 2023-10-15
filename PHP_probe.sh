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

# Prompt for the PHP version
echo "Choose a PHP version to install:"
echo "1. PHP 7.4 (recommended)"
echo "2. PHP 8.0"
read -p "Enter the number (1 or 2): " php_version_choice

# Validate the PHP version choice
if [ "$php_version_choice" != "1" ] && [ "$php_version_choice" != "2" ]; then
    echo "Invalid choice. Installing PHP 7.4 by default."
    php_version_choice="1"
fi

# Set PHP version based on the choice
if [ "$php_version_choice" = "1" ]; then
    php_version="7.4"
else
    php_version="8.0"
fi

# Check if the selected web server is installed
if [ "$web_server_choice" = "1" ]; then
    if ! command -v nginx &> /dev/null; then
        echo "Nginx is not installed. Installing Nginx..."
        sudo apt update
        sudo apt install -y nginx
    fi
    web_server="Nginx"
else
    if ! command -v apache2 &> /dev/null; then
        echo "Apache is not installed. Installing Apache..."
        sudo apt update
        sudo apt install -y apache2
    fi
    web_server="Apache"
fi

# Check if PHP is installed
if ! command -v php$php_version &> /dev/null; then
    echo "PHP $php_version is not installed. Installing PHP $php_version..."
    sudo apt update
    sudo apt install -y php$php_version
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
    listen 80;
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
<VirtualHost *:80>
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
echo "PHP probe has been installed successfully with $web_server and PHP $php_version."
echo "You can access it at: http://your_server_ip/PHP_probe.php"
