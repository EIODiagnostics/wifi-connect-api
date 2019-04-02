#!/usr/bin/env bash

export DBUS_SYSTEM_BUS_ADDRESS=unix:path=/host/run/dbus/system_bus_socket

sleep infinity

# setup logging of this script /data/command.log
mkdir -p /data
readonly LOG_LOCATION=/data/command.log
exec > >(tee -a -i $LOG_LOCATION)
exec 2>&1

echo `date` " Script started"


# check for active WiFi Connection regularly 
while true; do

    wget "http://clients3.google.com/generate_204?" -O /dev/null 2>&1 | grep "204 No Content" > /dev/null
    haveInternetAccess=$?
    iwgetid --raw
    haveWifiAccess=$?

    if [[ $haveInternetAccess -eq 0 && $haveWifiAccess -eq 0 ]]; then
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
