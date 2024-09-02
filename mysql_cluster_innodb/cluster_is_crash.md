A Node in MySQL innoDB cluster is crashed and unable to re-join the crashed node to the cluster

I did the following to restore the failed node from backup and able to recover the cluster state.

1. Below is status of the cluster when one of the nodes failed (NODE01)
```
[root@mysql03 ~]# mysqlsh --uri clusteradmin@mysql03:3306

 MySQL   mysql03:3306   JS 
  > dba.getCluster().status();
{
    "clusterName": "mobiedu",
    "defaultReplicaSet": {
        "name": "default",
        "primary": "mysql03.mobiedu.vn:3306",
        "ssl": "REQUIRED",
        "status": "OK_NO_TOLERANCE_PARTIAL",
        "statusText": "Cluster is NOT tolerant to any failures. 1 member is not active.",
        "topology": {
            "mysql01.mobiedu.vn:3306": {
                "address": "mysql01.mobiedu.vn:3306",
                "instanceErrors": [
                    "ERROR: GR Applier channel applier stopped with an error: Worker 1 failed executing transaction 'c5330d69-38a9-11ed-a29b-02005cf90027:17382425'; Could not execute Write_rows event on table mschool_course_dev2.CompleteLessonLog; The table 'CompleteLessonLog' is full, Error_code: 1114; handler error HA_ERR_RECORD_FILE_FULL (1114) at 2024-07-08 15:18:43.610823",
                    "ERROR: group_replication has stopped with an error."
                ],
                "memberRole": "SECONDARY",
                "memberState": "ERROR",
                "mode": "R/O",
                "readReplicas": {},
                "role": "HA",
                "status": "(MISSING)",
                "version": "8.0.30"
            },
            "mysql02.mobiedu.vn:3306": {
                "address": "mysql02.mobiedu.vn:3306",
                "instanceErrors": [
                    "WARNING: The replication recovery account in use by the instance is not stored in the metadata. Use Cluster.rescan() to update the metadata."
                ],
                "memberRole": "SECONDARY",
                "mode": "R/O",
                "readReplicas": {},
                "replicationLag": "applier_queue_applied",
                "role": "HA",
                "status": "ONLINE",
                "version": "8.0.30"
            },
            "mysql03.mobiedu.vn:3306": {
                "address": "mysql03.mobiedu.vn:3306",
                "memberRole": "PRIMARY",
                "mode": "R/W",
                "readReplicas": {},
                "replicationLag": "applier_queue_applied",
                "role": "HA",
                "status": "ONLINE",
                "version": "8.0.30"
            }
        },
        "topologyMode": "Single-Primary"
    },
    "groupInformationSourceMember": "mysql03.mobiedu.vn:3306"
}
```

2. Take mysqldump from the master node using the following command.
```
[root@NODE03 db_backup]# mysqldump --all-databases --add-drop-database --single-transaction --triggers --routines --port=3306 --user=root -p > /opt/mysql_dump_20240902.sql
Enter password:
```

3. Execute below step to remove the faied node from the cluster
```
[root@mysql03 opt]# mysqlsh --uri clusteradmin@mysql03:3306
Please provide the password for 'clusteradmin@mysql03:3306': *****************
Save password for 'clusteradmin@mysql03:3306'? [Y]es/[N]o/Ne[v]er (default No): Y
MySQL Shell 8.0.30

Copyright (c) 2016, 2022, Oracle and/or its affiliates.
Oracle is a registered trademark of Oracle Corporation and/or its affiliates.
Other names may be trademarks of their respective owners.

Type '\help' or '\?' for help; '\quit' to exit.
Creating a session to 'clusteradmin@mysql03:3306'
Fetching schema names for autocompletion... Press ^C to stop.
Your MySQL connection id is 6149745
Server version: 8.0.30 MySQL Community Server - GPL
No default schema selected; type \use <schema> to set one.
 MySQL   mysql03:3306   JS 
  > var c=dba.getCluster()
 MySQL   mysql03:3306   JS 
  > c.rescan()
Rescanning the cluster...

Result of the rescanning operation for the 'mobiedu' cluster:
{
    "name": "mobiedu",
    "newTopologyMode": null,
    "newlyDiscoveredInstances": [],
    "unavailableInstances": [
        {
            "host": "mysql01.mobiedu.vn:3306",
            "label": "mysql01.mobiedu.vn:3306",
            "member_id": "be27176a-38a2-11ed-a593-02005cf90027"
        }
    ],
    "updatedInstances": []
}

The instance 'mysql01.mobiedu.vn:3306' is no longer part of the cluster.
The instance is either offline or left the HA group. You can try to add it to the cluster again with the cluster.rejoinInstance('mysql01.mobiedu.vn:3306') command or you can remove it from the cluster configuration.
Would you like to remove it from the cluster metadata? [Y/n]: Y
Removing instance from the cluster metadata...
The instance 'mysql01.mobiedu.vn:3306' was successfully removed from the cluster metadata.


 MySQL   mysql03:3306   JS 
  > c.status()
{
    "clusterName": "mobiedu",
    "defaultReplicaSet": {
        "name": "default",
        "primary": "mysql03.mobiedu.vn:3306",
        "ssl": "REQUIRED",
        "status": "OK_NO_TOLERANCE",
        "statusText": "Cluster is NOT tolerant to any failures.",
        "topology": {
            "mysql02.mobiedu.vn:3306": {
                "address": "mysql02.mobiedu.vn:3306",
                "memberRole": "SECONDARY",
                "mode": "R/O",
                "readReplicas": {},
                "replicationLag": "applier_queue_applied",
                "role": "HA",
                "status": "ONLINE",
                "version": "8.0.30"
            },
            "mysql03.mobiedu.vn:3306": {
                "address": "mysql03.mobiedu.vn:3306",
                "memberRole": "PRIMARY",
                "mode": "R/W",
                "readReplicas": {},
                "replicationLag": "applier_queue_applied",
                "role": "HA",
                "status": "ONLINE",
                "version": "8.0.30"
            }
        },
        "topologyMode": "Single-Primary"
    },
    "groupInformationSourceMember": "mysql03.mobiedu.vn:3306"
}
```

4. Stop group replication if it is still running on failed node.
```
mysql> STOP GROUP_REPLICATION;
```
5. Reset "gtid_executed" on the failed node.
```
mysql> show global variables like 'GTID_EXECUTED';
+---------------+--------------------------------------------------------------------------------------------------------------------------------------+
| Variable_name | Value                                                                                                                                |
+---------------+--------------------------------------------------------------------------------------------------------------------------------------+
| gtid_executed | be27176a-38a2-11ed-a593-02005cf90027:1-7,
c5330d69-38a9-11ed-a29b-02005cf90027:1-17382424,
c53311fa-38a9-11ed-a29b-02005cf90027:1-28 |
+---------------+--------------------------------------------------------------------------------------------------------------------------------------+
1 row in set (0.00 sec)

mysql> reset master;
Query OK, 0 rows affected (0.70 sec)

mysql> reset slave;
Query OK, 0 rows affected, 1 warning (0.04 sec)

mysql> show global variables like 'GTID_EXECUTED';
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| gtid_executed |       |
+---------------+-------+
1 row in set (0.00 sec)
```
6. Disable "super_readonly_flag" on the failed node
```
mysql> SELECT @@global.read_only, @@global.super_read_only;
+--------------------+--------------------------+
| @@global.read_only | @@global.super_read_only |
+--------------------+--------------------------+
|                  1 |                        1 |
+--------------------+--------------------------+
1 row in set (0.00 sec)

mysql> SET GLOBAL super_read_only = 0;
Query OK, 0 rows affected (0.00 sec)

mysql> SELECT @@global.read_only, @@global.super_read_only;
+--------------------+--------------------------+
| @@global.read_only | @@global.super_read_only |
+--------------------+--------------------------+
|                  1 |                        0 |
+--------------------+--------------------------+
1 row in set (0.00 sec)
```
7. Restore the mysqldump from master on to the failed node.
```

```
8. Once restore is completed enable "super_readonly_flag" on the failed node.
```
mysql> SELECT @@global.read_only, @@global.super_read_only;
+--------------------+--------------------------+
| @@global.read_only | @@global.super_read_only |
+--------------------+--------------------------+
|                  1 |                        0 |
+--------------------+--------------------------+
1 row in set (0.00 sec)

mysql> SET GLOBAL super_read_only = 1;
Query OK, 0 rows affected (0.00 sec)

mysql> SELECT @@global.read_only, @@global.super_read_only;
+--------------------+--------------------------+
| @@global.read_only | @@global.super_read_only |
+--------------------+--------------------------+
|                  1 |                        1 |
+--------------------+--------------------------+
1 row in set (0.00 sec)
```

9. Finally add the failed node back to the innodb cluster.
```
mysql01: mysql> SET GLOBAL super_read_only = 0;

[root@mysql03 opt]# mysqlsh --uri clusteradmin@mysql03:3306
 MySQL   mysql03:3306   JS 
  > var c=dba.getCluster();
  > c.addInstance('clusteradmin@mysql01.mobiedu.vn:3306');

WARNING: A GTID set check of the MySQL instance at 'mysql01.mobiedu.vn:3306' determined that it contains transactions that do not originate from the cluster, which must be discarded before it can join the cluster.

mysql01.mobiedu.vn:3306 has the following errant GTIDs that do not exist in the cluster:
be27176a-38a2-11ed-a593-02005cf90027:8

WARNING: Discarding these extra GTID events can either be done manually or by completely overwriting the state of mysql01.mobiedu.vn:3306 with a physical snapshot from an existing cluster member. To use this method by default, set the 'recoveryMethod' option to 'clone'.

Having extra GTID events is not expected, and it is recommended to investigate this further and ensure that the data can be removed prior to choosing the clone recovery method.

Please select a recovery method [C]lone/[A]bort (default Abort): C
Validating instance configuration at mysql01.mobiedu.vn:3306...

This instance reports its own address as mysql01.mobiedu.vn:3306

Instance configuration is suitable.
NOTE: Group Replication will communicate with other members using 'mysql01.mobiedu.vn:3306'. Use the localAddress option to override.

A new instance will be added to the InnoDB cluster. Depending on the amount of
data on the cluster this might take from a few seconds to several hours.

Adding instance to the cluster...

NOTE: User 'mysql_innodb_cluster_1'@'%' already existed at instance 'mysql03.mobiedu.vn:3306'. It will be deleted and created again with a new password.
Monitoring recovery process of the new cluster member. Press ^C to stop monitoring and let it continue in background.
Clone based state recovery is now in progress.

NOTE: A server restart is expected to happen as part of the clone process. If the
server does not support the RESTART command or does not come back after a
while, you may need to manually start it back.

* Waiting for clone to finish...
NOTE: mysql01.mobiedu.vn:3306 is being cloned from mysql03.mobiedu.vn:3306
** Stage DROP DATA: Completed
** Clone Transfer
    FILE COPY  ############################################################  100%  Completed
    PAGE COPY  ############################################################  100%  Completed
    REDO COPY  ############################################################  100%  Completed

NOTE: mysql01.mobiedu.vn:3306 is shutting down...

* Waiting for server restart... ready
* mysql01.mobiedu.vn:3306 has restarted, waiting for clone to finish...
** Stage RESTART: Completed
* Clone process has finished: 15.37 GB transferred in 1 min 1 sec (251.96 MB/s)

State recovery already finished for 'mysql01.mobiedu.vn:3306'

The instance 'mysql01.mobiedu.vn:3306' was successfully added to the cluster.

 MySQL   mysql03:3306   JS 
  > c.status();
{
    "clusterName": "mobiedu",
    "defaultReplicaSet": {
        "name": "default",
        "primary": "mysql03.mobiedu.vn:3306",
        "ssl": "REQUIRED",
        "status": "OK",
        "statusText": "Cluster is ONLINE and can tolerate up to ONE failure.",
        "topology": {
            "mysql01.mobiedu.vn:3306": {
                "address": "mysql01.mobiedu.vn:3306",
                "memberRole": "SECONDARY",
                "mode": "R/O",
                "readReplicas": {},
                "replicationLag": "applier_queue_applied",
                "role": "HA",
                "status": "ONLINE",
                "version": "8.0.30"
            },
            "mysql02.mobiedu.vn:3306": {
                "address": "mysql02.mobiedu.vn:3306",
                "memberRole": "SECONDARY",
                "mode": "R/O",
                "readReplicas": {},
                "replicationLag": "applier_queue_applied",
                "role": "HA",
                "status": "ONLINE",
                "version": "8.0.30"
            },
            "mysql03.mobiedu.vn:3306": {
                "address": "mysql03.mobiedu.vn:3306",
                "memberRole": "PRIMARY",
                "mode": "R/W",
                "readReplicas": {},
                "replicationLag": "applier_queue_applied",
                "role": "HA",
                "status": "ONLINE",
                "version": "8.0.30"
            }
        },
        "topologyMode": "Single-Primary"
    },
    "groupInformationSourceMember": "mysql03.mobiedu.vn:3306"
}

```

```
mysql> select * from performance_schema.replication_group_members;
+---------------------------+--------------------------------------+--------------------+-------------+--------------+-------------+----------------+----------------------------+
| CHANNEL_NAME              | MEMBER_ID                            | MEMBER_HOST        | MEMBER_PORT | MEMBER_STATE | MEMBER_ROLE | MEMBER_VERSION | MEMBER_COMMUNICATION_STACK |
+---------------------------+--------------------------------------+--------------------+-------------+--------------+-------------+----------------+----------------------------+
| group_replication_applier | bab6f475-38a2-11ed-be4c-0200109d0025 | mysql03.mobiedu.vn |        3306 | ONLINE       | PRIMARY     | 8.0.30         | MySQL                      |
| group_replication_applier | bbb91e62-38a2-11ed-b5f1-0200217e0026 | mysql02.mobiedu.vn |        3306 | ONLINE       | SECONDARY   | 8.0.30         | MySQL                      |
| group_replication_applier | be27176a-38a2-11ed-a593-02005cf90027 | mysql01.mobiedu.vn |        3306 | ONLINE       | SECONDARY   | 8.0.30         | MySQL                      |
+---------------------------+--------------------------------------+--------------------+-------------+--------------+-------------+----------------+-------------
```

refer: 
- https://stackoverflow.com/questions/55036255/a-node-in-mysql-5-7-innodb-cluster-is-crashed-and-unable-to-re-join-the-crashed
- https://ahelpme.com/software/mysql/recovery-of-mysql-8-cluster-instance-after-server-crash-and-corrupted-data-in-log-event


