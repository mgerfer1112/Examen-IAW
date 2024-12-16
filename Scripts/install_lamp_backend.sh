#!/bin/bash

# Configuramos para mostrar los comandos y finalizar
set -ex

#Importamos el archivo .env

source .env

# Actualizamos el sistema
apt update

# Actualiza paquetes
apt upgrade -y  

# Instalamos Apache
apt install apache2 -y

# Habilitamos el módulo rewrite
a2enmod rewrite

# Instalamos PHP y el módulo de Apache para PHP
apt install php libapache2-mod-php php-mysql -y

# Instalamos MySQL
apt install mysql-server -y

#Configuramos el archivo /etc/mysql/mysql.conf.d/mysqld.cnf

sed -i "s/127.0.0.1/$MYSQL_PRIVATE_IP/" /etc/mysql/mysql.conf.d/mysqld.cnf

# Reiniciamos el servicio de Apache
systemctl restart apache2

