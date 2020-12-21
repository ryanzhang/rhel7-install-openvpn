#!/bin/bash
case $script_type in
up)
  echo "nameserver 10.xx.xx.xx #Your dns server
nameserver 10.xx.xx.xx #Secondary dns server" >/etc/resolv.conf
  ;;
down)
  echo "nameserver 192.xx.xx.xx #recover static dns" >/etc/resolv.conf
  ;;
esac
