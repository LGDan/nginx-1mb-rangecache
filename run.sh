#!/bin/bash

docker stop nginx-1mb-rangecache
docker rm nginx-1mb-rangecache

docker run -d \
  --name nginx-1mb-rangecache \
  -p 8081:80 \
  -v /home/dan/source/repos/nginx-1mb-rangecache/nginx.conf:/etc/nginx/conf/nginx.conf \
  nginx-1mb-rangecache:latest

sleep 2

docker logs nginx-1mb-rangecache
