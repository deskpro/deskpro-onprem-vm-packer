#!/bin/sh
set -eux

# Increase the ES startup timeout
# Reason: ES takes time to start and on CPU constrained systems, particularly those
# being used for demo purposes, ES might take longer to startup.
mkdir -p /etc/systemd/system/elasticsearch.service.d
cat <<'EOF' | tee /etc/systemd/system/elasticsearch.service.d/override.conf
[Service]
TimeoutStartSec=180
EOF

# Disable unnecessary services
# Reason: man-db takes quite a while to regenerate manuals, which aren't important
#         motd-news is about updating the motd message with news from Ubuntu, which isn't important
#         mdadm is a toold for managing raid arrays, but its a vm and we dont have any so not relevant
#         remote-fs is a target for the init of remote file systems, but its a vm and we dont configure any
#         lvm2 is for managing lvm volumes, but we dont use them, so not relevant
systemctl mask \
  man-db.timer \
  man-db.service \
  motd-news.timer \
  mdmonitor-oneshot.timer \
  mdcheck_continue.timer \
  mdcheck_start.timer \
  remote-fs.target \
  lvm2-monitor.service \
  lvm2-lvmpolld.service \
  lvm2-lvmpolld.socket
