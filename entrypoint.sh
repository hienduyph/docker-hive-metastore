#!/usr/bin/env bash

DB_TYPE=${DB_TYPE:-derby}
schematool -initSchema -dbType ${DB_TYPE} -verbose 2> /dev/null || true
schematool -upgradeSchema -dbType ${DB_TYPE} -verbose
start-metastore
