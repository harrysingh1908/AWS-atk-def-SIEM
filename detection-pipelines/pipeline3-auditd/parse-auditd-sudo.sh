#!/bin/bash

JSON_LOG="/home/ec2-user/soc-lab/logs/auditd/sudo-commands.json"
mkdir -p /home/ec2-user/soc-lab/logs/auditd

# Clear existing
> "$JSON_LOG"

# Parse USER_CMD events to JSON
sudo ausearch -m USER_CMD --start today -i 2>/dev/null | awk '
BEGIN { in_event=0 }
/^----$/ { in_event=1; next }
/^type=USER_CMD/ {
    if (in_event) {
        # Extract timestamp
        match($0, /audit\(([^)]+)\)/, ts)
        timestamp = ts[1]
        
        # Extract user
        match($0, /uid=([^ ]+)/, user)
        uid = user[1]
        
        # Extract command from msg field
        match($0, /cmd=([^ ]+( [^ ]+)*)/, command)
        cmd = command[1]
        
        # Extract terminal
        match($0, /terminal=([^ ]+)/, term)
        terminal = term[1]
        
        # Extract result
        match($0, /res=([^ ]+)/, result)
        res = result[1]
        
        # Clean up command (remove quotes if present)
        gsub(/'\''/, "", cmd)
        
        # Output JSON
        printf "{\"timestamp\":\"%s\",\"user\":\"%s\",\"command\":\"%s\",\"terminal\":\"%s\",\"result\":\"%s\",\"event_type\":\"sudo_command\"}\n", 
            timestamp, uid, cmd, terminal, res
        
        in_event=0
    }
}
' >> "$JSON_LOG"

echo "Parsed $(wc -l < $JSON_LOG) sudo commands to $JSON_LOG"
