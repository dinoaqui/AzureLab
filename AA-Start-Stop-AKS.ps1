# Automation Account - Start and Stop AKS
workflow start-stop-aks {
	Param(
	[string]$VmName,
	[string]$ResourceGroupName,
	[ValidateSet(“start”, “stop”)]
	[string]$VmAction
	
	)
	# Converter: Wrapping initial script in an InlineScript activity, and passing any parameters for use within the InlineScript
	# Converter: If you want this InlineScript to execute on another host rather than the Automation worker, simply add some combination of -PSComputerName, -PSCredential, -PSConnectionURI, or other workflow common parameters (http://technet.microsoft.com/en-us/library/jj129719.aspx) as parameters of the InlineScript
	inlineScript {
		$VmName = $using:VmName
		$ResourceGroupName = $using:ResourceGroupName
		$VmAction = $using:VmAction
		
		# Autenticar na conta de automação
		$Conn = Get-AutomationConnection -Name AzureRunAsConnection
		Connect-AzAccount -ServicePrincipal -Tenant $Conn.TenantID `
-ApplicationID $Conn.ApplicationID -CertificateThumbprint $Conn.CertificateThumbprint
		# Iniciar VM
		IF ($VmAction -eq “stop”) {
		Stop-AzAksCluster -Name $VmName -ResourceGroupName $ResourceGroupName
		}
		# Desligar VM
		IF ($VmAction -eq “start”) {
		Start-AzAksCluster -Name $VmName -ResourceGroupName $ResourceGroupName
		}
	}
}
