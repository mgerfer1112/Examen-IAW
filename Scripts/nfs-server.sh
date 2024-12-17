#!/bin/bash

set -ex

#Importación de variables.
source .env

#Actualización del sistema.
apt update

#Instalación del servidor NFS.
apt install nfs-kernel-server -y

#Creamos las carpetas que alojará el servidor
mkdir -p $MOODLE_DIRECTORY
mkdir -p $MOODLE_DATA_DIRECTORY

#Cambiamos los permisos a nobody:nogroup.
sudo chown nobody:nogroup $MOODLE_DIRECTORY
sudo chown nobody:nogroup $MOODLE_DATA_DIRECTORY

#Copiamos nuestro archivo exports al sistema.
cp ../exports /etc/exports

#Sustituimos con sed las siguientes palabras por nuestras variables.
sed -i "s#Network#$Network#" /etc/exports
sed -i "s#MOODLE_DIRECTORY#$MOODLE_DIRECTORY#" /etc/exports
sed -i "s#MOODLE_DATA_DIRECTORY#$MOODLE_DATA_DIRECTORY#" /etc/exports

#Reiniciamos el servidor NFS.
systemctl restart nfs-kernel-server