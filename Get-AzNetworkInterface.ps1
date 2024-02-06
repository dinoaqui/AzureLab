#
#### Script in developing - Be Carefull to Execute #####
#
# This script provides a structured approach to gather and document Azure network interface configurations, 
# which can be particularly useful for audits, documentation, or troubleshooting in cloud environments


# Install and Import the ImportExcel module for Excel operations
Install-Module -Name ImportExcel -RequiredVersion 7.5.3 -Force -Verbose 
Import-Module ImportExcel 

# Define a class for network interface card (NIC) properties
class nics {
    [string]$NicName
    [string]$VMNAME
    [string]$ResourceGroupName
    [string]$Location
    [string]$IpConfigurations 
    [string]$DNS
}

# Initialize a list to hold NIC objects
$nicsList = New-Object Collections.Generic.List[nics]

# Retrieve all NIC IDs in the current Azure subscription
$nicid = (Get-AzNetworkInterface).id

# Iterate over each NIC ID to collect detailed information
foreach ($nicsid in $nicid){
    $nics = [nics]::new()
    $nics.NicName = (Get-AzNetworkInterface -ResourceId $nicsid).Name
    $nics.VMNAME = (Get-AzNetworkInterface -ResourceId $nicsid).VirtualMachine.id
    $nics.ResourceGroupName = (Get-AzNetworkInterface -ResourceId $nicsid).ResourceGroupName
    $nics.Location = (Get-AzNetworkInterface -ResourceId $nicsid).Location
    $nics.IpConfigurations = (Get-AzNetworkInterface -ResourceId $nicsid).IpConfigurations.PrivateIpAddress
    $nics.DNS = (Get-AzNetworkInterface -ResourceId $nicsid).DnsSettings.DnsServers
    $nicsList.add($nics)
}

# Export the collected NIC information to an Excel file and a CSV file
$nicsList | Export-Excel -Path .\nics.xlsx -WorksheetName 'NICS' -AutoSize -TableStyle 'Light9' -FreezeTopRow -Append
$nicsList | Export-Csv -Path nics.csv -NoTypeInformation
