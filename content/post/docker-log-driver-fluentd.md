---
layout:     post 
title:      "使用fluentd作为docker日志驱动收集日志"
subtitle:   ""
description: "Fluentd是一个开源的日志统一处理数据收集器,非常轻量级,目前是CNCF的毕业项目."  
date:       2020-02-15
author:     "lan"
image: "https://res.cloudinary.com/lyp/image/upload/v1581818753/hugo/blog.github.io/white-and-brown-bird-near-body-of-water-under-blue-sky-at-1106416.jpg"
published: true
tags: 
    - docker
    - cncf
    - image
    - fluentd
    - cloudNative
    - 日志收集
categories: 
    - Middleware
    - devops
---


# 前言  
docker默认的日志驱动是[json-file](https://docs.docker.com/config/containers/logging/json-file/),每一个容器都会在本地生成一个``/var/lib/docker/containers/containerID/containerID-json.log``,而日志驱动是支持扩展的,本章主要讲解的是Fluentd驱动收集docker日志.  

Fluentd是用于统一日志记录层的开源数据收集器,是继Kubernetes、Prometheus、Envoy 、CoreDNS 和containerd后的第6个CNCF毕业项目,常用来对比的是elastic的logstash,相对而言fluentd更加轻量灵活,现在发展非常迅速社区很活跃,在编写这篇blog的时候github的star是8.8k,fork是1k就可见一斑.

# 前提

1. [docker](https://www.docker.com/get-started)  
2. 了解[fluentd](https://www.fluentd.org/)配置  
3. [docker-compose](https://docs.docker.com/compose/reference/overview/)  

##  准备配置文件    


docker-compose.yml  
```
version: '3.7'

x-logging:
  &default-logging
  driver: fluentd
  options:
    fluentd-address: localhost:24224
    fluentd-async-connect: 'true'
    mode: non-blocking
    max-buffer-size: 4m
    tag: "kafeidou.{{.Name}}"  #配置容器的tag,以kafeidou.为前缀,容器名称为后缀,docker-compose会给容器添加副本后缀,如 fluentd_1

services:

  fluentd:
   image: fluent/fluentd:v1.3.2
   ports:
    - 24224:24224
   volumes:
    - ./:/fluentd/etc
    - /var/log/fluentd:/var/log/fluentd
   environment:
    - FLUENTD_CONF=fluentd.conf

  fluentd-worker:
   image: fluent/fluentd:v1.3.2
   depends_on:
     - fluentd
   logging: *default-logging
```  

fluentd.conf
```
<source>
  @type forward
  port 24224
  bind 0.0.0.0
</source>

<match kafeidou.*>
  @type              file
  path               /var/log/fluentd/kafeidou/${tag[1]}
  append             true
  <format>
    @type            single_value
    message_key      log
  </format>
  <buffer tag,time>
    @type             file
    timekey           1d
    timekey_wait      10m
    flush_mode        interval
    flush_interval    5s
  </buffer>
</match>

<match **>
  @type              file
  path               /var/log/fluentd/${tag}
  append             true
  <format>
    @type            single_value
    message_key      log
  </format>
  <buffer tag,time>
    @type             file
    timekey           1d
    timekey_wait      10m
    flush_mode        interval
    flush_interval    5s
  </buffer>
</match>
```  

由于fluentd需要在配置的目录中有写入的权限,所以需要先准备好存放log的目录以及给予权限.  
创建目录
```
mkdir /var/log/fluentd
```  
给予权限,这里用于实验演示,直接授权777  
```
chmod -R 777 /var/log/fluentd
```  

在docker-compose.yml和fluentd.conf的目录中执行命令:  
``
docker-compose up -d
``  

```
[root@master log]# docker-compose up -d
WARNING: The Docker Engine you're using is running in swarm mode.

Compose does not use swarm mode to deploy services to multiple nodes in a swarm. All containers will be scheduled on the current node.

To deploy your application across the swarm, use `docker stack deploy`.

Creating network "log_default" with the default driver
Creating fluentd ... done
Creating fluentd-worker ... done
```

查看一下日志目录下,应该就有对应的容器日志文件了:  
```
[root@master log]# ls /var/log/fluentd/kafeidou/
fluentd-worker.20200215.log  ${tag[1]}
```  

这是我最后的一个实验结果,会创建一个``${tag[1]}``目录,挺奇怪的,而且在这个目录下还会有两个文件  
```
[root@master log]# ls /var/log/fluentd/kafeidou/\$\{tag\[1\]\}/
buffer.b59ea0804f0c1f8b6206cf76aacf52fb0.log  buffer.b59ea0804f0c1f8b6206cf76aacf52fb0.log.meta
```  

如果有明白这块的也欢迎一起交流!  

## 架构总结  

### 为什么不用docker的原始日志呢?  

我们先看一下原始的docker日志是怎么样一个架构:  

![https://res.cloudinary.com/lyp/image/upload/v1581787531/hugo/blog.github.io/fluentd/docker-log-driver-local.jpg](https://res.cloudinary.com/lyp/image/upload/v1581787531/hugo/blog.github.io/fluentd/docker-log-driver-local.jpg)  

docker会在本机的``/var/lib/docker/containers/containerID/containerID-json.log``路径为每一个容器生成一个log文件,存储docker的日志.  

上图中总共有7个容器,当成7个微服务的话,在需要查看日志的时候就已经很不方便了,最差情况需要分别在三台机器上查看每一个容器的日志.  

### 使用了fluentd后有什么不一样?

使用fluentd收集docker日志后可以将容器汇总到一起.来看看配置了本文的fluentd配置文件后的架构:  

![https://res.cloudinary.com/lyp/image/upload/v1581787531/hugo/blog.github.io/fluentd/docker-log-driver-fluent-local.jpg](https://res.cloudinary.com/lyp/image/upload/v1581787531/hugo/blog.github.io/fluentd/docker-log-driver-fluent-local.jpg)  

由于fluentd配置的是存储在fluentd所在机器的本地目录,所以效果是将其他机器的容器日志收集到fluentd所在机器的本地目录中.  

### fluentd只能将容器日志收集到本地吗?

fluentd实际上可以将收集到的日志再次传输出去,例如传输到elasticsearch等存储软件中:  

![https://res.cloudinary.com/lyp/image/upload/v1581787532/hugo/blog.github.io/fluentd/docker-log-driver-art.jpg](https://res.cloudinary.com/lyp/image/upload/v1581787532/hugo/blog.github.io/fluentd/docker-log-driver-art.jpg)  

### fluentd灵活性  

fluentd能做的事情还有很多,fluentd本身能作为传输节点也能作为接受节点,还能够过滤特定日志,格式化特定内容的日志,将匹配的特定日志再次传输出去,这里只是做到一个简单的收集docker容器日志的效果.