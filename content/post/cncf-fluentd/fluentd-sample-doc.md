---
layout:     post 
slug:      "fluentd-quickstart"
title:      "fluentd语法入门"
subtitle:   ""
description: "Fluentd是一个开源的日志统一处理数据收集器,非常轻量级,目前是CNCF的毕业项目."  
date:       2020-02-14
author:     "梁远鹏"
image: "https://res.cloudinary.com/lyp/image/upload/v1581649210/hugo/blog.github.io/blur-close-up-code-computer-546819.jpg"
published: true
wipnote: true
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

实验主要以 docker 进行环境搭建,所以需要提前准备好 docker


## fluent.conf文件编写    