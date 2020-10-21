//test again
terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "TechAlto"
    workspaces {
      name = "MyAzureTerraform"
    }
  }
}
provider "azurerm" {
  version  = ">= 2.0"
  features {}
}

resource "azurerm_resource_group" "mygithubtest" {
  name = "mygithub_resource_group"
  location = "eastus"
}

resource "azurerm_storage_account" "mygithubtest" {
  account_replication_type  = "LRS"
  account_tier              = "Standard"
  account_kind              = "Storage"
  enable_https_traffic_only = false
  location                  = var.location
  name                      = "atosapimgmtteststorage"
  resource_group_name       = azurerm_resource_group.mygithubtest.name
}


resource "azurerm_network_security_group" "mygithubtest" {
  name                = "ApiTestSG"
  location            = var.location
  resource_group_name = azurerm_resource_group.mygithubtest.name

  security_rule {
    access                                     = "Allow"
    description                                = ""
    destination_address_prefix                 = "*"
    destination_address_prefixes               = []
    destination_application_security_group_ids = []
    destination_port_range                     = "22"
    destination_port_ranges                    = []
    direction                                  = "Inbound"
    name                                       = "Port_22"
    priority                                   = 100
    protocol                                   = "TCP"
    source_address_prefix                      = ""
    source_address_prefixes                    = ["81.102.30.115/32"]
    source_application_security_group_ids      = []
    source_port_range                          = "*"
    source_port_ranges                         = []
  }

  security_rule {
    access                                     = "Allow"
    description                                = ""
    destination_address_prefix                 = "*"
    destination_address_prefixes               = []
    destination_application_security_group_ids = []
    destination_port_range                     = "8080"
    destination_port_ranges                    = []
    direction                                  = "Inbound"
    name                                       = "Port_8080"
    priority                                   = 101
    protocol                                   = "TCP"
    source_address_prefix                      = "*"
    source_address_prefixes                    = []
    source_application_security_group_ids      = []
    source_port_range                          = "*"
    source_port_ranges                         = []
  }
  security_rule {
    access                                     = "Allow"
    description                                = ""
    destination_address_prefix                 = "*"
    destination_address_prefixes               = []
    destination_application_security_group_ids = []
    destination_port_range                     = "*"
    destination_port_ranges                    = []
    direction                                  = "Outbound"
    name                                       = "all_out"
    priority                                   = 411
    protocol                                   = "*"
    source_address_prefix                      = "*"
    source_address_prefixes                    = []
    source_application_security_group_ids      = []
    source_port_range                          = "*"
    source_port_ranges                         = []
  }
  security_rule {
    access                                     = "Allow"
    description                                = ""
    destination_address_prefix                 = "*"
    destination_address_prefixes               = []
    destination_application_security_group_ids = []
    destination_port_range                     = "80"
    destination_port_ranges                    = []
    direction                                  = "Inbound"
    name                                       = "Port_80"
    priority                                   = 201
    protocol                                   = "*"
    source_address_prefix                      = ""
    source_address_prefixes                    = ["81.102.30.115/32"]
    source_application_security_group_ids      = []
    source_port_range                          = "*"
    source_port_ranges                         = []
  }
}

resource "azurerm_virtual_network" "mygithubtest" {
  name                = "mygithubtest-network"
  location            = var.location
  resource_group_name = azurerm_resource_group.mygithubtest.name
  address_space       = ["10.0.0.0/22"]
  //  dns_servers         = ["10.0.0.4", "10.0.0.5"]

  tags = {
    environment = "MyTest"
  }
}
resource "azurerm_subnet" "mygithubtest" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.mygithubtest.name
  virtual_network_name = azurerm_virtual_network.mygithubtest.name
  address_prefixes     = ["10.0.1.0/24"]
}
resource "azurerm_subnet_network_security_group_association" "mygithubtest" {
  subnet_id   = azurerm_subnet.mygithubtest.id
  network_security_group_id = azurerm_network_security_group.mygithubtest.id
}
resource "azurerm_public_ip" "mygithubtest" {
  location            = var.location
  name                = "apitest-public-ip"
  allocation_method   = "Static"
  resource_group_name = azurerm_resource_group.mygithubtest.name
  sku                 = "Basic"
  ip_version          = "IPv4"
  domain_name_label   = "apitest-server"
}

resource "azurerm_network_interface" "mygithubtest" {
  name                = "mygithubtest-nic"
  location            = azurerm_resource_group.mygithubtest.location
  resource_group_name = azurerm_resource_group.mygithubtest.name

  ip_configuration {
    name                          = "internal-ip"
    subnet_id                     = azurerm_subnet.mygithubtest.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.mygithubtest.id
  }
}
resource "azurerm_dns_zone" "mygithubtest" {
  name                = "azure-api-test.net"
  resource_group_name = azurerm_resource_group.mygithubtest.name
}
resource "azurerm_dns_a_record" "mygithubtest" {
  name                = "apitestvm"
  zone_name           = azurerm_dns_zone.mygithubtest.name
  resource_group_name = azurerm_resource_group.mygithubtest.name
  ttl                 = 300
  # records             = ["10.0.1.4"]\
  target_resource_id  = azurerm_public_ip.mygithubtest.id
}

resource "azurerm_virtual_machine" "mygithubtest" {
  name                  = "APIServer"
  location              = azurerm_resource_group.mygithubtest.location
  resource_group_name   = azurerm_resource_group.mygithubtest.name
  network_interface_ids = [azurerm_network_interface.mygithubtest.id]
  vm_size               = "Standard_DS1_v2"
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "apivmosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "apitest-server"
    admin_username = var.api_username
    admin_password = var.aptmgmtuser_pw
  }
  os_profile_linux_config {
    disable_password_authentication = false
    # ssh_keys {
    #     path     = "/home/{username}/.ssh/authorized_keys"
    #     key_data = file("~/.ssh/id_rsa.pub")
    # }
    # provisioner "remote-exec" {
    #   inline = [
    #     "sudo apt-get update && sudo apt-get upgrade -y",
    #     "sudo apt-get install -y openjdk-11-jre-dcevm",
    #     "sudo apt install -y apache2",
    #   ]
    #   }
  }
}
