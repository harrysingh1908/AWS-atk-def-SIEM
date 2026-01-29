# Enable PowerShell Script Block Logging
# Run as Administrator

Write-Host "[+] Enabling PowerShell Script Block Logging..." -ForegroundColor Green

New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" -Name "EnableScriptBlockLogging" -Value 1

Write-Host "[+] PowerShell logging enabled!" -ForegroundColor Green
Write-Host "    Script blocks will be logged to: Windows Logs > PowerShell > Operational (Event ID 4104)" -ForegroundColor Yellow
