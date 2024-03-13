variable "cpus" {
  default = 2
}

variable "esxi_host" {
  type    = string
  default = ""
}

variable "esxi_server" {
  type    = string
  default = ""
}

variable "esxi_username" {
  type    = string
  default = ""
}

variable "esxi_password" {
  type    = string
  default = ""
}

variable "cloudflared_hostname" {
  type    = string
  default = ""
}

variable "deskpro_installer_url" {
  type    = string
  default = env("DESKPRO_INSTALLER_URL")
}

variable "disk_size_mb" {
  default = 65536
}

variable "dockerhub_username" {
  type    = string
  default = env("DOCKERHUB_USERNAME")
}

variable "dockerhub_token" {
  type      = string
  default   = env("DOCKERHUB_TOKEN")
  sensitive = true
}

variable "environment" {
  default = "dev"
}

variable "github_event_name" {
  default = env("GITHUB_EVENT_NAME")
}

variable "headless" {
  default = true
}

variable "hostname" {
  default = "deskpro-opc"
}

variable "iso_checksum" {
  default = "sha256:a4acfda10b18da50e2ec50ccaf860d7f20b389df8765611142305c0e911d16fd"
}

variable "iso_url" {
  default = "https://dpbuild-onprem-vm-isos.s3.amazonaws.com/ubuntu-22.04.3-live-server-amd64.iso"
}

variable "mac_address" {
  default = ""
}

variable "memory" {
  default = 4 * 1024
}

variable "project_id" {
  type        = string
  description = "Project ID in GCP"
  default     = "deskpro-onprem-vm"
}

variable "ssh_username" {
  default = "deskpro_admin"
}

# changing this also requires changing the password hash in local.user_data
variable "ssh_password" {
  default = "deskpro"
}

variable "ssh_timeout" {
  default = "1800s"
}

variable "vm_name" {
  default = "Deskpro"
}

variable "azure_resource_group_name" {
  type      = string
  default   = env("AZURE_RESOURCE_GROUP_NAME")
  sensitive = true
}

variable "azure_service_principal_password" {
  type      = string
  default   = env("AZURE_SERVICE_PRINCIPAL_PASSWORD")
  sensitive = true
}

variable "azure_service_principal_tenant_id" {
  type      = string
  default   = env("AZURE_SERVICE_PRINCIPAL_TENANT_ID")
  sensitive = true
}

variable "azure_subscription_id" {
  type      = string
  default   = env("AZURE_SUBSCRIPTION_ID")
  sensitive = true
}

variable "azure_service_principal_app_id" {
  type      = string
  default   = env("AZURE_SERVICE_PRINCIPAL_APP_ID")
  sensitive = true
}
