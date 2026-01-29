# Export Windows event logs to JSON format
# Run after attack generation

$LogDir = "C:\Tools\Logs"
New-Item -Path $LogDir -ItemType Directory -Force | Out-Null

Write-Host "[+] Exporting Windows event logs to JSON..." -ForegroundColor Green

# Export Sysmon events
Write-Host "  - Exporting Sysmon logs..." -ForegroundColor Cyan
$SysmonEvents = Get-WinEvent -LogName "Microsoft-Windows-Sysmon/Operational" -MaxEvents 1000 -ErrorAction SilentlyContinue | ForEach-Object {
    [PSCustomObject]@{
        TimeCreated = $_.TimeCreated.ToString("yyyy-MM-dd HH:mm:ss")
        EventID = $_.Id
        Level = $_.LevelDisplayName
        Message = $_.Message
        ProcessId = $_.ProcessId
        Computer = $_.MachineName
    }
}
$SysmonEvents | ConvertTo-Json -Depth 3 | Out-File "$LogDir\sysmon-events.json" -Encoding UTF8

# Export Security events
Write-Host "  - Exporting Security logs..." -ForegroundColor Cyan
$SecEvents = Get-WinEvent -FilterHashTable @{LogName='Security'; ID=4624,4625,4688} -MaxEvents 1000 -ErrorAction SilentlyContinue | ForEach-Object {
    [PSCustomObject]@{
        TimeCreated = $_.TimeCreated.ToString("yyyy-MM-dd HH:mm:ss")
        EventID = $_.Id
        Level = $_.LevelDisplayName
        Message = $_.Message
        Computer = $_.MachineName
    }
}
$SecEvents | ConvertTo-Json -Depth 3 | Out-File "$LogDir\security-events.json" -Encoding UTF8

# Export PowerShell events
Write-Host "  - Exporting PowerShell logs..." -ForegroundColor Cyan
$PSEvents = Get-WinEvent -LogName "Microsoft-Windows-PowerShell/Operational" -MaxEvents 1000 -ErrorAction SilentlyContinue | Where-Object {$_.Id -eq 4104} | ForEach-Object {
    [PSCustomObject]@{
        TimeCreated = $_.TimeCreated.ToString("yyyy-MM-dd HH:mm:ss")
        EventID = $_.Id
        Level = $_.LevelDisplayName
        ScriptBlock = $_.Properties[2].Value
        Computer = $_.MachineName
    }
}
$PSEvents | ConvertTo-Json -Depth 3 | Out-File "$LogDir\powershell-events.json" -Encoding UTF8

Write-Host "[+] Export complete!" -ForegroundColor Green
Write-Host "    Logs saved to: $LogDir" -ForegroundColor Yellow
Write-Host ""
Write-Host "Event counts:" -ForegroundColor Cyan
Write-Host "  Sysmon: $($SysmonEvents.Count) events" -ForegroundColor White
Write-Host "  Security: $($SecEvents.Count) events" -ForegroundColor White
Write-Host "  PowerShell: $($PSEvents.Count) events" -ForegroundColor White
