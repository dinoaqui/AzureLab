# Specify the provider and version
provider "azurerm" {
  features {}
  version = "~>2.0"
}

# Create a Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "My_POC_VM_Pool"
  location = "East US"
}

# Create a Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "My-VNET-POC"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create a Subnet within the Virtual Network
resource "azurerm_subnet" "subnet" {
  name                 = "Subnet_POC"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Optionally create Public IPs for each VM
#resource "azurerm_public_ip" "publicip" {
#  count               = 50
#  name                = "publicIP-${format("%02d", count.index)}"
#  location            = azurerm_resource_group.rg.location
#  resource_group_name = azurerm_resource_group.rg.name
#  allocation_method   = "Dynamic"
#}

# Create Network Interfaces for the VMs
resource "azurerm_network_interface" "nic" {
  count               = 50
  name                = "nic-${format("%02d", count.index)}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip[count.index].id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  count                 = 50
  name                  = "vm-${format("%02d", count.index)}"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = "Standard_B1s"
  admin_username        = "c3pio"
  admin_password        = "!@12qwaszx"
  network_interface_ids = [azurerm_network_interface.nic[count.index].id]
  disable_password_authentication = false

  # Define the OS disk configuration
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # Define the source image for the VM
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  # Add tags to the VM resource
  tags = {
    Environment = "Development"
    Project     = "ProjectName"
    Owner       = "YourName"
  }
}
