1. Stop Mysql service
Before makeing any changes, you need to stop mysql service.

```
systemctl stop mysql
```
2. Move data
By default, Mysql stores its data in /var/lib/mysql. Move this directory to the new location.

```
mv /var/lib/mysql /opt/mysql/data
```

Make sure the new directory has proper ownership by Mysql user
```
chown -R mysql:mysql /new/mysql/data
```

3. Update Mysql configuration
On Linux, this is usually located at /etc/mysql/my.cnf or /etc/my.cnf

Add or modify the following lines:
```
[mysqld]
datadir = /new/mysql/data
```

4. Restar Mysql
```
systemctl start mysql
```

5. Verify the Change
``
mysql -u root -p
mysql> SHOW VARIABLES LIKE 'datadir';
```


   
