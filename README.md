## Docker Repo

A repository stores some dockerfiles or docker-compose files for quickly starting service or service cluster.

一个使用Dockerfile和Docker-Compose快速搭建各种服务组件或服务组件集群的仓库；

About Dockerfile：

-   Official：[DockerFile Official Doc](https://docs.docker.com/engine/reference/builder/)
-   Blog：[Dockerfile学习](https://jasonkayzk.github.io/2019/10/16/Dockerfile%E5%AD%A6%E4%B9%A0/)

About Docker-Compose：

-   Official：[Docker-Compose Official Doc](https://docs.docker.com/compose/)

<br/>

### Finished

| Image                                                        | Date       | Info                            | Note                                                         |
| ------------------------------------------------------------ | ---------- | ------------------------------- | ------------------------------------------------------------ |
| [zookeeper-v3.4-cluster](https://github.com/JasonkayZK/docker_repo/tree/zookeeper-v3.4-cluster) | 2020-04-26 | zookeeper-3.4 cluster           | 3 or more nodes                                              |
| [kafka-v2.4.1-cluster](https://github.com/JasonkayZK/docker_repo/tree/kafka-v2.4.1-cluster) | 2020-04-26 | kafka-v2.4.1-cluster            | zookeeper cluster & kafka cluster                            |
| [elk-v7.1-single](https://github.com/JasonkayZK/docker_repo/tree/elk-v7.1-single) | 2021-05-15 | ELK-v7.1.0-single               | Compose ELK Single-Node<br />(Without Filebeat)              |
| [elk-stack-v7.1-single](https://github.com/JasonkayZK/docker_repo/tree/elk-stack-v7.1-single) | 2021-05-15 | ELK-Stack-v7.1.0-single         | Compose ELK Single-Node<br />(Full-Stack with Filebeat)      |
| [hadoop-v2.7-single](https://github.com/JasonkayZK/docker_repo/tree/hadoop-v2.7-single) | 2021-06-25 | Hadoop-v2.7-Single              | Directly run with Docker                                     |
| [redash-single](https://github.com/JasonkayZK/docker_repo/tree/redash-single) | 2021-08-08 | Redash-v8                       | Directly run Redash with Docker                              |
| [hadoop-3.1.3-cluster](https://github.com/JasonkayZK/docker_repo/tree/hadoop-3.1.3-cluster) | 2021-08-21 | Hadoop-3.1.3-cluster            | Run Hadoop-3.1.3 cluster with Docker                         |
| [epic-games-claimer](https://github.com/JasonkayZK/docker_repo/tree/epic-games-claimer) | 2021-09-04 | Epic-game-claimer               | Auto gain free epic game everyday                            |
| [elk-v7.14-single](https://github.com/JasonkayZK/docker_repo/tree/elk-v7.14-single) | 2021-09-11 | ELK-Stack-v7.14.0-single        | Update version: [elk-stack-v7.1-single](https://github.com/JasonkayZK/docker_repo/tree/elk-stack-v7.1-single)<br />Contributed by [wwhai](https://github.com/wwhai) |
| [mysql-federated](https://github.com/JasonkayZK/docker-repo/tree/mysql-federated) | 2021-11-09 | MySQL Federated Engine Demo     | A demo to show how Federated Engine works in MySQL<br />Blog: [《MySQL跨数据库查询方案总结》](https://jasonkayzk.github.io/2021/11/09/MySQL跨数据库查询方案总结/) |
| [dubbo-admin](https://github.com/JasonkayZK/docker-repo/tree/dubbo-admin) | 2023-03-23 | Dubbo Admin v0.5.0              | Run Dubbo Admin & Zookeeper with Docker                      |
| [canal](https://github.com/JasonkayZK/docker-repo/tree/canal) | 2023-03-26 | Canal v1.1.6                    | Run Canal & MySQL with docker-compose<br />Blog: [《Java订阅Binlog的几种方式》](https://jasonkayzk.github.io/2023/03/26/Java订阅Binlog的几种方式/) |
| [ansible](https://github.com/JasonkayZK/docker-repo/tree/ansible) | 2023-04-12 | Ubuntu 20.04 ARM/AMD64 with ssh | Run Ansible managed node cluster                             |
| [talebook](https://github.com/JasonkayZK/docker-repo/tree/talebook) | 2024-08-22 | talebook v3.8.1 & douban-api-rs | A branch to deloy [talebook](https://github.com/talebook/talebook) & [douban-rs-api ](https://github.com/cxfksword/douban-api-rs) stack |
|                                                              |            |                                 |                                                              |

