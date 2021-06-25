docker run -dit \
--name hadoop \
--privileged=true \
-p 50070:50070 \
-p 8088:8088 \
sequenceiq/hadoop-docker:2.7.0 /etc/bootstrap.sh -bash
