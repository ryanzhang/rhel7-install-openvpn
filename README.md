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

