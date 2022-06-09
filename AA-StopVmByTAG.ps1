# Connect AA
$azConn = Get-AutomationConnection -Name 'AzureRunAsConnection'
Add-AzureRMAccount -ServicePrincipal -Tenant $azConn.TenantID -ApplicationId $azConn.ApplicationId -CertificateThumbprint $azConn.CertificateThumbprint

# Stop VM by Tag name - Stop 18:00
$azVMs = Get-AzureRMVM | Where-Object {$_.Tags.Stop -eq '18:00'}

# Runbook
$azVMS | Start-AzureRMVM
