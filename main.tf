# Configure the Microsoft Azure Provider

provider "azurerm" {

    # The "feature" block is required for AzureRM provider 2.x.

    # If you're using version 1.x, the "features" block is not allowed.

    version = "~>2.0"
    skip_provider_registration = true

    features {}

}

resource "azurerm_subnet" "internal" {

  name                 = "WEB"

  resource_group_name  = "shared-services-vnet"

  virtual_network_name = "web-shared-services-vnet"

  address_prefixes     = ["10.26.32.0/25"]

}



resource "azurerm_network_interface" "nic" {

  name                = "kishore-nic"

  location            = "centralindia"

  resource_group_name = "Terraform-HR"



  ip_configuration {

    name                          = "kishoreip"

	    subnet_id                     = azurerm_subnet.internal.id

    private_ip_address_allocation = "Dynamic"

  }

}



resource "azurerm_virtual_machine" "main" {

  name                  = "kishore-vm"

  location              = "centralindia"

  resource_group_name   = "Terraform-HR"

  network_interface_ids = [azurerm_network_interface.nic.id]

  vm_size               = "Standard_DS1_v2"




  storage_image_reference {

    publisher = "Canonical"

    offer     = "UbuntuServer"

	    sku       = "16.04-LTS"

    version   = "latest"

  }

  storage_os_disk {

    name              = "kishoreosdisk1"

    caching           = "ReadWrite"

    create_option     = "FromImage"

    managed_disk_type = "Standard_LRS"

  }

  os_profile {

    computer_name  = "kishore-terraform"

    admin_username = "testadmin"

    admin_password = "Password1234!"

  }

  os_profile_linux_config {

    disable_password_authentication = false

  }

provisioner "remote-exec" {
        connection {
            type     = "ssh"
            user     = "testadmin"
            password = "password1234!"
        }

        inline = [
          "apt-get update"
          "apt-get install postgresql"
        ]
    }

}
