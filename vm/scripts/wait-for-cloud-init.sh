#!/bin/sh
set -eux

if command -v cloud-init 2>&1 >/dev/null ; then
	cloud-init status --wait
fi
