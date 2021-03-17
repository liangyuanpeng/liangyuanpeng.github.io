---
layout:     post 
slug:      "prometheus-v2.25-feature"
title:      "Prometheus2.25新特性讲解"
subtitle:   ""
description: "Prometheus作为第二个从CNCF毕业的顶级项目,其成熟程度是毋庸置疑的,甚至推出了另一个CNCF项目OpenMetrics,希望将Prometheus的指标格式演进成为一个行业规范"
date:       2021-03-17
author:     "梁远鹏"
image: "https://res.cloudinary.com/lyp/image/upload/v1612744351/hugo/blog.github.io/pexels-bruno-cervera-6032877.jpg"
published: false
tags:
    - prometheus
    - cncf
    - monitor
    - ops
categories: 
    - CloudNative
---  

# 前言  

Prometheus作为第二个从CNCF毕业的顶级项目,其成熟程度是毋庸置疑的,甚至推出了另一个CNCF项目OpenMetrics,希望将Prometheus的指标格式演进成为一个行业规范。  

# 更新总览  

在Prometheus-v2.25.0版本中更新一览:  

1. 2个实验性功能  
2. 8个增强  
3. 10个BugFix  

本文会主要讲解两个实验性功能和两个增强＃8273 ＃8416、和BUGFIX ＃8423 ＃8353。  

官方地址是:[https://github.com/prometheus/prometheus/releases/tag/v2.25.0](https://github.com/prometheus/prometheus/releases/tag/v2.25.0) 

# 实验性功能  

默认关闭的功能列表在这里可以找到:https://github.com/prometheus/prometheus/blob/main/docs/disabled_features.md  

在`prometheus`命令`help`中也可以找到:   
```shell
      --enable-feature= ...      Comma separated feature names to enable. Valid options: 'promql-at-modifier' to enable the @
                                 modifier, 'remote-write-receiver' to enable remote write receiver. See
                                 https://prometheus.io/docs/prometheus/latest/disabled_features/ for more details.
```

## prometheus可以作为另一个prometheus的远程存储  

也就是说可以支持Prometheus将拉取到的数据写入到另一个Prometheus.  

想象一下这样一个场景:监控中心的Prometheus部署在服务器A,而业务程序部署在服务器B并且由于网络安全等问题服务器B不能开放Exporter端口或路径到外部访问,这时候一般会加一个PushGateway,由业务程序主动将Metrics推送到PushGateway,Prometheus再从PushGateway拉取Metrics.  

但这种方式并不是很好,PushGateway没有收到业务程序最新的Metrics了,但Prometheus依然能够从PushGateway拉取到数据,并且这还存在PushGateway单点问题.  

现在Prometheus支持作为远程存储后可以怎么玩呢?在业务程序网络覆盖的范围内部署一个Prometheus,再由这个Prometheus将数据远程存储到监控中心的Prometheus.  

这就是一个典型的SideCar模式.  

这让我想到一个套娃的Prometheus,比如现在有两个Prometheus,他们都设置对方为远程存储,那么是不是就无限循环了呢?感兴趣的可以试试!   

PR地址:[https://github.com/prometheus/prometheus/pull/8424](https://github.com/prometheus/prometheus/pull/8424)

## 新增'@'修饰符  

简单来说就是多了一个'@'的语法,在v2.25.0之前`topk()`只支持及时查询,也就是无法查询某段时间内的`topk`,当你使用`topk`查询图表时,会查询出不符合预期的结果,比如` topk(2, rate(jvm_memory_used_bytes[10m])) `希望查询出`10分钟内jvm_memory_used_bytes指标的平均速率增长趋势最大的2个指标`,但是查询的结果会`多余预期的2个`.  

说明: Graph(图表)即某段时间范围内的结果,Table即实时查询.可以看看下面两个图再进一步理解.  

![table]()  

![graph]()

一起来看看下面的`PromQL`:  

```shell
rate(jvm_memory_used_bytes[1m])
and 
topk(2, rate(jvm_memory_used_bytes[30m] @ end())) 
```  

`rate(jvm_memory_used_bytes[1m])`是希望查询的实际数据,`topk(2, rate(jvm_memory_used_bytes[30m] @ end())) ` 意思是筛选出最近时间段内(如果是Table则是实时)30分钟平均速率趋势最大的2个指标,然后展示他们1分钟的平均速率数据.  

相关PR有三个,分别是:＃8121 ＃8436 ＃8425