#!/bin/bash

DB_DATABASE=$1

if [ "$DB_DATABASE" == "" ]; then
    echo "usage $0 <databbase>"
    exit
fi

sudo su - postgres -c "dropdb $DB_DATABASE" 2>/dev/null
sudo su - postgres -c "createdb $DB_DATABASE"
sudo su - postgres -c "psql --list"