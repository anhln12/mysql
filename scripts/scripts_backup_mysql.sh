#!/bin/bash

# Author anhln
# Email: anhle0412@gmail.com
# Shell script to backup db mysql

###########################################################
# Some other variables here
###########################################################

DB_USER="root"
DB_PASS="123456a@"
DB_NAME="database-name"
BACKUP_DIR="/database/backupdir/mysql"
DATE=$(date +"%Y-%m-%d_%H-%M-%S")


##########################################################
# All Script Functions Goes Here
##########################################################

mysqldump --user=$DB_USER --password=$DB_PASS $DB_NAME > $BACKUP_DIR/$DB_NAME-$DATE.sql
gzip $BACKUP_DIR/$DB_NAME-$DATE.sql

find $BACKUP_DIR -type f -name "*.gz" -mtime +7 -delete



# Backup db mysql daily
0 1 * * * sh /database/backupdir/script_backup_mysql.sh > /database/backupdir/logs/backup_mysql.log 2>&1
