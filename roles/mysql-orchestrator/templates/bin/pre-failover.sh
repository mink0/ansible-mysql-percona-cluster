#!/usr/bin/env bash

# variable exposed by Orchestrator
old_master="$(getent hosts $ORC_FAILED_HOST | awk '{ print $1; exit }')"

# timeout in seconds for graceful conections drain
GRACE_TIMEOUT=${GRACE_TIMEOUT:-3}


proxysql_login="-h{{ mysql_proxy_host }} -u{{ mysql_proxy_admin_user }} \
  {{ '-p' if mysql_proxy_admin_password else '' }}{{ mysql_proxy_admin_password }} -P{{ mysql_proxy_admin_port }}"

echo -e "\nstarting $0..\n"

echo 'stop accepting new connections to old master, existing connections are still working'
echo "set $old_master status=OFFLINE_SOFT"
mysql ${proxysql_login} -v -e "UPDATE mysql_servers SET STATUS='OFFLINE_SOFT' \
  WHERE hostname=\"$old_master\"; LOAD MYSQL SERVERS TO RUNTIME;"

# after GRACE_TIMEOUT orchestrator will promote new master
# wait for GRACE_TIMEOUT while connections are draining
start=$(date +%s)
while true; do
  connections=$(mysql ${proxysql_login} -e \
    "SELECT IFNULL(SUM(ConnUsed),0) FROM stats_mysql_connection_pool WHERE \
      status='OFFLINE_SOFT' AND srv_host=\"$old_master\";" -B -N &2> /dev/null)

  if [ $? -ne 0 ]; then
    echo "error: connection check fail: exit code: $?"
    exit 1
  fi

  if [[ "$connections" == "0" ]]; then
    echo "all connections to $old_master are gracefully drained"
    exit 0
  fi

  end=$(date +%s)
  duration=$((end-start))

  if [ $duration -ge $GRACE_TIMEOUT ]; then
    echo "error: $old_master graceful conections drain timeout"
    exit 1
  fi

  echo "waiting while connections are draining from $old_master ..${duration}/${GRACE_TIMEOUT}s"
  sleep 0.01
done
