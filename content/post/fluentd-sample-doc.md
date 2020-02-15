---
layout:     post 
title:      "fluentd语法入门"
subtitle:   ""
description: "Fluentd是一个开源的日志统一处理数据收集器,非常轻量级,目前是CNCF的毕业项目."  
date:       2020-02-14
author:     "lan"
image: "https://res.cloudinary.com/lyp/image/upload/v1581649210/hugo/blog.github.io/blur-close-up-code-computer-546819.jpg"
published: false
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

实验主要以docker进行环境搭建,所以需要提前准备好docker


## fluent.conf文件编写  