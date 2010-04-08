#!/bin/bash
#
# Andreas Wenk <andy.wenk@googlemail.com> 08.04.2010 | BSD License
#
# pg_overwrite.sh
#
# Script to write a backup into a PostgreSQL database. This is basically meant to use it for daily restoring a 
# test database or demo database or stuff like that. For sure you could also use pg_restore but it's fun to code and
# to understand how to work with options when calling a shell script. You can use this as a start point for some other 
# tasks and scripts.

# The main method which runs the process
run_backup() {
  echo -e "\nNow restoring the data ...\n"
	
  # now run all the methods to get the backup into the database
  cut_connection
  drop_database
  create_empty_database
  insert_dump
}

# We cut all the connections to the database
cut_connection() {
  pkill -u postgres -f "postgres: $user $database";
  echo "Connections cut ..."
}

# We delete the database. An error is thrown when it's not possible to do that. 
drop_database() {
  # check if dropdb is availabel
  program_is_available 'dropdb'

  if ! dropdb -p $port $database; then 
    echo -e "\nERROR: It is not possible to delete the database $database. Terminating program ...\n" >&2
    exit 1
  fi      

  echo "Database $database deleted ..."
}

# Create an empty database for the provided user
create_empty_database() {
  # check if createdb is available
  program_is_available 'createdb'

  if ! createdb -p $port --owner=$user --encoding=UTF8 $database; 
  then
    echo -e "\nERROR: not possible to create the database $database on port $port for user $user. Terminating program ...\n" >&2
    exit 1
  fi

  echo "Database $database created ..."      
} 

# Insert the backup dump
insert_dump() {
  if ! psql -U $user -p $port $database < $backup
  then
    echo -e "\nERROR: not able to insert the backup dump $backup to database $database (user: $user, port: $port)\n" >&2
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
    echo -e "\nERROR: the program $program is not available. Terminating program ...\n"
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

For bugs and  questions get in touch with Andy Wenk <andy.wenk@googlemail.com>

EOF
return
}

###
### Main programm
###

# initialize default values
port=5432
user="postgres"

# Parse the command line arguments. Options -d,-u, -p and -p are 
# expecting values while -h is not
while getopts 'd:u:p:b:h' OPTION
do
  case $OPTION in
    d) database="$OPTARG";;
    u) user="$OPTARG";;
    b) backup="$OPTARG";;
    p) port="$OPTARG";;
    h) print_help; exit 1;; 
  esac
done  

# check if the required options are given
if [ -z $database ] || [ -z $backup ]
then
  echo -e "\nERROR: missing parameter ...\n"
  print_help
  exit 1
fi

# checking whether we use the standard port or the given
([ -z $port ] && port=5432) || port=$port

# checking wther we use a given user or the user postgres  
([ -z $user ] && user="postgres") || user=$user

# run the backup
run_backup
