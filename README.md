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
