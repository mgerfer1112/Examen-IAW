#!/bin/bash 

# Para mostrar los comandos que se van ejecutando
set -ex

# Cargamos las variables
source .env

# Crear la base de datos de Moodle
mysql -u root <<< "DROP DATABASE IF EXISTS $MOODLE_DB_NAME"
mysql -u root <<< "CREATE DATABASE $MOODLE_DB_NAME"

# Crear el usuario y asignar permisos
mysql -u root <<< "DROP USER IF EXISTS $MOODLE_DB_USER@'%'"
mysql -u root <<< "CREATE USER $MOODLE_DB_USER@'%' IDENTIFIED BY '$MOODLE_DB_PASSWORD'"
mysql -u root <<< "GRANT ALL PRIVILEGES ON $MOODLE_DB_NAME.* TO $MOODLE_DB_USER@'%'"

