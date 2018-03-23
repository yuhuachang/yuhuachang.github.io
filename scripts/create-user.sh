#!/bin/bash

DB_USER=$1
DB_PASSWORD=$2

if [ "$DB_USER" == "" or "$DB_PASSWORD" == "" ]; then
    echo "usage $0 <user> <password>"
    exit
fi

#
# create user
#
sudo su - postgres -c "dropuser $DB_USER" 2>/dev/null
sudo su - postgres -c "createuser --encrypted --no-createdb --no-createrole --no-superuser --no-replication $DB_USER"
sudo su - postgres -c "psql -c \"alter user $DB_USER password '$DB_PASSWORD'\""
sudo su - postgres -c "psql -c 'select * from pg_user'"

#
# store password
#
echo "*:5432:$DB_DATABASE:$DB_USER:$DB_PASSWORD" >> ~/.pgpass
chmod 0600 ~/.pgpass
