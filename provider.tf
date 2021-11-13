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

provider "time" {
  version = "~> 0.4"
}

//== Store 10 years in the future ==//
resource "time_offset" "sas_expiry" {
  offset_years = 10
}

//== Store (now - 10) days to ensure we have valid SAS ==//
resource "time_offset" "sas_start" {
  offset_days = -10
}
