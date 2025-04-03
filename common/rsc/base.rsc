# Basic Mikrotik Setup

:global CN

:global GATEWAY
:global GATEWAYMASK
:global NETWORK
:global NETMASK

:global OUTINT
:global BRIDGEINTERFACES

:global DHCPPOOL

:local macAddress [/interface get 0 mac-address]

/log info message="Setting MAC address to bridge interface"

#Define bridge with MAC address
/interface bridge
:if ([:len [find]] = 0) do={
    add admin-mac=$macAddress auto-mac=no comment=defconf name=bridge
} else={
	set 0 admin-mac=$macAddress auto-mac=no comment=defconf name=bridge
}

#Define bridge for all present network interfaces
/interface bridge port
:foreach interface in=$BRIDGEINTERFACES do={
    :if ([:len [find where interface=$interface]] = 0) do={
        add bridge=bridge comment=defconf interface=$interface
    }
}

#Remove output interface from bridge
:if ([:len [find where interface=$OUTINT]] > 0) do={
    remove [find where interface=$OUTINT]
}

/log info message="Setting main IP address"
#Set main IP address, dhcp and vpn pools, dhcp server
/ip address
:if ([:len [find]] = 0) do={
    add address=$GATEWAYMASK comment=defconf interface=bridge network=$NETWORK
} else={
    set 0 address=$GATEWAYMASK comment=defconf interface=bridge network=$NETWORK
}

/log info message="Setting main dhcp pool"
/ip pool
:if ([:len [find]] = 0) do={
    add name="DHCPPOOL" ranges=$DHCPPOOL
} else={
    set 0 name="DHCPPOOL" ranges=$DHCPPOOL
}

/log info message="Assign dhcp pool to bridge"
/ip dhcp-server
:if ([:len [find]] = 0) do={
    add address-pool="DHCPPOOL" interface=bridge name=dhcp1
}  else={
    set 0 address-pool="DHCPPOOL" interface=bridge name=dhcp1
}

/log info message="Assign network to bridge"
/ip dhcp-server network
:if ([:len [find]] = 0) do={
    add address=$NETMASK comment=defconf dns-server=$GATEWAY gateway=$GATEWAY
} else={
    set 0 address=$NETMASK comment=defconf dns-server=$GATEWAY gateway=$GATEWAY
}

/ip dns
set allow-remote-requests=yes
/ip dns static
:if ([:len [find]] = 0) do={
    add address=$GATEWAY comment=defconf name=router.lan
} else={
    set 0 address=$GATEWAY comment=defconf name=router.lan
}

## Set WebFig certificate for HTTPS
/ip service
set www-ssl certificate="webfig@$CN" disabled=no

/system logging
add disabled=yes topics=dns,packet