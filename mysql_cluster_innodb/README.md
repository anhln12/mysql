**Monitoring Mysql InnoDB Cluster**
- Check version
```
[root@mysql03 opt]# mysqlsh --version
mysqlsh   Ver 8.0.30 for Linux on x86_64 - for MySQL 8.0.30 (MySQL Community Server (GPL))
```
- clusteradmin
```
[root@mysql03 opt]# mysqlsh --uri clusteradmin@mysql03:3306
MySQL Shell 8.0.30

Copyright (c) 2016, 2022, Oracle and/or its affiliates.
Oracle is a registered trademark of Oracle Corporation and/or its affiliates.
Other names may be trademarks of their respective owners.

Type '\help' or '\?' for help; '\quit' to exit.
Creating a session to 'clusteradmin@mysql03:3306'
Fetching schema names for autocompletion... Press ^C to stop.
Your MySQL connection id is 6156719
Server version: 8.0.30 MySQL Community Server - GPL
No default schema selected; type \use <schema> to set one.
 MySQL   mysql03:3306   JS 
  > var c=dba.getCluster();
  > c.status();
```

or mysqlsh --uri clusteradmin@mysql03:3306 -- cluster status

# Install And Deploy MySQL 8 InnoDB Cluster with 3 node under Centos 8
https://ahelpme.com/software/mysql/install-and-deploy-mysql-8-innodb-cluster-with-3-nodes-under-centos-8-and-mysql-router-for-ha/#google_vignette



