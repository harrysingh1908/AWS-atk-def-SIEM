# SIEM Lab Infrastructure

Multi-layer SOC detection laboratory demonstrating realistic threat detection across network, application, host, and authentication layers.

## Architecture

**Platform:** AWS  
**Deployment:** Terraform  
**Systems:**
- Attacker: Ubuntu 20.04 (10.0.1.203)
- Linux Victim: Amazon Linux 2 (10.0.1.84)
- Windows Victim: Windows Server 2019 (planned)

## Detection Stack (Linux Victim)

### Layer 1: Application (ModSecurity WAF)
**Purpose:** Detect web application attacks  
**Detections:** SQLi, XSS, path traversal, command injection  
**Coverage:** 121+ validated detections across 7 attack categories  
**Config:** OWASP CRS (PARANOIA level 2)  
**Log:** `logs/modsec/detections.json`

**Sample metrics:**
- Anomaly scores: 8, 13, 18, 23, 28
- Attack types: SQLi (60%), XSS (30%), Traversal (7%), Command Injection (3%)
- 7+ different application endpoints targeted

### Layer 2: Network (Suricata IDS)
**Purpose:** Detect network-level threats  
**Detections:** Port scans, brute-force, protocol anomalies, threat intelligence  
**Coverage:** SSH scans, service enumeration, real botnet traffic  
**Threat Intel:** CINS Active Threat Intelligence, Spamhaus DROP  
**Log:** `logs/suricata/eve.json`

**Real threats detected:**
- CINS/Spamhaus blacklisted IPs scanning the server
- CVE-2024-6409 (OpenSSH vulnerability banner detection)
- ET SCAN alerts (SSH, PostgreSQL probing)

### Layer 3: Host (Auditd)
**Purpose:** Monitor privileged operations  
**Detections:** Sudo command execution, sensitive file access  
**Coverage:** 59+ privileged operations captured  
**Log:** `logs/auditd/sudo-commands.json`

**Monitored activities:**
- Privilege escalation attempts (sudo, su)
- Password file access (/etc/shadow, /etc/passwd)
- SSH key access
- Suspicious binary execution (wget, curl, nc)
- System configuration changes

### Layer 4: Authentication (SSH Logs)
**Purpose:** Detect authentication attacks  
**Detections:** Brute-force, invalid users, successful vs failed logins  
**Coverage:** 68+ authentication events (57 failed, 10 successful, 1 invalid user)  
**Log:** `logs/auth/ssh-events.json`

**Attack sources detected:**
- 10.0.1.203 (38 attempts) - Controlled Hydra brute-force from attacker VM
- 206.189.9.56 (8 attempts) - Real internet botnet
- 167.71.72.71 (7 attempts) - Real internet botnet
- 178.62.244.86 (4 attempts) - Real internet botnet

## Quick Start

### Deploy Infrastructure
```bash
cd terraform/
terraform init
terraform apply
```

### Start Detection Pipelines (on Linux Victim: 10.0.1.84)

**Pipeline 1: ModSecurity**
```bash
cd detection-pipelines/pipeline1-modsecurity
./start-pipeline.sh
./capture-modsec-logs.sh &
```

**Pipeline 2: Suricata**
```bash
# Suricata runs via Docker, logs appear automatically in:
# /home/ec2-user/soc-lab/logs/suricata/eve.json
```

**Pipeline 3: Auditd**
```bash
cd detection-pipelines/pipeline3-auditd
sudo cp soc-detection.rules /etc/audit/rules.d/
sudo augenrules --load
./parse-auditd-sudo.sh
```

**Pipeline 4: SSH Authentication**
```bash
cd detection-pipelines/pipeline4-ssh-auth
./parse-ssh-auth.sh
```

## Attack Generation (from Attacker: 10.0.1.203)

**Web application attacks:**
```bash
~/phase1-attacks.sh    # Targeted attacks (SQLi, XSS, traversal)
~/phase2-attacks.sh    # Volume generation (70+ variations)
~/phase3-attacks.sh    # Behavioral attacks (POST, headers, User-Agent)
```

**Network attacks:**
```bash
nmap -sV 10.0.1.84                           # Service enumeration
hydra -l admin -P wordlist.txt ssh://10.0.1.84  # SSH brute-force
```

## Log Analysis Examples

**ModSecurity - Top attack types:**
```bash
cat logs/modsec/detections.json | jq -r '.anomaly_score' | sort | uniq -c
```

**Suricata - Threat intel hits:**
```bash
cat logs/suricata/eve.json | jq 'select(.alert.signature | contains("CINS"))'
```

**Auditd - Privileged commands:**
```bash
cat logs/auditd/sudo-commands.json | jq -r '.command' | sort | uniq -c
```

**SSH - Brute-force sources:**
```bash
cat logs/auth/ssh-events.json | jq -r 'select(.status=="failure") | .source_ip' | sort | uniq -c
```

## Project Status

- [x] AWS infrastructure (Terraform)
- [x] Pipeline 1: ModSecurity (121 detections)
- [x] Pipeline 2: Suricata (network + threat intel)
- [x] Pipeline 3: Auditd (59 privileged operations)
- [x] Pipeline 4: SSH authentication (68 events, 57 attacks)
- [ ] Windows victim + Sysmon
- [ ] Centralized log aggregation (ELK)
- [ ] SOC dashboard visualization

## Design Philosophy

**Detection breadth over attack volume.** Each layer provides unique telemetry that correlates across the attack chain. The lab captures both controlled test traffic and real-world internet threats for realistic SOC scenarios.

## Key Learnings

**Swap memory configuration:** AWS t2.micro instances require swap for Suricata container stability  
**Host networking:** ModSecurity CRS requires `--network host` to properly proxy to backend  
**Multi-layer correlation:** Same attack appears differently across layers (e.g., SSH brute-force shows in Suricata flows + auth logs)  
**Real threat value:** Internet-facing systems naturally attract botnet traffic, providing authentic threat telemetry
