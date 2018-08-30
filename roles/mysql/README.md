# Mysql Percona server

Install and configure Percona MySQL server.

Config is optimized for InnoDB storage engine use.

Playbook example:

```yaml
---

- hosts: all
  become: yes
  roles:
    - mysql
```

#### Tags

  - install

    install all packages

  - configure

    setup percona mysql config


#### Create mysql databases
To create mysql databases you should specify `mysql_databases` array.

Example:
```yaml
mysql_databases:
  - db_one
  - db_two
```

#### Create mysql users and grants
To create database users you should specify `mysql_users` array.
Grants should be filled according to [official documentation](http://docs.ansible.com/ansible/latest/mysql_user_module.html).

Example:
```yaml
mysql_users:
  - username: "user"
    password: "12345"
    grants: "db_one.*:ALL/db_two.*:ALL"
```
