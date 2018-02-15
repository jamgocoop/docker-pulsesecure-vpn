#!/bin/sh
set -e
set -x

echo $VPN_PASSWORD | openconnect -q --cookieonly $OPENCONNECT_OPTIONS --disable-ipv6 -c /root/$VPN_USER.pem --protocol=nc --os=linux $VPN_URL -u $VPN_USER --passwd-on-stdin | openconnect $OPENCONNECT_OPTIONS -b --disable-ipv6 -c /root/$VPN_USER.pem --protocol=nc --os=linux $VPN_URL --cookie-on-stdin

iptables -t nat -A POSTROUTING -o tun0 -j MASQUERADE
iptables -A FORWARD -i eth0 -j ACCEPT