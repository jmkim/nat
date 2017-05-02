#!/bin/bash

DEF_IFACE="$(route | grep '^default' | awk '{print $1}')"
ENX_IFACES="$(route | egrep 'enx[0-9a-f]{12}' | awk '{print $1}')"

echo "$DEF_IFACE" > /tmp/default-network-interface
echo "$ENX_IFACES" > /tmp/enx-network-interfaces

echo 1 > /proc/sys/net/ipv4/ip_forward

iptables -t nat -D POSTROUTING -o $DEF_IFACE -j MASQUERADE &> /dev/null
iptables -t nat -A POSTROUTING -o $DEF_IFACE -j MASQUERADE

for IFACE in $ENX_IFACES; do
    iptables -t filter -D FORWARD -i $IFACE -o $DEF_IFACE -j ACCEPT &> /dev/null
    iptables -t filter -D FORWARD -i $DEF_IFACE -o $IFACE -j ACCEPT &> /dev/null
    iptables -t filter -A FORWARD -i $IFACE -o $DEF_IFACE -j ACCEPT
    iptables -t filter -A FORWARD -i $DEF_IFACE -o $IFACE -j ACCEPT
done

if [[ $? -eq 0 ]]; then echo "Success"; fi
