#!/bin/bash

#VARIABLES
SERVER="localhost"
PORT="9999"
ACTUAL_HEADER="RECTP"
ACTUAL_VERSION="0.6"

#ENVIO AUDIO
AUDIO_FILE="EVR.wav"
MESSAGE_AUDIO_FILE="FILE_NAME $AUDIO_FILE"

#MENSAJE
MESSAGE="$ACTUAL_HEADER $ACTUAL_VERSION $IP_LOCAL"

#INICIO
echo "Client RECTP_0.5"

#INICIA EL ENVIO
echo "1. SEND"

#IP_LOCAL=$(ip -4 addr | grep "scope global" | awk {print $2} | cut -d'/' -f 1 )
IP_LOCAL=$(ip -4 addr | grep "scope global" | tr -s ' ' | cut -d' ' -f 3 | cut -d'/' -f1)

	echo "Sending : $MESSAGE | FROM $IP_LOCAL"
	sleep 1
	echo "$MESSAGE" | nc $SERVER -q 0 $PORT

#CLIENTE ESPERA RESPUESTA
echo "2. LISTEN"

RESPONSE=$(nc -l -p "$PORT")

	echo "Server answer : $RESPONSE"

HEADER=$(echo $RESPONSE | cut -d " " -f1)
VERSION=$(echo $RESPONSE | cut -d " " -f2)

#CONFIRMA QUE TODO OKE
echo "5. TEST SERVER RESPONSE"

if [ "$HEADER" != "HEADER_OK" ]
then
	echo "ERROR 1: Wrong Header"
	sleep 1
	echo "HEADER_KO ERROR:HEADER" | nc $SERVER -q 0 $PORT
	echo "Sending : HEADER_KO ERROR:HEADER"
	exit 1
fi

if [ "$VERSION" != "VERSION_OK" ]
then
	echo "ERROR 2: Wrong Version"
	sleep 1
	echo "VERSION_KO" | nc $SERVER -q 0 $PORT
	echo "Sending : VERSION_KO"
	exit 2
fi

echo "6. SEND (FILE NAME)"

	echo "Sending : $MESSAGE_AUDIO_FILE"
	sleep 1
	echo "$MESSAGE_AUDIO_FILE" | nc $SERVER -q 0 $PORT

echo "7. LISTEN (FILE NAME RESPONSE)"

RESPONSE2=$(nc -l -p "$PORT")

echo "10. TEST FILE_NAME_OK"

	echo "Server answer (file name) : $RESPONSE2"

if [ "$RESPONSE2" != "FILE_NAME_OK" ]
then
	echo "ERROR 4: Server did not accept file name"
	exit 3
fi

echo "11. SEND (FILE DATA)"

if [ ! -f "$AUDIO_FILE" ]; then
    echo "ERROR: '$AUDIO_FILE' no existe."
    exit 4
fi

	sleep 1
cat $AUDIO_FILE | nc $SERVER -q 0 $PORT

echo "12. LISTEN"

echo "15. TEST AND END"

echo "15.1 TEST"

if [ "$RESPONSE" != "FILE_DATA_OK" ]
then
	echo "ERROR 3: Corrupted data in FILE DATA"
	exit 4
fi

echo "Every process was succesful!"

exit 0
