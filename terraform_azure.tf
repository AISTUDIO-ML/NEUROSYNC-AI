
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "neurosync_rg" {
  name     = "NeuroSyncResourceGroup"
  location = "East US"
}

resource "azurerm_virtual_network" "neurosync_vnet" {
  name                = "NeuroSyncVNet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.neurosync_rg.location
  resource_group_name = azurerm_resource_group.neurosync_rg.name
}

resource "azurerm_subnet" "neurosync_subnet" {
  name                 = "NeuroSyncSubnet"
  resource_group_name  = azurerm_resource_group.neurosync_rg.name
  virtual_network_name = azurerm_virtual_network.neurosync_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "neurosync_nic" {
  name                = "NeuroSyncNIC"
  location            = azurerm_resource_group.neurosync_rg.location
  resource_group_name = azurerm_resource_group.neurosync_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.neurosync_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "neurosync_vm" {
  name                = "NeuroSyncVM"
  resource_group_name = azurerm_resource_group.neurosync_rg.name
  location            = azurerm_resource_group.neurosync_rg.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"
  network_interface_ids = [azurerm_network_interface.neurosync_nic.id]
  admin_password      = "YourPassword123!"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "22_04-lts"
    version   = "latest"
  }

  custom_data = base64encode(<<-EOF
                #!/bin/bash
                apt update -y
                apt install -y docker.io docker-compose unzip git
                systemctl start docker
                usermod -aG docker azureuser
                cd /home/azureuser
                git clone https://github.com/your-org/neurosync-sdk.git
                cd neurosync-sdk
                docker-compose up --build -d
                EOF)
}
