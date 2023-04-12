1. How do I turn off the mysql password validation?
2. 
To disable password checks in mariadb-10.1.24 (Fedora 24) I had to comment out a line in /etc/my.cnf.d/cracklib_password_check.cnf file:

;plugin-load-add=cracklib_password_check.so

then restart mariadb service:

systemctl restart mariadb.service
