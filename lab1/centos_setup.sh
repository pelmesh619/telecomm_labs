#!/usr/bin/bash

sudo yum install -y NetworkManager ethtool lshw net-tools dhcp-client
sudo systemctl restart NetworkManager
