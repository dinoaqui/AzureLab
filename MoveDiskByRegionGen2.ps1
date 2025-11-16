# ==========================================
# README
# This script copies an Azure managed OS disk
# to another region while preserving the
# original Hyper-V generation (V1 or V2).
# Requirement: azcopy.exe must be available
# in the PATH or current directory.
# ==========================================

# ==============================
# SOURCE DISK VARIABLES
# ==============================
$sourceDiskName = "VirtualMachineName_OsDisk_eus2"
$sourceRG       = "rg-workload-eus2"

# ==============================
# TARGET DISK VARIABLES
# ==============================
$targetDiskName = "VirtualMachineName_OsDisk_brs"
$targetRG       = "rg-workload-brs"
$targetLocation = "BrazilSouth"   # Azure region where the TARGET disk will be created

# ==============================
# GET SOURCE DISK INFORMATION
# ==============================
$sourceDisk = Get-AzDisk -ResourceGroupName $sourceRG -DiskName $sourceDiskName

# Optional: check the Hyper-V generation of the source disk (V1 or V2)
$sourceDisk.HyperVGeneration

# ==============================
# CREATE TARGET DISK CONFIGURATION
# ==============================
# For data disks, remove the parameter: -OsType $sourceDisk.OsType
$targetDiskconfig = New-AzDiskConfig `
    -SkuName 'Premium_LRS' `                                  # Storage SKU
    -UploadSizeInBytes $($sourceDisk.DiskSizeBytes + 512) `   # Upload size (disk size + small buffer)
    -OsType $sourceDisk.OsType `                              # OS type (Linux/Windows)
    -Location $targetLocation `                               # Target region
    -CreateOption 'Upload' `                                  # Disk will be populated via upload (AzCopy)
    -HyperVGeneration $sourceDisk.HyperVGeneration            # Keep the same Hyper-V generation (V1/V2) as the source

# Create the target managed disk (empty, waiting for upload)
$targetDisk = New-AzDisk -ResourceGroupName $targetRG -DiskName $targetDiskName -Disk $targetDiskconfig

# ==============================
# GENERATE SAS TOKENS (READ / WRITE)
# ==============================
# SAS token with READ access on the SOURCE disk
$sourceDiskSas = Grant-AzDiskAccess `
    -ResourceGroupName $sourceRG `
    -DiskName $sourceDiskName `
    -DurationInSecond 86400 `      # 24 hours
    -Access 'Read'

# SAS token with WRITE access on the TARGET disk
$targetDiskSas = Grant-AzDiskAccess `
    -ResourceGroupName $targetRG `
    -DiskName $targetDiskName `
    -DurationInSecond 86400 `      # 24 hours
    -Access 'Write'

# ==============================
# COPY DATA FROM SOURCE TO TARGET USING AZCOPY
# ==============================
# Make sure azcopy.exe is in the current directory or in the PATH
.\azcopy.exe copy $sourceDiskSas.AccessSAS $targetDiskSas.AccessSAS --blob-type PageBlob

# ==============================
# REVOKE SAS TOKENS
# ==============================
Revoke-AzDiskAccess -ResourceGroupName $sourceRG -DiskName $sourceDiskName
Revoke-AzDiskAccess -ResourceGroupName $targetRG -DiskName $targetDiskName

# ==============================
# OPTIONAL: VALIDATE HYPER-V GENERATION ON TARGET DISK
# ==============================
(Get-AzDisk -ResourceGroupName $targetRG -DiskName $targetDiskName).HyperVGeneration
