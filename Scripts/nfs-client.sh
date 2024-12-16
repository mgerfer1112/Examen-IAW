#!/bin/bash
set -ex
source .env
apt update
apt install nfs-common -y


mkdir -p $MOODLE_DIRECTORY
mkdir -p $MOODLE_DATA_DIRECTORY

sudo mount $SERVER_IP:$MOODLE_DIRECTORY $MOODLE_DIRECTORY
df -h

sudo mount $SERVER_IP:$MOODLE_DATA_DIRECTORY $MOODLE_DATA_DIRECTORY
df -h

 
echo "$SERVER_IP:$MOODLE_DIRECTORY $MOODLE_DIRECTORY nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0" >> /etc/fstab
echo "$SERVER_IP:$MOODLE_DATA_DIRECTORY $MOODLE_DATA_DIRECTORY nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0" >> /etc/fstab