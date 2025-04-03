#Create scripts from uploaded files

:global initScript do={
    :local fullname "$title.rsc"
    :local pFile [/file find where name=$fullname]

    if ($pFile != "") do={
        :local content [/file get $pFile contents]
        
        /system script
        add name="$title" source="$content"
        
        :put "Script ($title) created."

        /log info message="Script ($title) created."

        /file remove $pFile
    }
}
#FIXME Set IDs into filename and do for loop
$initScript title="run"
$initScript title="first-boot"
$initScript title="vars"
$initScript title="certificates"
$initScript title="base"    
$initScript title="vpn"    
$initScript title="ipsec"    
$initScript title="wan"    
$initScript title="firewall"    
$initScript title="nat"   
$initScript title="wireless"
$initScript title="staticdns"   
$initScript title="lock"     
$initScript title="secure"     
$initScript title="wait"     

