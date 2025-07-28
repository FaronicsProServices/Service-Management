# === Step 1: Set the scheduled time ===
$hour =   22    # e.g., 22 = 10 PM
$minute = 25

# === Step 2: Embedded script — warn, then wait 20 mins, then shutdown ===
$shutdownScript = @'
Add-Type -AssemblyName PresentationFramework
[System.Windows.MessageBox]::Show("Your computer will shut down in 20 minutes. Please save your work.", "Shutdown Warning", 'OK', 'Warning')
Start-Sleep -Seconds 1200  # 20 minutes = 1200 seconds
Stop-Computer -Force
'@

$scriptPath = "$env:ProgramData\WarnThenShutdown.ps1"
$shutdownScript | Out-File -FilePath $scriptPath -Encoding UTF8 -Force

# === Step 3: Schedule the task ===
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""
$trigger = New-ScheduledTaskTrigger -Daily -At ([datetime]::Today.AddHours($hour).AddMinutes($minute))
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

$formattedTime = "{0}:{1:D2}" -f $hour, $minute

Register-ScheduledTask -TaskName "WarnThenShutdownDaily" `
    -Action $action `
    -Trigger $trigger `
    -Principal $principal `
    -Description "Shows a warning, waits 20 minutes, then shuts down daily at $formattedTime." `
    -Force

Write-Host "Daily shutdown task created for $formattedTime. It will warn, wait 20 mins, then shutdown."
