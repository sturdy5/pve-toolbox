#!/bin/bash

# install tailscale
curl -fsSL https://tailscale.com/install.sh | sh

tailscale up
