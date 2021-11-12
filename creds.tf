# Create (and display) an SSH key
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits = 4096
}
output "tls_private_key" { 
    value = tls_private_key.example_ssh.private_key_pem 
    sensitive = true
}

data "azurerm_storage_account_sas" "token" {
  connection_string = azurerm_storage_account.mystorageaccount.connection_string.value
  https_only        = true

  resource_types {
    service   = true
    container = true
    object    = true
  }

  services {
    blob  = true
    table = true
    queue = false
    file = false
  }

  start  = time_offset.sas_start.rfc3339
  expiry = time_offset.sas_expiry.rfc3339

  permissions {
    read    = true
    write   = true
    delete  = true
    list    = true
    add     = true
    create  = true
    update  = true
    process = true
  }
}