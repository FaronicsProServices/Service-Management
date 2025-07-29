# Requires PowerShell 5.1+
# Save this file in UTF-8 encoding (important for msg.exe text)

# Load ScheduledTasks module
Import-Module ScheduledTasks

# Configuration
$ShutdownHour = 06           # Specify the hour for shutdown (24-hour format)
$ShutdownMinute = 05    # Specify the minute for shutdown
$WarningMinutesBefore = 20   # Show warning 20 mins before shutdown, this can be adjusted.

# Calculate Warning Time
$warningHour = $ShutdownHour
$warningMinute = $ShutdownMinute - $WarningMinutesBefore
if ($warningMinute -lt 0) {
    $warningHour--
    $warningMinute = 60 + $warningMinute
    if ($warningHour -lt 0) { $warningHour = 23 }
}

# Convert to formatted times
$shutdownTimeStr = "{0:D2}:{1:D2}" -f $ShutdownHour, $ShutdownMinute
$warningTimeStr  = "{0:D2}:{1:D2}" -f $warningHour, $warningMinute

Write-Host "⚠️  Warning will trigger daily at: $warningTimeStr"
Write-Host "⏹️  Shutdown will occur daily at: $shutdownTimeStr"

# Task Names
$WarningTaskName = "ShutdownWarning"
$ShutdownTaskName = "ScheduledShutdown"

# --- Scheduled Task Actions ---
$warningAction = New-ScheduledTaskAction -Execute "msg.exe" -Argument "* /TIME:60 Your PC will shut down in $WarningMinutesBefore minutes!, please save your work immediately."
$shutdownAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-Command `"Stop-Computer -Force`""

# --- Triggers (Daily) ---
$warningTrigger = New-ScheduledTaskTrigger -Daily -At "$warningTimeStr"
$shutdownTrigger = New-ScheduledTaskTrigger -Daily -At "$shutdownTimeStr"

# --- Run As SYSTEM ---
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

# --- Register Warning Task ---
try {
    Register-ScheduledTask -TaskName $WarningTaskName -Action $warningAction -Trigger $warningTrigger -Principal $principal -Force
    Write-Host "✅ Scheduled task '$WarningTaskName' created successfully."
} catch {
    Write-Host "❌ Failed to create '$WarningTaskName': $_"
}

# --- Register Shutdown Task ---
try {
    Register-ScheduledTask -TaskName $ShutdownTaskName -Action $shutdownAction -Trigger $shutdownTrigger -Principal $principal -Force
    Write-Host "✅ Scheduled task '$ShutdownTaskName' created successfully."
} catch {
    Write-Host "❌ Failed to create '$ShutdownTaskName': $_"
}
