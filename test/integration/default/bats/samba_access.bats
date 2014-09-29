#!/usr/bin/env bats

load samba_helper

smbclient_available
if [ $? -ne 0 ]
then
    echo "smbclient not available"
    exit 1
fi

@test "elmo can read/write to elmo_erni" {
    test_write_read "//localhost/elmo_erni" elmo elmo
}

@test "erni can read/write to elmo_erni" {
    test_write_read "//localhost/elmo_erni" erni erni
}

@test "elmo can overwrite a file created by erni in elmo_erni" {
    echo "1234" | tee test &> /dev/null
    smbclient //localhost/elmo_erni -U erni%erni -c "put test"
    echo "4321" | tee test &> /dev/null
    smbclient //localhost/elmo_erni -U elmo%elmo -c "put test;get test test_out"
    [ `cat test_out` -eq "4321" ]
    rm test test_out
}

@test "elmo_erni share is not listed" {
    smbclient -L localhost -U % | grep -v elmo_erni
}

@test "elmo and little_bird publish to sesame share, others read" {
    echo "elmos announcement" | tee elmo.txt
    smbclient //localhost/sesame -U elmo%elmo -c "put elmo.txt"
    echo "little birds song" | tee little_bird.txt
    smbclient //localhost/sesame -U little_bird%little_bird -c "put little_bird.txt"
    smbclient //localhost/sesame -U erni%erni -c "get elmo.txt test"
    smbclient //localhost/sesame -U big_bird%big_bird -c "get elmo.txt test"
    smbclient //localhost/sesame -U big_bird%big_bird -c "get little_bird.txt test"
    ls -al /tmp/sesame
    echo "elmos corrections" >> little_bird.txt
    smbclient //localhost/sesame -U elmo%elmo -c "put little_bird.txt"
    smbclient //localhost/sesame -U little_bird%little_bird -c "rm little_bird.txt; rm elmo.txt"
    rm elmo.txt
    rm little_bird.txt
    rm test
}

@test "big_bird, erni can't write to sesame" {
    echo "test" > test.txt
    smbclient //localhost/sesame -U big_bird%big_bird -c "put test.txt" | grep ACCESS_DENIED
    smbclient //localhost/sesame -U erni%erni -c "put test.txt" | grep ACCESS_DENIED
}

@test "guest write and read public share" {
    echo "test" > test
    smbclient //locahost/public -U % -c "put test;get test;rm test"
    rm test
}
