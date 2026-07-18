#!/bin/bash
#
# This script is intended to be run inside your linux container (lxc). It will install tailscale and start it up. Before running
# this script, you should use the enable-tun-for-lxc.sh script on your proxmox host first.
#

# install tailscale
curl -fsSL https://tailscale.com/install.sh | sh

tailscale up
