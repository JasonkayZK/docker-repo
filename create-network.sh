# 创建网络
docker network create --subnet 172.30.0.0/24 --gateway 172.30.0.1 big-data

# 创建容器
docker run -itd --name big-data-1 --net big-data --ip 172.30.0.11  --hostname big-data-1 --privileged  jasonkay/big-data-1:v1.0 /usr/sbin/init
docker run -itd --name big-data-2 --net big-data --ip 172.30.0.12  --hostname big-data-2 --privileged  jasonkay/big-data-2:v1.0 /usr/sbin/init
docker run -itd --name big-data-3 --net big-data --ip 172.30.0.13  --hostname big-data-3 --privileged  jasonkay/big-data-3:v1.0 /usr/sbin/init

# 进入容器
docker exec -it big-data-1 /bin/bash
