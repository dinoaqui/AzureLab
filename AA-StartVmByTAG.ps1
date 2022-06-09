# Connect AA
$azConn = Get-AutomationConnection -Name 'AzureRunAsConnection'
Add-AzureRMAccount -ServicePrincipal -Tenant $azConn.TenantID -ApplicationId $azConn.ApplicationId -CertificateThumbprint $azConn.CertificateThumbprint

# Start VM by Tag name - Start 08:00
$azVMs = Get-AzureRMVM | Where-Object {$_.Tags.Start -eq '08:00'}

# Runbook
$azVMS | Start-AzureRMVM
