# Parameter input: Path to the CSV file with the list of VMs and disks, Subscription ID, and Location
# Usage: .\02CreateSnapshot.ps1 -CsvPath "./VMsAndDisks.csv"

param (
    [string]$CsvPath,
    # Type Subscription ID
    [string]$SubscriptionId = "0000-0000-0000-0000-000000",
    # Type Region
    [string]$Location = "eastus2",
    # Type RG_Destination
    [string]$SnapshotResourceGroup = "RG_Snapshot",
    # Type RG_Source
    [string]$ResourceGroupName = "RG_Source"
)

# Authenticate to Azure
# Connect-AzAccount

# Set the current subscription
Set-AzContext -SubscriptionId $SubscriptionId

# Read the list of VMs and disks from the CSV file
$vmList = Import-Csv -Path $CsvPath

foreach ($vm in $vmList) {
    # Log details about the OS disk snapshot creation
    Write-Output "Creating snapshot for OS disk: $($vm.OSDiskName) with source URI: /subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Compute/disks/$($vm.OSDiskName)"
    
    # Create snapshot of the OS disk
    $osDiskSnapshotConfig = New-AzSnapshotConfig -SourceUri "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Compute/disks/$($vm.OSDiskName)" -Location $Location -CreateOption Copy
    New-AzSnapshot -ResourceGroupName $SnapshotResourceGroup -SnapshotName "$($vm.VMName)-OSDiskSnapshot" -Snapshot $osDiskSnapshotConfig

    # Check and create snapshots of the data disks
    if ($vm.DataDisks) {
        $dataDisks = $vm.DataDisks -split ", "
        foreach ($dataDisk in $dataDisks) {
            # Log details about the data disk snapshot creation
            Write-Output "Creating snapshot for data disk: $dataDisk with source URI: /subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Compute/disks/$dataDisk"

            $dataDiskSnapshotConfig = New-AzSnapshotConfig -SourceUri "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Compute/disks/$dataDisk" -Location $Location -CreateOption Copy
            $dataSnapshot = New-AzSnapshot -ResourceGroupName $SnapshotResourceGroup -SnapshotName "$($vm.VMName)-$dataDisk-Snapshot" -Snapshot $dataDiskSnapshotConfig
            Write-Output "Snapshot created: $($dataSnapshot.Name) at $($dataSnapshot.TimeCreated)"
        }
    }
}

