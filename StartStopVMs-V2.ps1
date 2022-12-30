workflow StartStopVMs
# Declare: Resource Group Name
# Declare: Action = Stop or Start
{
Param(
    [string]$resourceGroup,
    [string]$action
)

# Ensures you do not inherit an AzContext in your runbook
Disable-AzContextAutosave -Scope Process

# Connect to Azure with system-assigned managed identity
Connect-AzAccount -Identity -AccountId "<Managed Identify ID>"

# set and store context
$AzureContext = Set-AzContext –SubscriptionId "<Subscription ID>"

# Start or stop VMs in parallel
if($action -eq "Start")
    {
        $vms = Get-AzVM -ResourceGroupName $resourceGroup
        ForEach -Parallel ($vm in $VMs)
        {
            Write-Output "Starting $($vm.Name)";
            Start-AzVM -Name $vm.Name -ResourceGroupName $resourceGroup -DefaultProfile $AzureContext
        }
    }
elseif ($action -eq "Stop")
    {
        $vms = Get-AzVM -ResourceGroupName $resourceGroup
        ForEach -Parallel ($vm in $VMs)
        {
            Write-Output "Stopping $($vm.Name)";
            Stop-AzVM -Name $vm.Name -ResourceGroupName $resourceGroup -DefaultProfile $AzureContext -Force
        }
    }
else {
	    Write-Output "`r`n Action not allowed. Please enter 'stop' or 'start'."
	}
}
