#!/bin/sh
set -eux

# Only add the secure path line if it is not already present
grep -q 'secure_path' /etc/sudoers \
  || sed -i -e '/Defaults\s\+env_reset/a Defaults\tsecure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"' /etc/sudoers;

# Set up password-less sudo for the user
echo "${SSH_USERNAME} ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/99_deskpro;
chmod 440 /etc/sudoers.d/99_deskpro;
