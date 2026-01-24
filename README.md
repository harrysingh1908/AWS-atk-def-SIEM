# SIEM Lab Infrastructure

Cloud-based Security Operations Center (SOC) lab on AWS for developing threat detection capabilities across network, host, and application layers.

## Infrastructure Overview

**Platform:** AWS (free-tier eligible)  
**Deployment:** Terraform  
**Systems:**
- Attacker: Ubuntu Linux (10.0.1.203)
- Victim: Amazon Linux 2 (10.0.1.84)

## Getting Started

### Prerequisites
- AWS account with free-tier access
- Terraform installed locally

### Deployment
```bash
# Configure
# Update terraform.tfvars with your key pair name

# Deploy
terraform init
terraform apply
```

## Detection Pipelines

### Pipeline 1: ModSecurity WAF (Active)

**Purpose:** Application-layer attack detection (SQLi, XSS, path traversal)

**Setup on victim machine:**
```bash
# Clone repo
git clone <your-repo-url>
cd siem-lab/detection-pipelines/pipeline1-modsecurity

# Start containers
./start-pipeline.sh

# Start log capture
./capture-modsec-logs.sh &
```

**Test from attacker machine:**
```bash
curl "http://10.0.1.84:8080/rest/products/search?q=apple'--"
```

**Log output:** Structured JSON in `~/soc-lab/logs/modsec/detections.json`

### Pipeline 2: Suricata IDS (Planned)
Network-layer detection for scans, brute-force, protocol abuse

### Pipeline 3: Host-based Detection (Planned)
System logs, authentication telemetry, process monitoring

## Project Status

- [x] AWS infrastructure deployment
- [x] Pipeline 1: ModSecurity application-layer detection
- [ ] Pipeline 2: Suricata network-layer detection
- [ ] Centralized log aggregation (Elasticsearch)
- [ ] SOC dashboard (Kibana)

## Key Principle

Detection diversity comes from **log source variety**, not attack volume. This lab prioritizes building multiple detection layers that produce unique, correlatable telemetry.
```

---

## FILES TO ADD TO GITHUB
```
siem-lab/
├── README.md                          (UPDATED above)
├── .gitignore                         (UPDATED above)
├── terraform/
│   └── (existing files)
└── detection-pipelines/
    └── pipeline1-modsecurity/
        ├── start-pipeline.sh          (NEW - see below)
        └── capture-modsec-logs.sh     (NEW - your working script)
