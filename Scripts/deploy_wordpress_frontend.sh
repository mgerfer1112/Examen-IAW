#!/bin/bash 

# Para mostrar los comandos que se van ejecutando
set -ex

# Cargamos las variables de configuración
source .env

# Borramos descargas previas de WP-CLI
rm -rf /tmp/wp-cli.phar

# Descargamos el archivo wp-cli.phar
wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -P /tmp

# Asignamos permisos de ejecución al archivo 
chmod +x /tmp/wp-cli.phar

# Movemos el script WP-CLI al directorio /usr/local/bin
mv /tmp/wp-cli.phar /usr/local/bin/wp

# Borramos instalaciones previas en /var/www/html
#rm -rf $WORDPRESS_DIRECTORY*

# Descargamos el código fuente de WordPress 
wp core download \
  --locale=es_ES \
  --path=$WORDPRESS_DIRECTORY \
  --allow-root

# Crear el archivo de configuración de WordPress 
wp config create \
  --dbname=$WORDPRESS_DB_NAME \
  --dbuser=$WORDPRESS_DB_USER \
  --dbpass=$WORDPRESS_DB_PASSWORD \
  --dbhost=$BACKEND_PRIVATE_IP \
  --path=$WORDPRESS_DIRECTORY \
  --allow-root

# Instalar WordPress 
wp core install \
  --url="https://$LE_DOMAIN" \
  --title="$WORDPRESS_TITLE" \
  --admin_user=$WORDPRESS_ADMIN_USER \
  --admin_password=$WORDPRESS_ADMIN_PASS  \
  --admin_email=$LE_MAIL \
  --path=$WORDPRESS_DIRECTORY \
  --allow-root


#Instalamos mindscape
wp theme install mindscape --activate --path=$WORDPRESS_DIRECTORY --allow-root

#instalamos el plugin
wp plugin install wps-hide-login --activate --path=$WORDPRESS_DIRECTORY --allow-root

wp option update whl_page "$wordpress_hide_login_url" --path=$WORDPRESS_DIRECTORY --allow-root

wp rewrite structure '/%postname%/' --path=$WORDPRESS_DIRECTORY --allow-root

cp ../htaccess/.htaccess $WORDPRESS_DIRECTORY

chown -R www-data:www-data  $WORDPRESS_DIRECTORY