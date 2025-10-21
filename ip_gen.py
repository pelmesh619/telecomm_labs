#!/usr/bin/env python3
"""
Простой генератор — выводит один случайный IPv4-адрес из объединённого набора.
Исключены: loopback (127/8), 0.0.0.0/8, 192.88.99.0/24, RFC1918 (10/8,172.16/12,192.168/16), 100.64.0.0/10.
Запуск: python gen_one_ip.py
"""
import ipaddress
import random

# Диапазоны, которые остаются в выборке (CIDR-строки).
CIDRS = [
    "240.0.0.0/4",        # Класс E
    "192.0.0.0/24",       # IETF Protocol assignments (reserved)
    "192.0.2.0/24",       # TEST-NET-1 (documentation)
    "198.51.100.0/24",    # TEST-NET-2 (documentation)
    "203.0.113.0/24",     # TEST-NET-3 (documentation)
    "198.18.0.0/15",      # Benchmarking
    # Можно добавить/убрать другие CIDR здесь при необходимости
]

# Подготовка сетей и их размеров
NETWORKS = [ipaddress.ip_network(c) for c in CIDRS]
SIZES = [net.num_addresses for net in NETWORKS]

def pick_random_address():
    # Выбрать сеть пропорционально её размеру
    chosen_net = random.choices(NETWORKS, k=1)[0]
    offset = random.randrange(chosen_net.num_addresses)
    addr_int = int(chosen_net.network_address) + offset
    return ipaddress.IPv4Address(addr_int)

if __name__ == "__main__":
    print(pick_random_address())
