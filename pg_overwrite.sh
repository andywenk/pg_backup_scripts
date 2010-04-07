#!/bin/bash
#
# Andreas Wenk 03.04.2010 | BSD License
#
# pg_overwrite.sh
#
# Script to write a backup into a PostgreSQL database. This is basically meant to use it for daily restoring a 
# test database or dem database or stuff like that. For sure you could also use pg_restore but it's fun to code and
# to understand now how to work with options when calling a shell script. You can use this as a start point for some other 
# tasks ans scripts.

# The main method which runs the process
# args: database user port backup
run_backup() {
  database=$1
  user=$2
  backup=$3
  
	# checking whether we use the standard port or the given
	if [ -z $4 ]
	then
	  port=5432
	else
	  port=$4
	fi
  
  # checking wther we use a given user or the user postgres  
  if [ -z $2 ]
  then
    user='postgres'
  else
    user=$2
  fi

	# fancy message for the user ;-)
	echo 
	echo "Now restoring the data ..."
	echo 
	
  # now run all the methods to get the backup into the database
	cut_connection $database
  drop_database $port $database 
  create_empty_database $port $user $database
  insert_dump $port $user $database $backup
}

# We cut all the connections to the database
cut_connection() {
	database=$1
	ps aux | grep "postgres: pgadmin $database" | grep -v grep | awk '{print $2}' | while read pid; do kill $pid;done
   cho "Connections cut ..."
}

# We delete the database. An error is thrown when it's not possible to do that. 
drop_database() {
	port=$1
	database=$2
	
	# check if dropdb is availabel
	program_is_available 'dropdb'

	if ! dropdb -p $port $database; then 
  	  echo "ERROR: somebody is working on the database $database. It is not possible to delete the database. Terminating program ..." >&2
          exit 1
	fi      

  echo "Database $database deleted ..."
}

# Create an empty database for the provided user
create_empty_database() {
	port=$1
  user=$2
  database=$3
	
	# check if createdb is available
	program_is_available 'createdb'

	if ! createdb -p $port --owner=$user --encoding=UTF8 $database; 
  then
    echo "ERROR: not possible to create the database $database on port $port for user $user. Terminating program ..." >&2
    exit 1
	fi

  echo "Database $database created ..."      
} 

# Insert the backup dump
insert_dump() {
  port=$1
  user=$2
  database=$3
  backup=$4

  if ! psql -U $user -p $port $database < $backup
  then
    echo "ERROR: not able to insrt the backup dump $backup to database $database (user: $user, port: $port)"
    exit 1;
  fi

  echo "Backup dump inserted ...";
} 
# helper method to check, if a program is available on the system
program_is_available() {
	program=$1
	available=`which $program`
	if [ $available == ''  ]
	then 
		echo "ERROR: the program $program is not available. Terminating program ..."
		exit 1
	fi
}

# show the help and how to use this script
print_help() {
cat << EOF
pg_overwrite.sh (c) 2010 Andreas Wenk

This script is restoring a given SQL dump in plain text into your 
PostgreSQL database. You have to provide at least the options
-d and -b.

USAGE: $0 options

OPTIONS:
   -d      In which database will the data be resored (required)?
   -u      Which is the database user (required)
   -b      The backup file in plain text (required)
   -p      Which is the database prot (default: 5432)
   -h      Show this help

For bugs and  questions get in touch at http://www.pg-praxisbuch.de

EOF
return
}

###
### Main programm
###

# Parse the command line arguments
while getopts 'd:u:p:b:h' OPTION
do
	case $OPTION in
		d) database="$OPTARG";;
		u) user="$OPTARG";;
    b) backup="$OPTARG";;
		p) port="$OPTARG";;
		h) print_help_uu; exit 1;; 
  esac
done  

# check if the required options are given
if [ -z $database ] || [ -z $backup ]
then
  echo
  echo "ERROR: missing parameter ..."
  echo ""
  print_help
  exit 1
fi

# run the backup
run_backup $database $user $backup $port

