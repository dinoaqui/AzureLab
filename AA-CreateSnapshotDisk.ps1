$connectionName = "AzureRunAsConnection"
$servicePrincipalConnection=Get-AutomationConnection -Name $connectionName
Add-AzureRmAccount `
-ServicePrincipal `
-TenantId $servicePrincipalConnection.TenantId `
-ApplicationId $servicePrincipalConnection.ApplicationId `
-CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint
#$disks=Get-AzureRmDisk | Select Name,Tags,Id,Location,ResourceGroupName; 
$disksh =@("srv-spb-hmqs-_DataDisk__shared_0", "srv-spb-hmqs-01_OsDisk_1_7c79cc4705aa4a04bc310a6d2817759a", "srv-spb-hmqs-02_OsDisk_1_b5ce2b63976f41398629167aeb9f38a1")
$disksp =@("srv-spb-pmqs_DataDisk_shared", "srv-spb-pmqs-03_shared_disk", "srv-spb-pmqs-01_OsDisk_1_27cb90c704fd4677878f4c2f695c1f74", "srv-spb-pmqs-02_OsDisk_1_dd81b1234d604048ac776599f6acaf0f", "srv-spb-pmqs-03_OsDisk_1_9e9092579ec2452bac3d8d4d26bb8032", "srv-spb-pmqs-04_OsDisk_1_e319a38c5b214e3fabf86eabb622e2f6")
#$disk=Get-AzureRmDisk -ResourceGroupName 'RG_SPB' -DiskName 'srv-spb-pmqs-03_shared_disk'

foreach ($disco in $Disksh) {
    $disk=Get-AzureRmDisk -ResourceGroupName 'RG_SPB_HMG' -DiskName $disco
    $snapshotconfig = New-AzureRmSnapshotConfig -SourceUri $disk.Id -CreateOption Copy -Location $disk.Location -AccountType Standard_LRS;$SnapshotName=$disk.Name+(Get-Date -Format "yyyy-MM-dd");New-AzureRmSnapshot -Snapshot $snapshotconfig -SnapshotName $SnapshotName -ResourceGroupName $disk.ResourceGroupName
}

foreach ($disco in $Disksp) {
    $disk=Get-AzureRmDisk -ResourceGroupName 'RG_SPB' -DiskName $disco
    $snapshotconfig = New-AzureRmSnapshotConfig -SourceUri $disk.Id -CreateOption Copy -Location $disk.Location -AccountType Standard_LRS;$SnapshotName=$disk.Name+(Get-Date -Format "yyyy-MM-dd");New-AzureRmSnapshot -Snapshot $snapshotconfig -SnapshotName $SnapshotName -ResourceGroupName $disk.ResourceGroupName
}
