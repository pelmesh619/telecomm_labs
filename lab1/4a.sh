#!/usr/bin/bash

while true; do
    echo "Current time: $(date '+%Y-%m-%d %H:%M:%S')"

    for iface in $(ls /sys/class/net | grep -vE '^(lo|bonding_masters)$'); do
        if [ -d "/sys/class/net/$iface/statistics" ]; then
            rx=$(cat /sys/class/net/$iface/statistics/rx_packets)
            tx=$(cat /sys/class/net/$iface/statistics/tx_packets)
            echo "Interface: $iface | RX packets: $rx | TX packets: $tx"
        fi
    done

    sleep 1
done
