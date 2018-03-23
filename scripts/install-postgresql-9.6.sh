#!/bin/bash
#
# Install PostgreSQL 9.6-3 Database Server
#
# Install database server on compile server only for testing.
# In AWS (QA and Prod), we should use AWS RDS instead of local database.
# All the settings in compile server, qa, and prod are the same.
#
# Ref: https://www.postgresql.org/download/linux/redhat/
#
################################################################################

#
# skip the installation if is installed already.
#
if [ -f /usr/pgsql-9.6/bin/postgres ]; then
    echo 'PostgreSQL Server is already installed.'
else
    echo 'Update the repository source'
    sudo yum -y install https://download.postgresql.org/pub/repos/yum/9.6/redhat/rhel-7-x86_64/pgdg-centos96-9.6-3.noarch.rpm

    echo 'Install PostgreSQL Client'
    sudo yum -y install postgresql96

    echo 'Install PostgreSQL Server'
    sudo yum -y install postgresql96-server

    echo 'Initialize the database and enable automatic start'
    sudo /usr/pgsql-9.6/bin/postgresql96-setup initdb
fi

#
# start listening.
#
echo "Set server to listen to all interfaces."
sudo sed -i "s/#listen_addresses = 'localhost'\s*# what IP address(es) to listen on;/listen_addresses = '*'                  # what IP address(es) to listen on;/" /var/lib/pgsql/9.6/data/postgresql.conf
sudo grep listen_addresses /var/lib/pgsql/9.6/data/postgresql.conf

#
# allow password login from localhost.
#
echo "Enable login from 127.0.0.1"
sudo sed -i "s/all             127.0.0.1\/32            ident/all             127.0.0.1\/32            md5/" /var/lib/pgsql/9.6/data/pg_hba.conf
sudo sed -i "s/all             127.0.0.1\/32            ident/all             0.0.0.0\/0               md5/" /var/lib/pgsql/9.6/data/pg_hba.conf
sudo grep 127.0.0.1 /var/lib/pgsql/9.6/data/pg_hba.conf

#
# allow password login from outside.
#
HOST_ADDRS=`ip a | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}'`
for HOST_ADDR in $HOST_ADDRS; do
    echo "Enable login from $HOST_ADDR"
    sudo sed -i -e 's#.*IPv4 local connections.*#\# IPv4 local connections:\nhost    all             all             '${HOST_ADDR}'        md5#' /var/lib/pgsql/9.6/data/pg_hba.conf
done

#echo 'Adjust Firewall'
#firewall-cmd --permanent --add-service=postgresql
#firewall-cmd --reload
#firewall-cmd --list-all

#echo 'Adjust SELinux'
#setsebool -P httpd_can_network_connect_db 1

#
# enable auto start on boot.
#
echo 'Enable PostgreSQL service'
sudo systemctl enable postgresql-9.6

#
# start server
#
echo 'Start PostgreSQL service'
sudo systemctl restart postgresql-9.6
sudo systemctl status postgresql-9.6
