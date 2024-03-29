export DOLT_HOME=/root/workspace/dolt

mkdir -p $DOLT_HOME
mkdir -p $DOLT_HOME/server-conf

# Write config, see more: https://docs.dolthub.com/sql-reference/server/configuration
cat > $DOLT_HOME/server-conf/config.yaml << EOF
log_level: info

behavior:
  read_only: false
  autocommit: true

user:
  name: root
  password: "your-password"

listener:
  host: localhost
  port: 3306
  max_connections: 100
  read_timeout_millis: 28800000
  write_timeout_millis: 28800000

performance:
  query_parallelism: null
EOF

docker run -itd --restart=always \
  --name my-dolt \
  -p 23306:3306 \
  -v $DOLT_HOME/server-conf:/etc/dolt/servercfg.d \
  -v $DOLT_HOME/dolt-conf:/etc/dolt/doltcfg.d \
  -v $DOLT_HOME/databases:/var/lib/dolt \
  dolthub/dolt-sql-server:1.32.0

# Change config need restart the container...!
docker exec -it my-dolt /bin/bash

# Add config
dolt config --global --set user.name "jasonkayzk"
dolt config --global --set user.email "jasonkayzk@gmail.com"
dolt login # set creds

# Restart container
docker restart my-dolt


