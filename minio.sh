mkdir -p /mnt/minio-data

docker run \
   -p 9000:9000 \
   -p 9001:9001 \
   --name minio \
   -v /mnt/minio-data:/data \
   -e "MINIO_ROOT_USER=ROOTNAME" \
   -e "MINIO_ROOT_PASSWORD=CHANGEME123" \
   quay.io/minio/minio server /data --console-address ":9001"
