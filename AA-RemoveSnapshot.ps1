$connectionName = "AzureRunAsConnection";

    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName        

    "Logging in to Azure..."
    Add-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
 
Get-AzureRmSnapshot -ResourceGroupName RG_ONE -SnapshotName $snapname | ?{($_.TimeCreated) -lt ([datetime]::UtcNow.AddDays(-7))} | remove-azurermsnapshot -force
Get-AzureRmSnapshot -ResourceGroupName RG_TWO -SnapshotName $snapname | ?{($_.TimeCreated) -lt ([datetime]::UtcNow.AddDays(-7))} | remove-azurermsnapshot -force
