export DOLT_HOME=/root/workspace/dolt

mkdir -p $DOLT_HOME

docker run -itd --restart=always \
  --name my-dolt \
  -p 23306:3306 \
  -v $DOLT_HOME/server-conf:/etc/dolt/servercfg.d \
  -v $DOLT_HOME/dolt-conf:/etc/dolt/doltcfg.d \
  -v $DOLT_HOME/databases:/var/lib/dolt \
  dolthub/dolt-sql-server:1.32.0

# Change config, and restart container...
