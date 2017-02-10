resource "azurerm_network_interface" "test" {
  name                = "test"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${azurerm_subnet.test.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.test.id}"
  }

  tags {
    //Name = "westus-example"
  }
}
