export STORAGE_LOCATION=$HOME/workspace/anythingllm && \
mkdir -p $STORAGE_LOCATION && \
touch "$STORAGE_LOCATION/.env" && \
docker run -d -p 3001:3001 \
--restart=always \
--name my-anything-llm \
--cap-add SYS_ADMIN \
-v ${STORAGE_LOCATION}:/app/server/storage \
-v ${STORAGE_LOCATION}/.env:/app/server/.env \
-e STORAGE_DIR="/app/server/storage" \
registry.cn-hangzhou.aliyuncs.com/jasonkay/anythingllm:latest
