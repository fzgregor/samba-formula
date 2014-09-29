
function smbclient_available {
    smbclient -? &> /dev/null
    return $?
}

function test_browse {
    smbclient $1 -U $2%$3 -c "l;" &> /dev/null
    return $?
}

function test_read {
    smbclient $1 -U $2%$3 -c "l;get $4" &> /dev/null
    ret_code=$?
    if [ $ret_code -eq 0 ] 
    then
        rm $4
    fi
    return $ret_code
}

function test_write_read {
    echo "1234" | tee "test_in" &> /dev/null
    smbclient $1 -U $2%$3 -c "put test_in test;get test test_out" &> /dev/null
    ret_code=$?
    if [ $ret_code -eq 0 ] 
    then
        smbclient $1 -U $2%$3 -c "rm test" &> /dev/null
        rm test_out
    fi
    rm test_in
    return $ret_code
}
