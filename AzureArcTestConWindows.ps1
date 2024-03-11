# List of Azure Arc endpoints to check

$endpoints = @(
    "management.azure.com", # Azure Resource Manager
    "login.microsoftonline.com", # Azure Active Directory
    "dc.services.visualstudio.com", # Application Insights
    # Add more endpoints as needed
    "aka.ms",
    "download.microsoft.com",
    "packages.microsoft.com",
    "login.windows.net",
    "login.microsoftonline.com",
    "pas.windows.net",
    "management.azure.com",
    "guestnotificationservice.azure.com"
)

# Port for connection test (443 is the default port for HTTPS)
$port = 443

# Check each endpoint
foreach ($endpoint in $endpoints) {
    Write-Host "Testing connection to: $($endpoint):$port"
    # Attempt a TCP handshake using the Test-NetConnection cmdlet
    $result = Test-NetConnection -ComputerName $endpoint -Port $port

    if ($result.TcpTestSucceeded) {
        Write-Host -ForegroundColor Green "Successful connection to $endpoint"
    } else {
        Write-Host -ForegroundColor Red "Failed to connect to $endpoint"
    }
    # Adds a blank line for separation
    Write-Host
}

Write-Host "Connectivity test completed."
