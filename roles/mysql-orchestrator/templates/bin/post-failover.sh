#!/usr/bin/env bash

# Setup sqlproxy:
#   remove old master from writer hostgroup (id=0)

# variable exposed by Orchestrator
old_master="$(getent hosts $ORC_FAILED_HOST | awk '{ print $1; exit }')"
new_master="$(getent hosts $ORC_SUCCESSOR_HOST | awk '{ print $1; exit }')"

proxysql_login="-h{{ mysql_proxy_host }} -u{{ mysql_proxy_admin_user }} \
  {{ '-p' if mysql_proxy_admin_password else '' }}{{ mysql_proxy_admin_password }} -P{{ mysql_proxy_admin_port }}"

echo -e "\nStarting $0..\n"

echo "remove old master ($old_master) from master hostgroup(0)"
mysql ${proxysql_login} -v -e \
  "DELETE FROM mysql_servers WHERE hostgroup_id=0 \
    AND hostname=\"$old_master\"; LOAD MYSQL SERVERS TO RUNTIME; SAVE MYSQL SERVERS TO DISK;" \
  || exit 1

echo "add orchestrator elected new master ($new_master) to master hostgroup(0)"
mysql ${proxysql_login} -v -e \
  "INSERT INTO mysql_servers(hostgroup_id,hostname,port,status) \
    values (0, \"$new_master\", 3306, 'ONLINE'); LOAD MYSQL SERVERS TO RUNTIME; SAVE MYSQL SERVERS TO DISK;" \
  || exit 1

echo -e "\nSuccess!"
