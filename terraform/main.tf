variable "location" { default = "westus" }

variable "username" { default = "ubuntu" }
variable "password" { default = "Password1234" }

resource "azurerm_resource_group" "test" {
  name     = "test"
  location = "${var.location}"
}

resource "azurerm_virtual_network" "test" {
  name                = "test"
  address_space       = ["10.0.0.0/16"]
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
}

resource "azurerm_subnet" "test" {
  name                 = "test"
  resource_group_name  = "${azurerm_resource_group.test.name}"
  virtual_network_name = "${azurerm_virtual_network.test.name}"
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_public_ip" "test" {
  name                         = "test"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.test.name}"
  public_ip_address_allocation = "static"
}

resource "azurerm_storage_account" "test" {
  name                = "testeaed353227ca"
  resource_group_name = "${azurerm_resource_group.test.name}"
  location            = "${var.location}"
  account_type        = "Standard_LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "test"
  resource_group_name   = "${azurerm_resource_group.test.name}"
  storage_account_name  = "${azurerm_storage_account.test.name}"
  container_access_type = "private"
}

resource "azurerm_virtual_machine" "test" {
  name                  = "test"
  location              = "${var.location}"
  resource_group_name   = "${azurerm_resource_group.test.name}"
  network_interface_ids = ["${azurerm_network_interface.test.id}"]
  vm_size               = "Standard_A0"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "14.04.2-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name          = "myosdisk1"
    vhd_uri       = "${azurerm_storage_account.test.primary_blob_endpoint}${azurerm_storage_container.test.name}/myosdisk1.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = "hostname1"
    admin_username = "${var.username}"
    admin_password = "${var.password}"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path = "/home/${var.username}/.ssh/authorized_keys"
      key_data = "${file("~/.ssh/id_rsa.pub")}"
    }
  }

  connection {
    host     = "${azurerm_public_ip.test.ip_address}"
    user     = "${var.username}"

    key_file = "${file("~/.ssh/id_rsa")}"
  }

  provisioner "remote-exec" {
    inline = ["echo 'CONNECTED!'"]
  }

  provisioner "file" {
    source      = "test.txt"
    destination = "/tmp/test.txt"
  }

  tags {
    Name = "${var.location}-example"
  }
}

output "public_ip" {
  value = "${azurerm_public_ip.test.ip_address}"
}
