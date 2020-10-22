output "azurerm_storage_account" {
  value = azurerm_storage_account.MyGithubTest_Storage.name
}

output "azurerm_network_interface" {
  value = azurerm_network_interface.MyGithubTest.name
}
output "azure_dns_a_record" {
  value = "azurerm_dns_zone.MyGithubTest.name"
}
output "azurerm_public_ip" {
  value = "azurerm_public_ip.MyGithubTest.id"
}