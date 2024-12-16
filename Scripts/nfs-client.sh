#!/bin/bash
set -ex
source .env
apt update
apt install nfs-common -y

sudo mount $SERVER_IP:$WORDPRESS_DIRECTORY $WORDPRESS_DIRECTORY
df -h

 
echo "$SERVER_IP:$WORDPRESS_DIRECTORY $WORDPRESS_DIRECTORY nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0" >> /etc/fstab