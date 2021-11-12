# Configure the Microsoft Azure Provider
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.4"
    }
  }
}
provider "azurerm" {
  features {}
}

