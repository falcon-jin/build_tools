#!/bin/bash


docker build -t  registry.cn-hangzhou.aliyuncs.com/falcon-tools/onlyoffice-documentserver:latest . --network host
docker push registry.cn-hangzhou.aliyuncs.com/falcon-tools/onlyoffice-documentserver:latest
