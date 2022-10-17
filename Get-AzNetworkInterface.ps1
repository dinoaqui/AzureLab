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
$nicsList | Export-Csv nics.csv
