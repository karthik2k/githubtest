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

resource "azurerm_resource_group" "MyGithubTest" {
  name = "MyGithutTestRG"
  location = var.location
}

resource "azurerm_storage_account" "MyGithubTest" {
  account_replication_type  = "LRS"
  account_tier              = "Standard"
  account_kind              = "Storage"
  enable_https_traffic_only = false
  location                  = var.location
  name                      = "azureteststorage"
  resource_group_name       = azurerm_resource_group.MyGithubTest.name
}


resource "azurerm_network_security_group" "MyGithubTest" {
  name                = "AzureTestSG"
  location            = var.location
  resource_group_name = azurerm_resource_group.MyGithubTest.name

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

resource "azurerm_virtual_network" "MyGithubTest" {
  name                = "MyGithubTest-network"
  location            = var.location
  resource_group_name = azurerm_resource_group.MyGithubTest.name
  address_space       = ["10.0.0.0/22"]
  //  dns_servers         = ["10.0.0.4", "10.0.0.5"]

  tags = {
    environment = "MyTest"
  }
}
resource "azurerm_subnet" "MyGithubTest" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.MyGithubTest.name
  virtual_network_name = azurerm_virtual_network.MyGithubTest.name
  address_prefixes     = ["10.0.1.0/24"]
}
resource "azurerm_subnet_network_security_group_association" "MyGithubTest" {
  subnet_id   = azurerm_subnet.MyGithubTest.id
  network_security_group_id = azurerm_network_security_group.MyGithubTest.id
}
resource "azurerm_public_ip" "MyGithubTest" {
  location            = var.location
  name                = "azuretest-public-ip"
  allocation_method   = "Static"
  resource_group_name = azurerm_resource_group.MyGithubTest.name
  sku                 = "Basic"
  ip_version          = "IPv4"
  domain_name_label   = "azuretest-server"
}

resource "azurerm_network_interface" "MyGithubTest" {
  name                = "MyGithubTest-nic"
  location            = azurerm_resource_group.MyGithubTest.location
  resource_group_name = azurerm_resource_group.MyGithubTest.name

  ip_configuration {
    name                          = "internal-ip"
    subnet_id                     = azurerm_subnet.MyGithubTest.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.MyGithubTest.id
  }
}
resource "azurerm_dns_zone" "MyGithubTest" {
  name                = "github-azure-test.net"
  resource_group_name = azurerm_resource_group.MyGithubTest.name
}
resource "azurerm_dns_a_record" "MyGithubTest" {
  name                = "azuretestvm"
  zone_name           = azurerm_dns_zone.MyGithubTest.name
  resource_group_name = azurerm_resource_group.MyGithubTest.name
  ttl                 = 300
  # records             = ["10.0.1.4"]\
  target_resource_id  = azurerm_public_ip.MyGithubTest.id
}


resource "azurerm_virtual_machine" "MyGithubTest" {
  name                  = "AzureTestServer"
  location              = azurerm_resource_group.MyGithubTest.location
  resource_group_name   = azurerm_resource_group.MyGithubTest.name
  network_interface_ids = [azurerm_network_interface.MyGithubTest.id]
  vm_size               = "Standard_DS1_v2"
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "azurevmosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "azuretest-server"
    admin_username = var.test_username
    admin_password = var.azureuser_pw
  }
  os_profile_linux_config {
    disable_password_authentication = false
    ssh_keys {
      path = "/home/var.test_username/.ssh/authorized_keys"
      //   key_data = file("/Users/karthik/.ssh/id_rsa.pub")
      key_data = "var.ssh_key"
    }
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update && sudo apt-get upgrade -y",
      "sudo apt-get install -y openjdk-11-jre-dcevm",
      "sudo apt install -y apache2",
    ]
  }
}
