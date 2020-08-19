resource "azurerm_resource_group" "mygithubtest" {
  name = "mygithub resource group"
  location = "eastus"

  tage {
    owner = " Karthik Si"
  }
}
