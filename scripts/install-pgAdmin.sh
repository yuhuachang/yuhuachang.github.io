#!/bin/bash

#
# install pgAdmin 4 v2
#

# check yum repository: https://yum.postgresql.org/ and download postgresql server rpm
yum install -y https://download.postgresql.org/pub/repos/yum/9.6/redhat/rhel-7-x86_64/pgdg-redhat96-9.6-3.noarch.rpm
# yum install -y https://download.postgresql.org/pub/repos/yum/9.6/redhat/rhel-7-x86_64/pgdg-centos96-9.6-3.noarch.rpm

# install rpm
yum install -y epel-release

# install pgAdmin
yum install -y pgadmin4-v2

# edit /usr/lib/python2.7/site-packages/pgadmin4-web/config_distro.py to add pgAdmin path.
# this file contains one line: HELP_PATH = '/usr/share/doc/pgadmin4-v2-docs/en_US/html'
# and we will add anoyther 4 paths.
echo "HELP_PATH = '/usr/share/doc/pgadmin4-v2-docs/en_US/html'" > /usr/lib/python2.7/site-packages/pgadmin4-web/config_distro.py
echo "LOG_FILE = '/var/log/pgadmin4/pgadmin4.log'" >> /usr/lib/python2.7/site-packages/pgadmin4-web/config_distro.py
echo "SQLITE_PATH = '/var/lib/pgadmin4/pgadmin4.db'" >> /usr/lib/python2.7/site-packages/pgadmin4-web/config_distro.py
echo "SESSION_DB_PATH = '/var/lib/pgadmin4/sessions'" >> /usr/lib/python2.7/site-packages/pgadmin4-web/config_distro.py
echo "STORAGE_DIR = '/var/lib/pgadmin4/storage'" >> /usr/lib/python2.7/site-packages/pgadmin4-web/config_distro.py
cat /usr/lib/python2.7/site-packages/pgadmin4-web/config_distro.py

# create the configuration database.
python /usr/lib/python2.7/site-packages/pgadmin4-web/setup.py

# Change the ownership of the configuration database directory to the user Apache:
chown -R apache:apache /var/lib/pgadmin4
chown -R apache:apache /var/log/pgadmin4

# If the SeLinux is enabled, adjust the SELinux policy using the following commands:
chcon -R -t httpd_sys_content_rw_t "/var/log/pgadmin4/"
chcon -R -t httpd_sys_content_rw_t "/var/lib/pgadmin4/"

# Create the Apache Virtual Host for PGAdmin 4
echo "<VirtualHost *>" > /etc/httpd/conf.d/pgadmin4.conf
echo "    ServerName pgadmin.yallalabs.local" >> /etc/httpd/conf.d/pgadmin4.conf
echo "" >> /etc/httpd/conf.d/pgadmin4.conf
echo "    WSGIDaemonProcess pgadmin processes=1 threads=25" >> /etc/httpd/conf.d/pgadmin4.conf
echo "    WSGIScriptAlias / /usr/lib/python2.7/site-packages/pgadmin4-web/pgAdmin4.wsgi" >> /etc/httpd/conf.d/pgadmin4.conf
echo "" >> /etc/httpd/conf.d/pgadmin4.conf
echo "    <Directory \"/usr/lib/python2.7/site-packages/pgadmin4-web/\">" >> /etc/httpd/conf.d/pgadmin4.conf
echo "        WSGIProcessGroup pgadmin" >> /etc/httpd/conf.d/pgadmin4.conf
echo "        WSGIApplicationGroup %{GLOBAL}" >> /etc/httpd/conf.d/pgadmin4.conf
echo "        Require all granted" >> /etc/httpd/conf.d/pgadmin4.conf
echo "    </Directory>" >> /etc/httpd/conf.d/pgadmin4.conf
echo "</VirtualHost>" >> /etc/httpd/conf.d/pgadmin4.conf
cat /etc/httpd/conf.d/pgadmin4.conf

# check config syntax
apachectl configtest

# restart httpd server
systemctl restart httpd

# To make sure PgAdmin can access to the PostgreSQL server we need to adjust Selinux to allow Apache to connect via network using the following command
setsebool -P httpd_can_network_connect 1

# If the Firewall is enabled, execute the following command to enable http service :
firewall-cmd --permanent --add-service=http
firewall-cmd --reload

