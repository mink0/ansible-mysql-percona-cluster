#!/usr/bin/env bash

PROXY_HOST="${PROXY_HOST:-127.0.0.1}"
PROXY_USER="${PROXY_USER:-test}"
PROXY_PASS="${PROXY_PASS:-test}"
PROXY_DB="${PROXY_DB:-proxy_test}"
PROXY_PORT="${PROXY_PORT:-3306}"

# will be created if not exist
table_name='proxy_test'
sleep_time=0.5

proxy_login="-h$PROXY_HOST -u$PROXY_USER -p$PROXY_PASS -P$PROXY_PORT"

main() {
  create
  trap cleanup EXIT

  while true; do
    mysql $proxy_login -N -e "\
      INSERT INTO $table_name (data) values (\"$(date +%s)\"); \
      SHOW GLOBAL VARIABLES LIKE 'gtid_executed'"


    mysql $proxy_login -e "\
      SELECT @@hostname,@@gtid_purged,@@gtid_executed,count(id) FROM $table_name"

    sleep $sleep_time
  done
}

create() {
  mysql $proxy_login -v -e "CREATE DATABASE IF NOT EXISTS $PROXY_DB"
  proxy_login="$proxy_login $PROXY_DB"

  mysql $proxy_login -v -e \
    "CREATE TABLE IF NOT EXISTS $table_name \
    ( \
      id int NOT NULL AUTO_INCREMENT, \
      ts DATETIME DEFAULT CURRENT_TIMESTAMP, \
      data varchar(255), \
      PRIMARY KEY (id)
    )"
}

cleanup() {
  mysql $proxy_login -v -e "DROP TABLE $table_name"
}

main $@
