# Create virtual Windows machine
resource "azurerm_windows_virtual_machine" "Win-VM" {
    name                  = "myWinVM"
    location              = "eastus"
    resource_group_name   = azurerm_resource_group.myterraformgroup.name
    network_interface_ids = [azurerm_network_interface.WinNIC.id]
    size                  = "Standard_F2"

    os_disk {
        caching           = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2016-Datacenter"
        version   = "latest"
    }

    computer_name  = "myWinvm"
    admin_username = "azureuser"
    admin_password = "P4ssw0rd"

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
    }

    tags = {
        environment = "Terraform Demo"
    }
}

#Add Windows Diagnostic Extension
# resource "azurerm_virtual_machine_extension" "InGuestDiagnostics" {
#   name                       = var.compute["InGuestDiagnostics"]["name"]
#   location                   = azurerm_resource_group.VMResourceGroup.location
#   resource_group_name        = azurerm_resource_group.VMResourceGroup.name
#   virtual_machine_name       = azurerm_virtual_machine.Compute.name
#   publisher                  = var.compute["InGuestDiagnostics"]["publisher"]
#   type                       = var.compute["InGuestDiagnostics"]["type"]
#   type_handler_version       = var.compute["InGuestDiagnostics"]["type_handler_version"]
#   auto_upgrade_minor_version = var.compute["InGuestDiagnostics"]["auto_upgrade_minor_version"]

#   settings           = <<SETTINGS
#     {
#       "xmlCfg": "${base64encode(templatefile("${path.module}/templates/wadcfgxml.tmpl", { vmid = azurerm_virtual_machine.Compute.id }))}",
#       "storageAccount": "${data.azurerm_storage_account.InGuestDiagStorageAccount.name}"
#     }
# SETTINGS
#   protected_settings = <<PROTECTEDSETTINGS
#     {
#       "storageAccountName": "${data.azurerm_storage_account.InGuestDiagStorageAccount.name}",
#       "storageAccountKey": "${data.azurerm_storage_account.InGuestDiagStorageAccount.primary_access_key}",
#       "storageAccountEndPoint": "https://core.windows.net"
#     }
# PROTECTEDSETTINGS
# }