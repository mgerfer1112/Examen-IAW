#!/bin/bash

# Configuramos para mostrar los comandos y finalizar
set -ex

# Importamos el archivo .env
source .env

# Actualizamos el sistema
apt update

# Actualiza paquetes
apt upgrade -y  

# Instalamos nginx 
apt install nginx -y

# Deshabilitamos el virtualhost por defecto 
if [ -f "/etc/nginx/sites-enabled/default" ]; then
    unlink /etc/nginx/sites-enabled/default
    echo "Virtualhost por defecto deshabilitado."
fi  

# Copiamos el archivo de configuración de NGINX
cp ../conf/loadbalancer.conf /etc/nginx/sites-available/

# Sustituimos los valores en el archivo de configuración
sed -i "s/IP_FRONTEND_1/$IP_FRONTEND_1/" /etc/nginx/sites-available/loadbalancer.conf
sed -i "s/IP_FRONTEND_2/$IP_FRONTEND_2/" /etc/nginx/sites-available/loadbalancer.conf
sed -i "s/LE_DOMAIN/$LE_DOMAIN/" /etc/nginx/sites-available/loadbalancer.conf

# Hacemos el enlace simbólico al sitio habilitado
if [ ! -f "/etc/nginx/sites-enabled/loadbalancer.conf" ]; then
    ln -s /etc/nginx/sites-available/loadbalancer.conf /etc/nginx/sites-enabled/
fi

# Recargamos NGINX
sudo systemctl restart nginx