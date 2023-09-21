---
layout:     post 
slug:      "fluentd-plugin-kafka"
title:      "制作带有kafka插件和es插件的fluentd镜像"
subtitle:   ""
description: "Fluentd是一个开源的日志统一处理数据收集器,非常轻量级,目前是CNCF的毕业项目."  
date:       2020-02-15
author:     "梁远鹏"
image: "https://res.cloudinary.com/lyp/image/upload/v1581729516/hugo/blog.github.io/avian-beak-bird-blur-416117.jpg"
published: true
tags: 
    - docker
    - cncf
    - image
    - fluentd
    - CloudNative
categories: 
    - TECH
---


# 前言  

Fluentd 是用于统一日志记录层的开源数据收集器,是继 Kubernetes、Prometheus、Envoy 、CoreDNS 和 containerd 后的第6个 CNCF 毕业项目,常用来对比的是 elasticsearch 的 logstash,相对而言 fluentd 更加轻量灵活,现在发展非常迅速社区很活跃,在编写这篇 blog 的时候 github 的 star 是8.8k, fork 是1k就可见一斑.

# 前提

1. [docker](https://www.docker.com/get-started)  


## Dockerfile文件编写  

Dockerfile
```
FROM fluent/fluentd:v1.3.2 
ADD fluent.conf /etc/fluent/
RUN echo "source 'https://mirrors.tuna.tsinghua.edu.cn/rubygems/'" > Gemfile && gem install bundler
RUN gem install fluent-plugin-kafka -v 0.12.3 --no-document
RUN gem install fluent-plugin-elasticsearch -v 4.0.3 --no-document
CMD ["fluentd"]
```

fluent.conf
```conf
<source>
  @type kafka

  brokers kafka:9092
  format json
  <topic>
    topic     kafeidou
  </topic>
</source>


<match *>
  @type elasticsearch
  host elasticsearch
  port 9200
  index_name fluentd
  type_name fluentd
</match>

```  


以版本为v1.3.2的 fluentd 镜像为基础镜像,由于fluentd的处理层扩展是以插件的方式进行扩展,所以在制作这个镜像时需要安装对应的 kafka 插件和elasticsearch 插件.  
这里 kafka 的 fluentd 插件版本为 0.12.3,elasticsearch 的 fluentd 插件版本为4.0.3.  

Dockerfile 和`fluent.conf`都准备好了,执行制作镜像命令
```shell
docker build -t fluentd-es-kafka:v1.3.2 .
```

这样一来包含 Elasticsearch 插件和 kafka 插件的 fluentd 镜像就制作完成了.  

运行这样一个 fluentd 只需要一条 docker 命令就可以运行起来.  

```shell
docker run -it -d fluentd-es-kafka:v1.3.2
```  

这个容器会在启动后开始监听 host 为 kafka 的 kafka 消息且传输数据到 host 为 elasticsearch 的 elasticsearch 节点.  

如果是 elasticsearch 的节点和 kafka 的节点地址不一样,则需要挂在 volume 覆盖容器内的默认配置文件.  

```shell
docker run -it -v {存放fluent.conf的目录}:/etc/fluent -d fluentd-es-kafka:v1.3.2
```

发一个已经制作完成的镜像:`lypgcs/fluentd-es-kafka:v1.3.2`
