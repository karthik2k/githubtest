//resource "azurerm_linux_virtual_machine" "myazure_vm" {
//  name                = "tokyo"
//  computer_name       = "tokyo"
//  resource_group_name = azurerm_resource_group.MyGithubTest.name
//  location            = azurerm_resource_group.MyGithubTest.location
//  size                = "Standard_B1ls"
//  admin_username      = var.test_username
//  network_interface_ids = [
//    azurerm_network_interface.MyGithubTest2.id,
//  ]
//
//  admin_ssh_key {
//    username   = var.test_username
//    public_key = file("~/.ssh/id_rsa.pub")
//  }
//
//  os_disk {
//    caching              = "ReadWrite"
//    storage_account_type = "Standard_LRS"
//  }
//
//  source_image_reference {
//    publisher = "Canonical"
//    offer     = "UbuntuServer"
//    sku       = "18_04-lts-gen2"
//    version   = "latest"
//  }
//}