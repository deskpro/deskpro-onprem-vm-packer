source "azure-arm" "deskpro-ubuntu" {
  os_type = "Linux"

  client_id     = var.azure_service_principal_app_id
  client_secret = var.azure_service_principal_password
  tenant_id     = var.azure_service_principal_tenant_id

  build_resource_group_name = var.azure_resource_group_name
  subscription_id           = var.azure_subscription_id

  managed_image_name                = "deskpro-onprem-{{timestamp}}"
  managed_image_resource_group_name = var.azure_resource_group_name
  vm_size                           = "Standard_DS2_v2"

  image_publisher = "Canonical"
  image_offer     = "0001-com-ubuntu-server-jammy"
  image_sku       = "22_04-lts-gen2"

  azure_tags = local.build_tags
}
build {
  sources = ["sources.azure-arm.deskpro-ubuntu"]
}
