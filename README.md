# SIEM Lab Infrastructure

Multi-platform SOC detection laboratory demonstrating realistic threat detection across network, application, host, and authentication layers on Linux and Windows systems.

## Architecture

**Platform:** AWS  
**Deployment:** Terraform  
**Systems:**
- Attacker: Ubuntu 20.04 (10.0.1.203)
- Linux Victim: Amazon Linux 2 (10.0.1.84)
- Windows Victim: Windows Server 2019 (10.0.1.103)

## Detection Stack Overview

**Total Events Captured:** 6,363 events across 7 detection sources

### Linux Victim (10.0.1.84) - 4 Detection Layers

#### Layer 1: Application (ModSecurity WAF)
**Purpose:** Web application attack detection  
**Events:** 121 detections  
**Coverage:** SQLi, XSS, path traversal, command injection  
**Config:** OWASP CRS (PARANOIA level 2)  
**Log:** `logs/modsec/detections.json`

**Attack distribution:**
- SQLi: 60%
- XSS: 30%
- Path Traversal: 7%
- Command Injection: 3%
- Anomaly scores: 8, 13, 18, 23, 28

#### Layer 2: Network (Suricata IDS)
**Purpose:** Network-level threat detection  
**Events:** 2,958 events  
**Coverage:** Port scans, brute-force, protocol anomalies, threat intelligence  
**Threat Intel:** CINS Active Threat Intelligence, Spamhaus DROP  
**Log:** `logs/suricata/eve.json`

**Real threats detected:**
- CVE-2024-6409 (OpenSSH vulnerability)
- ET SCAN alerts (SSH, PostgreSQL probing)
- Active botnet traffic from internet
- Blacklisted IP detections

#### Layer 3: Host (Auditd)
**Purpose:** Privileged operations monitoring  
**Events:** 59 sudo commands  
**Coverage:** Privilege escalation, sensitive file access, system modifications  
**Log:** `logs/auditd/sudo-commands.json`

**Monitored activities:**
- Sudo/su execution
- Password file access (/etc/shadow, /etc/passwd)
- SSH key access
- Suspicious binary execution (wget, curl, nc)
- System configuration changes

#### Layer 4: Authentication (SSH Logs)
**Purpose:** Authentication attack detection  
**Events:** 68 events (57 failed, 10 successful, 1 invalid user)  
**Coverage:** Brute-force, invalid users, auth timeline  
**Log:** `logs/auth/ssh-events.json`

**Attack sources:**
- 10.0.1.203 (38 attempts) - Controlled Hydra brute-force
- 206.189.9.56 (8 attempts) - Real botnet
- 167.71.72.71 (7 attempts) - Real botnet
- 178.62.244.86 (4 attempts) - Real botnet

---

### Windows Victim (10.0.1.103) - 3 Detection Layers

#### Layer 5: Endpoint (Sysmon)
**Purpose:** Process execution and system activity monitoring  
**Events:** 1,000 events  
**Coverage:** Process creation, network connections, file events, registry modifications  
**Config:** SwiftOnSecurity production config  
**Log:** `logs/windows/sysmon-events.json`

**Key Event IDs:**
- Event ID 1: Process creation (command-line, parent-child chains)
- Event ID 3: Network connections
- Event ID 10: Process access (LSASS credential dumping detection)
- Event ID 11: File creation
- Event ID 13: Registry value set (persistence detection)

#### Layer 6: Authentication (Security Event Log)
**Purpose:** Windows authentication monitoring  
**Events:** 1,000 events  
**Coverage:** RDP success/failure, logon types, process creation  
**Log:** `logs/windows/security-events.json`

**Key Event IDs:**
- Event ID 4624: Successful logon (Logon Type 10 = RDP)
- Event ID 4625: Failed logon (brute-force detection)
- Event ID 4688: Process creation (backup telemetry)

#### Layer 7: Command Execution (PowerShell Operational Log)
**Purpose:** PowerShell command visibility  
**Events:** 157 script blocks  
**Coverage:** PowerShell commands, script content, execution timeline  
**Log:** `logs/windows/powershell-events.json`

**Key Event IDs:**
- Event ID 4104: Script block logging (full command visibility)

---

## Attack Scenarios Executed

### Linux Attacks

**Web Application Exploitation:**
```bash
# SQLi variants (boolean, union, time-based, encoded)
# XSS variants (script tags, event handlers, attribute injection)
# Path traversal attempts
# Command injection attempts
```

**Network Reconnaissance:**
```bash
nmap -sV 10.0.1.84              # Service enumeration
hydra -l admin -P wordlist.txt ssh://10.0.1.84  # SSH brute-force
```

### Windows Attacks

**RDP Brute-Force:**
```bash
hydra -l Administrator -P rockyou.txt rdp://10.0.1.103
```

**Post-Exploitation:**
```powershell
# Reconnaissance commands (whoami, Get-LocalUser, Get-NetTCPConnection)
# LSASS credential dumping simulation (rundll32 + comsvcs.dll)
# Registry persistence (HKLM Run key)
# Suspicious file downloads (PsExec, netcat)
```

---

## Quick Start

### Deploy Infrastructure
```bash
cd terraform/
terraform init
terraform apply
```

### Linux Detection Pipelines

**Pipeline 1: ModSecurity**
```bash
cd detection-pipelines/pipeline1-modsecurity
./start-pipeline.sh
./capture-modsec-logs.sh &
```

**Pipeline 2: Suricata**
```bash
# Logs automatically captured in ~/soc-lab/logs/suricata/eve.json
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

### Windows Detection Pipelines

**Pipeline 5: Sysmon + Event Logging**
```powershell
# Run in PowerShell as Administrator
cd detection-pipelines/pipeline5-windows-sysmon

# Install Sysmon
.\install-sysmon.ps1

# Enable PowerShell logging
.\enable-powershell-logging.ps1

# After attack generation, export logs
.\export-windows-logs.ps1
```

---

## Log Analysis Examples

**ModSecurity - Attack type distribution:**
```bash
cat logs/modsec/detections.json | jq -r '.anomaly_score' | sort | uniq -c
```

**Suricata - Threat intel hits:**
```bash
cat logs/suricata/eve.json | jq 'select(.alert.signature | contains("CINS"))'
```

**SSH - Brute-force sources:**
```bash
cat logs/auth/ssh-events.json | jq -r 'select(.status=="failure") | .source_ip' | sort | uniq -c
```

**Sysmon - Process creation events:**
```bash
cat logs/windows/sysmon-events.json | jq 'select(.EventID == 1)'
```

**Security - Failed RDP logins:**
```bash
cat logs/windows/security-events.json | jq 'select(.EventID == 4625)'
```

---

## Project Status

- [x] AWS infrastructure (Terraform)
- [x] Pipeline 1: ModSecurity (121 detections)
- [x] Pipeline 2: Suricata (2,958 events)
- [x] Pipeline 3: Auditd (59 privileged operations)
- [x] Pipeline 4: SSH authentication (68 events)
- [x] Pipeline 5: Windows Sysmon (1,000 events)
- [x] Pipeline 6: Windows Security (1,000 events)
- [x] Pipeline 7: Windows PowerShell (157 events)
- [x] Log centralization on Linux victim
- [ ] Dashboard visualization (in progress)

---

## Design Philosophy

**Multi-layer detection over single-tool depth.** Each detection source provides unique telemetry that correlates across the attack chain. The lab captures both controlled test traffic and real-world internet threats for realistic SOC scenarios.

---

## Key Technical Decisions

**Swap Memory:** AWS t2.micro instances require swap configuration for Suricata container stability  
**Host Networking:** ModSecurity CRS requires `--network host` for proper backend proxying  
**Log Centralization:** All logs aggregated on Linux victim for unified analysis  
**JSON Format:** All logs exported to JSON for dashboard compatibility  
**Attack Realism:** Slow, deliberate attacks generate high-quality detections over volume

---

## Detection Coverage Matrix

| Attack Technique | Linux Detection | Windows Detection |
|-----------------|-----------------|-------------------|
| Web Exploitation | ModSecurity | - |
| Network Scanning | Suricata | - |
| SSH Brute-Force | Suricata + SSH Logs | - |
| Privileged Commands | Auditd | - |
| RDP Brute-Force | - | Security Log (4625) |
| Process Execution | - | Sysmon (ID 1) |
| Credential Dumping | - | Sysmon (ID 10) |
| Persistence | - | Sysmon (ID 13) |
| PowerShell Abuse | - | Event ID 4104 |

---

**Built for SOC analysts and blue team engineers.**
```

---

## FINAL GITHUB STRUCTURE

After these additions:
```
siem-lab/
├── detection-pipelines/
│   ├── pipeline1-modsecurity/
│   │   ├── start-pipeline.sh
│   │   └── capture-modsec-logs.sh
│   ├── pipeline2-suricata/
│   │   └── capture-suricata-logs.sh
│   ├── pipeline3-auditd/
│   │   ├── parse-auditd-sudo.sh
│   │   └── soc-detection.rules
│   ├── pipeline4-ssh-auth/
│   │   └── parse-ssh-auth.sh
│   └── pipeline5-windows-sysmon/       # NEW
│       ├── install-sysmon.ps1          # NEW
│       ├── enable-powershell-logging.ps1  # NEW
│       └── export-windows-logs.ps1     # NEW
├── terraform-infra/
├── .gitignore
└── README.md                            # UPDATED
