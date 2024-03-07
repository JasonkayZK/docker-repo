docker run -itd --restart=always -p 1883:1883 -p 9001:9001 --name my-eclipse-mosquitto eclipse-mosquitto

###### In Container ######
## Create user & passwd
## https://mosquitto.org/documentation/authentication-methods/
docker exec -it my-eclipse-mosquitto /bin/sh
cd /mosquitto
mosquitto_passwd -c password_file <username>
## Input passwd ...

## Change config
vi /mosquitto/config/mosquitto.conf
### listener 1883
### password_file /mosquitto/password_file

# Restart containner
docker restart my-eclipse-mosquitto
