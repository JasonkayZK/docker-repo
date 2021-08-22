# **Hadoop Cluster**

A branch for quickly starting the hadoop v3.1.3 cluster.

<br/>

## **使用**

### **使用容器启动集群**

在Shell执行：

```bash
# 创建网络
docker network create --subnet 172.30.0.0/24 --gateway 172.30.0.1 big-data

# 创建容器
docker run -itd --name big-data-1 --net big-data --ip 172.30.0.11  --hostname big-data-1 --privileged  jasonkay/big-data-1:v1.0 /usr/sbin/init
docker run -itd --name big-data-2 --net big-data --ip 172.30.0.12  --hostname big-data-2 --privileged  jasonkay/big-data-2:v1.0 /usr/sbin/init
docker run -itd --name big-data-3 --net big-data --ip 172.30.0.13  --hostname big-data-3 --privileged  jasonkay/big-data-3:v1.0 /usr/sbin/init

# 进入容器
docker exec -it big-data-1 /bin/bash
```

容器中执行：

```bash
~/bin/hdp.sh start
```

启动Hadoop集群；

查看结果：

![](https://cdn.jsdelivr.net/gh/jasonkayzk/blog_static@master/images/big-data-2.png)

<br/>

### **使用Docker-Compose启动**

编辑docker-compose.yml

```yaml
version: '3.4'

services:
  big-data-1:
    image: jasonkay/big-data-1:v1.0
    hostname: big-data-1
    container_name: big-data-1
    privileged: true
    links:
      - big-data-2
      - big-data-3
    depends_on:
      - big-data-2
      - big-data-3
    ports:
      - 9870:9870
      - 22
    entrypoint: ["/usr/sbin/init"]
    networks:
      big-data:
        ipv4_address: 172.30.0.11

  big-data-2:
    image: jasonkay/big-data-2:v1.0
    hostname: big-data-2
    container_name: big-data-2
    privileged: true
    entrypoint: ["/usr/sbin/init"]
    ports:
      - 22
    networks:
      big-data:
        ipv4_address: 172.30.0.12

  big-data-3:
    image: jasonkay/big-data-3:v1.0
    hostname: big-data-3
    container_name: big-data-3
    privileged: true
    entrypoint: ["/usr/sbin/init"]
    ports:
      - 22
    networks:
      big-data:
        ipv4_address: 172.30.0.13

networks:
  big-data:
    external:
      name: big-data
```

启动三个节点：

```bash
[root@localhost docker-repo]# docker-compose  up -d
Creating big-data-3 ... done
Creating big-data-2 ... done
Creating big-data-1 ... done
```

进入`big-data-1`启动集群：

```bash
[root@big-data-1 bin]# ./hdp.sh start
 =================== Start  Hadoop Cluster ===================
 --------------- Start hdfs ---------------
Starting namenodes on [big-data-1]
Last login: Wed Aug 18 04:48:01 UTC 2021
Starting datanodes
Last login: Sun Aug 22 08:13:26 UTC 2021
Starting secondary namenodes [big-data-3]
Last login: Sun Aug 22 08:13:28 UTC 2021
 --------------- Start yarn ---------------
Starting resourcemanager
Last login: Wed Aug 18 04:47:56 UTC 2021
Starting nodemanagers
Last login: Sun Aug 22 08:13:35 UTC 2021
 --------------- Start historyserver ---------------
```

查看状态：

```bash
[root@big-data-1 ~]# ./xcall.sh jps
--------- big-data-1 ----------
1137 Jps
811 NodeManager
940 JobHistoryServer
492 DataNode
271 NameNode
--------- big-data-2 ----------
694 NodeManager
317 ResourceManager
142 DataNode
1054 Jps
--------- big-data-3 ----------
145 DataNode
229 SecondaryNameNode
518 Jps
316 NodeManager
```

启动成功！

<br/>

## **测试**

数据准备：

```bash
cd ~/
vi data.txt

# 写入内容
hello hadoop
hello World
Hello Java
Hey man
i am a programmer
```

写入HDFS：

```bash
# 创建/input目录
hdfs dfs -mkdir /input 

# 写入hdfs
hdfs dfs -put data.txt /input 

# 查看HDFS
hdfs dfs -ls /input

Found 1 items
-rw-r--r--   1 root supergroup         62 2021-08-18 06:42 /input/data.txt
```

Word Count测试：

```bash
cd /opt/module/hadoop-3.1.3/share/hadoop/mapreduce/

hadoop jar hadoop-mapreduce-examples-3.1.3.jar wordcount /input/data.txt /output
```

查看结果：

```bash
hdfs dfs -cat /output/part-r-00000

2021-08-21 07:00:46,337 INFO sasl.SaslDataTransferClient: SASL encryption trust check: localHostTrusted = false, remoteHostTrusted = false
Hello   1
Hey     1
Java    1
World   1
a       1
am      1
hadoop  1
hello   2
i       1
man     1
programmer      1
```

成功！

<br/>

## 相关文章

Github Pages：[从零开始搭建大数据镜像-1](https://jasonkayzk.github.io/2021/08/21/从零开始搭建大数据镜像-1/)

国内Gitee镜像：[从零开始搭建大数据镜像-1](https://jasonkay.gitee.io/2021/08/21/从零开始搭建大数据镜像-1/)
