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

# default database name, user, and password for application to access.
DB_DATABASE="morrison"
DB_USER="morrison"
DB_PASSWORD="morrison"

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
#sed -i "s/all             127.0.0.1\/32            ident/all             127.0.0.1\/32            md5/g" /var/lib/pgsql/9.6/data/pg_hba.conf
#sed -i "s/all             127.0.0.1\/32            ident/all             127.0.0.1\/32            md5/" /var/lib/pgsql/9.6/data/pg_hba.conf
#sudo grep 127.0.0.1 /var/lib/pgsql/9.6/data/pg_hba.conf

#
# allow password login from outside.
#
#HOST_ADDR=`ip a | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}'`
#echo "Enable login from $HOST_ADDR"
#sed -i -e 's#.*IPv4 local connections.*#\# IPv4 local connections:\nhost    all             all             '${HOST_ADDR}'        md5#' /var/lib/pgsql/9.5/data/pg_hba.conf

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

#
# create database
#
echo "Create database '$DB_DATABASE'"
sudo su - postgres -c "dropdb $DB_DATABASE" 2>/dev/null
sudo su - postgres -c "createdb $DB_DATABASE"
sudo su - postgres -c "psql --list"

#
# create user
#
echo "Create user '$DB_USER' with password '$DB_PASSWORD'"
sudo su - postgres -c "dropuser $DB_USER" 2>/dev/null
sudo su - postgres -c "createuser --encrypted --no-createdb --no-createrole --no-superuser --no-replication $DB_USER"
sudo su - postgres -c "psql -c \"alter user $DB_USER password '$DB_PASSWORD'\""
sudo su - postgres -c "psql -c 'select * from pg_user'"

#
# store password
#
echo "Store password in ~/.pgpass"
echo "*:5432:$DB_DATABASE:$DB_USER:$DB_PASSWORD" > ~/.pgpass
chmod 0600 ~/.pgpass

#psql -h 127.0.0.1 -p 5432 -U tkk -d tkk -c "select * from information_schema.role_table_grants where grantee='tkk'"
#psql -h 127.0.0.1 -p 5432 -U tkk -d tkk -c "select count(*) from information_schema.tables"
#psql -h 127.0.0.1 -p 5432 -U tkk -d tkk -c "create table abc ( id int )"
#psql -h 127.0.0.1 -p 5432 -U tkk -d tkk -c "select * from abc"
#psql -h 127.0.0.1 -p 5432 -U tkk -d tkk -c "drop table abc"
