#!/bin/bash
# Suricata log capture - eve.json contains all detection data

LOG_DIR="/home/ec2-user/soc-lab/logs/suricata"
mkdir -p "$LOG_DIR"

echo "Suricata logs captured in real-time to: $LOG_DIR/eve.json"
echo "Logs include: alerts, flows, DNS queries, HTTP metadata, threat intel hits"
echo ""
echo "View alerts: cat $LOG_DIR/eve.json | jq 'select(.event_type==\"alert\")'"
echo "View flows: cat $LOG_DIR/eve.json | jq 'select(.event_type==\"flow\")'"
