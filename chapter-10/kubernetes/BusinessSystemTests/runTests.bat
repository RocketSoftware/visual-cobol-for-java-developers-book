@echo off
setlocal

set POSTGRES_HOST=localhost
set POSTGRES_DB=test-db
set POSTGRES_USER=postgres
set POSTGRES_PASSWORD=db-password

mvn clean test
