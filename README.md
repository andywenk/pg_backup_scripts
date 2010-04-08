pg_backup_scripts
=================

2010 Andreas Wenk http://www.nms.de http://www.pg-praxisbuch.de

Here you can find some helpfull shell scripts for creating automated backups of
a PostgreSQL database or a whole cluster.

Description of each script:
----------------------------
pg_overwrite.sh can be used for manual backups or cronjob backups. Actually, it's more 
kind of a how to, because you can simply use pg_restore. But for sure it provides some convenient
stuff like killing the running process when trying to delete the database.

pg_simple_backup.sh is a very simple backup script which creates backups from each database in 
the cluster and transfers it to a defined place on the server. Actually it's not possible to give any options
to the script. Feel free to add them ;-)  
