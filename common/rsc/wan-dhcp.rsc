:global OUTINT

/log info message="Setting dchp client on out interface"
/ip/dhcp-client
:if ([:len [find]] = 0) do={
    add interface=$OUTINT use-peer-dns=yes add-default-route=yes
} else={
    set 0 interface=$OUTINT use-peer-dns=yes add-default-route=yes
}