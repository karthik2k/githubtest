
terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "SountiHome"

    workspaces {
      name = "MyAzureTerraform"
    }
  }
}

resource "azurerm_resource_group" "mygithubtest" {
  name = "mygithub_resource_group"
  location = "eastus"

}
