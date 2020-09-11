//test again
terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "SountiHome"

    workspaces {
      name = "MyAzureTerraform"
    }
  }
}

provider "azurerm" {
  version = "v2.0.0"
}

resource "azurerm_resource_group" "mygithubtest" {
  name = "mygithub_resource_group"
  location = "eastus"
}
