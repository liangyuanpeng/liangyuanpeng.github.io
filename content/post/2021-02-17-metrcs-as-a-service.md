---
layout:     post 
title:      "metrics托管服务即将发布"
subtitle:   ""
description: "在云原生时代,每时每刻都有metrics被prometheus定时抓取.."
date:       2021-03-11
author:     "lyp"
image: "https://res.cloudinary.com/lyp/image/upload/v1544363191/hugo/blog.github.io/743a4e9227e1f14cb24a1eb6db29e183.jpg"
published: true
tags:
    - Metrics
    - Prometheus
    - SAAS
categories: 
    - CloudNative
---  

# 前言  

现在很多人都在使用静态博客来记录自己的内容，但动态博客依然还有很多存在，也许永远也不会消失。最近几年一个基于SpringBoot编写的Blog正在慢慢变得火热起来，那就是Halo，而Java编写的其他博客或其他系统也不少,这些系统都像烟囱一样部署在各自的服务器上。  

一般人们不会专门为了自己的一个小网站专门去部署监控的内容，毕竟在大流量来临之前没必要去花这些功夫，但是了解自己线上系统运行情况还是非常需要有一个监控存在的。  

#  产品介绍  

用户只需要暴露标准的prometheus exporter给平台抓取metrics即可，然后可以在专属的Grafana页面看到自己的程序运行时情况，下面以JVM程序为例给个图：   

![metrics-jvm](https://res.cloudinary.com/lyp/image/upload/v1615419259/hugo/blog.github.io/saas/prometheus/metrics-jvm.png)    

## 支持的exporter类型  

1. JVM Micrometer exporter
2. Node exporter  
3. Redis exporter

#  产品定价   


|  |  基础版   | 高级版  |
|  ----|  ----  | ----  |
| 价格 | 50/年  | 暂定/年 |
| metrics应用数 | 3  | 暂定 |
| 数据保存 | 两个月  | 一年 |
| Node Exporter | √  | √ |
| Redis Exporter | √  | √ |
| 邮件告警 | √ | √ |
| 钉钉告警 | ×  | √ |
|独立Prometheus实例 | × | √ |
|独立Grafana实例 | × | √ |
|存储空间 | 暂定 | 暂定 |
|部署节点 | 香港 | 香港 |
