mkdir -p /root/workspace/piwigo

docker run -d \
--name=my-piwigo \
-e PUID=1000 \
-e PGID=1000 \
-e TZ=Etc/UTC+8 \
-p 19880:80 \
-v /root/workspace/piwigo/config:/config \
-v /root/workspace/piwigo/appdata/gallery:/gallery \
--restart unless-stopped \
lscr.io/linuxserver/piwigo:15.5.0
