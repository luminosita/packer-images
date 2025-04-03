:global WPA2KEY

/interface wireless
set [ find default-name=wlan1 ] band=2ghz-b/g/n channel-width=20/40mhz-XX disabled=no distance=indoors frequency=auto installation=indoor mode=ap-bridge ssid=MikroTik-2945D2 wireless-protocol=802.11
set [ find default-name=wlan2 ] band=5ghz-a/n/ac channel-width=20/40/80mhz-XXXX disabled=no distance=indoors frequency=auto installation=indoor mode=ap-bridge ssid=MikroTik-2945D3 wireless-protocol=802.11
/interface wireless security-profiles
set [ find default=yes ] authentication-types=wpa2-psk comment=defconf disable-pmkid=yes mode=dynamic-keys supplicant-identity=MikroTik wpa2-pre-shared-key=$WPA2KEY
