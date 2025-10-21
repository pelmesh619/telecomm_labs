#!/bin/bash

sudo cp "./01-netcfg.yaml" "/etc/netplan/01-netcfg.yaml"
sudo chmod 600 "/etc/netplan/01-netcfg.yaml"
sudo netplan apply

sleep 1

ping -c 4 10.100.0.2
ping -c 4 10.100.0.3
ping -c 4 10.100.0.4
ping -c 4 10.100.0.5

arp -n
