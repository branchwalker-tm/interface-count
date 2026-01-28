# interface-count
This is a simple bash script that leverages the PANOS XML API on Palo Alto Networks Panorama Devices to return a count of all of the interfaces on your Panorama managed firewalls that are in the up state along with the model number and serial number of each device.

## How to use
Ensure you have your API key:
`curl -H "Content-Type: application/x-www-form-urlencoded" -X POST https://firewall/api/?type=keygen -d 'user=<user>&password=<password>'`

Update the `PAN_IP` and `API_KEY` variables in the script with your Panorama IP address and API key respectively.

Run the script:
`bash interface-count.sh`
