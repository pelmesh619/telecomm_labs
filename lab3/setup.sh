#!/usr/bin/bash

apt update
apt upgrade -y
apt install -y sudo tcpdump mtr vnstat traceroute bmon nethogs nload iftop sshpass net-tools

