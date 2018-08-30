# Deploy a Production Ready MySQL Cluster

  * [Percona mysql server](https://www.percona.com/software/mysql-database/percona-server)
  * `Master`-`Slave` asynchronous replication with [GTID](https://dev.mysql.com/doc/refman/5.6/en/replication-gtids-concepts.html)
  * [Innobackupex](https://www.percona.com/doc/percona-xtrabackup/LATEST/howtos/recipes_ibkx_gtid.html) for minimum downtimes during `master` seeding
  * [Orchestrator](https://github.com/github/orchestrator)
  * [Proxysql](https://github.com/sysown/proxysql) as mysql proxy and read/write splitter

## Install

    # install dependencies from `requirements.txt`
    $ sudo pip install -r requirements.txt

    # copy `inventory/sample` as `inventory/mycluster`
    $ cp -rfp inventory/sample/* inventory/mycluster

## Deploy

    # deploy
    $ ansible-playbook -i inventory/mycluster/hosts.ini mysql-cluster.yml

    # deploy and run tests
    $ ansible-playbook -i inventory/mycluster/hosts.ini mysql-cluster.yml --tags all,test


## Run tests

    $ ansible-playbook -i inventory/mycluster/hosts.ini mysql-cluster.yml --tags test
