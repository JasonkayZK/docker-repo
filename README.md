A branch for quickly starting the kafka v2.4.1 cluster;

### 前言

kafka依赖于zookeeper存放元数据, 所以在创建kafka集群之前需要创建zookeeper;

更多关于zookeeper集群创建见:

[zookeeper-v3.4-cluster](https://github.com/JasonkayZK/docker_repo/tree/zookeeper-v3.4-cluster)

### 拉取镜像

```bash
docker pull zookeeper:3.4
docker pull wurstmeister/kafka:2.12-2.4.1
```

>   其中kafka版本中的2.12为Scala版本

### 创建子网段

```bash
docker network create --subnet 172.30.1.0/16 --gateway 172.30.0.1 kafka
```

以三个zookeeper为例, 各个子容器的ip地址分配如下:

| hostname      | ip          | port      |
| ------------- | ----------- | --------- |
| zoo1          | 172.30.0.11 | 2184:2181 |
| zoo2          | 172.30.0.12 | 2185:2181 |
| zoo3          | 172.30.0.13 | 2186:2181 |
| kafka1        | 172.30.1.11 | 9092:9092 |
| kafka2        | 172.30.1.12 | 9093:9093 |
| kafka3        | 172.30.1.13 | 9094:9094 |

### Zookeeper集群

zookeeper的docker-compose文件与[zookeeper-v3.4-cluster](https://github.com/JasonkayZK/docker_repo/tree/zookeeper-v3.4-cluster)中的类似;

见本分支的`docker-compose-zookeeper.yml`, 这里不再赘述;

### Kafka集群

在`docker-compose-kafka.yml`中定义了三个kafka容器:

```yaml
version: '3.4'

services: 
    kafka1:
        image: wurstmeister/kafka
        restart: always
        hostname: kafka1
        container_name: kafka1
        privileged: true
        ports:
            - 9092:9092
        environment:
              KAFKA_ADVERTISED_HOST_NAME: kafka1
              KAFKA_LISTENERS: PLAINTEXT://kafka1:9092
              KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://kafka1:9092
              KAFKA_ADVERTISED_PORT: 9092
              KAFKA_ZOOKEEPER_CONNECT: zoo1:2181,zoo2:2181,zoo3:2181
        volumes:
            - /home/zk/workspace/volumes/kafkaCluster/kafka1/logs:/kafka
        networks:
            kafka:
                ipv4_address: 172.30.1.11
        extra_hosts: 
            zoo1: 172.30.0.11
            zoo2: 172.30.0.12
            zoo3: 172.30.0.13

    kafka2:
        image: wurstmeister/kafka
        restart: always
        hostname: kafka2
        container_name: kafka2
        privileged: true
        ports:
            - 9093:9093
        environment:
              KAFKA_ADVERTISED_HOST_NAME: kafka2
              KAFKA_LISTENERS: PLAINTEXT://kafka2:9093
              KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://kafka2:9093
              KAFKA_ADVERTISED_PORT: 9093
              KAFKA_ZOOKEEPER_CONNECT: zoo1:2181,zoo2:2181,zoo3:2181
        volumes:
            - /home/zk/workspace/volumes/kafkaCluster/kafka2/logs:/kafka
        networks:
            kafka:
                ipv4_address: 172.30.1.12
        extra_hosts: 
            zoo1: 172.30.0.11
            zoo2: 172.30.0.12
            zoo3: 172.30.0.13

    kafka3:
        image: wurstmeister/kafka
        restart: always
        hostname: kafka3
        container_name: kafka3
        privileged: true
        ports:
            - 9094:9094
        environment:
              KAFKA_ADVERTISED_HOST_NAME: kafka3
              KAFKA_LISTENERS: PLAINTEXT://kafka3:9094
              KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://kafka3:9094
              KAFKA_ADVERTISED_PORT: 9094
              KAFKA_ZOOKEEPER_CONNECT: zoo1:2181,zoo2:2181,zoo3:2181
        volumes:
            - /home/zk/workspace/volumes/kafkaCluster/kafka3/logs:/kafka
        networks:
            kafka:
                ipv4_address: 172.30.1.13
        extra_hosts: 
            zoo1: 172.30.0.11
            zoo2: 172.30.0.12
            zoo3: 172.30.0.13                            

networks: 
    kafka:
        external: 
            name: kafka      
```

需要注意的是zookeeper和kafka需要在同一个网段(如上方声明的kafka);

此外需要在extra_hosts中声明各zookeeper的host地址;(会被写入`/etc/hosts`)中

### 将zookeeper和kafka合并

可将zookeekper和kafka的配置结合为单独一个compose文件如`docker-compose.yml`:

```yaml
version: '3.4'

services: 
    zoo1:
        image: zookeeper:3.4
        restart: always
        hostname: zoo1
        container_name: zoo1
        ports:
            - 2184:2181
        volumes: 
            - "/home/zk/workspace/volumes/zkcluster/zoo1/data:/data"
            - "/home/zk/workspace/volumes/zkcluster/zoo1/datalog:/datalog"
        environment: 
            ZOO_MY_ID: 1
            ZOO_SERVERS: server.1=0.0.0.0:2888:3888 server.2=zoo2:2888:3888 server.3=zoo3:2888:3888
        networks:
            kafka:
                ipv4_address: 172.30.0.11

    zoo2:
        image: zookeeper:3.4
        restart: always
        hostname: zoo2
        container_name: zoo2
        ports:
            - 2185:2181
        volumes: 
            - "/home/zk/workspace/volumes/zkcluster/zoo2/data:/data"
            - "/home/zk/workspace/volumes/zkcluster/zoo2/datalog:/datalog"
        environment: 
            ZOO_MY_ID: 2
            ZOO_SERVERS: server.1=zoo1:2888:3888 server.2=0.0.0.0:2888:3888 server.3=zoo3:2888:3888
        networks:
            kafka:
                ipv4_address: 172.30.0.12
        
    zoo3:
        image: zookeeper:3.4
        restart: always
        hostname: zoo3
        container_name: zoo3
        ports:
            - 2186:2181
        volumes: 
            - "/home/zk/workspace/volumes/zkcluster/zoo3/data:/data"
            - "/home/zk/workspace/volumes/zkcluster/zoo3/datalog:/datalog"
        environment: 
            ZOO_MY_ID: 3
            ZOO_SERVERS: server.1=zoo1:2888:3888 server.2=zoo2:2888:3888 server.3=0.0.0.0:2888:3888
        networks:
            kafka:
                ipv4_address: 172.30.0.13

    kafka1:
        image: wurstmeister/kafka
        restart: always
        hostname: kafka1
        container_name: kafka1
        privileged: true
        ports:
            - 9092:9092
        environment:
              KAFKA_ADVERTISED_HOST_NAME: kafka1
              KAFKA_LISTENERS: PLAINTEXT://kafka1:9092
              KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://kafka1:9092
              KAFKA_ADVERTISED_PORT: 9092
              KAFKA_ZOOKEEPER_CONNECT: zoo1:2181,zoo2:2181,zoo3:2181
        volumes:
            - /home/zk/workspace/volumes/kafkaCluster/kafka1/logs:/kafka
        networks:
            kafka:
                ipv4_address: 172.30.1.11
        extra_hosts: 
            - "zoo1:172.30.0.11"
            - "zoo2:172.30.0.12"
            - "zoo3:172.30.0.13"
        depends_on: 
            - zoo1
            - zoo2
            - zoo3
        external_links: 
            - zoo1
            - zoo2
            - zoo3

    kafka2:
        image: wurstmeister/kafka
        restart: always
        hostname: kafka2
        container_name: kafka2
        privileged: true
        ports:
            - 9093:9093
        environment:
              KAFKA_ADVERTISED_HOST_NAME: kafka2
              KAFKA_LISTENERS: PLAINTEXT://kafka2:9093
              KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://kafka2:9093
              KAFKA_ADVERTISED_PORT: 9093
              KAFKA_ZOOKEEPER_CONNECT: zoo1:2181,zoo2:2181,zoo3:2181
        volumes:
            - /home/zk/workspace/volumes/kafkaCluster/kafka2/logs:/kafka
        networks:
            kafka:
                ipv4_address: 172.30.1.12
        extra_hosts: 
            - "zoo1:172.30.0.11"
            - "zoo2:172.30.0.12"
            - "zoo3:172.30.0.13"                
        depends_on: 
            - zoo1
            - zoo2
            - zoo3                
        external_links: 
            - zoo1
            - zoo2
            - zoo3           

    kafka3:
        image: wurstmeister/kafka
        restart: always
        hostname: kafka3
        container_name: kafka3
        privileged: true
        ports:
            - 9094:9094
        environment:
              KAFKA_ADVERTISED_HOST_NAME: kafka3
              KAFKA_LISTENERS: PLAINTEXT://kafka3:9094
              KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://kafka3:9094
              KAFKA_ADVERTISED_PORT: 9094
              KAFKA_ZOOKEEPER_CONNECT: zoo1:2181,zoo2:2181,zoo3:2181
        volumes:
            - /home/zk/workspace/volumes/kafkaCluster/kafka3/logs:/kafka
        networks:
            kafka:
                ipv4_address: 172.30.1.13
        extra_hosts: 
            - "zoo1:172.30.0.11"
            - "zoo2:172.30.0.12"
            - "zoo3:172.30.0.13"                
        depends_on: 
            - zoo1
            - zoo2
            - zoo3                
        external_links: 
            - zoo1
            - zoo2
            - zoo3

networks: 
    kafka:
        external: 
            name: kafka
```

>   在kafka服务中声明了depends_on, 所以在所有zookeeper启动之后才会真正启动kafka容器

### 使用

#### 分别启动各容器

分别使用`docker-compose-zookeeper`和`docker-compose-kafka`启动两个集群;

```bash
docker-compose -f docker-compose-zookeeper.yml up -d
docker-compose -f docker-compose-kafka.yml up -d
```

先启动注册中心zookeeper, 然后启动kafka;

>此方法的好处是在关闭时可以分别关闭;
>
>但是启动时可能需要按照顺序启动

#### 启动两个集群

直接使用组合启动:

```bash
docker-compose -f docker-compose.yml up -d
```

>此方法的好处是启动便捷;
>
>但是关闭时会将zookeeper和kafka同时关闭;

### 测试

登录kafka1创建topic并发送消息:

```bash
$ docker exec -it kafka1 /bin/bash

# 在容器中执行
# 创建topic
$ cd /opt/kafka_2.12-2.4.1/bin/
$ kafka-topics.sh --create --topic test1 --replication-factor 3 --partitions 2 --zookeeper 192.168.1.106:2184
Created topic test1.

$ kafka-topics.sh --list --zookeeper 192.168.1.106:2184
test1

$ sh /opt/kafka_2.12-2.4.1/bin/kafka-console-producer.sh --broker-list 192.168.1.106:9092 --topic test1
>你好
>这是我的test1
>哈哈
>e 
>asef
```

登录kafka2连接topic并接收消息:

```bash
$ docker exec -it kafka2 /bin/bash
$ sh /opt/kafka_2.12-2.4.1/bin/kafka-console-consumer.sh --bootstrap-server 192.168.1.106:9092 --topic test1 --from-beginning
这是我的test1
你好
哈哈
e 
asef
```

