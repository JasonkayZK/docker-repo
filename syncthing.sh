docker run -itd --network=host -v /root/data/docker-volumn/sync-thing:/var/syncthing --restart=always --name=my-syncthing --privileged=true syncthing/syncthing:1.22
