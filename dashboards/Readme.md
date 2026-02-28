# SOC Dashboards

Splunk-based security operations dashboards visualizing 6,363 events across 7 detection sources.

## Master Console

**File:** `screenshots/soc-master-console.pdf`  
**Type:** Dashboard Studio (Absolute Layout)  
**Purpose:** Single Pane of Glass for multi-vector threat monitoring

**Panels:**
- **Top Row KPIs:** Total events, threat intel hits, failed authentications, web attacks blocked
- **Geographic Map:** Real-time threat origin visualization
- **Detection Timeline:** 4-layer stacked area chart (Web, Network, Windows, Linux)
- **Attack Classification:** Donut chart showing SQLi, XSS, Path Traversal distribution
- **Top Threat Actors:** Table with source IPs and event counts
- **Critical Events:** Recent high-severity detections across all layers
- **Activity Sparklines:** Per-layer event frequency over time

**Data Sources:**
- `web_attacks` (121 events) - ModSecurity WAF
- `network_ids` (2,958 events) - Suricata IDS
- `endpoint_windows` (2,157 events) - Sysmon + Security + PowerShell
- `endpoint_linux` (127 events) - SSH auth + Auditd

## Domain-Specific Dashboards

### Web Application Security
- Attack type distribution
- Anomaly score histogram
- Top targeted URIs
- Timeline of attacks

### Network Threats
- Suricata alert signatures
- Threat intelligence hits (CINS, Spamhaus)
- Protocol distribution
- Top attacking IPs

### Windows Endpoint
- Failed RDP attempts timeline
- Brute-force source IPs
- Sysmon process creation
- PowerShell activity

### Linux Endpoint
- SSH authentication status
- Brute-force attackers
- Sudo command frequency
- Auth timeline

## Reproducing Dashboards

1. Install Splunk Enterprise (Free)
2. Create indices: `web_attacks`, `network_ids`, `endpoint_windows`, `endpoint_linux`
3. Import JSON from `splunk-json/` directory
4. Ingest logs from `siem-lab/logs/` (see main README)
5. Dashboard will auto-populate with data

## Design Principles

- **Dark theme** for reduced eye strain during long monitoring sessions
- **High density** to maximize information per screen
- **Color-coded severity** (cyan = info, orange = warning, red = critical, green = success)
- **Real-time feel** via 30-second refresh interval
- **Geographic context** via IP geolocation and mapping
