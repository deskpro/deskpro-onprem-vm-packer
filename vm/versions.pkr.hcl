packer {
  required_plugins {
    amazon        = { version = "~> 1.0", source = "github.com/hashicorp/amazon" }
    azure         = { version = "~> 1.0", source = "github.com/hashicorp/azure" }
    digitalocean  = { version = "~> 1.0", source = "github.com/digitalocean/digitalocean" }
    googlecompute = { version = "~> 1.0", source = "github.com/hashicorp/googlecompute" }
    hyperv        = { version = "~> 1.0", source = "github.com/hashicorp/hyperv" }
    qemu          = { version = "~> 1.0", source = "github.com/hashicorp/qemu" }
    virtualbox    = { version = "~> 1.0", source = "github.com/hashicorp/virtualbox" }
    vsphere       = { version = "~> 1.0", source = "github.com/hashicorp/vsphere" }
  }
}
