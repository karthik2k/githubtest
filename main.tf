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
  version  = ">= 2.0"
  features {}
}

resource "azurerm_resource_group" "mygithubtest" {
  name = "mygithub_resource_group"
  location = "eastus"
}
