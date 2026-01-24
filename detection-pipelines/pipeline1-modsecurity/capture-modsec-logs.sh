#!/bin/bash
# Real-time ModSecurity log capture with JSON parsing

RAW_LOG="/home/ec2-user/soc-lab/logs/modsec/detections.log"
JSON_LOG="/home/ec2-user/soc-lab/logs/modsec/detections.json"

mkdir -p /home/ec2-user/soc-lab/logs/modsec

docker logs -f modsec 2>&1 | grep --line-buffered "ModSecurity: Access denied" | while read -r line; do
    echo "$line" >> "$RAW_LOG"
    
    timestamp=$(echo "$line" | grep -oP '^\d{4}/\d{2}/\d{2} \d{2}:\d{2}:\d{2}')
    client_ip=$(echo "$line" | grep -oP '\[client \K[0-9.]+')
    rule_id=$(echo "$line" | grep -oP '\[id "\K\d+')
    msg=$(echo "$line" | grep -oP '\[msg "\K[^"]+' | sed 's/"/\\"/g')
    uri=$(echo "$line" | grep -oP '\[uri "\K[^"]+')
    score=$(echo "$line" | grep -oP 'Total Score: \K\d+')
    request=$(echo "$line" | grep -oP 'request: "\K[^"]+')
    severity=$(echo "$line" | grep -oP '\[severity "\K[^"]+')
    
    echo "{\"timestamp\":\"$timestamp\",\"client_ip\":\"$client_ip\",\"rule_id\":\"$rule_id\",\"message\":\"$msg\",\"uri\":\"$uri\",\"anomaly_score\":$score,\"request\":\"$request\",\"severity\":\"$severity\"}" >> "$JSON_LOG"
done
```
