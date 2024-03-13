source "amazon-ebs" "deskpro-ubuntu" {
  assume_role {
    role_arn = "arn:aws:iam::103710129413:role/packer"
  }

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }

  vpc_filter {
    filters = {
      "tag:Name" = "packer"
    }
  }

  subnet_filter {
    filters = {
      "tag:Application" : "packer"
    }
    most_free = true
    random    = true
  }

  ami_name                = "deskpro-onprem-{{timestamp}}"
  ami_description         = "Deskpro OnPremise"
  ami_virtualization_type = "hvm"
  instance_type           = "m5.large"
  region                  = "us-east-1"
  ssh_username            = var.ssh_username

  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = floor(var.disk_size_mb / 1024)
    volume_type           = "gp2"
    delete_on_termination = true
  }

  ami_users = ["780541616714", "208502828811"]

  user_data = "#cloud-config\n${yamlencode(local.cloud_user_data)}"

  tags = {
    Environment = var.environment
  }

  run_volume_tags = local.build_tags
  run_tags        = local.build_tags
  # skip_create_ami         = true

  aws_polling {
    delay_seconds = 30
    max_attempts  = 240
  }
}
