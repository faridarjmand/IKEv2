#!/bin/bash
## Created By.Farid Arjmand ##

##############################
########## Functions #########
##############################

install ()
{
	# Step 1 — Installing StrongSwan
	apt-get install strongswan strongswan-plugin-eap-mschapv2 moreutils iptables-persistent
}
Read ()
{
	read -p "Please Enter Your IP: " ip
	read -p "Please Insert Your VPN Username: " user
	read -p "Please Insert Your VPN Password: " pass
	read -p "Please Enter Your Interface:(eth0) " interface
}
Certificate_Authority () 
{
	# Step 2 — Creating a Certificate Authority
	ipsec pki --gen --type rsa --size 4096 --outform pem > server-root-key.pem
	chmod 600 server-root-key.pem

	ipsec pki --self --ca --lifetime 3650 \
	--in server-root-key.pem \
	--type rsa --dn "C=US, O=VPN Server, CN=VPN Server Root CA" \
	--outform pem > server-root-ca.pem
}
Certificate_VPNServer ()
{
	# Step 3 — Generating a Certificate for the VPN Server
	ipsec pki --gen --type rsa --size 4096 --outform pem > vpn-server-key.pem
	ipsec pki --pub --in vpn-server-key.pem \
	--type rsa | ipsec pki --issue --lifetime 1827 \
	--cacert server-root-ca.pem \
	--cakey server-root-key.pem \
	--dn "C=US, O=VPN Server, CN=$ip" \
	--san $ip \
	--flag serverAuth --flag ikeIntermediate \
	--outform pem > vpn-server-cert.pem
	cp vpn-server-cert.pem /etc/ipsec.d/certs/vpn-server-cert.pem
	cp vpn-server-key.pem /etc/ipsec.d/private/vpn-server-key.pem
	chown root /etc/ipsec.d/private/vpn-server-key.pem
	chgrp root /etc/ipsec.d/private/vpn-server-key.pem
	chmod 600 /etc/ipsec.d/private/vpn-server-key.pem
}
StrongSwan ()
{
	# Step 4 — Configuring StrongSwan
	cp /etc/ipsec.conf /etc/ipsec.conf.original
	echo '' | sudo tee /etc/ipsec.conf
	# When configuring the server ID (leftid), only include the @ character if your VPN server will be identified by a domain name:
	#   leftid=@vpn.example.com
	# If the server will be identified by its IP address, just put the IP address in:
	#   leftid=111.111.111.111
echo "config setup
  charondebug="ike 1, knl 1, cfg 0"
  uniqueids=no
conn ikev2-vpn
  auto=add
  compress=no
  type=tunnel
  keyexchange=ikev2
  fragmentation=yes
  forceencaps=yes
  ike=aes256-sha1-modp1024,3des-sha1-modp1024!
  esp=aes256-sha1,3des-sha1!
  dpdaction=clear
  dpddelay=300s
  rekey=no
  left=%any
  leftid=$ip
  leftcert=/etc/ipsec.d/certs/vpn-server-cert.pem
  leftsendcert=always
  leftsubnet=0.0.0.0/0
  right=%any
  rightid=%any
  rightauth=eap-mschapv2
  rightsourceip=10.10.10.0/24
  rightdns=8.8.8.8,8.8.4.4
  rightsendcert=never
  eap_identity=%identity" >> /etc/ipsec.conf
}
IpSec ()
{
	# Step 5 — Configuring VPN Authentication
	echo -e "$ip : RSA \"/etc/ipsec.d/private/vpn-server-key.pem\"\n$user %any% : EAP \"$pass\"" > /etc/ipsec.secrets
	ipsec reload
}
Firewall ()
{
	# Step 6 — Configuring the Firewall & Kernel IP Forwarding
	read -p "Do You Want To Set iptables and disable ufw ?(y/n): " iptables
	if [ $iptables == y ];then
		read -p "Do You Want To Remove Curent iptables Roll ?(y/n): " remove
		if [ $remove == y ];then
			ufw disable
			iptables -P INPUT ACCEPT
			iptables -P FORWARD ACCEPT
			iptables -F
			iptables -Z
		fi
		iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
		read -p "Please Insert Your SSH Port: " ssh
		iptables -A INPUT -p tcp --dport $ssh -j ACCEPT
		iptables -A INPUT -i lo -j ACCEPT
		iptables -A INPUT -p udp --dport  500 -j ACCEPT
		iptables -A INPUT -p udp --dport 4500 -j ACCEPT
		iptables -A FORWARD --match policy --pol ipsec --dir in  --proto esp -s 10.10.10.10/24 -j ACCEPT
		iptables -A FORWARD --match policy --pol ipsec --dir out --proto esp -d 10.10.10.10/24 -j ACCEPT
		iptables -t nat -A POSTROUTING -s 10.10.10.10/24 -o $interface -m policy --pol ipsec --dir out -j ACCEPT
		iptables -t nat -A POSTROUTING -s 10.10.10.10/24 -o $interface -j MASQUERADE
		iptables -t mangle -A FORWARD --match policy --pol ipsec --dir in -s 10.10.10.10/24 -o $interface -p tcp -m tcp --tcp-flags SYN,RST SYN -m tcpmss --mss 1361:1536 -j TCPMSS --set-mss 1360
		iptables -A INPUT -j DROP
		iptables -A FORWARD -j DROP
		netfilter-persistent save
		netfilter-persistent reload
	fi
}
sysctl ()
{
	echo -e "net.ipv4.ip_forward = 1\nnet.ipv4.conf.all.accept_redirects = 0\nnet.ipv4.conf.all.send_redirects = 0\nnet.ipv4.ip_no_pmtu_disc = 1" >> /etc/sysctl.conf
	echo "Please Restart your system"
}

##############################
############ Main ############
##############################

Read
install
mkdir /etc/vpn-certs
cd /etc/vpn-certs
Certificate_Authority
Certificate_VPNServer
StrongSwan
IpSec
Firewall
sysctl
echo "Add more user on /etc/ipsec.secrets"

#############################
############ END ############
#############################
