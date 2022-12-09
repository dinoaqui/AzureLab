<# 
	This PowerShell script was automatically converted to PowerShell Workflow so it can be run as a runbook.
	Specific changes that have been made are marked with a comment starting with “Converter:”
#>
workflow StartStopVMbyTag {
	Param(
	[string]$VmName1 = "VM-A",
	###     [string]$VmName2 = "VM-B",
	[string]$ResourceGroupName,
	[ValidateSet(“Start”, “Stop”)]
	[string]$VmAction
	
	)
	# Converter: Wrapping initial script in an InlineScript activity, and passing any parameters for use within the InlineScript
	# Converter: If you want this InlineScript to execute on another host rather than the Automation worker, simply add some combination of -PSComputerName, -PSCredential, -PSConnectionURI, or other workflow common parameters (http://technet.microsoft.com/en-us/library/jj129719.aspx) as parameters of the InlineScript
	inlineScript {
		$VmName1 = $using:VmName1
		$ResourceGroupName = $using:ResourceGroupName
		$VmAction = $using:VmAction
		
# 		Autenticar na conta de automação
		Connect-AzAccount -Identity -Subscription "0000000-000000-000000-000000-000000"
		
 		"Start VM"
		IF ($VmAction -eq “Start”) {
		Start-AzVM -Name $VmName1 -ResourceGroupName $ResourceGroupName
		###     Start-AzVM -Name $VmName2 -ResourceGroupName $ResourceGroupName
		}
 		"Stop VM"
		IF ($VmAction -eq “Stop”) {
		Stop-AzVM -Name $VmName1 -ResourceGroupName $ResourceGroupName -Force
		###     Stop-AzVM -Name $VmName2 -ResourceGroupName $ResourceGroupName -Force
		}
	}
}
