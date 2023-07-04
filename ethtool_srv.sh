#!/bin/bash

# check the ethtool is installed or not
if ! command -v ethtool &> /dev/null; then
    echo "ethtool is not installed. Installing..."

    # install the ethtool 
    sudo apt update
    sudo apt install ethtool -y

    if [ $? -eq 0 ]; then
        echo "ethtool has been installed successfully."
    else
        echo "failed to install. Exiting..."
        exit 1
    fi 
else
    echo "ethtool is already installed."
fi 

# create a service in systemd
SERVICE_FILES_PATH="/etc/systemd/system/ethtool.service"

if [ -e "$SERVICE_FILES_PATH" ]; then
    echo "ethtool service is exists. Exiting..."
    exit 0
else
    echo "creating the ethtool service..."
fi

# service contents
sudo cat > $SERVICE_FILES_PATH << EOF
[Unit]
Description=setup eth0 speed and duplex
After=multi-user.target

[Service]
ExecStart=/sbin/ethtool -s eth0 speed 100 duplex full
Type=oneshot

[Install]
WantedBy=multi-user.target
EOF

# changing access
chmod 644 $SERVICE_FILES_PATH

# reloading the systemd configuration
sudo systemctl daemon-reload
echo "the ethtool service has configured"

sudo systemctl enable ethtool.service
sudo systemctl start ethtool.service
