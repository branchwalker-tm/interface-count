#!/bin/bash

PAN_IP="<YOUR_PANORAMA_IP>"
API_KEY="<YOUR_API_KEY>"

curl -k -s -H "X-PAN-KEY: $API_KEY" "https://$PAN_IP/api/?type=op&cmd=%3Cshow%3E%3Cdevices%3E%3Call%3E%3C/all%3E%3C/devices%3E%3C/show%3E" \
| grep -oP '(?<=serial>)[^<]+|(?<=model>)[^<]+' \
| paste - - \
| while read -r serial model; do
    echo -n "Serial: $serial | Model: $model | Active Interfaces: "
    
    # Run query against specific managed firewall
    result=$(curl -k -s --max-time 5 -H "X-PAN-KEY: $API_KEY" \
        "https://$PAN_IP/api/?type=op&cmd=%3Cshow%3E%3Cinterface%3Eall%3C/interface%3E%3C/show%3E&target=$serial")
    
    # Count physical interfaces that are in 'up' state
    count=$(echo "$result" | grep -oE 'ethernet[^"]+|<state>up</state>' | grep -B 1 "<state>up</state>" | grep -c "ethernet")
    
    echo "$count"
done

