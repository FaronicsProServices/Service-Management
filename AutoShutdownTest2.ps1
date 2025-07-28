# === Step 1: Configure your desired daily shutdown time ===
$hour = 9      # 24-hour format: 22 = 10 PM, 23 = 11 PM, 0 = Midnight
$minute = 30     # Always use numbers like 0, 15, 30, 45 etc.

# === Step 2: Write the shutdown script to a safe system location ===
$shutdownScript = @'
Add-Type -AssemblyName PresentationFramework
[System.Windows.MessageBox]::Show("Your computer will shut down in 2 minutes. Please save your work.", "Shutdown Warning", 'OK', 'Warning')
Start-Sleep -Seconds 120
Stop-Computer -Force
'@

$scriptPath = "$env:ProgramData\WarnThenShutdown.ps1"
$shutdownScript | Out-File -FilePath $scriptPath -Encoding UTF8 -Force

# === Step 3: Create the scheduled task ===
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""

$trigger = New-ScheduledTaskTrigger -Daily -At ([datetime]::Today.AddHours($hour).AddMinutes($minute))

$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

$formattedTime = "{0}:{1:D2}" -f $hour, $minute

Register-ScheduledTask -TaskName "WarnThenShutdownDaily" `
    -Action $action `
    -Trigger $trigger `
    -Principal $principal `
    -Description "Shows a 2-minute warning and shuts down the PC every day at $formattedTime." `
    -Force

Write-Host "Daily shutdown task created for $formattedTime (24-hour clock)."
