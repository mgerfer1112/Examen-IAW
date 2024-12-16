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

# Preparamos el directorio de instalación de Moodle
rm -rf "$MOODLE_DIRECTORY"
mkdir -p "$MOODLE_DIRECTORY"

# Movemos los archivos extraídos al directorio de instalación de Moodle
mv /tmp/moodle/* "$MOODLE_DIRECTORY"

# Configuramos el directorio de datos de Moodle
rm -rf "$MOODLE_DATA_DIRECTORY"
mkdir -p "$MOODLE_DATA_DIRECTORY"
chown -R www-data:www-data "$MOODLE_DATA_DIRECTORY"
chmod -R 770 "$MOODLE_DATA_DIRECTORY"

# Cambiamos los permisos de Moodle
chown -R www-data:www-data "$MOODLE_DIRECTORY"
chmod -R 755 "$MOODLE_DIRECTORY"


# Copiamos el archivo .htaccess para configurar el acceso y seguridad en el servidor web
cp ../htaccess/.htaccess /var/www/html/.htaccess


# Copiamos el archivo de configuración de Apache
cp ../conf/000-default.conf /etc/apache2/sites-available/000-default.conf


#Instalamos las extensiones php requeridas para moodle
sudo apt install -y php-curl php-zip php-xml php-mbstring php-gd php-intl php-soap php-ldap php-opcache php-readline
systemctl restart apache2

# Crear la base de datos de Moodle
mysql -u root <<< "DROP DATABASE IF EXISTS $MOODLE_DB_NAME"
mysql -u root <<< "CREATE DATABASE $MOODLE_DB_NAME"

# Crear el usuario y asignar permisos
mysql -u root <<< "DROP USER IF EXISTS '$MOODLE_DB_USER'@'%'"
mysql -u root <<< "CREATE USER '$MOODLE_DB_USER'@'%' IDENTIFIED BY '$MOODLE_DB_PASSWORD'"
mysql -u root <<< "GRANT ALL PRIVILEGES ON $MOODLE_DB_NAME.* TO '$MOODLE_DB_USER'@'%'"

#Cambiamos el máximo de caracteres para que cumpla los requisitos de moodle
sudo sed -i 's/^;max_input_vars = 1000/max_input_vars = 5000/' /etc/php/8.3/cli/php.ini

sudo -u www-data php "$MOODLE_DIRECTORY/admin/cli/install.php" \
  --wwwroot="$MOODLE_URL" \
  --dataroot=$MOODLE_DATA_DIRECTORY \
  --dbtype="mysqli" \
  --dbname="$MOODLE_DB_NAME" \
  --dbuser="$MOODLE_DB_USER" \
  --dbpass="$MOODLE_DB_PASSWORD" \
  --dbhost="localhost" \
  --fullname="$MOODLE_NAME" \
  --shortname="$MOODLE_SHORTNAME" \
  --adminuser="$MOODLE_USER" \
  --adminpass="$MOODLE_PASSWORD" \
  --non-interactive \
  --agree-license

#Completamos aspectos de la configuración referentes a la zona horaria.
sudo sed -i "s|^;date.timezone =|date.timezone = UTC|" /etc/php/*/cli/php.ini
sudo sed -i "s|^;date.timezone =|date.timezone = UTC|" /etc/php/*/apache2/php.ini

#Aseguramos que Moodle funciona en https.
sudo sed -i "s|'http://mgerfer1112.hopto.org/moodle'|'https://mgerfer1112.hopto.org/moodle'|" /var/www/html/moodle/config.php


# Reiniciamos Apache
systemctl restart apache2
