#!/bin/bash

# Configuramos para mostrar los comandos y finalizar
set -ex

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

# Copiamos el archivo de configuración de Apache
cp ../conf/000-default.conf /etc/apache2/sites-available/

# Copiamos el script de prueba PHP
cp ../php/index.php /var/www/html

# Modificamos el propietario y el grupo del archivo index.php
chown -R www-data:www-data /var/www/html

# Reiniciamos el servicio de Apache
systemctl restart apache2

