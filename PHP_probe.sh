#!/bin/bash

# Welcome message
echo "Welcome to the Automated PHP Probe Installation Script"
echo

# Prompt for the port
read -p "Enter the desired port number (default is 8080): " port
port=${port:-8080}

# Check if PHP is installed
if ! command -v php &> /dev/null; then
    echo "PHP is not installed. Please install PHP before continuing."
    exit 1
fi

# Check if the Apache web server is installed
if ! command -v apache2ctl &> /dev/null; then
    echo "Apache web server is not installed. Please install Apache before continuing."
    exit 1
fi

# Download the PHP probe script
echo "Downloading the PHP probe script..."
wget -O /var/www/html/PHP_probe.php https://raw.githubusercontent.com/YuanLiuchang/PHP_probe/main/PHP_probe.php

# Create a virtual host configuration for Apache
cat << EOF > /etc/apache2/sites-available/probe.conf
<VirtualHost *:$port>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

# Enable the virtual host
sudo a2ensite probe.conf

# Reload Apache configuration
sudo systemctl reload apache2

# Display the access link
echo
echo "PHP probe has been installed successfully. You can access it at:"
echo "http://your_server_ip:$port/PHP_probe.php"
