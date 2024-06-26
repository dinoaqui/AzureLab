# Parameter input: Name of the resource group
# Usage: 01GetVMsAzure.ps1 -ResourceGroupName "Resource_Group_Source"

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
        DataDisks  = ($dataDisks | ForEach-Object { $_.Name }) -join ", "
    }

    # Add the object to the list
    $vmList += $vmInfo
}

# Path for the CSV file
$csvPath = "./VMsAndDisks.csv"

# Save the list to a CSV file
$vmList | Export-Csv -Path $csvPath -NoTypeInformation

# Output message about the file creation
Write-Output "A lista de VMs e discos foi salva em: $csvPath"

