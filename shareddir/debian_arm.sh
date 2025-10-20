#!/usr/bin/bash

apt update
apt upgrade -y

mount /dev/cdrom /media

cd /media
./VBoxLinuxAdditions-arm64.run --nox11
