#
# Get Az Route Table
#

# Insert your TenantID
$TenantId = "000-000-000-000-000-000"

Connect-AzAccount -TenantID $TenantId

# $SubscriptionId 
# Connect-AzAccount -SubscriptionId $SubscriptionId 

$OutputPath = '.\'

# Get Current Context
Write-Verbose "Running for all subscriptions in tenant" -Verbose
$Subscriptions = Get-AzSubscription -TenantId $TenantId

# Get Role roles in foreach loop
$report = @()
 
foreach ($Subscription in $Subscriptions) {
    # Choose subscription
    Write-Verbose "Changing to Subscription $($Subscription.Name)" -Verbose
    Select-AzSubscription -Subscription $Subscription.Id
    $rts = Get-AzRouteTable

foreach ($rt in $rts) {

          $rotas = $rt.routes

          foreach ($rota in $rotas) {

          $SubscriptionName = $Subscription.Name
          $SubscriptionID = $Subscription.Id
          $RouTableName = $rt.name
          $rgname = $rt.ResourceGroupName
          $RouteName = $rota.Name
          $PrefxodeRede = $rota.AddressPrefix
          $TipodeSalto = $rota.NextHopType
          $ProximoSalto = $rota.NextHopIpAddress
             
          # New PSObject
          $obj = New-Object -TypeName PSObject
          $obj | Add-Member -MemberType NoteProperty -Name SubscriptionName -value $SubscriptionName
          $obj | Add-Member -MemberType NoteProperty -Name SubscriptionID -value $SubscriptionID      
          $obj | Add-Member -MemberType NoteProperty -Name RouteTable -Value $RouTableName
          $obj | Add-Member -MemberType NoteProperty -Name NomeRG -value $rgname 
          $obj | Add-Member -MemberType NoteProperty -Name NomeRota -Value $RouteName 
          $obj | Add-Member -MemberType NoteProperty -Name PrefixoOrigem -value $PrefxodeRede
          $obj | Add-Member -MemberType NoteProperty -Name TipoSalto -value $TipodeSalto
          $obj | Add-Member -MemberType NoteProperty -Name SaltoDestino -value  $ProximoSalto
            
          $Report += $obj
     } 
 
    }
  }
 
if ($OutputPath) {
  #Export to CSV file
  Write-Verbose "Exporting CSV file to $OutputPath" -Verbose
  $Report | Export-Csv $OutputPath\RouteExport-$(Get-Date -Format "yyyy-MM-dd").csv

}else {
  $Report
}
