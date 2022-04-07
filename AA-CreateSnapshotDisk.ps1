# Automation Account - Create Snapshot Disk

$connectionName = "AzureRunAsConnection"
$servicePrincipalConnection=Get-AutomationConnection -Name $connectionName
Add-AzureRmAccount `
-ServicePrincipal `
-TenantId $servicePrincipalConnection.TenantId `
-ApplicationId $servicePrincipalConnection.ApplicationId `
-CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint
#$disks=Get-AzureRmDisk | Select Name,Tags,Id,Location,ResourceGroupName; 
$disksh =@("DATADISK_1", "DATADISK_2", "DATADISK_3")
$disksp =@("DATADISK_1", "DATADISK_2", "DATADISK_3")
#$disk=Get-AzureRmDisk -ResourceGroupName 'RG_ONE' -DiskName 'DATA_DISK_NAME'

foreach ($disco in $Disksh) {
    $disk=Get-AzureRmDisk -ResourceGroupName 'RG_NAME_A' -DiskName $disco
    $snapshotconfig = New-AzureRmSnapshotConfig -SourceUri $disk.Id -CreateOption Copy -Location $disk.Location -AccountType Standard_LRS;$SnapshotName=$disk.Name+(Get-Date -Format "yyyy-MM-dd");New-AzureRmSnapshot -Snapshot $snapshotconfig -SnapshotName $SnapshotName -ResourceGroupName $disk.ResourceGroupName
}

foreach ($disco in $Disksp) {
    $disk=Get-AzureRmDisk -ResourceGroupName 'RG_NAME_B' -DiskName $disco
    $snapshotconfig = New-AzureRmSnapshotConfig -SourceUri $disk.Id -CreateOption Copy -Location $disk.Location -AccountType Standard_LRS;$SnapshotName=$disk.Name+(Get-Date -Format "yyyy-MM-dd");New-AzureRmSnapshot -Snapshot $snapshotconfig -SnapshotName $SnapshotName -ResourceGroupName $disk.ResourceGroupName
}
