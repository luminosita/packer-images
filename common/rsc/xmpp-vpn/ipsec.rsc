:global OUTINT

:global NETMASK
:global GATEWAY

:local ipaddress [/ip address get [/ip address find interface=$OUTINT] address]

:local publicIp [:pick $ipaddress 0 [:find $ipaddress "/"]]

:local clientSecret "androidklijent"

/ip ipsec policy
set 0 comment="default policy"

/ip ipsec policy group
add name=android

/ip ipsec profile
add dh-group=modp4096,modp3072,modp2048 enc-algorithm=aes-256,aes-192,aes-128 hash-algorithm=sha256 name=ph1Android prf-algorithm=sha1

/ip ipsec peer
add exchange-mode=ike2 local-address=$publicIp name=androidClients passive=yes profile=ph1Android send-initial-contact=no

/ip ipsec proposal
set [ find default=yes ] auth-algorithms=sha256,sha1
add auth-algorithms=sha512,sha256,sha1,md5,null enc-algorithms=aes-256-cbc,aes-256-ctr,aes-256-gcm,aes-192-cbc,aes-192-ctr,aes-192-gcm,aes-128-cbc,aes-128-ctr,aes-128-gcm,des name=ph2Android pfs-group=none

/ip ipsec mode-config
add address-pool=default-dhcp address-prefix-length=32 name=modeConfAndroidVpn split-include=$NETMASK static-dns=$GATEWAY system-dns=no

/ip ipsec identity
add generate-policy=port-override mode-config=modeConfAndroidVpn peer=androidClients policy-template-group=android secret=$clientSecret

/ip ipsec policy
set 0 comment="default policy"
add group=android proposal=ph2Android template=yes