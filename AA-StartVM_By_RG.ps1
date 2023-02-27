# 
# Start VMs by Resource Group Name
#
# StartVM is Runbook name
#
workflow StartVM
{
    (
        {
        Import-Module 'az.accounts',
        Import-Module 'az.compute'
        }
    )
    Connect-AzAccount -Identity
    # Add Subscription ID
    Set-AzContext -SubscriptionId "00000000-0000-0000-0000-000000000000"
    $resultList = @()
    $retryList = @()
    $retryListTemp = @()
    try
    {
        # Add Resource Group Name
        $VMs = Get-AzVM -ResourceGroupName "RG_Resource_Group_Name"
        do
        {
            $retryListTemp = @()
            Foreach -parallel -throttlelimit 10 ($Vm in $VMs) 
            {
                $obj = $workflow:retryList | Where-Object { $_.ResourceGroup -eq $Vm.ResourceGroupName -and $_.Name -eq $Vm.Name }
                $Status = $null
                if ($obj -eq $null)
                {
                    $obj= @{
                                "ResourceGroup" = $Vm.ResourceGroupName;
                                "Name" = $Vm.Name;
                                "ActionResult" = "";
                                "RetryAttempts" = 0;
                                "Output" = ""
                            }
                }
                else
                {
                    $obj = InlineScript { $o = $using:obj; $o.RetryAttempts += 1; $o}
                }
                    if ($obj.RetryAttempts -gt 1)
                    {
                        $obj = InlineScript { $o = $using:obj; $o.RetryAttempts -= 1; $o}
                        Write-Output ("Failed Starting VM: " + $Vm.Name)
                        $workflow:resultList += $obj
                    }
                    else
                    {
                        Write-Output ("Starting VM: " + $Vm.Name)
                        try
                        {
                            $Status = Start-AzVM -Name $Vm.Name -ResourceGroupName $Vm.ResourceGroupName
                            if ($Status.Error -eq $null)
                            {
                                $obj = InlineScript { $o = $using:obj; $o.ActionResult = "Started"; $o.Output = $using:Status.Error; $o}
                                Write-Output ("VM Started: " + $Vm.Name)
                                $workflow:resultList += $obj
                            }
                            else
                            {
                                $obj = InlineScript { $o = $using:obj; $o.ActionResult = "Failed Starting"; $o.Output = $using:Status.Error; $o}
                                $workflow:retryListTemp += $obj
                                Write-Output ("Error Starting VM: " + $Vm.Name)
                                Write-Output ("Error message: " + $Status.Error)
                            }
                        }
                        catch
                        {
                            $obj = InlineScript { $o = $using:obj; $o.ActionResult = "Failed Starting"; $o.Output = $using:_.ErrorRecord; $o}
                            $workflow:retryListTemp += $obj
                            Write-Output ("Error Starting VM: " + $Vm.Name)
                            Write-Output ("Error message: " + $_.ErrorRecord)
                        }
                    }
                }
            $VMs = $VMs | Where-Object { $_.Name -notin ($resultList | select @{n="Name"; e={$_.Name} } ).Name }
            
            $retryList = $retryListTemp
        }
        while ($retryList.Count -gt 0)
    }
    catch
    {
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
    if ($resultList.Count -eq 0)
    {
        Write-Output "No VMs scheduled to Start at this time."
        return
    }
    else
    {
        Write-Output "Task completed, check logs"
    }
}