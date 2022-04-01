#!/bin/bash
set -e
CUR_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
export dd_ACCOUNTFILE=$CUR_DIR/testData/account.dat
export dd_CUSTOMERFILE=$CUR_DIR/testData/customer.dat
export dd_TRANSACTIONFILE=$CUR_DIR/testData/transaction.dat

mvn clean test
