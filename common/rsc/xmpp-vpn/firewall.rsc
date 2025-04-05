:global PORT

:global OUTINT

:global NETMASK

:global SSHPORT

/interface list
add comment=defconf name=WAN
add comment=defconf name=LAN

/interface list member
add comment=defconf interface=bridge list=LAN
add comment=defconf interface=$OUTINT list=WAN

/ip neighbor discovery-settings
set discover-interface-list=LAN

#Firewall
/ip firewall address-list
add list=Port_knocking_stage_1
add list=Port_knocking_stage_2
add list=Port_knocking_stage_3
add list=Trusted_port_knocker

/ip firewall filter
add action=accept chain=input comment="Allow HTTPS from anywhere" dst-port=443 protocol=tcp

add action=accept chain=input comment="Allow SSH from anywhere" dst-port=$SSHPORT protocol=tcp

add action=accept chain=input comment="Allow Winbox from Everywhere" dst-port=8291 protocol=tcp

add action=accept chain=input comment="Allow OpenVPN" dst-port=$PORT protocol=tcp

add action=accept chain=input comment="VPN IP sec" dst-port=1701 protocol=udp
add action=accept chain=input protocol=ipsec-esp
add action=accept chain=input dst-port=500 protocol=udp
add action=accept chain=input dst-port=4500 protocol=udp

add action=accept chain=input comment="Accept DNS requests from VPN clients" dst-port=53 log=yes log-prefix=dns_fw protocol=udp src-address=$NETMASK

add action=add-src-to-address-list address-list=Port_knocking_stage_1 address-list-timeout=2s chain=input comment="Port knocking for ping and server probing" dst-port=17441 protocol=tcp
add action=add-src-to-address-list address-list=Port_knocking_stage_2 address-list-timeout=2s chain=input dst-port=45781 protocol=tcp src-address-list=Port_knocking_stage_1
add action=add-src-to-address-list address-list=Port_knocking_stage_3 address-list-timeout=2s chain=input dst-port=26884 protocol=tcp src-address-list=Port_knocking_stage_2
add action=add-src-to-address-list address-list=Trusted_port_knocker address-list-timeout=8h chain=input src-address-list=Port_knocking_stage_3
add action=accept chain=input protocol=icmp src-address-list=Trusted_port_knocker
add action=add-src-to-address-list address-list=Port_scanner address-list-timeout=22h chain=input comment="Port scanner detect" protocol=tcp psd=9,3s,3,2 src-address-list=!Trusted_port_knocker
add action=add-src-to-address-list address-list="" address-list-timeout=22h chain=input protocol=udp psd=9,3s,3,2 src-address-list=!Trusted_port_knocker
add action=drop chain=input comment="Drop port scanner" src-address-list=Port_scanner

add action=accept chain=forward comment="in out ipsec policy" ipsec-policy=in,ipsec
add action=accept chain=forward ipsec-policy=out,ipsec

add action=accept chain=input comment="defconf: accept established,related,untracked" connection-state=established,related,untracked
add action=drop chain=input comment="defconf: drop invalid" connection-state=invalid
add action=drop chain=input comment="defconf: drop all not coming from LAN" in-interface-list=!LAN
add action=drop chain=forward comment="defconf: drop invalid" connection-state=invalid
add action=drop chain=forward comment="defconf: drop all from WAN not DSTNATed" connection-nat-state=!dstnat connection-state=new in-interface-list=WAN
add action=accept chain=input comment="defconf: accept ICMP" protocol=icmp
add action=accept chain=input comment="defconf: accept to local loopback (for CAPsMAN)" dst-address=127.0.0.1
add action=accept chain=input comment="Allow Established and Related" connection-state=established,related
add action=drop chain=input comment="Drop Invalid" connection-state=invalid
add action=log chain=input log-prefix="DROP INPUT"
add action=drop chain=input comment="Drop All Other"
add action=accept chain=forward comment="Allow Established and Related Forward" connection-state=established,related
add action=fasttrack-connection chain=forward comment="defconf: fasttrack" connection-state=established,related hw-offload=yes
add action=drop chain=forward comment="Drop Invalid Forward" connection-state=invalid

#Firewall IPV6
/ipv6 firewall address-list
add address=::/128 comment="defconf: unspecified address" list=bad_ipv6
add address=::1/128 comment="defconf: lo" list=bad_ipv6
add address=fec0::/10 comment="defconf: site-local" list=bad_ipv6
add address=::ffff:0.0.0.0/96 comment="defconf: ipv4-mapped" list=bad_ipv6
add address=::/96 comment="defconf: ipv4 compat" list=bad_ipv6
add address=100::/64 comment="defconf: discard only " list=bad_ipv6
add address=2001:db8::/32 comment="defconf: documentation" list=bad_ipv6
add address=2001:10::/28 comment="defconf: ORCHID" list=bad_ipv6
add address=3ffe::/16 comment="defconf: 6bone" list=bad_ipv6
/ipv6 firewall filter
add action=accept chain=input comment="defconf: accept established,related,untracked" connection-state=established,related,untracked
add action=drop chain=input comment="defconf: drop invalid" connection-state=invalid
add action=accept chain=input comment="defconf: accept ICMPv6" protocol=icmpv6
add action=accept chain=input comment="defconf: accept UDP traceroute" port=33434-33534 protocol=udp
add action=accept chain=input comment="defconf: accept DHCPv6-Client prefix delegation." dst-port=546 protocol=udp src-address=fe80::/10
add action=accept chain=input comment="defconf: accept IKE" dst-port=500,4500 protocol=udp
add action=accept chain=input comment="defconf: accept ipsec AH" protocol=ipsec-ah
add action=accept chain=input comment="defconf: accept ipsec ESP" protocol=ipsec-esp
add action=accept chain=input comment="defconf: accept all that matches ipsec policy" ipsec-policy=in,ipsec
add action=drop chain=input comment="defconf: drop everything else not coming from LAN" in-interface-list=!LAN
add action=accept chain=forward comment="defconf: accept established,related,untracked" connection-state=established,related,untracked
add action=drop chain=forward comment="defconf: drop invalid" connection-state=invalid
add action=drop chain=forward comment="defconf: drop packets with bad src ipv6" src-address-list=bad_ipv6
add action=drop chain=forward comment="defconf: drop packets with bad dst ipv6" dst-address-list=bad_ipv6
add action=drop chain=forward comment="defconf: rfc4890 drop hop-limit=1" hop-limit=equal:1 protocol=icmpv6
add action=accept chain=forward comment="defconf: accept ICMPv6" protocol=icmpv6
add action=accept chain=forward comment="defconf: accept HIP" protocol=139
add action=accept chain=forward comment="defconf: accept IKE" dst-port=500,4500 protocol=udp
add action=accept chain=forward comment="defconf: accept ipsec AH" protocol=ipsec-ah
add action=accept chain=forward comment="defconf: accept ipsec ESP" protocol=ipsec-esp
add action=accept chain=forward comment="defconf: accept all that matches ipsec policy" ipsec-policy=in,ipsec
add action=drop chain=forward comment="defconf: drop everything else not coming from LAN" in-interface-list=!LAN
