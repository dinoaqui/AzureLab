workflow AA-Start-Stop-AKS {
	Param(
	[string]$TagName,
	[string]$TagValue,
	[ValidateSet(“start”, “stop”)]
	[string]$AKSAction
	)

# Ensures you do not inherit an AzContext in your runbook
Disable-AzContextAutosave -Scope Process

# Connect to Azure with system-assigned managed identity
Connect-AzAccount -Identity

# set and store context
$AzureContext = Set-AzContext –SubscriptionId "<Subscription ID>" 

$vms = Get-AzResource -TagName $TagName -TagValue $TagValue | where {$_.ResourceType -like "Microsoft.ContainerService/managedClusters"}
     
    Foreach -Parallel ($vm in $vms){
        
        if($AKSAction -eq "stop" ){
            Write-Output "Stopping $($vm.Name)";        
            Stop-AzAksCluster -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName;
        }
        if($AKSAction -eq "start" ){
            Write-Output "Starting $($vm.Name)";        
            Start-AzAksCluster -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName;
        }
    }
}
