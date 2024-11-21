# Restart Audio Service
# Define the service name
$serviceName = "Audiosrv"

# Stop the service
Write-Host "Stopping Windows Audio Service..."
Stop-Service -Name $serviceName -Force

# Wait for a moment before starting the service again
Start-Sleep -Seconds 3

# Start the service
Write-Host "Starting Windows Audio Service..."
Start-Service -Name $serviceName

Write-Host "Windows Audio Service has been restarted."
