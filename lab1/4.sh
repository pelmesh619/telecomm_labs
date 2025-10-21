#!/bin/bash

sudo modprobe bonding

sudo cp "./01-bonding.yaml" "/etc/netplan/01-bonding.yaml"
sudo chmod 600 "/etc/netplan/01-bonding.yaml"
sudo netplan apply

sleep 1

ip a show bond007
cat /proc/net/bonding/bond007

