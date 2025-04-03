#Define pppoe-client for bridged modem

:global PPPOEUSER
:global PPPOEPASS

:global OUTINT

:global VLANID

/interface/vlan/
add name=VLAN vlan-id=$VLANID interface=bridge

/interface pppoe-client
add add-default-route=yes allow=chap,mschap1,mschap2 disabled=no interface=VLAN name=$OUTINT password=$PPPOEPASS use-peer-dns=yes user=$PPPOEUSER
