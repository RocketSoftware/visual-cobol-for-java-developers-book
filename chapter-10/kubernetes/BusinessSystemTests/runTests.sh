#!/bin/bash
set -e

export POSTGRES_HOST='localhost'
export POSTGRES_DB='test-db'
export POSTGRES_USER='postgres'
export POSTGRES_PASSWORD='db-password'

mvn clean test
