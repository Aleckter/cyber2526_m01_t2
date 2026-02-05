#!/usr/bin/env bash

echo -e "\\e[1;32mRECTP SENDER\\e[0m: Wrapper del cliente de RECTP\\n"

sleep 0.5

SERVER_ADDRESS=`echo $1`

if [ $# -lt 1 ]
then
    while [ -z "$SERVER_ADDRESS" ]
    do
        read -p "Introduce la dirección del servidor: " SERVER_ADDRESS
        if [ -z "$SERVER_ADDRESS" ]
        then
            echo -e "\\e[0;30;41mIntroduce un nombre válido.\\e[0m"
            sleep 0.5
        fi
    done
fi

MESSAGE=""

while [ -z "$MESSAGE" ]
do
    read -p "Introduce el mensaje a enviar: " MESSAGE
    if [ -z "$MESSAGE" ]
    then
        echo -e "\\e[0;30;41mIntroduce un mensaje.\\e[0m"
        sleep 0.5
    fi
done

echo -en "\\n\\e[1;36mGenerando el archivo de audio: \\e[0m"

echo "$MESSAGE" | text2wave -o audio.wav

sleep 1
echo -e "\\e[1;32mGENERADO\\n\\e[0m"

sleep 1
echo -en "\\e[1;33mIniciando el cliente de RECTP \\e[0m"

sleep 1
echo -n "."
sleep 1
echo -n "."
sleep 1
echo -n "."

sleep 2

./cliente.sh "$SERVER_ADDRESS"

ERROR_RECTP=`echo $?`

if [ "$ERROR_RECTP" -gt 0 ]
then
    echo -e "\\e[0;30;41mError $ERROR_RECTP al enviar el archivo.\\e[0m"

    # Formato: FECHA;ERROR;DIRECCION_SERVIDOR;MENSAJE
    FECHA=`date +"%Y-%m-%d %H:%M:%S"`
    
    echo "$FECHA;$ERROR_RECTP;$SERVER_ADDRESS;$MESSAGE" >> rectp_sender.log
fi

