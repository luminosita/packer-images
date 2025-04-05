#Create setup scripts from uploaded files
  
:global runScript do={
    :local pScript [/system script find where name=$title]

    :if ($pScript != "") do={
        :local scriptName [/system script get $pScript name]

        :put "Running script ($scriptName) ..."

        /log info message="Running script ($scriptName) ..."

        /system script run $pScript

        :put "Script ($scriptName) finished."

        /log info message="Script ($scriptName) finished."

        /system script remove $pScript
    } else={
        :put "Script ($title) skipped."

        /log info message="Script ($title) skipped."
    }
}                        

:put "Running scripts from files ..."

/log info message="Running scripts from files ..."

#FIXME Set IDs into filename and do for loop

$runScript title="first-boot"
$runScript title="vars"
$runScript title="certificates"
$runScript title="base"    
$runScript title="vpn"    
$runScript title="ipsec"    
$runScript title="wan"    
$runScript title="firewall"    
$runScript title="nat"   
$runScript title="wireless"
$runScript title="staticdns"   
$runScript title="lock"     

#Secure will be executed only per request not as part of regular setup
#$runScript title="secure"     

/log info message="Removing scheduler ..."

/system/scheduler
remove 0

/log/print file="logs.txt"
