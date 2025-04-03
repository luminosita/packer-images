#Misc
/system clock
set time-zone-name=Europe/Belgrade
/system routerboard mode-button
set enabled=yes on-event=dark-mode
/tool mac-server
set allowed-interface-list=LAN
/tool mac-server mac-winbox
set allowed-interface-list=LAN

/ip cloud
set ddns-enabled=yes ddns-update-interval=1m update-time=yes
