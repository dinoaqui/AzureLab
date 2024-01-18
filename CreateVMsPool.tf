terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.37.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "5d4b7cba-fa27-4c98-bd11-2c9ec6315155"
  tenant_id       = "c96eeece-4266-4a73-b4f8-d0be66d4ba0b"
}

# Crie um recurso de grupo de recursos
resource "azurerm_resource_group" "my_resource_group" {
  name     = "RG_PoC"
  location = "East US 2"
}

# Crie uma rede virtual
resource "azurerm_virtual_network" "my_vnet" {
  name                = "Vnet-POC"
  resource_group_name = azurerm_resource_group.my_resource_group.name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.my_resource_group.location
}

# Crie uma sub-rede
resource "azurerm_subnet" "my_subnet" {
  name                 = "Sub-Servers"
  resource_group_name  = azurerm_resource_group.my_resource_group.name
  virtual_network_name = azurerm_virtual_network.my_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "my_network_interface" {
  count               = 20
  name                = "NIC-POC-${count.index}"
  location            = azurerm_resource_group.my_resource_group.location
  resource_group_name = azurerm_resource_group.my_resource_group.name

  ip_configuration {
    name                          = "ipconfig-${count.index}"
    subnet_id                     = azurerm_subnet.my_subnet.id
    private_ip_address_allocation = "Dynamic"

  }
}

# Crie uma VM
resource "azurerm_windows_virtual_machine" "my_vm" {
  count                 = 20
  name                  = "VM-POC-${count.index}"
  resource_group_name   = azurerm_resource_group.my_resource_group.name
  location              = azurerm_resource_group.my_resource_group.location
  network_interface_ids = [azurerm_network_interface.my_network_interface[count.index].id]
  size                  = "Standard_B1s"
  admin_username        = "adminuser"
  admin_password        = "MySecurePassword123!"
  tags    = {
    Start = "08:00"
    Stop  = "20:00"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  os_disk {
    name                 = "osdisk-${count.index}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

}
