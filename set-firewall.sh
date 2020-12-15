#!/bin/bash
#需要root权限

echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
sysctl -p

firewall-cmd --permanent --add-service=openvpn
firewall-cmd --permanent --zone=trusted --add-interface=tun0
firewall-cmd --permanent --zone=trusted --add-masquerade
