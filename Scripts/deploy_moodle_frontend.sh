#!/bin/bash

set -ex

# Importamos el archivo de variables
source .env

# Eliminamos descargas previas de Moodle en /tmp
rm -rf /tmp/moodle-latest-405.tgz*

# # Descargamos la última versión estable de Moodle
wget https://download.moodle.org/download.php/direct/stable405/moodle-latest-405.tgz -P /tmp

# Extraemos el archivo descargado
tar -xzf /tmp/moodle-latest-405.tgz -C /tmp

# Movemos los archivos extraídos al directorio de instalación de Moodle
mv /tmp/moodle/* "$MOODLE_DIRECTORY"

# Configuramos el directorio de datos de Moodle y sus permisos.
chown -R www-data:www-data "$MOODLE_DATA_DIRECTORY"
chmod -R 770 "$MOODLE_DATA_DIRECTORY"

# Cambiamos los permisos de Moodle
chown -R www-data:www-data "$MOODLE_DIRECTORY"
chmod -R 755 "$MOODLE_DIRECTORY"

# Copiamos el archivo .htaccess para configurar el acceso y seguridad en el servidor web
cp ../htaccess/.htaccess /var/www/html/.htaccess

# Copiamos el archivo de configuración de Apache
cp ../conf/000-default.conf /etc/apache2/sites-available/000-default.conf

# Instalamos las extensiones PHP requeridas para Moodle
sudo apt install -y php-curl php-zip php-xml php-mbstring php-gd php-intl php-imagick php-soap php-xmlrpc php-mysqli php-bz2 php-opcache

#Reiniciamos apache.
systemctl restart apache2


# Configuración recomendada de PHP para Apache
sudo sed -i 's/^;max_execution_time\s=.*/max_execution_time = 300/' /etc/php/8.3/apache2/php.ini
sudo sed -i 's/^;memory_limit\s=.*/memory_limit = 256M/' /etc/php/8.3/apache2/php.ini
sudo sed -i 's/^;post_max_size\s=.*/post_max_size = 50M/' /etc/php/8.3/apache2/php.ini
sudo sed -i 's/^;upload_max_filesize\s=.*/upload_max_filesize = 50M/' /etc/php/8.3/apache2/php.ini

# Configuración recomendada de PHP para CLI
sudo sed -i 's/^;max_execution_time\s=.*/max_execution_time = 300/' /etc/php/8.3/cli/php.ini
sudo sed -i 's/^;memory_limit\s=.*/memory_limit = 256M/' /etc/php/8.3/cli/php.ini
sudo sed -i 's/^;post_max_size\s=.*/post_max_size = 50M/' /etc/php/8.3/cli/php.ini
sudo sed -i 's/^;upload_max_filesize\s=.*/upload_max_filesize = 50M/' /etc/php/8.3/cli/php.ini

sudo -u www-data php "$MOODLE_DIRECTORY/admin/cli/install.php" \
  --wwwroot="$MOODLE_URL" \
  --dataroot=$MOODLE_DATA_DIRECTORY \
  --dbtype="mysqli" \
  --dbname="$MOODLE_DB_NAME" \
  --dbuser="$MOODLE_DB_USER" \
  --dbpass="$MOODLE_DB_PASSWORD" \
  --dbhost="$BACKEND_PRIVATE_IP" \
  --lang="ES" \
  --fullname="$MOODLE_NAME" \
  --shortname="$MOODLE_SHORTNAME" \
  --summary="Sitio Web del examen" \
  --adminuser="$MOODLE_USER" \
  --adminpass="$MOODLE_PASSWORD" \
  --adminemail="$LE_MAIL"\
  --non-interactive \
  --agree-license 

  

#Completamos aspectos de la configuración referentes a la zona horaria.
sudo sed -i "s|^;date.timezone =|date.timezone = UTC|" /etc/php/*/cli/php.ini
sudo sed -i "s|^;date.timezone =|date.timezone = UTC|" /etc/php/*/apache2/php.ini

#Cambiamos el máximo de caracteres para que cumpla los requisitos de moodle
sudo sed -i 's/^;max_input_vars = 1000/max_input_vars = 5000/' /etc/php/8.3/cli/php.ini
sudo sed -i 's/^;max_input_vars = 1000/max_input_vars = 5000/' /etc/php/8.3/apache2/php.ini

#Cambiamos las variables para habilitar el proxy inverso.
sed -i "/\$CFG->admin/a \$CFG->reverseproxy=1;\n\$CFG->sslproxy=1;" $MOODLE_DIRECTORY/config.php

# Reiniciamos Apache
systemctl restart apache2
