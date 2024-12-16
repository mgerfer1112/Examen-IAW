#!/bin/bash

set -ex

source .env

apt update

apt install nfs-kernel-server -y

mkdir -p $MOODLE_DIRECTORY
mkdir -p $MOODLE_DATA_DIRECTORY

sudo chown nobody:nogroup $MOODLE_DIRECTORY
sudo chown nobody:nogroup $MOODLE_DATA_DIRECTORY
cp ../exports /etc/exports

sed -i "s#Network#$Network#" /etc/exports
sed -i "s#MOODLE_DIRECTORY#$MOODLE_DIRECTORY#" /etc/exports
sed -i "s#MOODLE_DATA_DIRECTORY#$MOODLE_DATA_DIRECTORY#" /etc/exports

systemctl restart nfs-kernel-server