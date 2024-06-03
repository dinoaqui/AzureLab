# Parâmetro de entrada: Nome do grupo de recursos
param (
    [string]$ResourceGroupName
)

# Autenticar no Azure
Connect-AzAccount

# Coletar VMs no grupo de recursos especificado
$vms = Get-AzVM -ResourceGroupName $ResourceGroupName

# Criar uma lista para armazenar as informações das VMs e discos
$vmList = @()

foreach ($vm in $vms) {
    # Obter informações do disco de sistema operacional
    $osDisk = $vm.StorageProfile.OsDisk

    # Obter informações dos discos de dados
    $dataDisks = $vm.StorageProfile.DataDisks

    # Criar um objeto com as informações da VM e discos
    $vmInfo = [PSCustomObject]@{
        VMName     = $vm.Name
        OSDiskName = $osDisk.Name
        DataDisks  = $dataDisks.Name -join ", "
    }

    # Adicionar o objeto à lista
    $vmList += $vmInfo
}

# Salvar a lista em um arquivo CSV
$vmList | Export-Csv -Path "./VMsAndDisks.csv" -NoTypeInformation
