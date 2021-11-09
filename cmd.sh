# Pull Image
docker pull mysql:5.7.36

# Run Container
sudo docker run -p 33331:3306 --name mysql-1 -v $(pwd)/my_mysql.cnf:/etc/mysql/conf.d/my_mysql.cnf -e MYSQL_ROOT_PASSWORD=123456 -d mysql:5.7.36
sudo docker run -p 33332:3306 --name mysql-2 -v $(pwd)/my_mysql.cnf:/etc/mysql/conf.d/my_mysql.cnf -e MYSQL_ROOT_PASSWORD=123456 -d mysql:5.7.36

# Init DB
cat schema-1.sql | mysql -uroot -h127.0.0.1 -P33331 -p123456
cat schema-2.sql | mysql -uroot -h127.0.0.1 -P33332 -p123456

# Do Join Execution in MySQL-2
cat test-1.sql | mysql -uroot -h127.0.0.1 -P33332 -p123456

# Do Join Execution in MySQL-2 Again
cat test-2.sql | mysql -uroot -h127.0.0.1 -P33332 -p123456
