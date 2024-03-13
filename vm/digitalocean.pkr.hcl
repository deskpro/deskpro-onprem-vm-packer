source "digitalocean" "deskpro-ubuntu" {
  region        = "nyc3"
  size          = "s-2vcpu-4gb"
  image         = "ubuntu-22-04-x64"
  snapshot_name = "deskpro-onprem-2023"

  user_data = "#cloud-config\n${yamlencode(local.cloud_user_data)}"

  ssh_username              = var.ssh_username
  ssh_clear_authorized_keys = true

  tags = concat(
    [
      "Environment:${var.environment}"
    ],
    [for k, v in local.build_tags : "${k}:${v}"]
  )
}
