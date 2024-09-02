# Course
https://www.youtube.com/@mughees52/playlists

# Mysql

Export table
/usr/bin/mysqldump -usmartdealer -pxxxx vnpt_dealer customer_package > /tmp/customer_package.sql
trong đó:
vnpt_dealer: schema
customer_package: bảng dữ liệu cần export

Export multi table
mysqldump -usmartdealer -pxxxx vnpt_dealer vnpt_cdr vnpt_cdr_cancel vnpt_cdr_renew order product product_asm_property commision_asm_policy commission commision_policy commision_history customer_package category user_over_threshold user business_center sale_department > shop_ctv.sql

Export table theo điều kiện
mysqldump -usmartdealer -pxxxx vnpt_dealer cdr_it --where="file in ('TICHHOP_20220423.txt','sps_20220423.txt','spi_20220423.txt','reservation_20220423.txt')" > /mnt/smartdealerbkp/cdr_it_20220423.sql

Export all theo database
mysqldump -usmartdealer -p vnpt_dealer --databases > /mnt/smartdealerbkp/smartdealer_20220209_full.sql

Import
```
mysql -u username -p database_name < file.sql
```
Backup ignore
00 03 * * * /opt/backup/mysql/backup_ignore_cdr.sh >> /opt/backup/backup_ignore_cdr.log

backup_ignore_cdr.sh
date=`date +"%Y%m%d_%H%M%S"`
/usr/bin/mysqldump -usmartdealer -pxxxx vnpt_dealer --databases --ignore-table=vnpt_dealer.cdr_it --ignore-table=vnpt_dealer.cdr_it_20210913  > /mnt/smartdealerbkp/smartdealer_${date}_ignore.sql

sleep 100
gzip /mnt/smartdealerbkp/smartdealer_${date}_ignore.sql

Backup all
00 04 * * 1 /opt/backup/mysql/backup.sh >> /opt/backup/mysql/backup.log
/opt/backup/mysql/backup.sh
date=`date +"%Y%m%d_%H%M%S"`
mysqldump -usmartdealer -pxxxx vnpt_dealer --databases > /mnt/smartdealerbkp/smartdealer_${date}_full.sql

sleep 300
gzip /mnt/smartdealerbkp/smartdealer_${date}_full.sql

Delete bin log
mysql> show variables like 'expire_logs_days';
mysql> PURGE BINARY LOGS BEFORE NOW() - INTERVAL 3 DAY;

# Reset mật khẩu
B1: Tiến hành stop dịch vụ MySQL
```
systemctl stop mysql
```
B2: Truy cập chế độ mysqld_safe
```
mysqld_safe --skip-grant-tables --skip-networking &
```
B3: Truy cập tài khoản root MySQL
```
mysql -u root
```
B4: Để thiết lập lại mật khẩu root MySQL , thực hiện lần lượt các lệnh
```
use mysql;
update user set password=PASSWORD(“mynewpassword”) where User='root';     (thay mynewpassword bằng password của bạn cần đặt)
flush privileges;
quit
```
B5 : Khởi động lại dịch vụ MySQL

# Tạo Database và User
```
create database zabbix character set utf8 collate utf8_bin;
create user zabbix@localhost identified by 'password';
grant all privileges on zabbix.* to zabbix@localhost;
quit;
```

# import dữ liệu
mysql -u username -p database_name < file.sql

# Check size database
```
SELECT table_schema "DB Name",
        ROUND(SUM(data_length + index_length) / 1024 / 1024, 1) "DB Size in MB" 
FROM information_schema.tables 
GROUP BY table_schema; 
```

# Fix lỗi mysql-bin files chiếm dung lượng
Binary logs có dạng mysql-bin.xxx trong thư mục /var/lib/mysql 
```
mysql> SHOW BINARY LOGS;
+——————+———–+
| Log_name | File_size |
+——————+———–+
| mysql-bin.000008 | 641222072 |
| mysql-bin.000009 | 324173772 |
| mysql-bin.000010 | 53931666 |
| mysql-bin.000011 | 10360680 |
```
```
mysql> PURGE BINARY LOGS TO ‘mysql-bin.000011’;
```
Khi đó hệ thống sẽ giải phóng xóa các file binary logs trước mysql-bin.000011.

Cấu hình disable hoặc rotate file log

Để thiết lập cho hệ thống không phát sinh các file này thì cần bỏ thông số: log-bin=mysql-bin trong file /etc/my.cnf sau đó restart lại dịch vụ mysql.

Hoặc muốn hệ thống tự động rotate và giữ lại các file này trong 3 ngày thì có thể thêm thông số: expire_logs_days=3 trong file /etc/my.cnf sau đó restart lại dịch vụ hoặc sử dụng command line mysql manager: 
```
mysql> SET GLOBAL expire_logs_days = 3;
```
