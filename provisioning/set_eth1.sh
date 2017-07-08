#!/bin/bash
# @sacloud-once

export DEBIAN_FRONTEND=noninteractive
sed -i '/auto eth1/d' /etc/network/interfaces
sed -i '/iface eth1 inet manual/d' /etc/network/interfaces
echo "auto eth1" >> /etc/network/interfaces
echo "iface eth1 inet static" >> /etc/network/interfaces
echo "address ${ip}" >> /etc/network/interfaces
echo "netmask 24" >> /etc/network/interfaces

ifdown eth1; ifup eth1
exit 0

#sed -i 's/gateway/#gateway/g' /etc/network/interfaces
#echo "up route add default gw %s" >> /etc/network/interfaces
#exit 0
