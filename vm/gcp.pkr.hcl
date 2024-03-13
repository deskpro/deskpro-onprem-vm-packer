source "googlecompute" "deskpro-ubuntu" {
  project_id                = "deskpro-onprem-vm"
  source_image_family       = "ubuntu-2004-lts"
  ssh_username              = var.ssh_username
  image_description         = "custom machine image"
  image_name                = "deskpro-onprem-{{timestamp}}"
  ssh_clear_authorized_keys = true
  disk_size                 = floor(var.disk_size_mb / 1024)
  wrap_startup_script       = false
  machine_type              = "n1-standard-1"
  zone                      = "us-central1-a"

  labels = local.build_tags

}
build {
  sources = ["sources.googlecompute.deskpro-ubuntu"]
}
