#NOTE: To allow clients to surf the Internet, make sure that there are permissive rules, such as:

:global NETMASK
:global OUTINT

/ip firewall filter
add chain=forward action=accept src-address=$NETMASK out-interface=$OUTINT place-before=0
add chain=forward action=accept in-interface=$OUTINT dst-address=$NETMASK place-before=1

/ip firewall nat
add chain=srcnat src-address=$NETMASK out-interface=$OUTINT action=masquerade

#proxy-arp to allow internet access to ovpn clients
/interface bridge
set 0 arp=proxy-arp

/interface ethernet
set [ find default-name=ether1 ] arp=proxy-arp
