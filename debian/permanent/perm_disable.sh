#!/bin/bash

DEF_IFACE="$(cat /tmp/default-network-interface)"
ENX_IFACES="$(cat /tmp/enx-network-interfaces)"

iptables -t nat -D POSTROUTING -o $DEF_IFACE -j MASQUERADE

for IFACE in $ENX_IFACES; do
    iptables -t filter -D FORWARD -i $IFACE -o $DEF_IFACE -j ACCEPT
    iptables -t filter -D FORWARD -i $DEF_IFACE -o $IFACE -j ACCEPT
done

sed -i~ '/net.ipv4.ip_forward=1/d' /etc/sysctl.d/00-ip-forward.conf
rm /etc/sysctl.d/00-ip-forward.conf~

if [[ "$(wc -l /etc/sysctl.d/00-ip-forward.conf)" == "0" ]]; then
    rm /etc/sysctl.d/00-ip-forward.conf
else
    sysctl -p /etc/sysctl.d/00-ip-forward.conf
fi
