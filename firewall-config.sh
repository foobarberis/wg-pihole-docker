#!/bin/bash

# More informations about these rules at https://docs.pi-hole.net/guides/vpn/openvpn/firewall/

# Clear out the entire firewall

iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -t nat -F
iptables -t mangle -F
iptables -F
iptables -X

ip6tables -P INPUT ACCEPT
ip6tables -P FORWARD ACCEPT
ip6tables -P OUTPUT ACCEPT
ip6tables -t nat -F
ip6tables -t mangle -F
ip6tables -F
ip6tables -X

iptables-legacy -P INPUT ACCEPT
iptables-legacy -P FORWARD ACCEPT
iptables-legacy -P OUTPUT ACCEPT
iptables-legacy -t nat -F
iptables-legacy -t mangle -F
iptables-legacy -F
iptables-legacy -X

# Add rules for IPv4

iptables -A INPUT -p tcp --destination-port 53 -j ACCEPT
iptables -A INPUT -p udp --destination-port 53 -j ACCEPT
iptables -A INPUT -p tcp --destination-port 80 -j ACCEPT
iptables -A INPUT -p tcp --destination-port 22 -j ACCEPT # Change the port to match the one you chose in /etc/ssh/sshd_config
iptables -A INPUT -p tcp --destination-port 51821 -j ACCEPT
iptables -A INPUT -p udp --destination-port 51820 -j ACCEPT
iptables -I INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -I INPUT -i lo -j ACCEPT
iptables -A INPUT -p udp --dport 80 -j REJECT --reject-with icmp-port-unreachable
iptables -A INPUT -p tcp --dport 443 -j REJECT --reject-with tcp-reset
iptables -A INPUT -p udp --dport 443 -j REJECT --reject-with icmp-port-unreachable
iptables -P INPUT DROP

# Add rules for IPv6

ip6tables -A INPUT -p tcp --destination-port 53 -j ACCEPT
ip6tables -A INPUT -p udp --destination-port 53 -j ACCEPT
ip6tables -A INPUT -p tcp --destination-port 80 -j ACCEPT
ip6tables -A INPUT -p tcp --destination-port 22 -j ACCEPT # Change the port to match the one you chose in /etc/ssh/sshd_config
ip6tables -A INPUT -p tcp --destination-port 51821 -j ACCEPT
ip6tables -A INPUT -p udp --destination-port 51820 -j ACCEPT
ip6tables -I INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
ip6tables -I INPUT -i lo -j ACCEPT
ip6tables -A INPUT -p udp --dport 80 -j REJECT --reject-with icmp6-port-unreachable
ip6tables -A INPUT -p tcp --dport 443 -j REJECT --reject-with tcp-reset
ip6tables -A INPUT -p udp --dport 443 -j REJECT --reject-with icmp6-port-unreachable
ip6tables -P INPUT DROP