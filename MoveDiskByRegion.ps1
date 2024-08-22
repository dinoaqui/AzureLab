# Optional
# Set-AzContext -Subscription "xxxx-xxxx-xxxx-xxxx"

# Name of the managed disk you are starting with
$sourceDiskName = "DiskName_DataDisk_0" # This disk is located in the Brazil Southeast region

# Name of the resource group where the source disk resides
$sourceRG = "RG_ResourceGroupName"

# Name you want the destination disk to have - Destination region is Brazil South
$targetDiskName = "DiskName_DataDisk_0_BrazilSouth"

# Name of the resource group where the destination disk will be created
$targetRG = "RG_ResourceGroupName"

# Azure region where the destination disk will be created
$targetLocate = "brazilsouth"

# Gather properties of the source disk
$sourceDisk = Get-AzDisk -ResourceGroupName $sourceRG -DiskName $sourceDiskName

# Configure the destination disk, adding the size with the 512 offset, and the -Upload flag
# If this is an OS disk, add this property: -OsType $sourceDisk.OsType
# Additionally, add the VM generation and security type if necessary
#   -SkuName 'Standard_LRS' `
$targetDiskConfig = New-AzDiskConfig `
    -SkuName 'Premium_LRS' `  # Configure the disk to use Premium SSD LRS
    -Location $targetLocate `
    -CreateOption 'Upload' `
    -UploadSizeInBytes $($sourceDisk.DiskSizeBytes + 512) `  # Add 512 bytes for alignment
    -OsType $sourceDisk.OsType `  # Specify the OS type if it's an OS disk
    -HyperVGeneration $sourceDisk.HyperVGeneration  # Preserve the VM generation

# Add the security profile if it exists on the source disk
if ($sourceDisk.SecurityProfile) {
    $targetDiskConfig.SecurityProfile = $sourceDisk.SecurityProfile
}

# Create the destination disk (empty)
$targetDisk = New-AzDisk -ResourceGroupName $targetRG -DiskName $targetDiskName -Disk $targetDiskConfig

# Get a SAS token for the source disk, so that AzCopy can read it
$sourceDiskSas = Grant-AzDiskAccess -ResourceGroupName $sourceRG -DiskName $sourceDiskName -DurationInSecond 86400 -Access 'Read'

# Get a SAS token for the destination disk, so that AzCopy can write to it
$targetDiskSas = Grant-AzDiskAccess -ResourceGroupName $targetRG -DiskName $targetDiskName -DurationInSecond 86400 -Access 'Write'

# Start the copy using AzCopy
azcopy copy $sourceDiskSas.AccessSAS $targetDiskSas.AccessSAS --blob-type PageBlob

# Revoke the SAS so that the disk can be used by a VM
Revoke-AzDiskAccess -ResourceGroupName $sourceRG -DiskName $sourceDiskName
Revoke-AzDiskAccess -ResourceGroupName $targetRG -DiskName $targetDiskName
