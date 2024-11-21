# Run a background job to get the status of a specific service, wait for it to complete, and retrieve the output
$job = Start-Job -ScriptBlock { Get-Service -Name servicename }
Wait-Job $job
Receive-Job $job

# Run a background job to get the status of the "WinDefend" service, wait for it to complete, and retrieve the output
# $job = Start-Job -ScriptBlock { Get-Service -Name WinDefend }; Wait-Job $job; Receive-Job $job

