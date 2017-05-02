#!/bin/bash

DEF_IFACE="$(cat /tmp/default-network-interface)"
ENX_IFACES="$(cat /tmp/enx-network-interfaces)"

iptables -t nat -D POSTROUTING -o $DEF_IFACE -j MASQUERADE

for IFACE in $ENX_IFACES; do
    iptables -t filter -D FORWARD -i $IFACE -o $DEF_IFACE -j ACCEPT
    iptables -t filter -D FORWARD -i $DEF_IFACE -o $IFACE -j ACCEPT
done

echo 0 > /proc/sys/net/ipv4/ip_forward
