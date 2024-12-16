#!/bin/bash
set -ex
source .env
apt update
apt install nfs-kernel-server -y
mkdir -p $WORDPRESS_DIRECTORY
sudo chown nobody:nogroup $WORDPRESS_DIRECTORY
cp ../exports /etc/exports

sed -i "s#CLIENT_IP_1#$Network#" /etc/exports
sed -i "s#WORDPRESS_DIRECTORY#$WORDPRESS_DIRECTORY#" /etc/exports

systemctl restart nfs-kernel-server