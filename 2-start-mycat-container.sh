# Start container
docker run -d --name mycat \
-p 18066:8066 -p 19066:9066 \
-v $(pwd)/mycat/server.xml:/usr/local/mycat/conf/server.xml \
-v $(pwd)/mycat/schema.xml:/usr/local/mycat/conf/schema.xml \
-v $(pwd)/mycat/rule.xml:/usr/local/mycat/conf/rule.xml \
jasonkay/mycat:1.6.7.5
