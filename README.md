# SIEM Lab Infrastructure

Enterprise-grade Security Operations Center (SOC) laboratory demonstrating realistic multi-platform threat detection, log aggregation, and security visualization.

## Project Overview

**Total Events:** 6,363 security events across 7 detection sources  
**Platforms:** Linux + Windows endpoint monitoring  
**Attack Vectors:** Web application, network, authentication, host-based  
**Visualization:** Splunk dashboards with geographic threat mapping

---

## Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                    AWS VPC (10.0.1.0/24)                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐ │
│  │   Attacker   │───▶│ Linux Victim │◀──▶│Windows Victim│ │
│  │  Ubuntu 20.04│    │ Amazon Linux │    │  Win Srv 2019│ │
│  │ 10.0.1.203   │    │  10.0.1.84   │    │  10.0.1.103  │ │
│  └──────────────┘    └──────────────┘    └──────────────┘ │
│         │                    │                    │         │
│    Attack Tools          Detection           Detection     │
│   - Hydra (SSH)          - ModSecurity       - Sysmon      │
│   - nmap (scans)         - Suricata          - Security Log│
│   - curl (web)           - Auditd            - PowerShell  │
│                          - SSH logs                         │
│                                                             │
│            Centralized Logs (JSON Format)                  │
│                         │                                   │
│                         ▼                                   │
│               ┌─────────────────┐                          │
│               │  Splunk Free    │                          │
│               │  (Local Machine)│                          │
│               │   Dashboards    │                          │
│               └─────────────────┘                          │
└─────────────────────────────────────────────────────────────┘
```

---

## Detection Stack

### Linux Victim (10.0.1.84)

| Layer | Tool | Events | Coverage |
|-------|------|--------|----------|
| Application | ModSecurity WAF | 121 | SQLi, XSS, Path Traversal, Command Injection |
| Network | Suricata IDS | 2,958 | Port scans, Threat Intel (CINS, Spamhaus), Protocol anomalies |
| Host | Auditd | 59 | Sudo commands, File access, Privilege escalation |
| Authentication | SSH Logs | 68 | Failed/successful logins, Brute-force (57 attacks, 10 success) |

### Windows Victim (10.0.1.103)

| Layer | Tool | Events | Coverage |
|-------|------|--------|----------|
| Endpoint | Sysmon | 1,000 | Process creation, Network connections, Registry modifications |
| Authentication | Security Event Log | 1,000 | RDP success/failure (4624/4625), Logon types |
| Command Execution | PowerShell Logs | 157 | Script block logging (Event ID 4104) |

---

## Attack Scenarios Executed

### Web Application Exploitation
- **121 detections** across SQLi (60%), XSS (30%), Path Traversal (7%), Command Injection (3%)
- Anomaly scores ranging from 8 to 28
- Attacks targeted 7+ different application endpoints

### Network Reconnaissance & Brute-Force
- **2,958 network events** including real internet threat traffic
- ET SCAN alerts (SSH, PostgreSQL probing)
- Real botnet detections: 206.189.9.56, 167.71.72.71, 178.62.244.86
- CVE-2024-6409 (OpenSSH vulnerability) detected

### Windows Post-Exploitation
- **RDP brute-force** from attacker VM (multiple failed 4625 events)
- **LSASS credential dumping** simulation (Sysmon Event ID 10)
- **Registry persistence** (Run key modification, Sysmon Event ID 13)
- **PowerShell reconnaissance** (Get-LocalUser, Get-NetTCPConnection)

### Linux Privilege Escalation
- **59 sudo commands** logged via Auditd
- **SSH brute-force** from attacker (38 failed attempts) + real internet botnets
- Sensitive file access monitoring (/etc/shadow, /etc/passwd)

---

## Key Technical Decisions

**Log Centralization:** All detection sources export to JSON format and centralize on Linux victim before Splunk ingestion

**Multi-Platform Coverage:** Demonstrates understanding of both Linux and Windows security monitoring

**Real Threat Context:** AWS-hosted infrastructure naturally attracts internet threat traffic, providing authentic botnet detections alongside controlled attacks

**Dashboard-First Approach:** Visualization designed for SOC analyst workflows, not just pretty charts

**Attack Realism:** Slow, deliberate attacks generate high-quality detections over volume

---

## Quick Start

### 1. Deploy Infrastructure
```bash
cd terraform/
terraform init
terraform apply
```

### 2. Configure Detection Pipelines

**Linux (SSH to 10.0.1.84):**
```bash
# ModSecurity
cd detection-pipelines/pipeline1-modsecurity
./start-pipeline.sh
./capture-modsec-logs.sh &

# Auditd
cd detection-pipelines/pipeline3-auditd
sudo cp soc-detection.rules /etc/audit/rules.d/
sudo augenrules --load
./parse-auditd-sudo.sh

# SSH Auth
cd detection-pipelines/pipeline4-ssh-auth
./parse-ssh-auth.sh
```

**Windows (RDP to 10.0.1.103):**
```powershell
# Sysmon + PowerShell Logging
cd detection-pipelines/pipeline5-windows-sysmon
.\install-sysmon.ps1
.\enable-powershell-logging.ps1

# After attacks, export logs
.\export-windows-logs.ps1
```

### 3. Generate Attacks

**From Attacker (10.0.1.203):**
```bash
# Web attacks
~/phase1-attacks.sh
~/phase2-attacks.sh

# Network attacks
nmap -sV 10.0.1.84
hydra -l admin -P rockyou.txt ssh://10.0.1.84
hydra -l Administrator -P rockyou.txt rdp://10.0.1.103
```

### 4. Visualize in Splunk

See `dashboards/` directory for:
- Dashboard screenshots
- Splunk JSON definitions
- Import instructions

---

## Detection Coverage Matrix

| Attack Technique | Linux Detection | Windows Detection |
|-----------------|-----------------|-------------------|
| Web Exploitation | ModSecurity | - |
| Network Scanning | Suricata | - |
| SSH Brute-Force | Suricata + Auth Logs | - |
| Privileged Commands | Auditd | - |
| RDP Brute-Force | - | Security Log (4625) |
| Process Execution | - | Sysmon (ID 1) |
| Credential Dumping | - | Sysmon (ID 10) |
| Persistence | - | Sysmon (ID 13) |
| PowerShell Abuse | - | Event ID 4104 |

---

## Project Status

- [x] AWS infrastructure (Terraform)
- [x] Linux detection stack (4 layers)
- [x] Windows detection stack (3 layers)
- [x] Attack generation (web, network, endpoint)
- [x] Log centralization (JSON format)
- [x] Splunk dashboards (5 domain + 1 master console)
- [x] Documentation complete

---

## Design Philosophy

**Multi-layer detection over single-tool depth.** Real SOC environments don't rely on one "super tool" — they correlate signals across network, application, host, and authentication layers. This lab demonstrates that architectural understanding.

**Realistic over dramatic.** Attacks are slow and deliberate, generating high-quality detections that mirror actual threat behavior rather than exploit demos.

**Dashboard usability over aesthetics.** Visualizations answer analyst questions ("What happened? When? From where?") rather than displaying vanity metrics.

---

## What This Lab Does NOT Do

This lab intentionally avoids:
- **Malware detonation** (focuses on attack techniques, not file-based threats)
- **EDR simulation** (uses native OS logging + open-source tools)
- **Artificial correlation** (doesn't force cross-platform attack chains)
- **Over-automation** (manual configuration demonstrates understanding)

---

## Repository Structure
```
siem-lab/
├── detection-pipelines/         # Setup scripts for each detection layer
│   ├── pipeline1-modsecurity/
│   ├── pipeline2-suricata/
│   ├── pipeline3-auditd/
│   ├── pipeline4-ssh-auth/
│   └── pipeline5-windows-sysmon/
├── terraform/                   # AWS infrastructure as code
├── dashboards/                  # Splunk dashboard screenshots & JSON
│   ├── screenshots/
├── .gitignore
└── README.md
```

---

**Built for SOC analysts, security engineers, and blue team professionals.**

*Demonstrates practical detection engineering, not penetration testing.*
