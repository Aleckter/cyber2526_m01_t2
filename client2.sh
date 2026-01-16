#!/bin/bash

AUDIO_FILE="audio.wav"

VERSION_CURRENT="0.7"

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

FILE_NAME_MD5=$(echo -n "$AUDIO_FILE" | md5sum | awk '{print $1}')

sleep 1
echo "FILE_NAME $AUDIO_FILE $FILE_NAME_MD5" | nc "$IP_SERVER" -q 0 "$PORT"

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

echo "15. TEST AND END"

if [ "$RESPONSE" != "FILE_DATA_OK" ]
then
echo "ERROR 3: Datos del archivo corruptos"
exit 3
fi

echo "Fin de comuniación"

exit 0
