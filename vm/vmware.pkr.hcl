source "vsphere-iso" "deskpro-ubuntu" {
  boot_wait    = local.boot_wait
  boot_command = local.boot_command

  vcenter_server      = var.esxi_server
  username            = var.esxi_username
  password            = var.esxi_password
  insecure_connection = true

  CPUs          = var.cpus
  RAM           = var.memory
  guest_os_type = "ubuntu64Guest"

  # Support ESXI 6.5+
  vm_version = 13

  http_port_min = 8889
  http_port_max = 8889
  http_content  = local.http_content

  vm_name = var.vm_name
  host    = var.esxi_host

  iso_checksum = var.iso_checksum
  iso_url      = var.iso_url

  network_adapters {
    network      = "VM Network"
    network_card = "vmxnet3"
    mac_address  = var.mac_address
  }

  storage {
    disk_size             = var.disk_size_mb
    disk_thin_provisioned = true
  }

  ssh_username = var.ssh_username
  ssh_password = var.ssh_password
  ssh_timeout  = var.ssh_timeout

  create_snapshot = true

  export {
    name             = "deskpro"
    force            = true
    output_directory = "output-vmware"
  }
}
