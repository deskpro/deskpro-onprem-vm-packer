source "hyperv-iso" "deskpro-ubuntu" {
  boot_wait    = local.hyperv_boot_wait
  boot_command = local.hyperv_boot_command

  guest_additions_mode = "disable"
  disk_size            = var.disk_size_mb

  headless     = var.headless
  http_content = local.http_content
  vm_name      = var.vm_name

  cpus   = var.cpus
  memory = var.memory

  iso_checksum = var.iso_checksum
  iso_url      = var.iso_url

  shutdown_command = "echo '${var.ssh_password}' | sudo -S /sbin/shutdown -hP now"
  output_directory = "output-hyperv"

  communicator = "ssh"
  ssh_port     = 22
  ssh_username = var.ssh_username
  ssh_password = var.ssh_password
  ssh_timeout  = var.ssh_timeout

  configuration_version = "8.0"
  generation            = 2
  enable_secure_boot    = false
  switch_name           = "Default Switch"
}
