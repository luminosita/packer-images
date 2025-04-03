:local proxmox "192.168.50.5"
:local secure "192.168.50.220"
:local insecure "192.168.50.223"
:local passthru "192.168.50.221"
:local ingress "192.168.50.225"

/ip dns static

#Direct
add address=$proxmox name=proxmox.lan

#Insecure
add address=$insecure name=argocd.lan
add address=$insecure name=wiki.lan
add address=$insecure name=lldap.lan 
add address=$insecure name=phpldapadmin.lan 
add address=$insecure name=whoami.lan 
add address=$insecure name=prometheus.lan 
add address=$insecure name=grafana.lan 
add address=$insecure name=alertmanager.lan 
add address=$insecure name=minio.lan 
add address=$insecure name=solar.lan 
add address=$insecure name=ejabberd.lan 
add address=$insecure name=auth.lan 
add address=$insecure name=nexus.lan 
