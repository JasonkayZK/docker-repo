## ELK单节点

本分支使用ElasticSearch官方的镜像和Docker-Compose来创建单节点的ELK，用于学习ELK；

各个环境版本：

-   操作系统：CentOS 7
-   Docker：20.10.6
-   Docker-Compose：1.29.1
-   ELK Version：7.1.0

**注：本分支仅仅采用通常的ElasticSearch + LogStash + Kibana组件，而未使用FileBeat；**



### 项目说明

首先，在配置文件`.env`中声明了ES以及各个组件的版本：

.env

```
ES_VERSION=7.1.0
```

其次，创建Docker-Compose的配置文件：

docker-compose.yml

```yaml
version: '3.4'

services: 
    elasticsearch:
        image: "docker.elastic.co/elasticsearch/elasticsearch:${ES_VERSION}"
        environment:
            - discovery.type=single-node
        volumes:
            - /etc/localtime:/etc/localtime
            - /docker_es/data:/usr/share/elasticsearch/data
        ports:
            - "9200:9200"
            - "9300:9300"
    
    logstash:
        depends_on:
            - elasticsearch
        image: "docker.elastic.co/logstash/logstash:${ES_VERSION}"
        volumes:
            - ./logstash.conf:/usr/share/logstash/pipeline/logstash.conf
        ports:
            - "4560:4560"
        links:
            - elasticsearch

    kibana:
        depends_on:
            - elasticsearch
        image: "docker.elastic.co/kibana/kibana:${ES_VERSION}"
        environment:
            - ELASTICSEARCH_URL=http://elasticsearch:9200
        volumes:
            - /etc/localtime:/etc/localtime
        ports:
            - "5601:5601"
        links:
            - elasticsearch
```

在Services中声明了三个服务：

-   elasticsearch；
-   logstash；
-   kibana；

在elasticsearch服务的配置中有几点需要特别注意：

-   `discovery.type=single-node`：将ES的集群发现模式配置为单节点模式；
-   `/etc/localtime:/etc/localtime`：Docker容器中时间和宿主机同步；
-   `/docker_es/data:/usr/share/elasticsearch/data`：将ES的数据映射并持久化至宿主机中；

>   **在启动ES容器时，需要先创建好宿主机的映射目录；**
>
>   **并且配置映射目录所属，例如：**
>
>   ```bash
>   sudo chown -R 1000:1000 /docker_es/data
>   ```
>
>   **否则可能报错！**
>
>   见：
>
>   -   [Caused by: java.nio.file.AccessDeniedException: /usr/share/elasticsearch/data/nodes](https://www.google.com/search?q=Caused+by%3A+java.nio.file.AccessDeniedException%3A+%2Fusr%2Fshare%2Felasticsearch%2Fdata%2Fnodes&sxsrf=ALeKk02j1--iGkUZ432Y7Hh1ggXe7FPU1A%3A1621041287165&ei=hyCfYNbGCZDQ-wT9hJCoCw&oq=Caused+by%3A+java.nio.file.AccessDeniedException%3A+%2Fusr%2Fshare%2Felasticsearch%2Fdata%2Fnodes&gs_lcp=Cgdnd3Mtd2l6EAMyBwgAEEcQsAMyBwgAEEcQsAMyBwgAEEcQsAMyBwgAEEcQsAMyBwgAEEcQsAMyBwgAEEcQsAMyBwgAEEcQsAMyBwgAEEcQsANQ2_gPWNv4D2Cz-g9oAHAFeACAAQCIAQCSAQCYAQGgAQKgAQGqAQdnd3Mtd2l6yAEIwAEB&sclient=gws-wiz&ved=0ahUKEwiWptmwwcrwAhUQ6J4KHX0CBLUQ4dUDCA4&uact=5)
>   -   https://techoverflow.net/2020/04/18/how-to-fix-elasticsearch-docker-accessdeniedexception-usr-share-elasticsearch-data-nodes/

在logstash服务的配置中有几点需要特别注意：

-   `./logstash.conf:/usr/share/logstash/pipeline/logstash.conf`：将宿主机本地的logstash配置映射至logstash容器内部；

在kibana服务的配置中有几点需要特别注意：

-   `ELASTICSEARCH_URL=http://elasticsearch:9200`：配置ES的地址；
-   `/etc/localtime:/etc/localtime`：Docker容器中时间和宿主机同步；

下面是LogStash的配置，在使用时可以自定义：

logstash.conf

```conf
input {
  tcp {
    mode => "server"
    host => "0.0.0.0"
    port => 4560
    codec => json
  }
}

output {
  elasticsearch {
    hosts => ["http://elasticsearch:9200"]
    index => "%{[service]}-%{+YYYY.MM.dd}"
  }
  stdout { codec => rubydebug }
}
```



### 使用方法

>   **使用前必看：**
>
>   **① 修改ELK版本**
>
>   可以修改在`.env`中的`ES_VERSION`字段，修改你想要使用的ELK版本；
>
>   **② LogStash配置**
>
>   修改`logstash.conf`为你需要的日志配置；
>
>   **③ 修改ES文件映射路径**
>
>   修改`docker-compose`中`elasticsearch`服务的`volumes`，将宿主机路径修改为你实际的路径：
>
>   ```diff
>   volumes:
>     - /etc/localtime:/etc/localtime
>   -  - /docker_es/data:/usr/share/elasticsearch/data
>   + - [your_path]:/usr/share/elasticsearch/data
>   ```
>
>   并且修改宿主机文件所属：
>
>   ```bash
>   sudo chown -R 1000:1000 [your_path]
>   ```

随后使用docker-compose命令启动：

```bash
docker-compose up -d
Creating network "docker_repo_default" with the default driver
Creating docker_repo_elasticsearch_1 ... done
Creating docker_repo_kibana_1        ... done
Creating docker_repo_logstash_1      ... done
```

在portainer中可以看到三个容器全部被成功创建：

![](https://cdn.jsdelivr.net/gh/jasonkayzk/docker_repo@elk-v7.1-single/images/demo1.png)

访问`<ip>:5601/`可以看到Kibana也成功启动：

![](https://cdn.jsdelivr.net/gh/jasonkayzk/docker_repo@elk-v7.1-single/images/demo2.png)



### 测试

#### 通过API进行数据的CRUD

向ES中增加数据：

```bash
curl -XPOST "http://127.0.0.1:9200/ik_v2/chinese/3?pretty"  -H "Content-Type: application/json" -d ' 
{ 
    "id" : 3, 
    "username" :  "测试测试", 
    "description" :  "测试测试" 
}'

# 返回 
{
  "_index" : "ik_v2",
  "_type" : "chinese",
  "_id" : "3",
  "_version" : 1,
  "result" : "created",
  "_shards" : {
    "total" : 2,
    "successful" : 1,
    "failed" : 0
  },
  "_seq_no" : 0,
  "_primary_term" : 1
}
```

获取数据：

```bash
curl -XGET "http://127.0.0.1:9200/ik_v2/chinese/3?pretty"

# 返回
{
  "_index" : "ik_v2",
  "_type" : "chinese",
  "_id" : "3",
  "_version" : 1,
  "_seq_no" : 0,
  "_primary_term" : 1,
  "found" : true,
  "_source" : {
    "id" : 3,
    "username" : "测试测试",
    "description" : "测试测试"
  }
}
```

修改数据：

```bash
curl -XPOST 'localhost:9200/ik_v2/chinese/3/_update?pretty' -H "Content-Type: application/json" -d '{ 
    "doc" : { 
            "username" : "testtest" 
        } 
    } 
}'

# 返回
{
  "_index" : "ik_v2",
  "_type" : "chinese",
  "_id" : "3",
  "_version" : 2,
  "result" : "updated",
  "_shards" : {
    "total" : 2,
    "successful" : 1,
    "failed" : 0
  },
  "_seq_no" : 1,
  "_primary_term" : 1
}
```

再次查询：

```bash
curl -XGET "http://127.0.0.1:9200/ik_v2/chinese/3?pretty"

# 返回
{
  "_index" : "ik_v2",
  "_type" : "chinese",
  "_id" : "3",
  "_version" : 2,
  "_seq_no" : 1,
  "_primary_term" : 1,
  "found" : true,
  "_source" : {
    "id" : 3,
    "username" : "testtest",
    "description" : "测试测试"
  }
}
```

可以看到，username已经成功被修改！



#### 在Kibana中查看

目前我们的Kibana中是不存在Index索引的，需要先创建；

在Management中点击`Kibana`下面的`Index Management`，并输入上面我们插入的索引`ik_v2`：

![](https://cdn.jsdelivr.net/gh/jasonkayzk/docker_repo@elk-v7.1-single/images/demo3.png)

创建成功后可以在`Discover`中查看：

![](https://cdn.jsdelivr.net/gh/jasonkayzk/docker_repo@elk-v7.1-single/images/demo4.png)

大体单节点的ELK就部署成功，可以使用了！



### 其他

相关文章：

-   Github Pages：[使用Docker-Compose部署单节点ELK](https://jasonkayzk.github.io/2021/05/15/使用Docker-Compose部署单节点ELK/)
-   国内Gitee镜像：[使用Docker-Compose部署单节点ELK](https://jasonkay.gitee.io/2021/05/15/使用Docker-Compose部署单节点ELK/)

