#!/usr/bin/bash

sudo yum update -y
sudo yum groupinstall -y 'Development Tools'

mount /dev/cdrom /media

cd /media
sudo ./VBoxLinuxAdditions.run --nox11
