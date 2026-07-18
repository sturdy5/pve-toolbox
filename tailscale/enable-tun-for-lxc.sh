#!/bin/bash
#
# This script is intended to run on your proxmox host. It will enable tun (network tunneling) for the linux containers (lxc)
# running on your host. This is a pre-requisite for running tailscale within the lxc.
#

# make sure we have exactly one argument
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <lxc id>"
  exit 1
fi

lxc_id=$1

# check to see if tun is already enabled for the lxc container
if cat /etc/pve/lxc/$lxc_id.conf | grep -q "lxc.cgroup2.devices.allow: c 10:200 rwm"; then
  echo "tun is already enabled for lxc container $lxc_id"
  exit 0
fi

# enable tun for the lxc container
echo "Enabling tun for lxc container $lxc_id"
echo "lxc.cgroup2.devices.allow: c 10:200 rwm" >> /etc/pve/lxc/$lxc_id.conf
echo "lxc.mount.entry: /dev/net/tun dev/net/tun none bind,create=file" >> /etc/pve/lxc/$lxc_id.conf

# restart the lxc container
echo "Restarting lxc container $lxc_id"
pct reboot $lxc_id
