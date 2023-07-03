#!/bin/bash

# Your DigitalOcean API token
DO_TOKEN="YOUR_API_TOKEN"

# Your DigitalOcean firewall ID
FIREWALL_ID="YOUR_FIREWALL_ID"

# Fetch Cloudflare's IPs
CF_IPV4=$(curl https://www.cloudflare.com/ips-v4)
CF_IPV6=$(curl https://www.cloudflare.com/ips-v6)

# Prepare the IP ranges for the DigitalOcean API
IP_RANGES=""

for ip in $CF_IPV4; do
    IP_RANGES="${IP_RANGES}{\"protocol\": \"tcp\", \"ports\": \"443\", \"sources\": {\"addresses\": [\"$ip\"]}},"
done

for ip in $CF_IPV6; do
    IP_RANGES="${IP_RANGES}{\"protocol\": \"tcp\", \"ports\": \"443\", \"sources\": {\"addresses\": [\"$ip\"]}},"
done

# Remove the trailing comma
IP_RANGES=${IP_RANGES%,}

# Create the JSON payload
PAYLOAD="{\"name\":\"cloudflare\",\"droplet_ids\":[284815668],\"inbound_rules\": [$IP_RANGES],\"outbound_rules\":[]}"

# Update the firewall rules
curl -X PUT -H "Content-Type: application/json" -H "Authorization: Bearer $DO_TOKEN" -d "$PAYLOAD" "https://api.digitalocean.com/v2/firewalls/$FIREWALL_ID"
