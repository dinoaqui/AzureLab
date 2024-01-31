try {
    "Logging in to Azure..."
    Connect-AzAccount -Identity
}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}

$TagName = "RemoteControl"
$TagValue = "True"

$VMs = Get-AzResource -TagName $TagName -TagValue $TagValue | Where-Object {$_.ResourceType -eq 'Microsoft.Compute/virtualMachines'}

foreach ($VM in $VMs) {
    $vmStatus = Get-AzVM -ResourceGroupName $VM.ResourceGroupName -Name $VM.Name -Status
    $vmPowerState = $vmStatus.Statuses | Where-Object { $_.Code -match 'PowerState/' } | Select-Object -ExpandProperty DisplayStatus

    if ($vmPowerState -eq 'VM deallocated') {
        # StartVM
        Start-AzVM -ResourceGroupName $VM.ResourceGroupName -Name $VM.Name -Verbose
    } elseif ($vmPowerState -eq 'VM running') {
        # StopVM
        Stop-AzVM -ResourceGroupName $VM.ResourceGroupName -Name $VM.Name -Force -Verbose
    } else {
        Write-Host "VM state not found for $($VM.Name) in Resource Group $($VM.ResourceGroupName): $vmPowerState"
    }
}
