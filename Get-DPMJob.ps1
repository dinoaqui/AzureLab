# Set the current date and the date 30 days ago
$currentDate = Get-Date
$startDate = $currentDate.AddDays(-30)

# Get cloud backup jobs from the last 30 days
$backupJobs = Get-DPMJob -DPMServerName "VM-MABS" -JobCategory "CloudBackup" | Where-Object { $_.StartTime -ge $startDate -and $_.StartTime -le $currentDate }

# Display the results
$backupJobs | Format-Table -Property JobCategory, Status, ProtectionGroupName, DataSources, StartTime


## Output sample
#  JobCategory Status ProtectionGroupName DataSources         StartTime
#  ----------- ------ ------------------- -----------         ---------
#  CloudBackup Failed Protection Group 1  VM-SQLSERVER\master 3/27/2024 5:34:37 PM
#  CloudBackup Failed Protection Group 1  VM-SQLSERVER\msdb   3/26/2024 10:00:01 PM
#  CloudBackup Failed Protection Group 1  VM-SQLSERVER\msdb   3/26/2024 9:00:00 PM
#  CloudBackup Failed Protection Group 1  VM-SQLSERVER\master 3/26/2024 9:00:00 PM
#  CloudBackup Failed Protection Group 1  VM-SQLSERVER\model  3/26/2024 9:00:00 PM
#  CloudBackup Failed Protection Group 1  VM-SQLSERVER\msdb   3/26/2024 8:00:00 PM
#  CloudBackup Failed Protection Group 1  VM-SQLSERVER\model  3/26/2024 8:00:00 PM
#  CloudBackup Failed Protection Group 1  VM-SQLSERVER\master 3/26/2024 8:00:00 PM
