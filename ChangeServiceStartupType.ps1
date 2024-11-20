# Sets the startup type of the specified service. 
# StartupType can be 'Automatic' (service starts automatically with Windows), 
# 'Manual' (service must be started manually), or 'Disabled' (service cannot be started).
Set-Service -Name "servicename" -StartupType 'Type'
