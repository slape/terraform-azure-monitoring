
resource "azurerm_storage_account" "storageaccount" {
    name                        = "storrage" #"diag${random_id.randomId.hex}"
    resource_group_name         = azurerm_resource_group.myterraformgroup.name
    location                    = "eastus"
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = {
        environment = "Terraform Demo"
    }
}

# resource "azurerm_storage_container" "example" {
#     name            = "example"
#     storage_account_name = azurerm_storage_account.storageaccount.name
#     container_access_type = "private"
# }