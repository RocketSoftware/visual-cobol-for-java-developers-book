@echo off
setlocal
set DB_CONNECTION_STRING=Driver=org.postgresql.Driver;URL=jdbc:postgresql:test-db?user=postgres^&password=db-password
mvn clean test
