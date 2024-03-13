#!/bin/sh
set -eux

write_per_once_mysql_maintenance_password_handling() {
  echo "make sure the per-once directory exists"
  mkdir -p /var/lib/cloud/scripts/per-once/

  echo "write the per-once script to maintain the mysql system maintenance password"
  cat << 'EOF' > /var/lib/cloud/scripts/per-once/95-regen-mysql-secrets.sh
#!/bin/sh -e

if [ ! -f /etc/mysql/debian.cnf ]; then
    PASSWORD=$(mcookie | head -c 16)

    echo mysql-server-8.0 mysql-server/root_password password $PASSWORD | debconf-set-selections
    echo mysql-server-8.0 mysql-server/root_password_again password $PASSWORD | debconf-set-selections
    dpkg-reconfigure -f noninteractive mysql-server-8.0
fi
EOF

  chmod 755 /var/lib/cloud/scripts/per-once/95-regen-mysql-secrets.sh
  rm -f /etc/mysql/debian.cnf
}

write_per_once_opc_init() {
  echo "make sure the per-once directory exists"
  mkdir -p /var/lib/cloud/scripts/per-once/

  echo "write the per-once script to initialize opc"
  cat << EOF > /var/lib/cloud/scripts/per-once/95-init-opc.sh
#!/bin/bash

source /opt/deskpro/provision/vm/opc-console-screen-utils

args=()

address="\$(metadata_ip_addresses | jq -r .address)"
version="\$(opc_install_version)"

if [ -n "\$address" ]; then
  args+=(--address "\$address")
fi

if [ -n "\$version" ]; then
  args+=(--opc-image-tag "\$version")

  if echo "\$version" | grep -q '^dev-' ; then
    mkdir -p /root/.config
    chmod 700 /root/.config

    echo "devMode: true" >> /root/.config/deskpro-opc-cli.yml
  fi
fi

opc init-opc "\${args[@]}"

if ! opc_install_version | grep -qE -- '-(dev|beta)\\b' ; then
  export HOME=/root
  opc update-opc
fi

EOF
  chmod 755 /var/lib/cloud/scripts/per-once/95-init-opc.sh
}

delete_extra_log_files() {
  echo "truncate any logs that have built up during the minization process"
  find /var/log -type f -exec truncate --size=0 {} \;
}

case "$PACKER_BUILDER_TYPE" in
  amazon-ebs|azure-arm|digitalocean|googlecompute)
    write_per_once_mysql_maintenance_password_handling
    write_per_once_opc_init
    delete_extra_log_files
    ;;
esac
