#region Parameters
$MessageTitle = "⚠️ Shutdown Warning"
$MessageText = "🚨 Your computer will shut down in 2 minutes. Please save your work now!"
$SleepMinutes = 2
$TaskName = "DailyShutdownWithWarning"
#endregion

# Log file for debugging
$log = "$env:ProgramData\ShutdownWarning.log"
"[$(Get-Date)] Script started" | Out-File -Append $log

# Check if running from Scheduled Task; if not, create one
if (-not $env:RUN_FROM_TASK) {
    $taskExists = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue

    if (-not $taskExists) {
        $scriptPath = "$env:ProgramData\DailyShutdownScript.ps1"
        Copy-Item -Path $PSCommandPath -Destination $scriptPath -Force

        $action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -Command `"`$env:RUN_FROM_TASK=1; & '$scriptPath'`""
        $trigger = New-ScheduledTaskTrigger -Daily -At 6:00PM  # Change time here if needed
        $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest
        Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Principal $principal

        "[$(Get-Date)] Scheduled task '$TaskName' created to run daily at 6:00PM." | Out-File -Append $log
    } else {
        "[$(Get-Date)] Scheduled task '$TaskName' already exists." | Out-File -Append $log
    }

    exit
}

# Show warning popup
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.MessageBox]::Show($MessageText, $MessageTitle, [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)

"[$(Get-Date)] Warning displayed, sleeping $SleepMinutes minute(s)..." | Out-File -Append $log
Start-Sleep -Seconds ($SleepMinutes * 60)

"[$(Get-Date)] Shutting down..." | Out-File -Append $log
Stop-Computer -Force
