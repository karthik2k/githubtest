resource "azurerm_virtual_machine" "MyGithubTest" {
  name                  = var.vmname
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
      path = "/home/azadmin/.ssh/authorized_keys"
       //  key_data = file("/Users/karthik/.ssh/id_rsa.pub")
      key_data =  "var.ssh_key"
    }
  }
  provisioner "remote-exec" {
    inline = [
      "hostnamectl set-hostname var.vmname",
      "sudo apt-get update && sudo apt-get upgrade -y",
      "sudo apt-get install -y openjdk-11-jre-dcevm",
      "sudo apt install -y apache2",
    ]
    connection {
      type = "ssh"
      host = var.vmname
      user = var.test_username
      password = var.azureuser_pw
    }
  }
}