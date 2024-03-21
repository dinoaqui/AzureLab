[CmdletBinding()]

param 
( 
    [Parameter(ValueFromPipeline=$true, Mandatory=$true)] [string]$Domain_DNSName = "nabucodonosor.local",
    [Parameter(ValueFromPipeline=$true, Mandatory=$true)] [string]$Domain_NETBIOSName = "NABUCODONOSOR",
    [Parameter(ValueFromPipeline=$true, Mandatory=$true)] [String]$SafeModeAdministratorPassword = "!@12qwaszx"
)

$SMAP = ConvertTo-SecureString -AsPlainText $SafeModeAdministratorPassword -Force

Set-NetFirewallProfile -Profile Public,Private,Domain -Enabled False
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
Install-WindowsFeature DNS -IncludeAllSubFeature -IncludeManagementTools
Install-ADDSForest -CreateDnsDelegation:$false -DatabasePath "C:\Windows\NTDS" -DomainMode "WinThreshold" -DomainName $Domain_DNSName -DomainNetbiosName $Domain_NETBIOSName -ForestMode "WinThreshold" -InstallDns:$true -LogPath "C:\Windows\NTDS" -NoRebootOnCompletion:$false -SysvolPath "C:\Windows\SYSVOL" -Force:$true -SkipPreChecks -SafeModeAdministratorPassword $SMAP
Restart-Computer
