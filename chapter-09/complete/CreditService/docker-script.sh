#!/bin/bash
docker network create app-network 
docker run --name postgres-server --network app-network -e POSTGRES_DB=application-db -e POSTGRES_PASSWORD=LakeOrangeGarden -p 5433:5432 -d postgres:12.3
docker run -p 8080:8080 --name credit-service --rm --network app-network -e DB_CONNECTION_STRING='Driver=org.postgresql.Driver;URL=jdbc:postgresql://postgres-server/application-db?user=postgres&password='$DB_TEST_PASSWORD mfcobolbook/credit-service:1.0   


