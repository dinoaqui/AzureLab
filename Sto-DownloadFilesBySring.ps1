# Install Az.Storage (optional)
# Install-Module -Name Az.Storage -Force -AllowClobber 

# Connect Subscription ID (optional)
# Connect-AzAccount -SubscriptionId XXXXXX-XXXXXXX-XXXXXX-XXXXXX

$storageAccountName = "Storage_Account_Name"
$containerName = "Container_Name"
$localDownloadPath = "C:\LocalPath"
# Define String that you want download
$pattern = "*_Contoso_202401*.pdf"
 
# Get Context Storage Account
# Define your Resource Group Name
$storageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName "RG_Resource_Group_Name" -AccountName $storageAccountName).Value[0]
$ctx = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey

# Get and Filter Blobs
$blobs = Get-AzStorageBlob -Container $containerName -Context $ctx | Where-Object { $_.Name -like $pattern }

# Download Filter Blobs
foreach ($blob in $blobs) {
    $destinationFilePath = Join-Path -Path $localDownloadPath -ChildPath $blob.Name
    $blobName = $blob.Name

    # Create path local dir if not exist
    $destinationDirectory = [System.IO.Path]::GetDirectoryName($destinationFilePath)
    if (-not (Test-Path -Path $destinationDirectory)) {
        New-Item -ItemType Directory -Path $destinationDirectory | Out-Null
    }

    # Download blob
    Get-AzStorageBlobContent -Blob $blobName -Container $containerName -Context $ctx -Destination $destinationFilePath
    Write-Host "Download: $blobName"
}
