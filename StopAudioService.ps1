# Stops Audio Service
# Define the service name
$serviceName = "Audiosrv"

# Stop the service
Write-Host "Stopping Windows Audio Service..."
Stop-Service -Name $serviceName -Force

Write-Host "Windows Audio Service has been stopped."
