# Лабораторная работа №1

Для работы понадобятся образы Debian (12 и выше) и CentOS (9 и выше)

Для упрощения жизни рекомендую сделать общую папку ([инструкция](../shareddir/guide.md))

Пока мы не испортили дефолтный настройки сети, установим необходимые пакеты. Для Debian выполните от имени `root`:

```sh
apt update  
apt install -y sudo network-manager ethtool lshw net-tools netplan.io
```

Для CentOS:

```sh
sudo yum install -y NetworkManager ethtool lshw net-tools dhcp-client
sudo systemctl restart NetworkManager
```

> Файлы: [debian_setup.sh](https://github.com/pelmesh619/telecomm_labs/blob/main/lab1/debian_setup.sh), [centos_setup.sh](https://github.com/pelmesh619/telecomm_labs/blob/main/lab1/centos_setup.sh)

## Часть 1

Запускаем машину с Debian или CentOS с изначальным сетевыми адаптерами

Скрипт:

```sh
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

    read "Press Enter to continue"
done
```

Запуская его, пользователь видит интерактивное меню

> Файлы: [1.sh](https://github.com/pelmesh619/telecomm_labs/blob/main/lab1/1.sh)

## Часть 2

В настройках виртуальной машины на CentOS делаем 1 адаптер "Внутренняя сеть", по умолчанию ее имя будет `intnet`

Запускаем машину, выполняем скрипт:

```sh
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
```

`netplan` создаст конфиг с именами `static1` и `br0`, а также виртуальный интерфейс типа `dummy` с именем `br0`

Пинги должны пройти без потери пакетов (`0% packet loss`)

Чтобы посмотреть список всех подключений:

```sh
nmcli con show
```

Чтобы поднять какое-то:

```sh
nmcli con up [название или uuid]
```

Чтобы удалить:

```sh
nmcli con delete [название или uuid]
```

После окончания машину с CentOS не выключаем - она понадобится в 3 части

> Файлы: [2.sh](https://github.com/pelmesh619/telecomm_labs/blob/main/lab1/2.sh)

## Часть 3

В настройках виртуальной машины на Debian делаем 1 адаптер "Внутренняя сеть", выбираем то имя, которое было у CentOS

Запускаем машину, создаем конфиг `/etc/`

Выполняем скрипт:

```sh
#!/bin/bash

sudo cp "./01-netcfg.yaml" "/etc/netplan/01-netcfg.yaml"
sudo chmod 600 "/etc/netplan/01-netcfg.yaml" # убираем предупреждение
sudo netplan apply

sleep 1

ping -c 4 10.100.0.2
ping -c 4 10.100.0.3
ping -c 4 10.100.0.4
ping -c 4 10.100.0.5

arp -n
```

Во время выполнения `netplan` может вылезти предупреждение `Cannot call openvswitch: ovsdb-server.service is not running.`, просто игнорируем

Пинг должны пройти успешно без потери пакетов. Таблица ARP-кэша должна выглядеть так:

```
Address                  HWtype  HWaddress           Flags Mask            Iface
10.100.0.3               ether   08:00:27:9a:a4:ef   C                     enp0s3
10.100.0.2               ether   08:00:27:9a:a4:ef   C                     enp0s3
```

Должно быть только 2 адреса - те, которые мы ставили для машины с CentOS, потому что узел с CentOS считается нашим соседом, адреса маршрутизации которого попали в ARP-кэш

> Файлы: [3.sh](https://github.com/pelmesh619/telecomm_labs/blob/main/lab1/3.sh), [01-netcfg.yaml](https://github.com/pelmesh619/telecomm_labs/blob/main/lab1/01-netcfg.yaml)

## Часть 4

Заходим в VirtualBox во вкладку "Инструменты" (клик по бургер-меню) -> "Сеть" -> "Сети NAT" -> "Создать" 

Создастся сеть `NatNetwork`, название можно изменить

В настройках виртуальной машины на Debian делаем 2 адаптера "Сеть NAT", устанавливаем нашу созданную сеть

Запускам Debian, проверяем, что модуль для bonding загружен:

```sh
lsmod | grep bonding
```

Если вывод пустой, то загружаем

```sh
sudo modprobe bonding
```

Также можно поставить его загрузку при включении:

```sh
echo "bonding" | sudo tee -a /etc/modules
```

В `ip link` можно увидеть наши интерфейсы, должно быть такое

```
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
    link/ether 08:00:27:c3:04:a5 brd ff:ff:ff:ff:ff:ff
3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
    link/ether 08:00:27:53:b8:53 brd ff:ff:ff:ff:ff:ff
```

Убеждаемся, что и `enp0s3`, и `enp0s8` в состоянии `state UP`. Если нет, то:

```sh
sudo ip link set enp0s3 up
sudo ip link set enp0s8 up
```

Далее делаем конфигурационный файл `/01-bonding.yaml`: 

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3: {}
    enp0s8: {}
  bonds:
    bond007:
      interfaces:
        - enp0s3
        - enp0s8
      parameters:
        mode: balance-rr
        mii-monitor-interval: 100
      dhcp4: true
```

`mode: balance-rr` - подход round-robin, пакеты отправляются по очереди через все интерфейсы

`mii-monitor-interval: 100` - проверяет состояние линков каждые 100 мс.

`dhcp4: true` - интерфейс получает IP-адрес автоматически от DHCP (в NAT-сети VirtualBox DHCP включен по умолчанию)

И применяем его с помощью `netplan apply`:

```sh
sudo cp "./01-bonding.yaml" "/etc/netplan/01-bonding.yaml"
sudo chmod 600 "/etc/netplan/01-bonding.yaml"
sudo netplan apply
```

Узнаем информацию о бонде:

```sh
ip a show bond007
cat /proc/net/bonding/bond007
```

Получаем:

```

1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host noprefixroute 
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc fq_codel master bond007 state UP group default qlen 1000
    link/ether ca:c5:df:35:3c:4d brd ff:ff:ff:ff:ff:ff permaddr 08:00:27:c3:04:a5
3: enp0s8: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc fq_codel master bond007 state UP group default qlen 1000
    link/ether ca:c5:df:35:3c:4d brd ff:ff:ff:ff:ff:ff permaddr 08:00:27:53:b8:53
4: bond007: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether ca:c5:df:35:3c:4d brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.4/24 metric 100 brd 10.0.2.255 scope global dynamic bond007
       valid_lft 418sec preferred_lft 418sec
    inet6 fe80::c8c5:dfff:fe35:3c4d/64 scope link 
       valid_lft forever preferred_lft forever
Ethernet Channel Bonding Driver: v6.1.0-25-amd64

Bonding Mode: load balancing (round-robin)
MII Status: up
MII Polling Interval (ms): 100
Up Delay (ms): 0
Down Delay (ms): 0
Peer Notification Delay (ms): 0

Slave Interface: enp0s8
MII Status: up
Speed: 1000 Mbps
Duplex: full
Link Failure Count: 1
Permanent HW addr: 08:00:27:53:b8:53
Slave queue ID: 0

Slave Interface: enp0s3
MII Status: up
Speed: 1000 Mbps
Duplex: full
Link Failure Count: 1
Permanent HW addr: 08:00:27:c3:04:a5
Slave queue ID: 0
```

Тут же пингуем DNS-сервер Google через бонд:

```sh
ping -I bond007 8.8.8.8
```

Далее на второй консоли (Ctrl + Alt + F2) создаем и запускаем скрипт:

```sh
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
```

Собираем 3 любых вывода, должно быть что-то такое:

```
Current time: 2025-10-20 22:47:27
Interface: bond007 | RX packets: 231 | TX packets: 260
Interface: enp0s3 | RX packets: 116 | TX packets: 135
Interface: enp0s8 | RX packets: 121 | TX packets: 129
Current time: 2025-10-20 22:47:28
Interface: bond007 | RX packets: 232 | TX packets: 261
Interface: enp0s3 | RX packets: 117 | TX packets: 135
Interface: enp0s8 | RX packets: 121 | TX packets: 130
Current time: 2025-10-20 22:47:29
Interface: bond007 | RX packets: 233 | TX packets: 262
Interface: enp0s3 | RX packets: 117 | TX packets: 136
Interface: enp0s8 | RX packets: 122 | TX packets: 130
```

Как можно заметить, число принятых (RX) пакетов на `enp0s3` и `enp0s8` изменяется попеременно: 116 -> 117 -> 117, 121 -> 121 -> 122

Так же и с переданными пакетами (TX)

А число пакетов через bond007 увеличивается всегда

Так как внутренняя сеть не подключена к интернету, то пинг не пройдет, будет 100% потерь пакетов


> Файлы: конфиг - [01-bonding.yaml](https://github.com/pelmesh619/telecomm_labs/blob/main/lab1/01-bonding.yaml), установка конфига - [4.sh](https://github.com/pelmesh619/telecomm_labs/blob/main/lab1/4.sh), мониторинг - [4a.sh](https://github.com/pelmesh619/telecomm_labs/blob/main/lab1/4a.sh)

