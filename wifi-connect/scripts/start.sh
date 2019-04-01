#!/usr/bin/env bash

export DBUS_SYSTEM_BUS_ADDRESS=unix:path=/host/run/dbus/system_bus_socket

sleep infinity

# setup logging of this script /data/command.log
mkdir -p /data
readonly LOG_LOCATION=/data/command.log
# if [ -f $LOG_LOCATION ]; then
#   rm $LOG_LOCATION
# fi
exec &> >(tee -a -i $LOG_LOCATION)
# exec 2>&1

echo `date` " Script started"


# check for active WiFi Connection regularly 
while true; do
    # echo `date` "1. Is there a default gateway?"
    # ip route | grep default

    # 2. Is there Internet connectivity?
    # nmcli -t g | grep full

    echo `date` " 3. Is there Internet connectivity via a google ping?"
    # wget --spider http://google.com 2>&1

    # echo -e "GET http://google.com HTTP/1.0\n\n" | nc google.com 80 > /dev/null 2>&1
    # if [ $? -eq 0 ]; then
    #     echo "Online"
    # else
    #     echo "Offline"
    # fi

    wget "http://clients3.google.com/generate_204?" -O /dev/null 2>&1 | grep "204 No Content" > /dev/null
    # if [ $? -eq 0 ]; then
    #     echo "Online"
    # else
    #     echo "Offline"
    # fi
    # 4. Is there an active WiFi connection?
    #iwgetid -r

    if [ $? -eq 0 ]; then
        printf 'Skipping WiFi Connect\n'
    else
        printf 'Starting WiFi Connect\n'
        # Start wifi-connect  and make it exit if no interaction happens within 1 minute.
        RUST_LOG=wifi-connect ./wifi-connect \
            --portal-ssid "EIO Camera ${RESIN_DEVICE_NAME_AT_INIT}" \
            --activity-timeout 60 \
            --portal-listening-port 45454
    fi

    # Start your application here. In the background. 
    echo "Use control-c to quit this script"

    # wait 10 seconds before checking again for internet connectivity
    sleep 10
done
