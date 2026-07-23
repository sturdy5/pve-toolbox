#!/bin/bash
#
# This script is intended to be run in your linux container (lxc). It will setup tailscale to listen on a port other than 80 or 443.
#

# make sure we have exactly one argument
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <port>"
  exit 1
fi

port=$1

# check to see if the script is being run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# make sure tailscale is installed
if ! command -v tailscale &> /dev/null; then
  echo "tailscale could not be found, please install it first"
  exit 1
fi

# create the systemd service file
cat <<EOF > /etc/systemd/system/tailscale-serve.service
[Unit]
Description=Tailscale Serve Port $port
After=tailscaled.service
Requires=tailscaled.service

[Service]
Type=simple
ExecStartPre=/bin/sleep 5
ExecStart=/usr/bin/tailscale serve $port
ExecStop=/usr/bin/tailscale serve off

[Install]
WantedBy=multi-user.target
EOF

# reload systemd daemon
systemctl daemon-reload
# enable and start the service
systemctl enable tailscale-serve.service
systemctl start tailscale-serve.service
