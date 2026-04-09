#!/bin/bash

PAN_IP="<YOUR_PANORAMA_IP>"
API_KEY="<YOUR_API_KEY>"

# Get the list of managed devices from Panorama
curl -k -s -H "X-PAN-KEY: $API_KEY" "https://$PAN_IP/api/?type=op&cmd=%3Cshow%3E%3Cdevices%3E%3Call%3E%3C/all%3E%3C/devices%3E%3C/show%3E" \
| grep -oP '(?<=serial>)[^<]+|(?<=model>)[^<]+' \
| paste - - \
| while read -r serial model; do
    echo -n "Serial: $serial | Model: $model | Active Interfaces: "
    
    # Run query against specific managed firewall
    result=$(curl -k -s --max-time 5 -H "X-PAN-KEY: $API_KEY" \
        "https://$PAN_IP/api/?type=op&cmd=%3Cshow%3E%3Cinterface%3Eall%3C/interface%3E%3C/show%3E&target=$serial")
    
    # Extract the total count of 'up' physical interfaces
    count=$(echo "$result" | grep -oE 'ethernet[^"]+|<state>up</state>' | grep -B 1 "<state>up</state>" | grep -c "ethernet")
    echo "$count"
    
    # Robustly parse XML for name and the speed/duplex/state field
    # In PAN-OS XML, the 'st' tag often contains the string "speed/duplex/state"
    echo "$result" | awk -F'[">]' '
        /<entry name="ethernet/ { 
            # Get interface name from name="interface" attribute
            split($0, a, "name=\""); split(a[2], b, "\""); name=b[1] 
        }
        /<st>/ {
            # st tag contains combined info like 1000/full/up
            val=$0; sub(/.*<st>/, "", val); sub(/<\/st>.*/, "", val)
            if (val ~ /\/up/) {
                split(val, parts, "/")
                print "  -> " name " | Speed: " parts[1]
            }
        }
    '
done
