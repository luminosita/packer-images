:delay 10

/log info message="Running first-boot script ..."

#Disable services 
/ip service
set telnet disabled=yes
set ftp disabled=yes
set api disabled=yes
set api-ssl disabled=yes
set winbox disabled=yes
set www disabled=yes
set www-ssl disabled=yes
set ssh disabled=no

/interface/ethernet
:if ([:len [find]] = 0) do={
      /log error message="No ethernet interface registered."
} else={
      /log info message="Setting ethernet interface name ..."
      set 0 name=ether1      

      /ip/dhcp-client/
      :if ([:len [find]] > 0) do={
            /log info message="Removing dhcp-client ..."

            /ip/dhcp-client/remove 0
      }

      /log info message="Adding dhcp-client for ether1 interface ..."

      /ip/dhcp-client/add interface=ether1 use-peer-dns=yes add-default-route=yes
}

