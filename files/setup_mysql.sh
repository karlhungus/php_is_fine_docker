#!/bin/bash

# Initialize MySQL database.
# ADD this file into the container via Dockerfile.
# Assuming you specify a VOLUME ["/var/lib/mysql"] or `-v /var/lib/mysql` on the `docker run` command…
# Once built, do e.g. `docker run your_image /path/to/docker-mysql-initialize.sh`
# Again, make sure MySQL is persisting data outside the container for this to have any effect.

# Start the MySQL daemon in the background.
sudo service mysql start
mysql_pid=$!

until mysqladmin ping >/dev/null 2>&1; do
  echo -n "."; sleep 0.2
done

# Permit root login without password from outside container.
mysql -u root -ppassword -e "GRANT ALL ON *.* TO root@'%' IDENTIFIED BY '' WITH GRANT OPTION"

# create the default database
mysql -u root -ppassword -e "create database dbname;"

# Tell the MySQL daemon to shutdown.
mysqladmin shutdown

# Wait for the MySQL daemon to exit.
wait $mysql_pid

