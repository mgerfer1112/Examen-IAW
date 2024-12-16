#!/bin/bash 

# Para mostrar los comandos que se van ejecutando
set -ex

# Cargamos las variables
source .env

# Crear la base de datos y el usuario para Wordpress
mysql -u root <<< "DROP DATABASE IF EXISTS $WORDPRESS_DB_NAME"
mysql -u root <<< "CREATE DATABASE $WORDPRESS_DB_NAME"
mysql -u root <<< "DROP USER IF EXISTS $WORDPRESS_DB_USER@$FRONTEND_PRIVATE_IP"
mysql -u root <<< "CREATE USER $WORDPRESS_DB_USER@$FRONTEND_PRIVATE_IP IDENTIFIED BY '$WORDPRESS_DB_PASSWORD'"
mysql -u root <<< "GRANT ALL PRIVILEGES ON $WORDPRESS_DB_NAME.* TO $WORDPRESS_DB_USER@$FRONTEND_PRIVATE_IP"
