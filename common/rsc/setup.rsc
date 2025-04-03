:put "Running init script ..."

/system/script/add name="init" source=[/file get [/file find where name="init.rsc"] contents]

/system script run [find where name="init"]

/system/script/remove [find name="init"]

/file/remove [find where name="init.rsc"]

/log info message="Adding run scheduler ..."

/system/scheduler 
add name="Boot" on-event="run" interval=0s start-time=startup

