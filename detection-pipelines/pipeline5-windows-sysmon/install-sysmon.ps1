# Sysmon Installation Script for SOC Lab
# Run as Administrator in PowerShell

Write-Host "[+] Installing Sysmon with SwiftOnSecurity Config..." -ForegroundColor Green

# Create tools directory
New-Item -Path "C:\Tools" -ItemType Directory -Force | Out-Null
Set-Location "C:\Tools"

# Download Sysmon
Write-Host "  - Downloading Sysmon..." -ForegroundColor Cyan
Invoke-WebRequest -Uri "https://download.sysinternals.com/files/Sysmon.zip" -OutFile "Sysmon.zip"

# Download SwiftOnSecurity config
Write-Host "  - Downloading SwiftOnSecurity Config..." -ForegroundColor Cyan
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml" -OutFile "sysmonconfig.xml"

# Extract and install
Write-Host "  - Extracting and installing..." -ForegroundColor Cyan
Expand-Archive "Sysmon.zip" -DestinationPath "Sysmon" -Force
Set-Location "Sysmon"
.\Sysmon64.exe -accepteula -i ..\sysmonconfig.xml

# Verify service
Write-Host "  - Verifying installation..." -ForegroundColor Cyan
Get-Service Sysmon64

Write-Host "[+] Sysmon installed successfully!" -ForegroundColor Green
Write-Host "    Event logs available at: Applications and Services Logs > Sysmon > Operational" -ForegroundColor Yellow
