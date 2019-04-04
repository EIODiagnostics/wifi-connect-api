#!/usr/bin/env bash

# setup logging of this script /data/command-$.log
mkdir -p /eio-data/log
readonly LOG_LOCATION=/eio-data/log/runCommand-${RESIN_SERVICE_NAME}.log
exec > >(tee -a -i $LOG_LOCATION)
exec 2>&1
source util.bash
echolog "$BASH_SOURCE started"

declare haveInternetAccess=1
declare haveWifiAccess=1

# to connect to edlab:
# nmcli connect up edlab
# to disconnect from edlab:
# nmcli connect down edlab

# to list all wifi networks:
# nmcli dev wifi list

# TODO compare nmcli connection show against list of all wifi networks to select a known network
# or to present known networks to the user

main() {
    # check for active WiFi Connection regularly 
    while true; do
        nmcli connection show | echolog

        checkForWifi
        if [[ $haveInternetAccess -eq "yes" && $haveWifiAccess -eq "yes" ]]; then
            echolog 'Skipping WiFi Connect'
            # wait 10 seconds before checking again for internet connectivity
            sleep 10
        else
            startWifiConnect
        fi
    done
}

checkForWifi() {
    wget "http://clients3.google.com/generate_204?" -O /dev/null 2>&1 | grep "204 No Content" > /dev/null
    if [[ $? -eq 0 ]]; then 
        haveInternetAccess="yes"
    fi
    echolog "haveInternetAccess: $haveInternetAccess"

    wifiNetwork=$(iwgetid --raw)
    if [[ $? -eq 0 ]]; then
        haveWifiAccess="yes"
        echolog $wifiNetwork
    fi
    echolog "haveWifiAccess: $haveWifiAccess"
}

declare DEFAULT_GATEWAY="192.168.42.1"
declare DEFAULT_DHCP_RANGE="192.168.42.2,192.168.42.254"

startPortal() {
    dnsmasq --address="/#/$DEFAULT_GATEWAY" \
        --dhcp-range=$DEFAULT_DHCP_RANGE \
        --dhcp-option=option:router,$DEFAULT_GATEWAY \
        --interface=wlan0 \
        --keep-in-foreground \
        --bind-interfaces \
        --except-interface=lo \
        --conf-file \
        --no-hosts &

    nmcli con add type wifi ifname wlan0 con-name Hostspot autoconnect yes ssid Hostspot
    nmcli con modify Hostspot 802-11-wireless.mode ap 802-11-wireless.band bg ipv4.method shared
    # nmcli con modify Hostspot wifi-sec.key-mgmt wpa-psk
    # nmcli con modify Hostspot wifi-sec.psk "veryveryhardpassword1234"
    nmcli con up Hostspot

    # if the hotspot won't come up:
    UUID=$(grep uuid /etc/NetworkManager/system-connections/Hotspot | cut -d= -f2)
    nmcli con up uuid $UUID
}

startWifiConnect() {
    echolog 'Starting WiFi Connect'
    # Start wifi-connect on a separate port
    ./wifi-connect \
        --portal-ssid "EIO Camera ${RESIN_DEVICE_NAME_AT_INIT}" \
        --portal-listening-port 45454

    wifiConnectExit=$?
    echolog "wifi-connect exited with code $wifiConnectExit"
}

main