#!/bin/sh
set -eux

case "$PACKER_BUILDER_TYPE" in
  hyperv-iso)
    echo "do nothing, hyperv is already configured"
    ;;

  *)
    echo "removing hyperv-only packages"
    dpkg --list \
      | awk '{ print $2 }' \
      | grep 'linux-cloud-tools-' \
      | xargs apt-get -y purge;
    ;;
esac
