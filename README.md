# **MySQL Federated**

A branch to show how MySQL Federated Engine works!



## **How to use**

First, pull image:

```shell
docker pull mysql:5.7.36
```

Second, run container:

```shell
sudo docker run -p 33331:3306 --name mysql-1 -v $(pwd)/my_mysql.cnf:/etc/mysql/conf.d/my_mysql.cnf -e MYSQL_ROOT_PASSWORD=123456 -d mysql:5.7.36
sudo docker run -p 33332:3306 --name mysql-2 -v $(pwd)/my_mysql.cnf:/etc/mysql/conf.d/my_mysql.cnf -e MYSQL_ROOT_PASSWORD=123456 -d mysql:5.7.36
```

Two MySQL server is up!

Then, initiate db:

```shell
cat schema-1.sql | mysql -uroot -h127.0.0.1 -P33331 -p123456
cat schema-2.sql | mysql -uroot -h127.0.0.1 -P33332 -p123456
```

Check join result:

```shell
cat test-1.sql | mysql -uroot -h127.0.0.1 -P33332 -p123456

user_name       salary
user-9  5500
user-10 5500
user-11 6500
user-12 6500
user-13 7500
user-14 7500
user-15 8500
user-16 8500
```

Result is ok!

Check join result Again:

```shell
cat test-2.sql | mysql -uroot -h127.0.0.1 -P33332 -p123456
user_name       salary
user-17 1500
user-9  5500
user-10 5500
user-11 6500
user-12 6500
user-13 7500
user-14 7500
user-15 8500
user-16 8500
```

Result is ok!



## **Linked Blog**

See linked blog to get more:

-   [MySQL跨数据库查询方案总结](https://jasonkayzk.github.io/2021/11/09/MySQL跨数据库查询方案总结/)

