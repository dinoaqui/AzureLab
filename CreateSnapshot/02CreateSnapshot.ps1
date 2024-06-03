# Parameter input: Path to the CSV file with the list of VMs and disks, Subscription ID, and Location
# Usage: .\02CreateSnapshot.ps1 -CsvPath "./VMsAndDisks.csv" -SubscriptionId "YourSubscriptionID" -Location "YourRegion"

param (
    [string]$CsvPath,
    [string]$SubscriptionId,
    [string]$Location,
    [string]$SnapshotResourceGroup = "RG_Snapshots"
)

# Authenticate to Azure
Connect-AzAccount

# Set the current subscription
Set-AzContext -SubscriptionId $SubscriptionId

# Read the list of VMs and disks from the CSV file
$vmList = Import-Csv -Path $CsvPath

foreach ($vm in $vmList) {
    # Create snapshot of the OS disk
    $osDiskSnapshotConfig = New-AzSnapshotConfig -SourceUri "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Compute/disks/$($vm.OSDiskName)" -Location $Location -CreateOption Copy
    New-AzSnapshot -ResourceGroupName $SnapshotResourceGroup -SnapshotName "$($vm.VMName)-OSDiskSnapshot" -Snapshot $osDiskSnapshotConfig

    # Create snapshots of the data disks
    $dataDisks = $vm.DataDisks -split ", "
    foreach ($dataDisk in $dataDisks) {
        $dataDiskSnapshotConfig = New-AzSnapshotConfig -SourceUri "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Compute/disks/$dataDisk" -Location $Location -CreateOption Copy
        New-AzSnapshot -ResourceGroupName $SnapshotResourceGroup -SnapshotName "$($vm.VMName)-$dataDisk-Snapshot" -Snapshot $dataDiskSnapshotConfig
    }
}
