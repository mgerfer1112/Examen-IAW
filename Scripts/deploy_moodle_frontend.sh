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