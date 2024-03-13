source "virtualbox-iso" "deskpro-ubuntu" {
  boot_wait    = local.boot_wait
  boot_command = local.boot_command

  vm_name = var.vm_name
  cpus    = var.cpus
  memory  = var.memory

  disk_size            = var.disk_size_mb
  hard_drive_interface = "sata"

  guest_os_type             = "Ubuntu_64"
  guest_additions_path      = "VBoxGuestAdditions_{{.Version}}.iso"
  guest_additions_mode      = "upload"
  guest_additions_interface = "sata"
  virtualbox_version_file   = ".vbox_version"


  gfx_controller = "vmsvga"
  gfx_vram_size  = 32

  # vboxmanage = [
  #   [
  #     "modifyvm",
  #     "{{.Name}}",
  #     "--audio",
  #     "none",
  #     "--nat-localhostreachable1",
  #     "on",
  #   ]
  # ]

  headless     = var.headless
  http_content = local.http_content

  iso_checksum = var.iso_checksum
  iso_url      = var.iso_url

  shutdown_command = "echo '${var.ssh_password}' | sudo -S /sbin/shutdown -hP now"
  output_directory = "output-virtualbox"
  format           = "ova"
  export_opts = [
    "--manifest",
    "--vsys", "0",
    "--description", "Deskpro On Premise",
  ]

  ssh_username = var.ssh_username
  ssh_password = var.ssh_password
  ssh_timeout  = var.ssh_timeout
}
