# **Canal**

A branch to deploy canal.

<br/>

# **How to use**

Start container:

```bash
docker-compose up -d
```

Into canal container:

```bash
$ docker exec -it canal-canal-1 bash

[root@9981ccc70979 admin]# cd /home/admin/canal-server/conf/example/
[root@9981ccc70979 example]# vi instance.properties
```

Edit config:

```ini
# 修改为你的 MySQL 地址
canal.instance.master.address=mysql:3306

# username/password
canal.instance.dbUsername=root
canal.instance.dbPassword=123456

# table black regex
# issue: https://github.com/alibaba/canal/issues/4245
canal.instance.filter.black.regex=.*\\.BASE TABLE.*
```

> Linked issue: https://github.com/alibaba/canal/issues/4245

<br/>

# **Reference**

Linked Blogs:

- [《Java订阅Binlog的几种方式》](https://jasonkayzk.github.io/2023/03/26/Java订阅Binlog的几种方式/)
