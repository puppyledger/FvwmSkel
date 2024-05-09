#! /bin/bash

# usage: Menu.host.interface.description.sh $host $interface

source /home/x1/.interface/fwhost.$1
INTERFACE0=$2

############## PREPARE NET ########################

ip link set dev $INTERFACE0 down 
ip link set dev $INTERFACE100 down 
ip route flush table all

echo "interfaces and routes cleared"

sleep 1

############## IPTABLES #####################

iptables --flush 
iptables -P INPUT DROP
iptables -P FORWARD DROP 
iptables -P OUTPUT DROP

# low level permits loopback and icmp 
iptables -A INPUT -i lo -j ACCEPT 
iptables -A OUTPUT -d $IPV4ADDR100 -j ACCEPT 
iptables -A INPUT  -p icmp -j ACCEPT
iptables -A OUTPUT -p icmp -j ACCEPT

# dns permit resolver traffic
iptables -A OUTPUT -p udp --dport $PORT_DNS1 -d $RESOLVER1 -j ACCEPT 
iptables -A INPUT -p udp --sport  $PORT_DNS1 -m multiport --dports 53,1024:65535 -s $RESOLVER1 -j ACCEPT 

iptables -A OUTPUT -p udp --dport $PORT_DNS1 -d $RESOLVER2 -j ACCEPT 
iptables -A INPUT -p udp --sport  $PORT_DNS1 -m multiport --dports 53,1024:65535 -s $RESOLVER2 -j ACCEPT 

# permit outbound tcp for hv console
iptables -A INPUT -p tcp -s $HVCONSOLE1 -m multiport --sports 1024:65535 -m state --state ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp -d $HVCONSOLE1 -m multiport --dports 1024:65535 -m state --state NEW,ESTABLISHED -j ACCEPT

# permit outbound httpd for downloads
iptables -A INPUT -p tcp --sport $PORT_HTTP1 -m state --state ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --sport $PORT_HTTPS1 -m state --state ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --dport $PORT_HTTP1 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --dport $PORT_HTTPS1 -m state --state NEW,ESTABLISHED -j ACCEPT

# allow output ssh on adminstrative and user ports. 
iptables -A INPUT -p tcp --sport $PORT_SSH1 -m state --state ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --dport $PORT_SSH1 -m state --state NEW,ESTABLISHED -j ACCEPT

iptables -A INPUT -p tcp --sport $PORT_SSH2 -m state --state ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --dport $PORT_SSH2 -m state --state NEW,ESTABLISHED -j ACCEPT

# log ssh scans 
iptables -A INPUT -p tcp --dport 22 -j LOG
iptables -A INPUT -p tcp --dport 22 -j DROP

echo "iptables complete"
sleep 1

############# INTERFACES UP #########################

# First loopback
ip addr add $IPV4ADDR100/$IPV4MASK100 dev $INTERFACE100
ip link set dev $INTERFACE100 up 

echo "Loopbacks up"
sleep 1 

# First Ethernet interface
ip addr add $IPV4ADDR0/$IPV4MASK0 dev $INTERFACE0
ip link set dev $INTERFACE0 up 

echo "Ethernets up"
sleep 1 

### 

ip route add default via 172.16.16.1

echo "Routes up"
sleep 1 

echo "nameserver $RESOLVER1" > /etc/resolv.conf
echo "nameserver $RESOLVER2" >> /etc/resolv.conf

echo "Resolvers up"
sleep 1 

# We keep a copy of iptables to diff against 
# later if we hose something up. 

iptables -S > /root/audit/data/iptables.boot

sleep 1 

iptables -S 

FvwmCommand 'Warp2Next'

