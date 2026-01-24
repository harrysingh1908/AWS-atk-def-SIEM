#!/bin/bash

JSON_LOG="/home/ec2-user/soc-lab/logs/auth/ssh-events.json"
mkdir -p /home/ec2-user/soc-lab/logs/auth

# Clear existing
> "$JSON_LOG"

# Parse SSH authentication events
sudo journalctl _COMM=sshd --since today --no-pager 2>/dev/null | grep -E "Failed|Accepted|Invalid" | while IFS= read -r line; do
    # Extract timestamp
    timestamp=$(echo "$line" | awk '{print $1" "$2" "$3}')
    
    # Determine event type
    if echo "$line" | grep -q "Accepted"; then
        event_type="successful_login"
        status="success"
    elif echo "$line" | grep -q "Failed"; then
        event_type="failed_login"
        status="failure"
    elif echo "$line" | grep -q "Invalid"; then
        event_type="invalid_user"
        status="failure"
    fi
    
    # Extract username
    if echo "$line" | grep -q "for "; then
        username=$(echo "$line" | grep -oP 'for \K[^ ]+' | head -1)
    else
        username="unknown"
    fi
    
    # Extract source IP
    source_ip=$(echo "$line" | grep -oP 'from \K[0-9.]+')
    
    # Extract port
    port=$(echo "$line" | grep -oP 'port \K[0-9]+')
    
    # Extract auth method (if present)
    if echo "$line" | grep -q "publickey"; then
        method="publickey"
    elif echo "$line" | grep -q "password"; then
        method="password"
    else
        method="unknown"
    fi
    
    # Output JSON
    echo "{\"timestamp\":\"$timestamp\",\"event_type\":\"$event_type\",\"status\":\"$status\",\"username\":\"$username\",\"source_ip\":\"$source_ip\",\"port\":\"$port\",\"auth_method\":\"$method\"}" >> "$JSON_LOG"
done

echo "Parsed $(wc -l < $JSON_LOG) SSH auth events to $JSON_LOG"
