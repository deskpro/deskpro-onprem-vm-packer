#!/bin/sh
set -eux

SSHD_CONFIG="/etc/ssh/sshd_config"

# ensure that there is a trailing newline before attempting to concatenate
sed -i -e '$a\' "$SSHD_CONFIG"

USEDNS="UseDNS no"
if grep -q -E "^[[:space:]]*UseDNS" "$SSHD_CONFIG"; then
    sed -i "s/^\s*UseDNS.*/${USEDNS}/" "$SSHD_CONFIG"
else
    echo "$USEDNS" >>"$SSHD_CONFIG"
fi

GSSAPI="GSSAPIAuthentication no"
if grep -q -E "^[[:space:]]*GSSAPIAuthentication" "$SSHD_CONFIG"; then
    sed -i "s/^\s*GSSAPIAuthentication.*/${GSSAPI}/" "$SSHD_CONFIG"
else
    echo "$GSSAPI" >>"$SSHD_CONFIG"
fi

CLIENTALIVEINTERVAL="ClientAliveInterval 30"
if grep -q -E "^[[:space:]]*ClientAliveInterval" "$SSHD_CONFIG"; then
    sed -i "s/^\s*ClientAliveInterval.*/${CLIENTALIVEINTERVAL}/" "$SSHD_CONFIG"
else
    echo "$CLIENTALIVEINTERVAL" >>"$SSHD_CONFIG"
fi
