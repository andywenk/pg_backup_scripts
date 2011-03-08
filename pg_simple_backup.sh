#!/bin/bash
# 
# Andreas Wenk 03.04.2010 | BSD License
#
# pg_single_backup.sh
#
# Script for creating a database dump in format custom from each database in a PostgreSQL cluster.
#
# Usage: 
# ./postgresql_backup.sh 
# 

# Variables

# Actual date in format 2010-04-02-05:40:00
DATE=`/bin/date "+%F-%T"` 

# Directory where to write the backup
BACKUPDIR="/var/backups/postgres/" 

# This is a common file extension for a binary backuo file
FILEFORMAT=".bak" 

# The name of the server 
SERVER=`hostname`

# The port on which the PostgreSQL is running at
PORT=5433

# With the use of the CLI programm psql we fire a query to the 
# table pg_database in the schema pg_catalog to get all names of 
# the excisting databases. What we do not want is the database
# postgres and all the template databases 
psql -t -c " SELECT datname FROM pg_catalog.pg_database WHERE  (datname NOT LIKE 'template%' AND datname != 'postgres');" |

# Iterating over the result form the query
while read i; do
	if [ ! -z $i ]; then 
		# Create the backup or exit with an error 
		pg_dump -p "$PORT" -Fc $i > "$BACKUPDIR$DATE-$i$FILEFORMAT" || 
		echo "error: backup $i not successfull." >&2
	fi; done

# Here we delete all backup files older than seven days
find $BACKUPDIR -ctime +7 -exec rm {} \;
