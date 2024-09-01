ProxySQL là một Proxy Server Open Source được thiết kế dùng để hỗ trợ cân bằng tải các cụm MySQL Database Cluster. ProxySQL có thể hỗ trợ hàng ngàn kết nối một lúc và có khả năng tùy biến cao thông qua giao diện command-line SQL.

Một số tính năng nổi bật của ProxySQL như:
* Hỗ trợ cân bằng tải
* Query Caching
* Query Routing
* Hỗ trợ Failover
* Firewall

Refer:
Github ProxySQL : https://github.com/sysown/proxysql
Documentation ProxySQL : https://proxysql.com/Documentation/
Packet Debian : https://repo.proxysql.com/ProxySQL/

**Installation**

Ubuntu
```
apt-get install -y --no-install-recommends lsb-release wget apt-transport-https ca-certificates gnupg
echo deb https://repo.proxysql.com/ProxySQL/proxysql-2.5.x/$(lsb_release -sc)/ ./ | tee /etc/apt/sources.list.d/proxysql.list
wget -nv -O /etc/apt/trusted.gpg.d/proxysql-2.5.x-keyring.gpg 'https://repo.proxysql.com/ProxySQL/proxysql-2.5.x/repo_pub_key.gpg'
apt-get update
apt-get install proxysql
apt install mysql-client-core-8.0
```

Configure ProxySQL
```
mkdir -p /opt/proxysql
chown -R proxysql:proxysql /opt/proxysql

vi /etc/proxysql.cnf

datadir="/var/lib/proxysql"
errorlog="/var/lib/proxysql/proxysql.log"
threads=4
max_connections=2048
interfaces="0.0.0.0:6033"
==>
datadir="/opt/proxysql"
errorlog="/opt/proxysql/proxysql.log"
threads=12
mysql-max_connections = 65000
interfaces="0.0.0.0:3306"
```








ProxySQL Admin> SHOW CREATE TABLE mysql_group_replication_hostgroups\G



