## ELK Stack单节点

本分支使用ElasticSearch官方的镜像和Docker-Compose来创建单节点的ELK Stack；

在ELK Stack中同时包括了Elastic Search、LogStash、Kibana以及Filebeat；

各个组件的作用如下：

-   Filebeat：采集文件等日志数据；
-   LogStash：过滤日志数据；
-   Elastic Search：存储、索引日志；
-   Kibana：用户界面；

各个组件之间的关系如下图所示：

![](https://cdn.jsdelivr.net/gh/jasonkayzk/docker_repo@elk-stack-v7.1-single/images/elk_stack.png)

>   **无Filebeat的版本：**
>
>   -   https://github.com/JasonkayZK/docker_repo/tree/elk-v7.1-single

<br/>

### 项目环境

各个环境版本：

-   操作系统：CentOS 7
-   Docker：20.10.6
-   Docker-Compose：1.29.1
-   ELK Version：7.1.0
-   Filebeat：7.1.0

<br/>

### 项目说明

#### Docker-Compose变量配置

首先，在配置文件`.env`中统一声明了ES以及各个组件的版本：

.env

```
ES_VERSION=7.1.0
```

<br/>

#### Docker-Compose服务配置

创建Docker-Compose的配置文件：

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
            - "5044:5044"
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

    filebeat:
        depends_on:
            - elasticsearch
            - logstash
        image: "docker.elastic.co/beats/filebeat:${ES_VERSION}"
        user: root # 必须为root，否则会因为无权限而无法启动
        environment:
            - strict.perms=false
        volumes:
            - ./filebeat.yml:/usr/share/filebeat/filebeat.yml:ro
            # 映射到容器中[作为数据源]
            - /docker_es/filebeat/logs:/usr/share/filebeat/logs:rw
            - /docker_es/filebeat/data:/usr/share/filebeat/data:rw
        # 将指定容器连接到当前连接，可以设置别名，避免ip方式导致的容器重启动态改变的无法连接情况
        links:
            - logstash
```

在Services中声明了四个服务：

-   elasticsearch；
-   logstash；
-   kibana；
-   filebeat；

<br/>

##### ElasticSearch服务

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

<br/>

##### **LogStash服务**

在logstash服务的配置中有几点需要特别注意：

-   `./logstash.conf:/usr/share/logstash/pipeline/logstash.conf`：将宿主机本地的logstash配置映射至logstash容器内部；

下面是LogStash的配置，在使用时可以自定义：

logstash.conf

```diff
input {
-  tcp {
-    mode => "server"
-    host => "0.0.0.0"
-    port => 5044
-    codec => json
-  }

+  # 来源beats
+  beats {
+      # 端口
+      port => "5044"
+  }

}

output {
  elasticsearch {
    hosts => ["http://elasticsearch:9200"]
-    index => "%{[service]}-%{+YYYY.MM.dd}"
+    index => "test"
  }
  stdout { codec => rubydebug }
}
```

在这里我们将原来tcp收集方式修改为由filebeat上报，同时固定了索引为`test`；

<br/>

##### **Kibana服务**

在kibana服务的配置中有几点需要特别注意：

-   `ELASTICSEARCH_URL=http://elasticsearch:9200`：配置ES的地址；
-   `/etc/localtime:/etc/localtime`：Docker容器中时间和宿主机同步；

<br/>

##### **Filebeat服务**

在Filebeat服务的配置中有几点需要特别注意：

-   配置`user: root`和环境变量`strict.perms=false`：如果不配置可能会因为权限问题无法启动；
-   `volumes`映射：
    -   `./filebeat.yml:/usr/share/filebeat/filebeat.yml:ro`：配置文件映射；
    -   `/docker_es/filebeat/logs:/usr/share/filebeat/logs:rw`：将日志目录映射至容器中；
    -   `/docker_es/filebeat/data:/usr/share/filebeat/data:rw`：将数据目录映射至容器中；

同时还需要创建Filebeat配置文件：

filebeat.yml

```yaml
filebeat.inputs:
  - type: log
    enabled: true
    paths:
      # 容器中目录下的所有.log文件
      - /usr/share/filebeat/logs/*.log
    multiline.pattern: ^\[
    multiline.negate: true
    multiline.match: after

filebeat.config.modules:
  path: ${path.config}/modules.d/*.yml
  reload.enabled: false

setup.template.settings:
  index.number_of_shards: 1

setup.dashboards.enabled: false

setup.kibana:
  host: "http://kibana:5601"

# 直接传输至ES
#output.elasticsearch:
# hosts: ["http://es-master:9200"]
# index: "filebeat-%{[beat.version]}-%{+yyyy.MM.dd}"

# 传输至LogStash
output.logstash:
  hosts: ["logstash:5044"]

processors:
  - add_host_metadata: ~
  - add_cloud_metadata: ~
```

上面给出了一个filebeat配置文件示例，实际使用时可以根据需求进行修改；

<br/>

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
>
>   **④ 修改filebeat服务配置**
>
>   修改`docker-compose`中`filebeat`服务的`volumes`，将宿主机路径修改为你实际的路径：
>
>   ```diff
>   volumes:
>       - ./filebeat.yml:/usr/share/filebeat/filebeat.yml:ro
>   -    - /docker_es/filebeat/logs:/usr/share/filebeat/logs:rw
>   +	 - <your_log_path>:/usr/share/filebeat/logs:rw
>   -    - /docker_es/filebeat/data:/usr/share/filebeat/data:rw
>   +	 - <your_data_path>:/usr/share/filebeat/logs:rw
>   ```
>
>   **⑤ 修改Filebeat配置**
>
>   修改`filebeat.yml`为你需要的配置；

随后使用docker-compose命令启动：

```bash
docker-compose up -d
Creating network "docker_repo_default" with the default driver
Creating docker_repo_elasticsearch_1 ... done
Creating docker_repo_kibana_1        ... done
Creating docker_repo_logstash_1      ... done
Creating docker_repo_filebeat_1      ... done
```

在portainer中可以看到四个容器全部被成功创建：

![](https://cdn.jsdelivr.net/gh/jasonkayzk/docker_repo@elk-stack-v7.1-single/images/demo_1.png)

访问`<ip>:5601/`可以看到Kibana也成功启动：

![](https://cdn.jsdelivr.net/gh/jasonkayzk/docker_repo@elk-stack-v7.1-single/images/demo_2.png)

同时Filebeat输出日志：

```bash
docker logs -f docker_repo_filebeat_1

2021-05-15T08:26:22.406Z        INFO    instance/beat.go:571    Home path: [/usr/share/filebeat] Config path: [/usr/share/filebeat] Data path: [/usr/share/filebeat/data] Logs path: [/usr/share/filebeat/logs]
2021-05-15T08:26:22.408Z        INFO    instance/beat.go:579    Beat ID: 4773bc8b-25d0-493d-9b07-40dca5989e53
2021-05-15T08:26:22.408Z        INFO    [index-management.ilm]  ilm/ilm.go:129  Policy name: filebeat-7.1.0
2021-05-15T08:26:22.410Z        INFO    [seccomp]       seccomp/seccomp.go:116  Syscall filter successfully installed
2021-05-15T08:26:22.410Z        INFO    [beat]  instance/beat.go:827    Beat info       {"system_info": {"beat": {"path": {"config": "/usr/share/filebeat", "data": "/usr/share/filebeat/data", "home": "/usr/share/filebeat", "logs": "/usr/share/filebeat/logs"}, "type": "filebeat", "uuid": "4773bc8b-25d0-493d-9b07-40dca5989e53"}}}
2021-05-15T08:26:22.410Z        INFO    [beat]  instance/beat.go:836    Build info      {"system_info": {"build": {"commit": "03b3db2a1d9d76fdf10475e829fce436c61901e4", "libbeat": "7.1.0", "time": "2019-05-15T23:59:19.000Z", "version": "7.1.0"}}}
2021-05-15T08:26:22.410Z        INFO    [beat]  instance/beat.go:839    Go runtime info {"system_info": {"go": {"os":"linux","arch":"amd64","max_procs":8,"version":"go1.11.5"}}}
……
2021-05-15T08:27:52.423Z        INFO    [monitoring]    log/log.go:144  Non-zero metrics in the last 30s{"monitoring": {"metrics": {"beat":{"cpu":{"system":{"ticks":30,"time":{"ms":2}},"total":{"ticks":50,"time":{"ms":3},"value":50},"user":{"ticks":20,"time":{"ms":1}}},"handles":{"limit":{"hard":1048576,"soft":1048576},"open":5},"info":{"ephemeral_id":"de4bc7c3-5db7-41b9-8395-2a47336980d6","uptime":{"ms":90025}},"memstats":{"gc_next":4194304,"memory_alloc":3166448,"memory_total":7058880}},"filebeat":{"harvester":{"open_files":0,"running":0}},"libbeat":{"config":{"module":{"running":0}},"pipeline":{"clients":1,"events":{"active":0}}},"registrar":{"states":{"current":0}},"system":{"load":{"1":0.47,"15":0.15,"5":0.3,"norm":{"1":0.0588,"15":0.0188,"5":0.0375}}}}}}
2021-05-15T08:28:22.425Z        INFO    [monitoring]    log/log.go:144  Non-zero metrics in the last 30s{"monitoring": {"metrics": {"beat":{"cpu":{"system":{"ticks":30,"time":{"ms":4}},"total":{"ticks":50,"time":{"ms":5},"value":50},"user":{"ticks":20,"time":{"ms":1}}},"handles":{"limit":{"hard":1048576,"soft":1048576},"open":5},"info":{"ephemeral_id":"de4bc7c3-5db7-41b9-8395-2a47336980d6","uptime":{"ms":120026}},"memstats":{"gc_next":4194304,"memory_alloc":3208408,"memory_total":7384144}},"filebeat":{"harvester":{"open_files":0,"running":0}},"libbeat":{"config":{"module":{"running":0}},"pipeline":{"clients":1,"events":{"active":0}}},"registrar":{"states":{"current":0}},"system":{"load":{"1":0.29,"15":0.15,"5":0.27,"norm":{"1":0.0363,"15":0.0188,"5":0.0338}}}}}}
```

监控成功！

<br/>

### 测试

#### 向文件中添加内容

由于我们的映射文件被映射在`/docker_es/filebeat/logs`目录下，所以我们在这个目录新增日志文件：

```bash
echo "hello filebeat" >> info.log
```

随后查看Filebeat日志：

```bash
docker logs -f docker_repo_filebeat_1

2021-05-15T08:32:22.421Z        INFO    [monitoring]    log/log.go:144  Non-zero metrics in the last 30s{"monitoring": {"metrics": {"beat":{"cpu":{"system":{"ticks":50,"time":{"ms":1}},"total":{"ticks":70,"time":{"ms":2},"value":70},"user":{"ticks":20,"time":{"ms":1}}},"handles":{"limit":{"hard":1048576,"soft":1048576},"open":5},"info":{"ephemeral_id":"de4bc7c3-5db7-41b9-8395-2a47336980d6","uptime":{"ms":360022}},"memstats":{"gc_next":4194304,"memory_alloc":2890176,"memory_total":10019672}},"filebeat":{"harvester":{"open_files":0,"running":0}},"libbeat":{"config":{"module":{"running":0}},"pipeline":{"clients":1,"events":{"active":0}}},"registrar":{"states":{"current":0}},"system":{"load":{"1":0.01,"15":0.12,"5":0.13,"norm":{"1":0.0013,"15":0.015,"5":0.0163}}}}}}
2021-05-15T08:32:32.488Z        INFO    log/harvester.go:254    Harvester started for file: /usr/share/filebeat/logs/info.log
2021-05-15T08:32:38.492Z        INFO    pipeline/output.go:95   Connecting to backoff(async(tcp://logstash:5044))
2021-05-15T08:32:38.493Z        INFO    pipeline/output.go:105  Connection to backoff(async(tcp://logstash:5044)) established
2021-05-15T08:32:52.425Z        INFO    [monitoring]    log/log.go:144  Non-zero metrics in the last 30s{"monitoring": {"metrics": {"beat":{"cpu":{"system":{"ticks":60,"time":{"ms":10}},"total":{"ticks":90,"time":{"ms":12},"value":90},"user":{"ticks":30,"time":{"ms":2}}},"handles":{"limit":{"hard":1048576,"soft":1048576},"open":7},"info":{"ephemeral_id":"de4bc7c3-5db7-41b9-8395-2a47336980d6","uptime":{"ms":390026}},"memstats":{"gc_next":6742608,"memory_alloc":3400712,"memory_total":11983960,"rss":2490368}},"filebeat":{"events":{"added":2,"done":2},"harvester":{"open_files":1,"running":1,"started":1}},"libbeat":{"config":{"module":{"running":0}},"output":{"events":{"acked":1,"batches":1,"total":1},"read":{"bytes":6},"write":{"bytes":456}},"pipeline":{"clients":1,"events":{"active":0,"filtered":1,"published":1,"retry":1,"total":2},"queue":{"acked":1}}},"registrar":{"states":{"current":1,"update":2},"writes":{"success":2,"total":2}},"system":{"load":{"1":0.01,"15":0.12,"5":0.12,"norm":{"1":0.0013,"15":0.015,"5":0.015}}}}}}
```

可以看到Filebeat成功收集到了日志！

<br/>

#### 在Kibana中查看

从上面我们可以看到Filebeat成功收集到了日志，那么有没有经过LogStash过滤并最终提交到ES中呢？

我们可以在Kibana中查看；

由于我们在LogStash中定义的Index是`test`，所以可以添加test索引；

在Management中点击`Kibana`下面的`Index Management`，并输入上面我们插入的索引`test`：

![](https://cdn.jsdelivr.net/gh/jasonkayzk/docker_repo@elk-stack-v7.1-single/images/demo_3.png)

创建成功后可以在`Discover`中查看：

![](https://cdn.jsdelivr.net/gh/jasonkayzk/docker_repo@elk-stack-v7.1-single/images/demo_4.png)

从图中可以看出，我们创建的文件的确提交到了整个ELK Stack中！

日志中显示了我们刚刚插入的`hello filebeat`！

至此，整个ELK Stack的功能测试完毕，尽情享用吧！

<br/>

### 其他

相关文章：

-   Github Pages：[使用Docker-Compose部署单节点ELK-Stack](https://jasonkayzk.github.io/2021/05/15/使用Docker-Compose部署单节点ELK-Stack/)
-   国内Gitee镜像：[使用Docker-Compose部署单节点ELK-Stack](https://jasonkay.gitee.io/2021/05/15/使用Docker-Compose部署单节点ELK-Stack/)

文章参考：

-   [通过docker compose部署EFK](https://maxidea.gitbook.io/k8s-testing/efk-dan-ji-bian-pai/tong-guo-docker-compose-bu-shu-efk)
-   [Docker Compose部署ELK 7.1.1分布式集群（单机版）](https://www.lmaye.com/2019/07/06/20190706204707/)
-   [使用Docker容器部署ELK](https://hhbbz.github.io/2018/07/03/%E4%BD%BF%E7%94%A8Docker%E5%AE%B9%E5%99%A8%E9%83%A8%E7%BD%B2ELK/)
