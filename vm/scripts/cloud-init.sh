#!/bin/sh
set -eux

apt install -y cloud-init

# Packer builder specific config
mkdir -p /etc/cloud/cloud.cfg.d/

# Delete Ubuntu specific config file installed by cloudinit
# that removes all data source configurations
rm -f /etc/cloud/cloud.cfg.d/99-installer.cfg

if [ -n "$CLOUD_INIT_CLOUD_CONFIG" ]; then
  echo "$CLOUD_INIT_CLOUD_CONFIG" > /etc/cloud/cloud.cfg.d/50_deskpro_opc_cloud.cfg
fi

# Prepare VM specific configs
case "$PACKER_BUILDER_TYPE" in
  vsphere-iso)
    echo "configuring vmware cloudinit configuration"
    {
      echo "datasource_list: [ \"VMware\", \"NoCloud\", \"None\" ]"
      echo "disable_vmware_customization: false"
    } > /etc/cloud/cloud.cfg.d/90_dpkg.cfg
    ;;
  amazon-ebs)
    echo "configuring aws cloudinit configuration"
    {
      echo "datasource_list: [ \"Ec2\", \"None\" ]"
    } > /etc/cloud/cloud.cfg.d/90_dpkg.cfg
    ;;
  digitalocean)
    echo "configuring do cloudinit configuration"
    {
      echo "datasource_list: [ \"DigitalOcean\", \"None\" ]"
    } > /etc/cloud/cloud.cfg.d/90_dpkg.cfg
    ;;
  googlecompute)
    echo "configuring gcp cloudinit configuration"
    {
      echo "datasource_list: [ \"GCE\", \"None\" ]"
    } > /etc/cloud/cloud.cfg.d/90_dpkg.cfg
    ;;
  azure-arm)
    echo "configuring azure cloudinit configuration"
    {
      echo "datasource_list: [ \"Azure\", \"None\" ]"
    } > /etc/cloud/cloud.cfg.d/90_dpkg.cfg
    ;;
  *)
    echo "configuring generic cloudinit configuration"
    {
      echo "datasource_list: [ \"NoCloud\", \"None\" ]"
    } > /etc/cloud/cloud.cfg.d/90_dpkg.cfg
    ;;
esac
