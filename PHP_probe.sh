#!/bin/bash

# Welcome message
echo "Welcome to the Automated PHP Probe Installation Script"
echo

# Prompt for PHP version
read -p "Enter the PHP version (7.4/8.0, default is 7.4): " php_version
php_version=${php_version:-7.4}

# Prompt for the port
read -p "Enter the desired port number (default is 8080): " port
port=${port:-8080}

# Check and install PHP
if ! command -v php$php_version &> /dev/null; then
    echo "PHP $php_version is not installed. Installing..."
    sudo apt update
    sudo apt install -y php$php_version
fi

# Check and install Git
if ! command -v git &> /dev/null; then
    echo "Git is not installed. Installing..."
    sudo apt update
    sudo apt install -y git
fi

# Download and unzip the PHP probe script from GitHub
echo "Downloading the PHP probe script..."
wget -O PHP_probe.zip https://github.com/YuanLiuchang/PHP_probe/archive/refs/heads/main.zip
unzip PHP_probe.zip -d /var/www/html
mv /var/www/html/PHP_probe-main/PHP_probe.php /var/www/html/
rm PHP_probe.zip
rm -r /var/www/html/PHP_probe-main

# Enable a firewall (e.g., UFW)
read -p "Do you want to enable the firewall? (y/n, default is n): " enable_firewall
if [ "$enable_firewall" = "y" ]; then
    sudo ufw allow $port/tcp
    sudo ufw enable
    echo "Firewall enabled, and port $port is allowed."
else
    echo "Firewall not enabled. Remember to configure your firewall manually if needed."
fi

# Display the access link
echo
echo "PHP probe has been installed successfully. You can access it at:"
echo "http://your_server_ip:$port/PHP_probe.php"
