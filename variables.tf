variable "azurerm_storage_account_name" {
    type = string
    description = "Azure storage account name to store the diagnostics. Typically [azurerm_storage_account.main.name]"
}
variable "azurerm_storage_account_primary_connection_string" {
    type = string
    description = "Azure storage account connection string. Typically [azurerm_storage_account.main.primary_connection_string]"
}
