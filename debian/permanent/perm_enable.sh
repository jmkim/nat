#!/bin/bash

# chkdep: Check dependencies for run this script
# $1    app_name
# $2    method_to_check         (ex. which appname)
# $3    is_required             (0: false, 1: true)
# $4    not_installed_retval    (0 means installed)
chkdep()
{
    echo -n "Check if $1 is available... "
    $2 &> /dev/null

    if [[ $? -ne 0 ]]; then
        echo "FAIL"
        (>&2 echo "Error: $1 is not installed. (Hint: 'sudo apt install $1')")

        if [[ $3 -eq 0 ]]; then return $4; else exit $4; fi
    else
        echo "OK"
    fi
}

chkdep "iptables" "which iptables" 0 -1
chkdep "iptables-persistent" "which iptables-apply" 1 -2

DEF_IFACE="$(route | grep '^default' | awk '{print $1}')"
ENX_IFACES="$(route | egrep 'enx[0-9a-f]{12}' | awk '{print $1}')"

echo "$DEF_IFACE" > /tmp/default-network-interface
echo "$ENX_IFACES" > /tmp/enx-network-interfaces

sed -i~ '/net.ipv4.ip_forward/d' /etc/sysctl.d/00-ip-forward.conf &> /dev/null
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.d/00-ip-forward.conf
sysctl -p /etc/sysctl.d/00-ip-forward.conf &> /dev/null

iptables -t nat -D POSTROUTING -o $DEF_IFACE -j MASQUERADE &> /dev/null
iptables -t nat -A POSTROUTING -o $DEF_IFACE -j MASQUERADE

for IFACE in $ENX_IFACES; do
    iptables -t filter -D FORWARD -i $IFACE -o $DEF_IFACE -j ACCEPT &> /dev/null
    iptables -t filter -D FORWARD -i $DEF_IFACE -o $IFACE -j ACCEPT &> /dev/null
    iptables -t filter -A FORWARD -i $IFACE -o $DEF_IFACE -j ACCEPT
    iptables -t filter -A FORWARD -i $DEF_IFACE -o $IFACE -j ACCEPT
done

touch /etc/network/iptables.up.rules
iptables-save > /etc/iptables/rules.v4
iptables-restore < /etc/iptables/rules.v4
iptables-apply
