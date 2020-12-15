#!/bin/bash
# you would need your ca certificate and client keypair to run this script
# Check README.md for obtaining your own ca and client keypair
# Please put your ca certification and kepair in your home folder
#eg:
#├── ca.crt
#├── ryan.crt
#├── ryan.key
cd your_openvpn_client_homefolder

# Replace with your gistid
gistid=yourgistid
ip=$(curl https://api.github.com/gists/$gistid |jq '.files.nuc1.content')
echo "you public ip: $ip"
echo "
client
dev tun
proto udp
#真实的ip地址自己填写
remote $ip 1194

#Replace with yourown ca filename
ca ca.crt
#Replace with your own client certificate and keys
cert client.crt
key client.key

cipher AES-256-CBC
auth SHA512
auth-nocache
tls-version-min 1.2
tls-cipher TLS-DHE-RSA-WITH-AES-256-GCM-SHA384:TLS-DHE-RSA-WITH-AES-256-CBC-SHA256:TLS-DHE-RSA-WITH-AES-128-GCM-SHA256:TLS-DHE-RSA-WITH-AES-128-CBC-SHA256

resolv-retry infinite
compress lzo
nobind
persist-key
persist-tun
mute-replay-warnings
up /etc/openvpn/scripts/update-systemd-resolved
up-restart
down /etc/openvpn/scripts/update-systemd-resolved
down-pre
dhcp-option DOMAIN-ROUTE .

verb 3

" >/tmp/homevpn.ovpn
sudo openvpn --config /tmp/homevpn.ovpn
