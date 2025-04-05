# Basic Mikrotik Setup

:global CN

:global GATEWAY
:global GATEWAYMASK
:global NETWORK
:global NETMASK

:global OUTINT

:global DHCPPOOL

:local macAddress [/interface get 0 mac-address]

#Define bridge with MAC address
/log info message="Setting MAC address to bridge interface"
/interface bridge
:if ([:len [find]] = 0) do={
    add admin-mac=$macAddress auto-mac=no comment=defconf name=bridge
} else={
	set 0 admin-mac=$macAddress auto-mac=no comment=defconf name=bridge
}

#Remove output interface from bridge
/interface bridge port
/log info message="Removing out interface from bridge"
:local outint [find where bridge=bridge and interface=$OUTINT]
:if ($outint != "") do={
    remove $outint
}

#Define bridge for all present network interfaces
/log info message="Add all available ether and wlan interface to bridge except out interface"
:foreach interface in=[/interface/find where type="ether" or type="wlan"] do={
    :if (([/interface/get $interface name] != $OUTINT) && ([find where interface=$interface and bridge=bridge] = "")) do={
        add bridge=bridge comment=defconf interface=$interface
    }
}

/log info message="Setting main IP address"
#Set main IP address, dhcp and vpn pools, dhcp server
/ip address
:local bridgeIp [find where interface=bridge]
:if ($bridgeIp = "") do={
    add address=$GATEWAYMASK comment=defconf interface=bridge network=$NETWORK
} else={
    set $bridgeIp address=$GATEWAYMASK comment=defconf interface=bridge network=$NETWORK
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
:local bridgeDhcp [find where interface=bridge]
:if ($bridgeDhcp = "") do={
    add address-pool="DHCPPOOL" interface=bridge name=dhcp1
}  else={
    set $bridgeDhcp address-pool="DHCPPOOL" interface=bridge name=dhcp1
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