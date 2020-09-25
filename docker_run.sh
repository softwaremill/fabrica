#!/bin/bash

CONTAINER_NAME=fabrikka-test

sudo docker run -it --name $CONTAINER_NAME \
  -u $(id -u ${USER}):$(id -g ${USER}) \
  -v /var/run/docker.sock:/var/run/docker.sock \
  fabrikka:latest sh fabric-compose.sh up

docker rm -f $CONTAINER_NAME


