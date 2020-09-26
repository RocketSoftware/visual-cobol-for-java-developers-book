#!/bin/bash
if [ ! -z $DB_TEST_PASSWORD  ] 
then 
    DB_CONNECTION_STRING='Driver=org.postgresql.Driver;URL=jdbc:postgresql:test-db?user=postgres&password='$DB_TEST_PASSWORD
    echo $DB_CONNECTION_STRING
    if mvn package  
    then 
        docker build . -t mfcobolbook/credit-service:1.0
    else 
        echo *** BUILD FAILED ***
    fi
else 
    echo Set DB_TEST_PASSWORD TO value for test database. 
fi 

     
