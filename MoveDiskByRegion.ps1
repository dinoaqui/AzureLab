# Optional
# Set-AzContext -Subscription "XXXXXXXXXXXXXXXXXXXXXX"

# Name of the managed disk you are starting with
$sourceDiskName1 = "DiskName_Source" # This disk is located in the Brazil Southeast region

# Name of the resource group where the source disk resides
$sourceRG1 = "RG_NameSource"

# Name you want the destination disk to have - Destination region is Brazil South
$targetDiskName1 = "DiskName_Destination"

# Name of the resource group where the destination disk will be created
$targetRG1 = "RG_NameDestination"

# Azure region where the destination disk will be created
$targetLocate1 = "DestinationRegion"

# Gather properties of the source disk
$sourceDisk1 = Get-AzDisk -ResourceGroupName $sourceRG1 -DiskName $sourceDiskName1

# Configure the destination disk, adding the size with the 512 offset, and the -Upload flag
# If this is an OS disk, add this property: -OsType $sourceDisk.OsType
# Additionally, add the VM generation and security type if necessary
#   -SkuName 'Standard_LRS' `
$targetDiskConfig1 = New-AzDiskConfig `
    -SkuName 'Standard_LRS' `
    -Location $targetLocate1 `
    -CreateOption 'Upload' `
    -UploadSizeInBytes ($sourceDisk1.DiskSizeBytes + 512) `
    -OsType $sourceDisk1.OsType `
    -HyperVGeneration $sourceDisk1.HyperVGeneration

# Add the security profile if it exists on the source disk
if ($sourceDisk1.SecurityProfile) {
    $targetDiskConfig1.SecurityProfile = $sourceDisk1.SecurityProfile
}

# Create the destination disk (empty)
$targetDisk1 = New-AzDisk -ResourceGroupName $targetRG1 -DiskName $targetDiskName1 -Disk $targetDiskConfig1

# Get a SAS token for the source disk, so that AzCopy can read it
$sourceDiskSas1 = Grant-AzDiskAccess -ResourceGroupName $sourceRG1 -DiskName $sourceDiskName1 -DurationInSecond 86400 -Access 'Read'

# Get a SAS token for the destination disk, so that AzCopy can write to it
$targetDiskSas1 = Grant-AzDiskAccess -ResourceGroupName $targetRG1 -DiskName $targetDiskName1 -DurationInSecond 86400 -Access 'Write'

# Start the copy using AzCopy
./azcopy.exe copy $sourceDiskSas1.AccessSAS $targetDiskSas1.AccessSAS --blob-type PageBlob

# Revoke the SAS so that the disk can be used by a VM
Revoke-AzDiskAccess -ResourceGroupName $sourceRG1 -DiskName $sourceDiskName1
Revoke-AzDiskAccess -ResourceGroupName $targetRG1 -DiskName $targetDiskName1
