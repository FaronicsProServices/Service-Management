# === Step 1: Configure your desired daily shutdown time ===
$hour = 22      # 24-hour format: 22 = 10 PM, 23 = 11 PM, 0 = Midnight
$minute = 00    # Set the minute (e.g., 0, 15, 30, etc.)

# === Step 2: Write the shutdown script to a safe system location ===
$shutdownScript = @'
Add-Type -AssemblyName PresentationFramework
[System.Windows.MessageBox]::Show("⚠️ Your computer will shut down in 2 minutes. Please save your work.", "Shutdown Warning", 'OK', 'Warning')
Start-Sleep -Seconds 120
Stop-Computer -Force
'@

$scriptPath = "$env:ProgramData\WarnThenShutdown.ps1"
$shutdownScript | Out-File -FilePath $scriptPath -Encoding UTF8 -Force

# === Step 3: Create a daily recurring scheduled task ===
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""

$trigger = New-ScheduledTaskTrigger -Daily -At ([datetime]::Today.AddHours($hour).AddMinutes($minute))

$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

Register-ScheduledTask -TaskName "WarnThenShutdownDaily" `
    -Action $action `
    -Trigger $trigger `
    -Principal $principal `
    -Description "Shows a 2-minute warning and shuts down the PC every day at ${hour}:${minute}." `
    -Force

Write-Host "✅ Daily shutdown task created for ${hour}:${minute} (24-hour clock)."
