FROM java:8-jre
MAINTAINER jasonkayzk@gmail.com
USER root
RUN cd /usr/local && \
    wget https://github.com/MyCATApache/Mycat-Server/releases/download/Mycat-server-1675-release/Mycat-server-1.6.7.5-release-20200422133810-linux.tar.gz && \
    tar -zxf Mycat-server-1.6.7.5-release-20200422133810-linux.tar.gz && \
    mkdir /usr/local/mycat/logs
ENV MYCAT_HOME=/usr/local/mycat
ENV PATH=$PATH:$MYCAT_HOME/bin
WORKDIR $MYCAT_HOME/bin
RUN chmod u+x ./mycat
EXPOSE 8066 9066
CMD ["./mycat","console"]
