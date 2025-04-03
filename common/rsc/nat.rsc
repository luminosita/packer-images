#Enable public internet for internal network (disable in production)

:global OUTINT

/ip firewall nat
add action=masquerade chain=srcnat out-interface=$OUTINT