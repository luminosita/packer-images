# Generate certificates

:global CN

/log info message="Creating CA certificate ($CN) ..."

## generate a CA certificate
/certificate
add name=ca-template common-name="$CN" days-valid=3650 key-usage=crl-sign,key-cert-sign
sign ca-template ca-crl-host=127.0.0.1 name="$CN"
:delay 10

/log info message="Creating www-ssl  certificate (server@$CN) ..."

## WebFig certificate
add name=webfig common-name="webfig@$CN"
sign webfig ca="$CN" name="webfig@$CN"
:delay 10
