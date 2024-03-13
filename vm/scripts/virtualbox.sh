#!/bin/sh
set -eux

case "$PACKER_BUILDER_TYPE" in
  virtualbox-iso)
    VER="$(cat "/home/${SSH_USERNAME}/.vbox_version")";
    ISO="VBoxGuestAdditions_$VER.iso";

    # mount the ISO to /tmp/vbox
    mkdir -p /tmp/vbox;
    mount -o loop "/home/${SSH_USERNAME}/$ISO" /tmp/vbox;

    echo "installing deps necessary to compile kernel modules"
    # We install things like kernel-headers here vs. preseed files so we make sure we install them for the updated kernel not the stock kernel
    apt-get install -y build-essential dkms bzip2 tar linux-headers-`uname -r`

    echo "installing the vbox additions"
    # this install script fails with non-zero exit codes for no apparent reason so we need better ways to know if it worked
    /tmp/vbox/VBoxLinuxAdditions.run --nox11 || true

    if ! modinfo vboxsf >/dev/null 2>&1; then
         echo "Cannot find vbox kernel module. Installation of guest additions unsuccessful!"
         exit 1
    fi

    echo "unmounting and removing the vbox ISO"
    umount /tmp/vbox;
    rm -rf /tmp/vbox;
    rm -f /home/"${SSH_USERNAME}"/*.iso;

    echo "removing kernel dev packages and compilers we no longer need"
    apt-get remove -y build-essential gcc g++ make libc6-dev dkms linux-headers-`uname -r`

    echo "removing leftover logs"
    rm -rf /var/log/vboxadd*
    ;;
esac
