provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-AD-LOCAL"
  location = "East US 2"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "VNET-AD-LOCAL"
  address_space       = ["192.168.0.0/24"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "SubnetA"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["192.168.0.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-VNET-AD-LOCAL"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_network_interface" "nic" {
  name                = "nic-VM-AD-LOCAL"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "vm" {
  name                = "VM-AD-LOCAL"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_DS1_v2"
  admin_username      = "dinoaqui"
  admin_password      = "!@12qwaszx"
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

# Exemplo de como adicionar um disco adicional - ajuste conforme necessário
#resource "azurerm_managed_disk" "additional_disk" {
#  name                 = "additionalDisk"
#  location             = azurerm_resource_group.rg.location
#  resource_group_name  = azurerm_resource_group.rg.name
#  storage_account_type = "Standard_LRS"
#  create_option        = "Empty"
#  disk_size_gb         = 1024
#}

#resource "azurerm_virtual_machine_data_disk_attachment" "disk_attachment" {
#  managed_disk_id    = azurerm_managed_disk.additional_disk.id
#  virtual_machine_id = azurerm_windows_virtual_machine.vm.id
#  lun                = "10"
#  caching            = "ReadWrite"
#}

resource "azurerm_virtual_machine_extension" "install_ad" {
  name                 = "installAD"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
  {
    "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -Command \"Invoke-Expression $(Unprotect-CmsMessage -Path 'ADDS.ps1')\""
  }
  SETTINGS

  # Este é um exemplo se você tiver o script como um arquivo local e precisar passá-lo como uma string codificada em base64.
  # Certifique-se de ajustar o caminho do script e a lógica de codificação conforme necessário.
  protected_settings = <<PROTECTED_SETTINGS
  {
    "script": "${filebase64("./ADDS.ps1")}"
  }
  PROTECTED_SETTINGS
}
