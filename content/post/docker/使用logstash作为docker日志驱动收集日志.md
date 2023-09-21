---
layout:     post 
slug:      "logstash-logdriver-docker"
title:      "使用logstash作为docker日志驱动收集日志"
subtitle:   ""
description: "logstash是一个开源的日志统一处理数据收集器,属于ELK中的L,在日志收集领域应用广泛."  
date:       2020-02-16
author:     "梁远鹏"
image: "/img/banner-pexels.jpg"
published: true
tags: 
    - docker
    - 日志收集
    - logstash
categories: 
    - DevOps
---


# 前言  
logstash是一个开源的日志统一处理数据收集器,属于ELK中的L,在日志收集领域应用广泛.  

docker默认的日志驱动是[json-file](https://docs.docker.com/config/containers/logging/json-file/),每一个容器都会在本地生成一个``/var/lib/docker/containers/containerID/containerID-json.log``,而日志驱动是支持扩展的,本章主要讲解的是使用logstash收集docker日志.  

docker是没有logstash这个驱动的,但是可以通过logstash的gelf input插件收集gelf驱动的日志.  

# 前提

1. [docker](https://www.docker.com/get-started)  
2. 了解[logstash](https://www.elastic.co/guide/en/logstash/current/index.html)配置  
3. [docker-compose](https://docs.docker.com/compose/reference/overview/)  

##  准备配置文件    

docker-compose.yml  
```
version: '3.7'

x-logging:
  &default-logging
  driver: gelf
  options:
    gelf-address: "udp://localhost:12201"
    mode: non-blocking
    max-buffer-size: 4m
    tag: "kafeidou.{{.Name}}"  #配置容器的tag,以kafeidou.为前缀,容器名称为后缀,docker-compose会给容器添加副本后缀,>如 logstash_1

services:

  logstash:
    ports:
      - 12201:12201/udp
    image: docker.elastic.co/logstash/logstash:7.5.1
    volumes:
      - ./logstash.yml:/usr/share/logstash/config/logstash.yml
      - /var/log/logstash:/var/log/logstash
      - ./logstash.conf:/usr/share/logstash/pipeline/logstash.conf

  logstash-worker:
    image: docker.elastic.co/logstash/logstash:7.5.1
    depends_on:
      - logstash
    logging:
      driver: "gelf"
      options:
        gelf-address: "udp://localhost:12201"
```  

logstash.yml
```
http.host: "0.0.0.0"
```  

logstash.conf
```
input {
 gelf{
  use_udp => true
  port_tcp => 12202
 }
}

 output {
   file {
        path => "/var/log/logstash/%{+yyyy-MM-dd-HH}/%{container_name}.log"
   }
 }
```  



由于logstash需要在配置的目录中有写入的权限,所以需要先准备好存放log的目录以及给予权限.  
创建目录
```
mkdir /var/log/logstash
```  
给予权限,这里用于实验演示,直接授权777  
```
chmod -R 777 /var/log/logstash
```  

在docker-compose.yml,logstash.conf和logstash.yml文件的目录中执行命令:  
``
docker-compose up -d
``  

```
[root@master logstash]# docker-compose up -d
WARNING: The Docker Engine you're using is running in swarm mode.

Compose does not use swarm mode to deploy services to multiple nodes in a swarm. All containers will be scheduled on the current node.

To deploy your application across the swarm, use `docker stack deploy`.

Starting logstash_logstash_1 ... done
Starting logstash_logstash-worker_1 ... done
```  

logstash启动较慢,我实验的效果是90秒左右,所以更推荐[使用fluentd收集日志](https://liangyuanpeng.com/post/fluentd-logdrive-docker/)

查看一下日志目录下,应该就有对应的容器日志文件了:  
```
[root@master logstash]# ls /var/log/logstash/
2020-02-16
[root@master logstash]# ls /var/log/logstash/2020-02-16/
logstash_logstash-worker_1.log
```  


也可以直接下载我的文件:  
1. [docker-compose.yml](https://res.cloudinary.com/lyp/raw/upload/v1581868906/hugo/blog.github.io/ELK/docker-compose.yml)
2. [logstash.conf](https://res.cloudinary.com/lyp/raw/upload/v1581868906/hugo/blog.github.io/ELK/logstash.conf)
3. [logstash.yml](https://res.cloudinary.com/lyp/raw/upload/v1581868942/hugo/blog.github.io/ELK/logstash.yml)  

## 总结  

### 技术选型更推荐fluentd，为什么?  

fluentd更加轻量级并且更灵活,并且目前属于CNCF,活跃度和可靠性都更上一层楼.  

### 为什么还要介绍logstash收集docker日志?

在一个公司或者业务中如果已经在使用ELK技术栈,也许就没有必要再引入一个fluentd,而是继续用logstash打通docker日志这块.这里主要做一个分享,让遇到这种情况的同学能够有多一个选择.   

## 推荐阅读:  

[使用fluentd作为docker日志驱动收集日志](https://liangyuanpeng.com/post/fluentd-logdrive-docker/)