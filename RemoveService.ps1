# Deletes the specified service from the system. Ensure the service is non-essential to avoid any system impact.
# Example: Deleting the 'wuauserv' service (Windows Update service) would cause issues, so use a non-critical service like 'XblGameSave' for deletion.
# sc.exe delete "XblGameSave"

sc.exe delete "servicename"
