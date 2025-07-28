# Requires PowerShell 5.1+
# Make sure this is saved in UTF-8 encoding

# Load necessary module
Import-Module ScheduledTasks

# Shutdown time (24-hour format)
$ShutdownHour = 12
$ShutdownMinute = 35

# How many minutes before shutdown should the warning appear?
$WarningMinutesBefore = 20

# Task names
$WarningTaskName = "ShutdownWarning"
$ShutdownTaskName = "ScheduledShutdown"

# Current date and time
$now = Get-Date

# Calculate full shutdown datetime today or tomorrow
$shutdownTime = (Get-Date -Hour $ShutdownHour -Minute $ShutdownMinute -Second 0)
if ($shutdownTime -lt $now) {
    $shutdownTime = $shutdownTime.AddDays(1)
}

# Calculate warning time
$warningTime = $shutdownTime.AddMinutes(-$WarningMinutesBefore)

# Format times
$shutdownTimeStr = $shutdownTime.ToString("HH:mm")
$warningTimeStr = $warningTime.ToString("HH:mm")

Write-Host "⚠️ Warning will trigger at: $warningTimeStr"
Write-Host "⏹️ Shutdown will occur at: $shutdownTimeStr"

# --- Create Scheduled Task Actions ---

# 1. Warning message using msg.exe (visible to logged-in user)
$warningAction = New-ScheduledTaskAction -Execute "msg.exe" -Argument "* /TIME:60 Your PC will shut down in $WarningMinutesBefore minutes!"

# 2. Shutdown action
$shutdownAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-Command `"Stop-Computer -Force`""

# --- Create Scheduled Task Triggers ---

# Warning trigger
$warningTrigger = New-ScheduledTaskTrigger -Once -At $warningTime

# Shutdown trigger
$shutdownTrigger = New-ScheduledTaskTrigger -Once -At $shutdownTime

# --- Set run level and principal (SYSTEM) ---
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

# --- Register Tasks ---

# 1. Register Warning Task
try {
    Register-ScheduledTask -TaskName $WarningTaskName -Action $warningAction -Trigger $warningTrigger -Principal $principal -Force
    Write-Host "✅ Scheduled task '$WarningTaskName' created successfully."
} catch {
    Write-Host "❌ Failed to create '$WarningTaskName': $_"
}

# 2. Register Shutdown Task
try {
    Register-ScheduledTask -TaskName $ShutdownTaskName -Action $shutdownAction -Trigger $shutdownTrigger -Principal $principal -Force
    Write-Host "✅ Scheduled task '$ShutdownTaskName' created successfully."
} catch {
    Write-Host "❌ Failed to create '$ShutdownTaskName': $_"
}
