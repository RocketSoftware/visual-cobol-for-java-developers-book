@echo off
setlocal
set dd_ACCOUNTFILE=%~dp0testData\account.dat
set dd_CUSTOMERFILE=%~dp0testData\customer.dat
set dd_TRANSACTIONFILE=%~dp0testData\transaction.dat

mvn clean test
