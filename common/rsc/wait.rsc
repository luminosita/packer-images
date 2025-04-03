:while ([/file find where name="logs.txt"] = "") do={ 
    /log info message="Waiting on bootstrap to finish ...";
    :delay 10; 
}