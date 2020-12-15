# VPN服务器搭建
OpenVPN搭建 请follow [《OpenVPN 安装与配置》](https://www.jianshu.com/p/17a56994b74f)

注意事项:

安装openvpn, easy-rsa需要用到epel repo
```
wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

yum install -y ./epel-release-latest-7.noarch.rpm
```

* 客户端链接的时候需要sudo 权限;  所以只能通过命令行去链接sudo openvpn --config ryan.ovpn
* 不要在宿主机上做这个服务；由于网络，多网卡，iptables转发这些东西；搞在一起容易出问题；所以宿主机器只做vm provision；其他的都不要做；
VPN配置文档中，有一段是配置iptables 这个是必须的；如果不配置，虽然可以链接上vpn，并且分配到tun的ip，但是只能连接到vpn服务器那台电脑；

    比如castleback
    * 内网ip: 192.168.2.25
    * vpn虚拟ip: 10.8.0.1
    
    然后客户端分配到ip
    * 你自己的ip, 用于正常ip链接
    * vpn虚拟通道ip: 10.8.0.6
	
    然后，你就可以链接10.8.0.1；以及192.168.2.25; 但是你还不能访问192.168.2.0内网的其他电脑；这里需要设置iptables这一段，用于内核转发:
```
iptables -A INPUT -i eth0 -m state --state NEW -p udp --dport 1194 -j ACCEPT
iptables -A INPUT -i tun+ -j ACCEPT
iptables -A FORWARD -i tun+ -j ACCEPT
iptables -A FORWARD -i tun+ -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth0 -o tun+ -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
iptables -A OUTPUT -o tun+ -j ACCEPT
```


注意检查你vpn服务器的网卡是否是eth0
测试成功之后运行: 

iptables-save > /etc/sysconfig/iptables

持久保存到iptables.

在路由器上，打开端口转发，并且在客户端ryan.ovpn中 指定外部ip，就可以成功链接了；

# 配置联通公网ip
https://ryanzhang.github.io/work/2020/12/13/privatecloudinyourhome-vpn-network.html
# 定期发送公网ip到gist
文档请参考: https://developer.github.com/v3/gists/#edit-a-gist

请参考 sendpublicip.sh
```
#!/bin/bash
#Send your ip to gist
#It will update an existing gist when you run this script
#How to get your token
#github->setting->developer setting->Personal access token
token=your_token
gistid=your_gist
generate_post_data()
{
  cat <<EOF
{"description": "Created via API", "public": "true", "files": {"$(hostname)": { "content":"$(curl ifconfig.co)"}}}
EOF
}
generate_post_data
curl -H "Authorization: token $token" --request PATCH --data "$(generate_post_data)" https://api.github.com/gists/$gistid

```

使用crontab 添加定时任务;
```
crontab -e
crontab -l
#Every hour send public ip to gist
1 * * * * /usr/local/bin/sendpublicip.sh
```

# 动态从gist中获取ip 然后链接vpn

请参考connect-myvpn.sh

您需要配置您自己的
* gistid -该gist用来保存 联通的浮动公网ip
* openvpn_client folder -目录里面是您自己的ca.crt以及client keypair
```
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
verb 3

" >/tmp/homevpn.ovpn
sudo openvpn --config /tmp/homevpn.ovpn

```

