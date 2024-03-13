locals {
  cloud_user_data = {
    system_info = {
      default_user = {
        name        = var.ssh_username
        shell       = "/bin/bash"
        lock_passwd = true
        gecos       = "Deskpro Administrator"
        groups      = ["adm", "audio", "cdrom", "dialout", "dip", "floppy", "lxd", "netdev", "plugdev", "sudo", "video"]
        sudo        = ["ALL=(ALL) NOPASSWD:ALL"]
      }
    }
  }

  user_data = {
    autoinstall = {
      "version" = 1
      "early-commands" = [
        # otherwise packer tries to connect and exceed max attempts:
        "systemctl stop ssh"
      ]
      "late-commands" = [
        # Perform upgrade during late-commands on first install to avoid
        # unnecessary reboots, as each reboot is causing a different IP
        # lease on DHCP which breaks subsequent provisioning scripts
        # after the reboot
        "curtin in-target --target=/target -- sed -i.bak 's/^Prompt=.*$/Prompt=never/' /etc/update-manager/release-upgrades",

        "curtin in-target --target=/target -- apt update -y",
        "curtin in-target --target=/target -- apt-get -y dist-upgrade -o Dpkg::Options::='--force-confnew'",
        "curtin in-target --target=/target -- apt install -y linux-image-generic linux-cloud-tools-virtual",

        # temp fix for missing packages in Ubuntu 22.04 upgrade whilst we wait for an OPC deployment
        "curtin in-target --target=/target -- apt install -y ufw cron bsdextrautils iputils-ping",

        # Force use of legacy interface names so that the one nic
        # we need to attach is always eth0 for all hypervisors
        "curtin in-target --target=/target -- sed -i 's/GRUB_CMDLINE_LINUX=\"\\(.*\\)\"/GRUB_CMDLINE_LINUX=\"net.ifnames=0 biosdevname=0 \\1\"/g' /etc/default/grub",
        "curtin in-target --target=/target -- update-grub",
      ],
      locale = "en_US.UTF-8"
      storage = {
        layout = {
          name = "direct"
        }
      }
      identity = {
        realname = "Deskpro Administrator"
        username = var.ssh_username
        hostname = var.hostname
        # Generated via: printf deskpro | mkpasswd -m sha-512 -S deskproadmin -s
        password = "$6$deskproadmin$Q9aw0M0e.S5GpoBwnc4lv.f26PI0x.mQ4/poo7nxOEHWvhheSHRzVRITcwpBRlOwVIhN/mIWe2ZRkrLaI3iI41"
      }
      ssh = {
        "install-server" = true
      }
      source = {
        id = "ubuntu-server-minimal"
      }
      packages = [
        "bash",
      ]
    }
  }

  http_content = {
    "/meta-data" = ""
    "/user-data" = "#cloud-config\n${yamlencode(local.user_data)}"
  }

  http_address = coalesce(var.cloudflared_hostname, "{{.HTTPIP}}")
  http_port    = var.cloudflared_hostname == "" ? "{{.HTTPPort}}" : "80"

  # this wait time needs to be low: if we don't act as soon as the vm boots, we
  # get sent to the default graphical installer where none of this works
  boot_wait = "3s"
  boot_command = [
    "<wait>c<wait><enter>",
    "<wait>set gfxpayload=keep<enter>",
    "<wait>linux /casper/vmlinuz ",
    "<wait>\"ds=nocloud-net;s=http://${local.http_address}:${local.http_port}/\" ",
    "<wait>net.ifnames=0 biosdevname=0 ",
    "<wait>quiet autoinstall ---<enter>",
    "<wait>initrd /casper/initrd<enter>",
    "<wait>boot<enter>"
  ]

  # this boot wait time needs to be even lower: our hyper-v VMs are being created
  # with generation 2 because booting generation 1 was a bit unreliable. and
  # generation 2 uses UEFI, which uses a different boot menu that only stays up
  # for a few seconds, so we need to use a different boot command and wait less
  # than wait on other builders
  hyperv_boot_wait = "3s"
  hyperv_boot_command = [
    "<esc><wait><esc><wait><esc><wait>",
    "<wait>c<enter>",
    "<wait>set gfxpayload=text<enter>",
    "<wait>linux /casper/vmlinuz ",
    "<wait>\"ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/\" ",
    "<wait>net.ifnames=0 biosdevname=0 ",
    "<wait>quiet autoinstall ---<enter>",
    "<wait>initrd /casper/initrd<enter>",
    "<wait>boot<enter>"
  ]

  # qemu just needs to happen faster because it starts fast enough that 5s does not cut it
  qemu_boot_wait = "3s"

  build_tags = {
    "created-by" = "packer"
  }
}

build {
  name = "privatecloud"

  sources = [
    "source.vsphere-iso.deskpro-ubuntu",
    "source.virtualbox-iso.deskpro-ubuntu",
    "source.hyperv-iso.deskpro-ubuntu",
    "source.qemu.deskpro-ubuntu",
  ]

  provisioner "shell" {
    environment_vars = [
      "DOCKERHUB_USERNAME=${var.dockerhub_username}",
      "DOCKERHUB_TOKEN=${var.dockerhub_token}",
      "SSH_USERNAME=${var.ssh_username}",
      "DESKPRO_INSTALLER_URL=${var.deskpro_installer_url}",
      "CLOUD_INIT_CLOUD_CONFIG=${yamlencode(local.cloud_user_data)}",
      "GITHUB_EVENT_NAME=${var.github_event_name}",
    ]

    scripts = [
      "scripts/update.sh",
      "scripts/sshd.sh",
      "scripts/sudoers.sh",
      "scripts/systemd.sh",
      "scripts/vmware.sh",
      "scripts/virtualbox.sh",
      "scripts/hyperv.sh",
      "scripts/cloud-init.sh",
      "scripts/install-deskpro-opc.sh",
      "scripts/optimise.sh",
      "scripts/cleanup.sh",
      "scripts/minimize.sh",
      "scripts/reset-password.sh",
    ]

    execute_command   = "echo 'deskpro' | {{.Vars}} sudo -H -S -E bash '{{.Path}}'"
    expect_disconnect = true
    pause_before      = "30s"
    pause_after       = "30s"
  }
}

build {
  name = "publiccloud"

  sources = [
    "source.amazon-ebs.deskpro-ubuntu",
    "source.digitalocean.deskpro-ubuntu",
    "source.googlecompute.deskpro-ubuntu",
    "source.azure-arm.deskpro-ubuntu",
  ]

  provisioner "shell" {
    environment_vars = [
      "DOCKERHUB_USERNAME=${var.dockerhub_username}",
      "DOCKERHUB_TOKEN=${var.dockerhub_token}",
      "SSH_USERNAME=${var.ssh_username}",
      "DESKPRO_INSTALLER_URL=${var.deskpro_installer_url}",
      "CLOUD_INIT_CLOUD_CONFIG=${yamlencode(local.cloud_user_data)}",
      "GITHUB_EVENT_NAME=${var.github_event_name}",
    ]

    scripts = [
      "scripts/wait-for-cloud-init.sh",
      "scripts/update.sh",
      "scripts/sshd.sh",
      "scripts/sudoers.sh",
      "scripts/systemd.sh",
      "scripts/cloud-init.sh",
      "scripts/install-deskpro-opc.sh",
      "scripts/optimise.sh",
      "scripts/cleanup.sh",
      "scripts/minimize.sh",
      "scripts/post-cleanup-tasks.sh",
      "scripts/reset-password.sh",
      "scripts/99-img-check.sh",
    ]

    execute_command   = "echo 'deskpro' | {{.Vars}} sudo -H -S -E bash '{{.Path}}'"
    expect_disconnect = true
    pause_before      = "30s"
    pause_after       = "30s"
  }

  post-processor "manifest" {
    output     = "packer-manifest.json"
    strip_path = true
  }
}
