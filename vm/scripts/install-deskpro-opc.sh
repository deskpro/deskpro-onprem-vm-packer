#!/bin/sh
set -eux

case "$PACKER_BUILDER_TYPE" in
  amazon-ebs)
    export DESKPRO_PERMIT_SSH_PASSWORD_LOGIN="no"
    export DESKPRO_PERMIT_SSH_ROOT_LOGIN="no"
    ;;
esac


curl -sL "${DESKPRO_INSTALLER_URL:-https://get.deskpro.com/installer.sh}" > /tmp/opc-install.sh

install_source="VM-$(printf "%s" "$PACKER_BUILDER_TYPE" | tr '[:lower:]' '[:upper:]')"

bash -x /tmp/opc-install.sh -- \
  --non-interactive \
  --no-opc-init \
  --no-telemetry \
  --install-source "$install_source"

latest_deskpro_tag="$(curl -s https://get.deskpro.com/manifest.json | jq -r '.releases | max_by(.version | split(".") | map(try tonumber catch -1)) | .docker_tag')"

docker pull "deskpro/deskpro-product:${latest_deskpro_tag}"
