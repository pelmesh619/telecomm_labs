#!/bin/bash

INTERFACE=$(ip -o link show | awk -F': ' '{print $2}' | grep -E '^e' | head -n1)

# настройка статической конфигурации

nmcli con add type ethernet ifname $INTERFACE con-name static1 \
    ipv4.addresses 10.100.0.2/24 \
    ipv4.gateway 10.100.0.1 \
    ipv4.dns 8.8.8.8 \
    ipv4.method manual

nmcli con up static1

# настройка виртуального интерфейса

nmcli con add type dummy ifname br0 con-name br0 \
    ipv4.addresses 10.100.0.3/24 \
    ipv4.method manual

nmcli con up br0

sleep 1

ping -c 2 10.100.0.2
ping -c 2 10.100.0.3
