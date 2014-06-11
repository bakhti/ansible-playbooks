dbbackup ansible role
=====================

Setup a cron job to backup databases to AWS S3 using [Percona XtraBackup](http://www.percona.com/software/percona-xtrabackup)

Requirements
------------

### Roles

- common
- awscli
- percona

### Variables

```yaml
my_root_password: mysql_root_password
backup_db:
  EC2_instance1_Name_tag: db1_name
  EC2_instance1_Name_tag: db1_name
```

If `backup_db` is not defined, all databases are backed up.