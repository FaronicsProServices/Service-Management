# === Section 1: Parameters for the Warning and Intended Shutdown Time ===

$IntendedShutdownHour = 00    # Shutdown time hour (24-hour format)
$IntendedShutdownMinute = 47  # Shutdown time minute

$WarningOffsetMinutes = 20

# Message details
$MessageTitle = "System Shutdown Warning!"
$MessageText = "⚠️ Your computer is scheduled for an important action in approximately 20 minutes. Please save your work immediately."

# Task names and descriptions
$WarningTaskName = "ShutdownWarning"
$ShutdownTaskName = "ScheduledShutdown"
$WarningDescription = "Displays a pop-up warning 20 minutes before the designated shutdown time."
$ShutdownDescription = "Automatically shuts down the computer at the specified time."

# === Section 2: Calculate Warning Trigger Time ===

$ShutdownTime = [datetime]::Today.AddHours($IntendedShutdownHour).AddMinutes($IntendedShutdownMinute)
$WarningTime = $ShutdownTime.AddMinutes(-$WarningOffsetMinutes)

$TriggerWarningHour = $WarningTime.Hour
$TriggerWarningMinute = $WarningTime.Minute

Write-Host "🔔 Warning will trigger at: $($TriggerWarningHour):$($TriggerWarningMinute)"
Write-Host "💣 Shutdown will occur at: $($IntendedShutdownHour):$($IntendedShutdownMinute)"

# === Section 3: Create the Warning Pop-up Script ===

$escapedMessageText = $MessageText -replace '"', '`"'
$escapedMessageTitle = $MessageTitle -replace '"', '`"'

$warningScriptContent = @"
try {
    Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
    [System.Windows.Forms.MessageBox]::Show("$escapedMessageText", "$escapedMessageTitle", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
    Write-Host "✅ Warning pop-up displayed."
} catch {
    Write-Warning "❌ Failed to load UI or show message: \$($_.Exception.Message)"
}
"@

$warningScriptPath = "$env:TEMP\$WarningTaskName-Action.ps1"
$warningScriptContent | Out-File -FilePath $warningScriptPath -Encoding UTF8 -Force

# === Section 4: Create the Shutdown Script ===

$shutdownScriptContent = @"
Stop-Computer -Force
"@

$shutdownScriptPath = "$env:TEMP\$ShutdownTaskName-Action.ps1"
$shutdownScriptContent | Out-File -FilePath $shutdownScriptPath -Encoding UTF8 -Force

# === Section 5: Create and Register the Scheduled Tasks ===

# --- Create Warning Task ---
try {
    $warningAction = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$warningScriptPath`""
    $warningTrigger = New-ScheduledTaskTrigger -Daily -At $WarningTime
    $warningPrincipal = New-ScheduledTaskPrincipal -UserId $env:UserName -LogonType Interactive -RunLevel Highest
    Register-ScheduledTask -TaskName $WarningTaskName -Action $warningAction -Trigger $warningTrigger -Principal $warningPrincipal -Description $WarningDescription -Settings (New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable) -Force
    Write-Host "✅ Scheduled task '$WarningTaskName' created successfully."
} catch {
    Write-Error "❌ Failed to register '$WarningTaskName': $_"
}

# --- Create Shutdown Task ---
try {
    $shutdownAction = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$shutdownScriptPath`""
    $shutdownTrigger = New-ScheduledTaskTrigger -Daily -At $ShutdownTime
    $shutdownPrincipal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
    Register-ScheduledTask -TaskName $ShutdownTaskName -Action $shutdownAction -Trigger $shutdownTrigger -Principal $shutdownPrincipal -Description $ShutdownDescription -Settings (New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable) -Force
    Write-Host "✅ Scheduled task '$ShutdownTaskName' created successfully."
} catch {
    Write-Error "❌ Failed to register '$ShutdownTaskName': $_"
}

# === Section 6: (REMOVED Immediate Pop-up) ===
# The warning message will now ONLY be shown by the scheduled task 20 minutes before shutdown.

# === Section 7: Optional Cleanup ===
# Remove temp script files if you want to clean them now. Comment out if debugging.
# Remove-Item $warningScriptPath, $shutdownScriptPath -Force -ErrorAction SilentlyContinue
