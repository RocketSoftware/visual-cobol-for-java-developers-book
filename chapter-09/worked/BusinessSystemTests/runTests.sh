#!/bin/bash
set -e
export DB_CONNECTION_STRING='Driver=org.postgresql.Driver;URL=jdbc:postgresql:test-db?user=postgres&password=db-password'

mvn clean test
