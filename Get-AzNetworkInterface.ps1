#
#### Script in developing - Be Carefull to Execute #####
#
#### Export NIC Name with Private IP and DNS Configuration
#
# TenantID
# SubscriptionID

# Install Excel Modules
Install-Module -Name ImportExcel -RequiredVersion 7.5.3 -Force -Verbose 
Import-Module ImportExcel 

class nics {
    [string]$NicName
    [string]$VMNAME
    [string]$ResourceGroupName
    [string]$Location
    [string]$IpConfigurations 
    [string]$DNS
}

$nicsList = New-Object Collections.Generic.List[nics]
$nicid = (Get-AzNetworkInterface).id

foreach ( $nicsid in $nicid){
    $nics = [nics]::new()
    $nics.NicName = (Get-AzNetworkInterface  -ResourceId $nicsid).Name
    $nics.VMNAME = (Get-AzNetworkInterface  -ResourceId $nicsid).VirtualMachine.id
    $nics.ResourceGroupName = (Get-AzNetworkInterface  -ResourceId $nicsid).ResourceGroupName
    $nics.Location = (Get-AzNetworkInterface  -ResourceId $nicsid).Location
    $nics.IpConfigurations = (Get-AzNetworkInterface  -ResourceId $nicsid).IpConfigurations.PrivateIpAddress
    $nics.DNS = (Get-AzNetworkInterface -ResourceId $nicsid).DnsSettings.DnsServers
    $nicsList.add($nics)
}
# Export Excel and CSV
$nicsList | Export-Excel -Path .\nics.xlsx -WorksheetName 'NICS' -AutoSize -TableStyle 'Light9' -FreezeTopRow -Append
$nicsList | Export-Csv nics.csv
