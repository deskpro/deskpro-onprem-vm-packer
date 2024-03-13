#!/bin/sh
set -eux

# Delete user passwords
passwd -dl "${SSH_USERNAME}"
passwd -dl "root"
