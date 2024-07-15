# Connect to Azure
## Connect-AzAccount

# Set the subscription ID and switch to the desired subscription
Set-AzContext -SubscriptionId "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

# List of desired Workspace IDs
$workspaceIds = @(
    "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
    "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
    "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
)
$subscriptionName = "SUBSCRIPTION-NAME"

# Retrieve all VMs
$all_vms = Get-AzVM

# Names of the extensions for OMS Agent on Linux and Windows
$omsAgentLinux = "OmsAgentForLinux"
$omsAgentWindows = "MicrosoftMonitoringAgent"

# Process each Workspace ID
foreach ($workspaceId in $workspaceIds) {
    # Retrieve information for the current Workspace
    $workspace = Get-AzOperationalInsightsWorkspace | Where-Object { $_.CustomerId -eq $workspaceId }

    # Prepare an array to hold the results
    $vmsConnectedToWorkspace = @()

    # Iterate through all VMs
    foreach ($vm in $all_vms) {
        $vm_name = $vm.Name
        $vm_resourceGroup = $vm.ResourceGroupName
        $vm_osType = $vm.StorageProfile.OsDisk.OsType

        # Determine the extension name based on the OS type
        $extensionName = $vm_osType -eq "Windows" ? $omsAgentWindows : $omsAgentLinux

        # Retrieve extension details for the VM
        $vm_extension = Get-AzVMExtension -ResourceGroupName $vm_resourceGroup -VMName $vm_name -Name $extensionName -ErrorAction SilentlyContinue

        if ($vm_extension -and $vm_extension.PublicSettings) {
            # Extract the workspace ID from the extension's configuration
            $settings = $vm_extension.PublicSettings | ConvertFrom-Json
            if ($settings.workspaceId -eq $workspaceId) {
                # Retrieve Resource Group tags
                $rgDetails = Get-AzResourceGroup -Name $vm_resourceGroup
                $rgTags = $rgDetails.Tags | ConvertTo-Json -Compress
                
                # Add the VM to the results array with additional details
                $vmsConnectedToWorkspace += [PSCustomObject]@{
                    VMName = $vm_name
                    ResourceGroup = $vm_resourceGroup
                    Location = $vm.Location
                    AgentType = $extensionName
                    SubscriptionName = $subscriptionName
                    WorkspaceName = $workspace.Name
                    WorkspaceTags = ($workspace.Tags | Out-String).Trim()
                    RGTags = $rgTags
                }
            }
        }
    }

    # Define the path for the Excel file for this specific workspace
    $excelPath = "C:\path\to\output\VMs_" + $subscriptionName + "_" + $workspace.Name + ".xlsx"

    # Export the data to Excel
    $vmsConnectedToWorkspace | Export-Excel -Path $excelPath -AutoSize -TableName "ConnectedVMs"

    # Confirmation message
    Write-Host "Data exported to Excel at: $excelPath for the workspace $workspace.Name"
}
