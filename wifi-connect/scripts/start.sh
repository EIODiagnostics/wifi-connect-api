#!/usr/bin/env bash

# setup logging of this script /data/command-$.log
mkdir -p /eio-data/log
readonly LOG_LOCATION=/eio-data/log/runCommand-${RESIN_SERVICE_NAME}.log
exec > >(tee -a -i $LOG_LOCATION)
exec 2>&1
source util.bash

echolog "wifi-connect-api started"
nmcli connection show | echolog
nmcli c up edlab

# check for active WiFi Connection regularly 
while true; do
    nmcli connection show | echolog

    wget "http://clients3.google.com/generate_204?" -O /dev/null 2>&1 | grep "204 No Content" > /dev/null
    haveInternetAccess=$?
    echolog "haveInternetAccess=$haveInternetAccess"
    
    iwgetid --raw | echolog
    echolog "haveWifiAcces=$haveWifiAccess"
    haveWifiAccess=$?

    if [[ $haveInternetAccess -eq 0 && $haveWifiAccess -eq 0 ]]; then
        echolog 'Skipping WiFi Connect'
        # wait 10 seconds before checking again for internet connectivity
        sleep 10
    else
        echolog 'Starting WiFi Connect'
        # Start wifi-connect on a separate port
        ./wifi-connect \
            --portal-ssid "EIO Camera ${RESIN_DEVICE_NAME_AT_INIT}" \
            --portal-listening-port 45454
        
        wifiConnectExit=$?

        echolog "wifi-connect exited with code $wifiConnectExit"
    fi

done
