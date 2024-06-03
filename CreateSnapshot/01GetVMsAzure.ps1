# Parameter input: Name of the resource group
# Usage: 01GetVMsAzure.ps1 -ResourceGroupName "ResourceGroupName"

param (
    [string]$ResourceGroupName
)

# Authenticate to Azure
Connect-AzAccount

# Collect VMs in the specified resource group
$vms = Get-AzVM -ResourceGroupName $ResourceGroupName

# Create a list to store the information of VMs and disks
$vmList = @()

foreach ($vm in $vms) {
    # Get information of the OS disk
    $osDisk = $vm.StorageProfile.OsDisk

    # Get information of the data disks
    $dataDisks = $vm.StorageProfile.DataDisks

    # Create an object with the information of the VM and disks
    $vmInfo = [PSCustomObject]@{
        VMName     = $vm.Name
        OSDiskName = $osDisk.Name
        DataDisks  = $dataDisks.Name -join ", "
    }

    # Add the object to the list
    $vmList += $vmInfo
}

# Save the list to a CSV file
$vmList | Export-Csv -Path "./VMsAndDisks.csv" -NoTypeInformation
