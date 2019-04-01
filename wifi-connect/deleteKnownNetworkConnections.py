#!/usr/bin/env python3
"""
Delete all known wifi connection credentials so we can test the wifi-connect interface

$ nmcli connection show
NAME                UUID                                  TYPE             DEVICE
WeWork              7e91bf92-fdc2-4a93-b0f0-22d9bf4d878b  802-11-wireless  wlan0
Wired connection 1  0c8b6195-2cb0-3b02-b362-a85992640c9e  802-3-ethernet   eth0
supervisor0         92435b02-e285-4c1a-85b8-13ce6a96d529  bridge           supervisor0

$ ./deleteKnownNetworkConnections.py
Deleting {'id': 'WeWork', 'permissions': [], 
'timestamp': 1551740291, 
'type': '802-11-wireless', 
'uuid': '7e91bf92-fdc2-4a93-b0f0-22d9bf4d878b'}

$ nmcli connection show
NAME                UUID                                  TYPE            DEVICE
Wired connection 1  0c8b6195-2cb0-3b02-b362-a85992640c9e  802-3-ethernet  eth0
supervisor0         92435b02-e285-4c1a-85b8-13ce6a96d529  bridge          supervisor0


To restart the container (until we figure out a better solutions)
curl -X POST --header "Content-Type:application/json" \
     --data "{\"appId\": $BALENA_APP_ID}" \
     "$BALENA_SUPERVISOR_ADDRESS/v1/restart?apikey=$BALENA_SUPERVISOR_API_KEY"
"""

import NetworkManager

for conn in NetworkManager.Settings.ListConnections():
    settings = conn.GetSettings()['connection']
    if settings['type'] == '802-11-wireless':
        if settings['id'] != 'WiFi Connect':
            print('Deleting {}'.format(settings))
            conn.Delete()
