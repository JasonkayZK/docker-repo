docker run -itd --net=host -v /root/data/docker-volumn/my-ubuntu:/root/workpsace --restart=always --name my-ubuntu --privileged=true ubuntu:22.04 /bin/bash