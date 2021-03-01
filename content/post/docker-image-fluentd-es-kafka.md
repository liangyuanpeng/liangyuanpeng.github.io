---
layout:     post 
title:      "制作带有kafka插件和es插件的fluentd镜像"
subtitle:   ""
description: "Fluentd是一个开源的日志统一处理数据收集器,非常轻量级,目前是CNCF的毕业项目."  
date:       2020-02-15
author:     "lan"
image: "https://res.cloudinary.com/lyp/image/upload/v1581729516/hugo/blog.github.io/avian-beak-bird-blur-416117.jpg"
published: true
tags: 
    - docker
    - cncf
    - image
    - fluentd
    - cloudNative
categories: 
    - 中间件
---


# 前言  
Fluentd是用于统一日志记录层的开源数据收集器,是继Kubernetes、Prometheus、Envoy 、CoreDNS 和containerd后的第6个CNCF毕业项目,常用来对比的是elastic的logstash,相对而言fluentd更加轻量灵活,现在发展非常迅速社区很活跃,在编写这篇blog的时候github的star是8.8k,fork是1k就可见一斑.

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
```
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


以版本为v1.3.2的fluentd镜像为基础镜像,由于fluentd的处理层扩展是以插件的方式进行扩展,所以在制作这个镜像时需要安装对应的kafka插件和elasticsearch插件.  
这里kafka的fluentd插件版本为0.12.3,elasticsearch的fluentd插件版本为4.0.3.  

Dockerfile和fluent.conf都准备好了,执行制作镜像命令
```
docker build -t fluentd-es-kafka:v1.3.2 .
```

这样一来包含es插件和kafka插件的fluentd镜像就制作完成了.  

运行这样一个fluentd只需要一条docker命令就可以运行起来.  

```
docker run -it -d fluentd-es-kafka:v1.3.2
```  

这个容器会在启动后开始监听host为kafka的kafka消息且传输数据到host为elasticsearch的elasticsearch节点.  

如果是es的节点和kafka的节点地址不一样,则需要挂在volume覆盖容器内的默认配置文件.  

```
docker run -it -v {存放fluent.conf的目录}:/etc/fluent -d fluentd-es-kafka:v1.3.2
```

发一个已经制作完成的镜像:``lypgcs/fluentd-es-kafka:v1.3.2``
