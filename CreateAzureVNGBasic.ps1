# Variáveis
$resourceGroupName = "RG_VPN_BASIC"
$vnetName = "vnet-basic"
$location = "East US"
$gatewayName = "VNG-BASIC"
$subnetName = "GatewaySubnet"
$subnetPrefix = "10.254.0.0/27"
$publicIpName = "pip-VNG-BASIC"

# Criação de SubnetGateway
$subnet = New-AzVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix $subnetPrefix

# Coletar informações da VNET
$vnet = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $resourceGroupName

# Coletar informações de SubnetGateway
$subnetConfig = Get-AzVirtualNetworkSubnetConfig -name 'gatewaysubnet' -VirtualNetwork $vnet

# Criação de Public IP
$publicIp = New-AzPublicIpAddress -ResourceGroupName $resourceGroupName -Location $location -Name $publicIpName -AllocationMethod Dynamic -Sku Basic

# Criar uma configuração de IP para o gateway
$gwIpConfig = New-AzVirtualNetworkGatewayIpConfig -Name "${gatewayName}IpConfig" -SubnetId $subnetConfig.Id -PublicIpAddressId $publicIp.Id

# Criar o Azure Virtual Network Gateway
New-AzVirtualNetworkGateway -ResourceGroupName $resourceGroupName -Location $location -Name $gatewayName -IpConfigurations $gwIpConfig -GatewayType "Vpn" -VpnType "RouteBased" -GatewaySku "Basic"
