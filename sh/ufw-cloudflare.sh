#!/bin/bash

# https://www.cloudflare.com/ips-v4/
ipv4_ranges=(
    "173.245.48.0/20"
    "103.21.244.0/22"
    "103.22.200.0/22"
    "103.31.4.0/22"
    "141.101.64.0/18"
    "108.162.192.0/18"
    "190.93.240.0/20"
    "188.114.96.0/20"
    "197.234.240.0/22"
    "198.41.128.0/17"
    "162.158.0.0/15"
    "104.16.0.0/13"
    "104.24.0.0/14"
    "172.64.0.0/13"
    "131.0.72.0/22"
)

# https://www.cloudflare.com/ips-v6/
ipv6_ranges=(
    "2400:cb00::/32"
    "2606:4700::/32"
    "2803:f800::/32"
    "2405:b500::/32"
    "2405:8100::/32"
    "2a06:98c0::/29"
    "2c0f:f248::/32"
)

# Prompt user for action
read -p "输入'A'添加IP，输入'D'删除IP" action

# Convert input to lowercase
action=$(echo $action | tr '[:upper:]' '[:lower:]')

if [[ "$action" == "a" ]]; then
    for ip in "${ipv4_ranges[@]}"; do
        sudo ufw allow from $ip to any port 80
        echo "Allowed $ip through UFW"
    done
    for ip in "${ipv4_ranges[@]}"; do
        sudo ufw allow from $ip to any port 443
        echo "Allowed $ip through UFW"
    done
    for ip in "${ipv6_ranges[@]}"; do
        sudo ufw allow from $ip to any port 80
        echo "Allowed $ip through UFW"
    done
    for ip in "${ipv6_ranges[@]}"; do
        sudo ufw allow from $ip to any port 443
        echo "Allowed $ip through UFW"
    done
elif [[ "$action" == "d" ]]; then
    for ip in "${ipv4_ranges[@]}"; do
        sudo ufw delete allow from $ip to any port 80
        sudo ufw delete allow from $ip to any port 443
        echo "Deleted $ip from UFW"
    done
    for ip in "${ipv6_ranges[@]}"; do
        sudo ufw delete allow from $ip to any port 80
        sudo ufw delete allow from $ip to any port 443
        echo "Deleted $ip from UFW"
    done
else
    echo "Invalid input. Please enter A to add or D to delete."
    exit 1
fi

# Enable UFW if not already enabled (only if adding rules)
if [[ "$action" == "a" ]]; then
    sudo ufw enable
fi

sudo ufw status
