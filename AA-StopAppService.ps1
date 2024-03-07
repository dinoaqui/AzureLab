Param(
    # The name of the resource group that contains the App Service
    [parameter(Mandatory=$true)]
    [string]$ResourceGroupName,

    # The name of the App Service you want to stop
    [parameter(Mandatory=$true)]
    [string]$AppServiceName
)

# Stop the App Service using the provided Resource Group Name and App Service Name
Stop-AzWebApp -ResourceGroupName $ResourceGroupName -Name $AppServiceName

# Output a confirmation message
Write-Output "App Service $AppServiceName has been stopped."
