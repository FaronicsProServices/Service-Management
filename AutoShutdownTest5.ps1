#region Parameters
$MessageTitle = "⚠️ Shutdown Warning"
$MessageText = "🚨 Your computer will shut down in 2 minutes. Please save your work now!"
$SleepMinutes = 2
$taskName = "Shutdown Computer"
$description = "Shows shutdown warning and shuts down the computer daily at 11:00PM"
$scriptPath = "$env:ProgramData\ShutdownScript\DailyShutdownWithWarning.ps1"
#endregion

# Ensure target folder exists
New-Item -ItemType Directory -Path (Split-Path $scriptPath) -Force | Out-Null

# Copy this script to the permanent path if not already there
if (-not (Test-Path $scriptPath)) {
    # Self-copy current script to $scriptPath
    $currentScript = $MyInvocation.MyCommand.Path
    Copy-Item -Path $currentScript -Destination $scriptPath -Force
}

# Run shutdown warning popup in current user session
try {
    # Get active user session ID (for GUI message)
    $sessionId = (Get-Process -IncludeUserName | Where-Object { $_.MainWindowHandle -ne 0 -and $_.UserName -like "*\*" } | Select-Object -First 1).SessionId
    if ($sessionId -ne $null) {
        $code = {
            Add-Type -AssemblyName System.Windows.Forms
            [System.Windows.Forms.MessageBox]::Show($using:MessageText, $using:MessageTitle, [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        }
        Start-Process -FilePath "powershell.exe" -ArgumentList "-WindowStyle Hidden -ExecutionPolicy Bypass -Command & {$(& $using:code)}" -NoNewWindow -Wait -WorkingDirectory "$env:TEMP" -Verb RunAs -WindowStyle Hidden
    }
} catch {
    Write-EventLog -LogName Application -Source PowerShell -EntryType Warning -EventId 1000 -Message "Failed to show warning message: $_"
}

# Sleep for configured minutes before shutdown
Start-Sleep -Seconds ($SleepMinutes * 60)

# Perform shutdown
Stop-Computer -Force

# Create the scheduled task (if not already exists)
if (-not (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue)) {
    $taskAction = New-ScheduledTaskAction `
        -Execute 'powershell.exe' `
        -Argument "-ExecutionPolicy Bypass -File `"$scriptPath`""

    $taskTrigger = New-ScheduledTaskTrigger -Daily -At 11:00PM

    Register-ScheduledTask `
        -TaskName $taskName `
        -Action $taskAction `
        -Trigger $taskTrigger `
        -Description $description `
        -User "SYSTEM" `
        -RunLevel Highest `
        -Force
}
