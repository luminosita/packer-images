# VPN Setup (ovpn server with certificates, client ipsec profile)

:global CN

:global GATEWAY

:local xmppserver "192.168.50.30"
:local xmppdomain "xmpp-server.com"

:local username "chat-server"
:local password "laptop01"

:local port 1194
:local vpnpool "192.168.50.31-192.168.50.39"

####################################### CERTIFICATES ######################################

/log info message="Creating server template certificate (server@$CN) ..."

## generate a server certificate
/certificate
:if ([:len [find where common-name="server@$CN"]] = 0) do={
    add name=server-template common-name="server@$CN" days-valid=3650 key-usage=digital-signature,key-encipherment,tls-server
    sign server-template ca="$CN" name="server@$CN"
    :delay 10
}

/log info message="Creating client template certificate (client@$CN) ..."

## create a client template
/certificate
:if ([:len [find where common-name="client@$CN"]] = 0) do={
    add name=client-template common-name="client@$CN" days-valid=3650 key-usage=tls-client
}

## generate a client certificate
/certificate
:if ([:len [find where common-name="$username@$CN"]] = 0) do={
    add name=client-template-to-issue copy-from="client-template" common-name="$username@$CN"
    sign client-template-to-issue ca="$CN" name="$username@$CN"
    :delay 10
}

## export the CA, client certificate, and private key
/certificate
export-certificate "$CN" export-passphrase=""
export-certificate "$username@$CN" export-passphrase="$password"
:delay 5

:local createFile do={
    # Create file.
    /file print file=$filename where name=""
    # Wait for the file to be created.
    :delay 1
    # Set file's content.
    /file set $filename contents=$content

    /log info message="File $filename created."
    :delay 5
}    

$createFile filename="server-pass" content=("$username\r\n$password")
$createFile filename="passphrase" content=$password


## Done. You will find the created certificates in Files.

####################################### DNS ######################################

/ip dns static
add address=$xmppserver name=$xmppdomain

####################################### OVPN ######################################

/ip pool
add name=VPNPOOL ranges=$vpnpool

/ppp profile
add dns-server=$GATEWAY local-address=$GATEWAY name=VPN-PROFILE remote-address=VPNPOOL use-encryption=yes

## setup OpenVPN server
/interface ovpn-server server
set auth=sha1 certificate="server@$CN" cipher=blowfish128,aes128-cbc,aes256-cbc,aes256-gcm default-profile=VPN-PROFILE port="$port" enabled=yes require-client-certificate=yes

## add a user
/ppp secret
add local-address=$GATEWAY name=$username password=$password profile=VPN-PROFILE remote-address=$xmppserver service=ovpn
