/**
Linux Diagnostic Agent
The linux diagnostic agent is rather complicated to get working.
You need:
1. A static timestamp for start/expiry time
2. A SAS token from the storage account with custom permissions
3. Importing multiple large jsons with custom cleanup
This is taken care of for everything below
**/

# Create virtual machine
resource "azurerm_linux_virtual_machine" "myterraformvm" {
    name                  = "myVM"
    location              = "eastus"
    resource_group_name   = azurerm_resource_group.myterraformgroup.name
    network_interface_ids = [azurerm_network_interface.LinuxNIC.id]
    size                  = "Standard_DS1_v2"

    os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    computer_name  = "myvm"
    admin_username = "azureuser"
    disable_password_authentication = true

    admin_ssh_key {
        username       = "azureuser"
        public_key     = tls_private_key.example_ssh.public_key_openssh
    }

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.storageaccount.primary_blob_endpoint
    }

    tags = {
        environment = "Terraform Demo"
    }
}

//=== Install Linux Diagnostic Extension ===//
resource "azurerm_virtual_machine_extension" "diagnostics" {
  count                      = var.provision ? 1 : 0
  name                       = "LinuxDiagnostic"
  virtual_machine_id         =  azurerm_linux_virtual_machine.myterraformvm.id
  publisher                  = "Microsoft.Azure.Diagnostics"
  type                       = "LinuxDiagnostic"
  type_handler_version       = "3.0"
  auto_upgrade_minor_version = "true"

  settings = <<SETTINGS
    {
      "StorageAccount": "${azurerm_storage_account.storageaccount.name}",
      "ladCfg": {
          "diagnosticMonitorConfiguration": {
                "eventVolume": "Medium", 
                "metrics": {
                     "metricAggregation": [
                        {
                            "scheduledTransferPeriod": "PT1H"
                        }, 
                        {
                            "scheduledTransferPeriod": "PT1M"
                        }
                    ], 
                    "resourceId": "${azurerm_linux_virtual_machine.myterraformvm.id}"
                },
                "performanceCounters": ${file("${path.module}/configs/performancecounters.json")},
                "syslogEvents": ${file("${path.module}/configs/syslogevents.json")}
          }, 
          "sampleRateInSeconds": 15
      }
    }
  SETTINGS

  protected_settings = <<SETTINGS
    {
        "storageAccountName": "${azurerm_storage_account.storageaccount.name}",
        "storageAccountSasToken": "${data.azurerm_storage_account_sas.token.sas}",
        "storageAccountEndPoint": "https://core.windows.net",
         "sinksConfig":  {
              "sink": [
                {
                    "name": "SyslogJsonBlob",
                    "type": "JsonBlob"
                },
                {
                    "name": "LinuxCpuJsonBlob",
                    "type": "JsonBlob"
                }
              ]
        }
    }
    SETTINGS
}