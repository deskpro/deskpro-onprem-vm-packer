source "qemu" "deskpro-ubuntu" {
  boot_wait    = local.qemu_boot_wait
  boot_command = local.boot_command

  vm_name = var.vm_name
  cpus    = var.cpus
  memory  = var.memory

  disk_size = "${var.disk_size_mb}M"

  headless     = var.headless
  http_content = local.http_content

  iso_checksum = var.iso_checksum
  iso_url      = var.iso_url

  shutdown_command = "echo '${var.ssh_password}' | sudo -S /sbin/shutdown -hP now"
  output_directory = "output-qemu"
  format           = "qcow2"

  ssh_username = var.ssh_username
  ssh_password = var.ssh_password
  ssh_timeout  = var.ssh_timeout
}
