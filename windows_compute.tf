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
resource "azurerm_virtual_machine_extension" "InGuestDiagnostics" {
  name                       = "Windowsdiagnostics"
  virtual_machine_id         = azurerm_windows_virtual_machine.Win-VM.id
  publisher                  = "Microsoft.Azure.Diagnostics"
  type                       = "IaaSDiagnostics"
  type_handler_version       = "1.16"
  auto_upgrade_minor_version = true
  settings           = <<SETTINGS
    {
      "xmlCfg": "${base64encode(templatefile("${path.module}/configs/wadcfgxml.tmpl", { vmid = azurerm_windows_virtual_machine.Win-VM.id }))}",
      "storageAccount": "${azurerm_storage_account.mystorageaccount.name}"
    }
SETTINGS
  protected_settings = <<PROTECTEDSETTINGS
    {
      "storageAccountName": "${azurerm_storage_account.mystorageaccount.name}",
      "storageAccountKey": "${azurerm_storage_account.mystorageaccount.primary_access_key}",
      "storageAccountEndPoint": "https://core.windows.net"
    }
PROTECTEDSETTINGS
}