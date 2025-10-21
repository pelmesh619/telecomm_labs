#!/bin/bash

IFACE=$(ip -o link show | awk -F': ' '{print $2}' | grep -E '^e' | head -n1)

while true; do
    clear
    echo "1) Network card information"
    echo "2) Current IPv4 configuration"
    echo "3) Set static config"
    echo "4) Set DHCP"
    echo "5) Exit"

    read choice

    case $choice in
        1)
            lshw -class network | grep -i -E 'product:' | sed 's/^ *product: /Product name: /g'
            ethtool $IFACE | grep -E "Speed|Duplex|Link detected"
            echo "MAC address: $(cat /sys/class/net/$IFACE/address)"
            ;;
        2)
            ip -4 addr show $IFACE | grep inet
            echo "Gate: $(ip route | grep default | awk '{print $3}')"
            echo "DNS: $(grep nameserver /etc/resolv.conf | awk '{print $2}')"
            ;;
        3)
            ip addr flush dev $IFACE
            ip addr add 10.100.0.2/24 dev $IFACE
            ip link set dev $IFACE up
            ip route del default dev $IFACE 2>/dev/null || true
            ip route add default via 10.100.0.1
            cp -n /etc/resolv.conf /etc/resolv.conf.netbak 2>/dev/null || true
            echo "nameserver 8.8.8.8" > /etc/resolv.conf
            echo "Static config set"
            ip -4 addr show $IFACE | grep inet
            ;;
        4)
            ip addr flush dev $IFACE
            dhclient -r $IFACE
            dhclient $IFACE
            echo "DHCP is done"
            ip -4 addr show $IFACE | grep inet
            ;;
        5)
            echo "Exit..."
            exit 0
            ;;
        *)
            echo "Wrong choice!"
            ;;
    esac

    read
done
