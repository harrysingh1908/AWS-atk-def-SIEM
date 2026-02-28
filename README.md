# AWS Attack-Defense SIEM Lab

![SOC Master Console](dashboards/SOC_MASTER_CONSOLE.png)

---

## Executive Summary

This project simulates an enterprise-grade Security Operations Center (SOC) environment in AWS, demonstrating end-to-end detection engineering across Linux and Windows systems.

**Core capabilities:** Infrastructure deployment (Terraform), multi-platform threat detection (7 sources), log normalization (JSON), and security visualization (Splunk Dashboard Studio).

**Philosophy:** Architectural clarity and analyst-grade signal quality over exploit demonstration. This lab prioritizes realistic detection workflows, not penetration testing theatrics.

**Result:** 6,363 security events captured across network, application, host, and authentication layers — including real internet threat traffic alongside controlled attacks.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    AWS VPC (10.0.1.0/24)                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐   │
│  │   Attacker   │───▶│ Linux Victim │◀──▶│Windows Victim│   │
│  │  Ubuntu 20.04│    │ Amazon Linux │    │  Win Srv 2019│   │
│  │ 10.0.1.203   │    │  10.0.1.84   │    │  10.0.1.103  │   │
│  └──────────────┘    └──────────────┘    └──────────────┘   │
│         │                    │                    │         │
│    Attack Tools          Detection           Detection      │
│   - Hydra (SSH)          - ModSecurity       - Sysmon       │
│   - nmap (scans)         - Suricata          - Security Log │
│   - curl (web)           - Auditd            - PowerShell   │
│                          - SSH Logs                         │
│                                                             │
│            Centralized Logs (JSON Format)                   │
│                         │                                   │
│                         ▼                                   │
│               ┌─────────────────┐                           │
│               │  Splunk Free    │                           │
│               │  (Local Machine)│                           │
│               │   Dashboards    │                           │
│               └─────────────────┘                           │
└─────────────────────────────────────────────────────────────┘
```

---

## Detection Stack

### Linux Victim (10.0.1.84) — 4 Detection Layers

| Layer | Tool | Events | Coverage |
|-------|------|--------|----------|
| **Application** | ModSecurity WAF | 121 | SQLi, XSS, Path Traversal, Command Injection |
| **Network** | Suricata IDS | 2,958 | Port scans, Threat Intel (CINS, Spamhaus), Protocol anomalies |
| **Host** | Auditd | 59 | Sudo commands, File access, Privilege escalation |
| **Authentication** | SSH Logs | 68 | 57 failed attempts, 10 successful logins, 1 invalid user |

**Attack highlights:**
- Web attacks: SQLi (60%), XSS (30%), Path Traversal (7%), Command Injection (3%)
- Anomaly scores: 8, 13, 18, 23, 28
- Real internet threat actors: 206.189.9.56, 167.71.72.71, 178.62.244.86

### Windows Victim (10.0.1.103) — 3 Detection Layers

| Layer | Tool | Events | Coverage |
|-------|------|--------|----------|
| **Endpoint** | Sysmon | 1,000 | Process creation, Network connections, Registry modifications |
| **Authentication** | Security Event Log | 1,000 | RDP success/failure (4624/4625), Logon types |
| **Command Execution** | PowerShell Logs | 157 | Script block logging (Event ID 4104) |

**Attack highlights:**
- RDP brute-force: Multiple failed authentication attempts (Event ID 4625)
- LSASS credential dumping: Sysmon Event ID 10 (process access)
- Registry persistence: Sysmon Event ID 13 (Run key modification)
- PowerShell reconnaissance: Get-LocalUser, Get-NetTCPConnection, whoami

---

## Sample Detection Flow

**Scenario: External attacker → Successful compromise → Post-exploitation**

1. **Initial Access:** Suricata detects port scanning (ET SCAN alerts) + SSH brute-force attempts visible in auth logs
2. **Authentication:** 57 failed login attempts (SSH logs from 10.0.1.203)
3. **Successful Login:** Valid RDP authentication logged (Security Event ID 4624, Logon Type 10)
4. **Post-Auth Activity:** Process execution recorded (Sysmon Event ID 1: powershell.exe spawned by explorer.exe)
5. **Credential Access:** LSASS memory access attempt detected (Sysmon Event ID 10: rundll32.exe → lsass.exe)
6. **Persistence:** Registry Run key modification (Sysmon Event ID 13: HKLM\...\Run)
7. **Command Execution:** PowerShell reconnaissance captured (Event ID 4104: script blocks with Get-LocalUser, whoami)

**Result:** Full attack chain visible across 4 detection layers — Network → Auth → Endpoint → Command — demonstrating realistic cross-platform detection and correlation capability.

---

## Prerequisites

- **AWS Account** (Free Tier eligible; minor data transfer charges may apply)
- **Terraform** installed locally ([Download](https://www.terraform.io/downloads))
- **Splunk Free/Enterprise** installed locally ([Download](https://www.splunk.com/en_us/download.html))
- **SSH client** (Linux/Mac: native | Windows: PuTTY or OpenSSH)
- **RDP client** (Windows: mstsc | Mac: Microsoft Remote Desktop | Linux: Remmina or xfreerdp)
- Basic familiarity with AWS VPC, Security Groups, and IP addressing

---

## Quick Start

### 1. Deploy Infrastructure

```bash
cd terraform-infra/
terraform init
terraform apply
```

**Expected output:**
- Attacker VM: Ubuntu 20.04 (10.0.1.203)
- Linux Victim: Amazon Linux 2 (10.0.1.84)
- Windows Victim: Windows Server 2019 (10.0.1.103)

### 2. Configure Detection Pipelines

**Linux Victim (SSH to 10.0.1.84):**

```bash
# Pipeline 1: ModSecurity WAF
cd detection-pipelines/pipeline1-modsecurity
./start-pipeline.sh
./capture-modsec-logs.sh &

# Pipeline 2: Suricata IDS
cd detection-pipelines/pipeline2-suricata
./capture-suricata-logs.sh &

# Pipeline 3: Auditd (Privileged Operations)
cd detection-pipelines/pipeline3-auditd
sudo cp soc-detection.rules /etc/audit/rules.d/
sudo augenrules --load
./parse-auditd-sudo.sh

# Pipeline 4: SSH Authentication
cd detection-pipelines/pipeline4-ssh-auth
./parse-ssh-auth.sh
```

**Windows Victim (RDP to 10.0.1.103):**

```powershell
# Pipeline 5: Sysmon + PowerShell Logging
cd detection-pipelines/pipeline5-windows-sysmon
.\install-sysmon.ps1
.\enable-powershell-logging.ps1

# After attack generation, export logs
.\export-windows-logs.ps1
```

### 3. Generate Attacks

**From Attacker VM (10.0.1.203):**

```bash
# Web application attacks
~/phase1-attacks.sh    # Targeted (SQLi, XSS, traversal, command injection)
~/phase2-attacks.sh    # Volume generation (70+ variations)

# Network reconnaissance
nmap -sV 10.0.1.84

# SSH brute-force
hydra -l admin -P /usr/share/wordlists/rockyou.txt ssh://10.0.1.84

# RDP brute-force
hydra -l Administrator -P /usr/share/wordlists/rockyou.txt rdp://10.0.1.103
```

### 4. Centralize Logs

Transfer Windows logs to Linux victim for unified Splunk ingestion:

```powershell
# On Windows: Compress and serve logs
Compress-Archive -Path C:\Tools\Logs\*.json -DestinationPath C:\Tools\windows-logs.zip
cd C:\Tools
python -m http.server 8000
```

```bash
# On Linux: Download and extract
wget http://10.0.1.103:8000/windows-logs.zip
unzip windows-logs.zip -d ~/soc-lab/logs/windows/
```

### 5. Visualize in Splunk

1. Create four indices in Splunk: `web_attacks`, `network_ids`, `endpoint_windows`, `endpoint_linux`
2. Ingest JSON logs from `~/soc-lab/logs/`
3. Import dashboard JSON from `dashboards/` (see `dashboards/Readme.md` for full instructions)
4. View the SOC Master Console for unified threat monitoring

---

## Detection Coverage Matrix

| Attack Technique | Linux Detection | Windows Detection |
|-----------------|-----------------|-------------------|
| Web Exploitation | ModSecurity WAF | — |
| Network Scanning | Suricata IDS | — |
| SSH Brute-Force | Suricata + Auth Logs | — |
| Privileged Commands | Auditd (sudo monitoring) | — |
| RDP Brute-Force | — | Security Event Log (4625) |
| Process Execution | — | Sysmon (Event ID 1) |
| Credential Dumping | — | Sysmon (Event ID 10) |
| Persistence Mechanisms | — | Sysmon (Event ID 13) |
| PowerShell Abuse | — | PowerShell Logs (Event ID 4104) |

---

## Key Technical Decisions

**Swap Memory Configuration:** AWS t2.micro instances require swap for Suricata container stability (2GB swap allocated).

**Host Networking for ModSecurity:** OWASP CRS requires `--network host` to properly proxy to backend applications.

**Log Centralization:** All detection sources export to JSON and centralize on the Linux victim before Splunk ingestion.

**JSON Over Syslog:** Structured logging enables easier field extraction, parsing, and dashboard creation in Splunk.

**Attack Realism:** Slow, deliberate attacks with 1–3 second delays generate cleaner detections than rapid-fire exploits.

---

## Design Philosophy

**Multi-layer detection over single-tool depth.** Real SOC environments correlate signals across network, application, host, and authentication layers — this lab demonstrates that architectural thinking.

**Realistic over dramatic.** Attacks are slow and deliberate, generating high-quality detections that mirror actual threat behavior rather than exploit demos.

**Dashboard usability over aesthetics.** Visualizations answer analyst questions ("What happened? When? From where?") rather than displaying vanity metrics.

**Signal quality over volume.** 121 web attacks with diverse rule triggers > 10,000 identical SQLi attempts.

---

## What This Lab Does NOT Do

This lab intentionally avoids:

- **Malware detonation** — focuses on attack techniques, not file-based threats
- **Full EDR simulation** — uses native OS logging and open-source tools
- **Artificial correlation** — doesn't force contrived cross-platform attack chains
- **Over-automation** — manual configuration demonstrates genuine understanding
- **Production-grade hardening** — AWS security groups allow broad access for lab purposes only

---

## Repository Structure

```
AWS-atk-def-SIEM-main/
├── detection-pipelines/              # Setup & parsing scripts per detection layer
│   ├── pipeline1-modsecurity/        # ModSecurity WAF (start-pipeline.sh, capture-modsec-logs.sh)
│   ├── pipeline2-suricata/           # Suricata IDS (capture-suricata-logs.sh)
│   ├── pipeline3-auditd/             # Auditd host monitoring (parse-auditd-sudo.sh, soc-detection.rules)
│   ├── pipeline4-ssh-auth/           # SSH authentication (parse-ssh-auth.sh)
│   └── pipeline5-windows-sysmon/     # Windows endpoint (install-sysmon.ps1, enable-powershell-logging.ps1, export-windows-logs.ps1)
├── terraform-infra/                  # AWS infrastructure as code
│   ├── ec2.tf                        # VM definitions (Attacker, Linux Victim, Windows Victim)
│   ├── vpc.tf                        # VPC and subnet configuration
│   ├── security-groups.tf            # Firewall rules
│   ├── variables.tf                  # Input variables
│   ├── outputs.tf                    # Output values (IPs, etc.)
│   └── provider.tf                   # AWS provider configuration
├── dashboards/                       # Splunk visualizations & screenshots
│   ├── SOC_Overview.png              # SOC Master Console screenshot
│   ├── Web_Application_Security.png  # Web attack dashboard
│   ├── Network_Threats.png           # Suricata/network dashboard
│   ├── Windows_Endpoint.png          # Windows detection dashboard
│   ├── Linux_Endpoint.png            # Linux detection dashboard
│   ├── SOC MASTER CONSOLE.pdf        # Full master console export
│   └── Readme.md                     # Dashboard import instructions
├── .gitignore
└── README.md
```

---

## Project Status

- [x] AWS infrastructure (Terraform)
- [x] Linux detection stack (4 layers, 3,206 events)
- [x] Windows detection stack (3 layers, 2,157 events)
- [x] Attack generation (web, network, authentication, endpoint)
- [x] Log centralization (JSON format)
- [x] Splunk dashboards (5 domain-specific + 1 SOC master console)
- [x] Documentation complete

---

## Skills Demonstrated

**SIEM Engineering:** Log aggregation, normalization, correlation, and visualization across 7 sources  
**Windows Event Analysis:** Security Event Log, Sysmon, PowerShell Operational Log  
**Linux Security:** Auditd, SSH authentication analysis, system hardening  
**Network Security:** Suricata IDS, threat intelligence feeds (CINS, Spamhaus), traffic analysis  
**Web Application Security:** ModSecurity WAF, OWASP CRS, attack classification  
**Cloud Infrastructure:** AWS (VPC, EC2, Security Groups), Terraform (IaC)  
**Visualization:** Splunk SPL, Dashboard Studio, data-driven security storytelling

---

**Built for SOC analysts, security engineers, and blue team professionals.**

*Demonstrates practical detection engineering, not penetration testing.*
