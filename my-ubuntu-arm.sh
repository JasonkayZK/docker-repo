# Features:
#  1. Arm images for M1
#  2. Tsinghua Images
#  3. ssh (Default passwd 123456, Default port 22)
docker run -itd -p10022:22 -v /root/data/docker-volumn/my-ubuntu:/root/workpsace --restart=always --name my-ubuntu --privileged=true jasonkay/ubuntu:arm-22.04 /bin/bash