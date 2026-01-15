#!/bin/bash

echo "Server RECTP_0.5"

PORT_RECV=9999
PORT_SEND=10000
ACTUAL_VERSION="0.5"
ACTUAL_HEADER="RECTP"

while true; do
    echo "0. LISTEN"

    DATA=$(nc -l -p "$PORT_RECV")
    echo "Data received: '$DATA'"

    HEADER=$(echo "$DATA" | cut -d " " -f 1)
    VERSION=$(echo "$DATA" | cut -d " " -f 2)
	
	echo "3. TEST"
    if [ "$HEADER" != "$ACTUAL_HEADER" ]; then
        echo "ERROR 1: Wrong Header"
        echo "HEADER_KO ERROR:HEADER" | nc localhost -q 0 "$PORT_SEND"
        continue
    fi

    if [ "$VERSION" != "$ACTUAL_VERSION" ]; then
        echo "ERROR 2: Wrong Version"
        echo "HEADER_KO ERROR:VERSION" | nc localhost -q 0 "$PORT_SEND"
        continue
    fi

    echo "3.1 RESPONSE"
    echo "HEADER_OK VERSION:$VERSION" | nc localhost -q 0 "$PORT_SEND"

    echo "4.REESTART LOOP"
done

