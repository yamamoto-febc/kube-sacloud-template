#!/bin/bash
# @sacloud-once

export DEBIAN_FRONTEND=noninteractive
echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers || exit 1
exit 0
