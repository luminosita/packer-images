#Disable some services 

:global SSHPORT

:global ADMINUSER
:global ADMINPASSWORD

/ip service
set telnet disabled=yes
set ftp disabled=yes
set api disabled=yes
set api-ssl disabled=yes
set winbox disabled=yes
set www disabled=yes
set www-ssl disabled=no
set ssh disabled=no
set ssh port=$SSHPORT

/log info message="Adding new admin user ($ADMINUSER)"
/user
add name=$ADMINUSER password=$ADMINPASSWORD group=full

:local fullname "id_rsa.pub"
:local pFile [/file find where name=$fullname]

:if ($pFile != "") do={
    /log info message="Adding public SSH key for new admin user"
    
    /user/ssh-keys
    import public-key-file=$fullname user=$ADMINUSER
}

/log info message="Removing default admin user"
/user remove admin

/tool 
mac-server set allowed-interface-list=none
mac-server mac-winbox set allowed-interface-list=none
mac-server ping set enabled=no
bandwidth-server set enabled=no 

/ip 
neighbor discovery-settings set discover-interface-list=none 
proxy set enabled=no
socks set enabled=no
upnp set enabled=no
ssh set strong-crypto=yes

#FIXME Difference between 7.8 and 7.18.2 versions
#/ip/cloud set ddns-enabled=no update-time=no

# /lcd set enabled=no

#FIXME
#/interface print
#/interface set x disabled=yes
