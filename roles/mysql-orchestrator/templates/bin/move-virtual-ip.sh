#!/usr/bin/env bash

# Setup virtual ip:
#   remove ${VIRTUAL_IP} from old master and add it to new master

VIRTUAL_IP="${VIRTUAL_IP:-{{ mysql_repl_virtual_ip }}}"

# variables exposed by Orchestrator
old_master="$ORC_FAILED_HOST"
new_master="$ORC_SUCCESSOR_HOST"

ssh='ssh -i ~/.ssh/id_rsa_orchestrator'
ssh_old_master="$ssh $old_master"
ssh_new_master="$ssh $new_master"
get_default_dev="/sbin/ip route | grep -Po 'default.*dev\s\K.*(?=\sproto)'"

echo -e "\nStarting $0..\n"
old_master_dev=$($ssh_old_master "$get_default_dev")
echo "remove $VIRTUAL_IP from $old_master interface $old_master_dev"
$ssh_old_master \
  "ip address del {{ mysql_repl_virtual_ip }}/32 dev $old_master_dev" \
  || echo "can't remove {{ mysql_repl_virtual_ip }}/32 from $old_master"

echo "check $VIRTUAL_IP is not accessible"
ping -c1 $VIRTUAL_IP
if [[ "$?" == "0" ]]; then
  echo "Error: $VIRTUAL_IP is available. Aborting."
  exit 1
fi

new_master_dev=$($ssh_new_master "$get_default_dev")
echo "add $VIRTUAL_IP to $new_master interface $new_master_dev"
$ssh_new_master \
  "ip address add {{ mysql_repl_virtual_ip }}/32 dev $new_master_dev" \
  || exit 1

echo "update arp cache.."
ping -c1 $VIRTUAL_IP

echo -e "\nSuccess: $VIRTUAL_IP is moved from $old_master to $new_master!"
