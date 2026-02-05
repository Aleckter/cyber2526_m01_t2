#!/bin/bash

echo $#

read

if	[ $# -lt 1 ]
then
	echo "Error 255: Número insuficiente de parámetros"

# Si se pasa un parámetro, usarlo como nombre de archivo.

if [ -n "$1" ]; then
    AUDIO_FILE="$1"
else
    AUDIO_FILE="audio.wav"
fi

# Comprobamos que el archivo existe
if [ ! -f "$AUDIO_FILE" ]; then
    echo "ERROR: el archivo '$AUDIO_FILE' no existe."
    exit 1
fi

VERSION_CURRENT="0.9"

PORT="9999"
IP_SERVER="localhost"

clear

echo "Cliente del protocolo RECTP v$VERSION_CURRENT"

echo "1. SEND. Enviamos la cabecera al servidor"

IP_LOCAL=$(ip -4 addr | grep "scope global" | awk '{print $2}' | cut -d "/" -f 1)

sleep 1
	echo "RECTP $VERSION_CURRENT $IP_LOCAL" | nc "$IP_SERVER" -q 0 "$PORT"

RESPONSE=$(nc -l -p "$PORT")

echo "5. TEST. Header Response"

if [ "$RESPONSE" != "HEADER_OK" ]
then
	echo "Error 1: Cabeceras mal formadas"
	exit 1
fi

# 0.7: envío de FILE_NAME + MD5(nombre)

echo "6. SEND. Nombre de archivo"

# Hash MD5 del NOMBRE, no del fichero

AUDIO_FILE_MD5=$(echo -n "$AUDIO_FILE" | md5sum | awk '{print $1}')

sleep 1
	echo "FILE_NAME $AUDIO_FILE $AUDIO_FILE_MD5" | nc "$IP_SERVER" -q 0 "$PORT"

echo "7. LISTEN. FILE_NAME_OK"

RESPONSE=$(nc -l -p "$PORT")

echo "10. TEST. FILE_NAME_OK"

if [ "$RESPONSE" != "FILE_NAME_OK" ]
then
	echo "Error 2: Nombre de archivo incorrecto o mal formado"
	exit 2
fi

echo "11. SEND. FILE DATA"

sleep 1
	cat "$AUDIO_FILE" | nc "$IP_SERVER" -q 0 "$PORT"

echo "12. LISTEN"

RESPONSE=$(nc -l -p "$PORT")

echo "16. TEST AND END"

if [ "$RESPONSE" != "FILE_DATA_OK" ]
then
	echo "ERROR 3: Datos del archivo corruptos"
	exit 3
fi

echo "17. SEND. FILE_DATA_HASH"

AUDIO_FILE_DATA_MD5=$(md5sum "$AUDIO_FILE" | cut -d " " -f 1)

	echo "a$AUDIO_FILE_DATA_MD5" | nc "$IP_SERVER" -q 0 "$PORT"

echo "18. LISTEN. FILE_DATA_HASH_ANSWER"

RESPONSE=$(nc -l -p "$PORT")

echo "19. TEST. FILE_DATA_HASH_ANSWER"

if [ "$RESPONSE" != "FILE_DATA_HASH_OK" ]
then
    echo "ERROR 4: MD5 de datos incorrecto"
    exit 4
fi
echo "Fin de comuniación"

exit 0
