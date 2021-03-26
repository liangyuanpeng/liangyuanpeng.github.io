---
layout:     post 
slug:      "prometheus-v2.25-feature"
title:      "Prometheus2.25新特性讲解"
subtitle:   ""
description: "Prometheus作为第二个从CNCF毕业的顶级项目,其成熟程度是毋庸置疑的,甚至推出了另一个CNCF项目OpenMetrics,希望将Prometheus的指标格式演进成为一个行业规范"
date:       2021-03-17
author:     "梁远鹏"
image: "https://res.cloudinary.com/lyp/image/upload/v1612744351/hugo/blog.github.io/pexels-bruno-cervera-6032877.jpg"
published: true
tags:
    - prometheus
    - cncf
    - monitor
    - ops
    - metrics
categories: 
    - CloudNative
---  

# 前言  

Prometheus作为第二个从CNCF毕业的顶级项目,其成熟程度是毋庸置疑的,甚至推出了另一个CNCF项目OpenMetrics,希望将Prometheus的指标格式演进成为一个行业规范。  

# 更新总览  

在Prometheus-v2.25.0版本中更新一览:  

TODO 把更新点都列出来

1. [实验性功能]支持remote_write请求,默认不启用,启用需要启动参数指定--enable-feature = remote-write-receiver  
2. [实验性功能]新增'@'修饰符,默认不启用,启用需要启动参数指定--enable-feature = promql-at-modifier
3. [增强]完善测试案例testgroup添加name属性  
4. [增强]UI界面上添加警告相关信息
5. [增强]加大压缩Histogram类型metrics的存储存储桶数,由512增大到8192  
6. [增强]允许设置自定义的header在远程写请求中  
7. [增强]将dashboard和config的libsonnet中的grafana替换成了grafanaPrometheus  
8. [增强]kubernetes服务发现中添加ndponits labels的metadata  
9. [增强]UI界面添加显示TSDB标签对的总数数据  
10. [增强]TSDB每分钟加载块数据,如果检测到有更新就执行保留数据操作.(这个PR标记成了#8243 应该是写错了,看了下这个PR 和块数据没关系)  
11. [BugFix]修复启动时web.listen-address参数没有传递端口报错问题  
12. [BugFix]完善一个错误处理,打开Mmap文件时继续走逻辑而不是立刻返回错误  
13. [BugFix]  
14. [BugFix]  

总共是`2个`实验性功能`8个`增强`10个`BugFix  

本文会主要讲解两个实验性功能和两个增强＃8273 ＃8416、和BUGFIX ＃8423 ＃8353。   TODO 用数字说出是哪几个

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

![table](https://res.cloudinary.com/lyp/image/upload/v1616047736/hugo/blog.github.io/prometheus/version/2.25/topk-org-table.png)  

![graph](https://res.cloudinary.com/lyp/image/upload/v1616047735/hugo/blog.github.io/prometheus/version/2.25/topk-org-graph.png)

一起来看看下面的`PromQL`:  

```shell
rate(jvm_memory_used_bytes[1m])
and 
topk(2, rate(jvm_memory_used_bytes[30m] @ end())) 
```  

`rate(jvm_memory_used_bytes[1m])`是希望查询的实际数据,`topk(2, rate(jvm_memory_used_bytes[30m] @ end())) ` 意思是筛选出最近时间段内(如果是Table则是实时)30分钟平均速率趋势最大的2个指标,然后展示他们在时间段内1分钟的平均速率数据.  

相关PR有三个,分别是:＃8121 ＃8436 ＃8425 
TODO 

# 增强  

## 远程存储支持自定义HTTP Header  

只需要在`remote_write`的`url配置下`添加一个`headers`的参数即可,填充`map类型`内容,如果版本在`v2.25以下`时填写了header内容会`报错`

```yaml
remote_write:
  - url: http://192.168.3.75:9494/api/v1/write
    headers:
      key: value
```  

当然了,一些HTTP自身的Header是不允许覆盖内容的,贴一下源码:  

```golang
	unchangeableHeaders = map[string]struct{}{
		// NOTE: authorization is checked specially,
		// see RemoteWriteConfig.UnmarshalYAML.
		// "authorization":                  {},
		"host":                              {},
		"content-encoding":                  {},
		"content-type":                      {},
		"x-prometheus-remote-write-version": {},
		"user-agent":                        {},
		"connection":                        {},
		"keep-alive":                        {},
		"proxy-authenticate":                {},
		"proxy-authorization":               {},
		"www-authenticate":                  {},
	}
```  

毕竟这是HTTP自带的header,如果覆盖了会引起一些未知的错误.  

PR地址:[https://github.com/prometheus/prometheus/pull/8273](https://github.com/prometheus/prometheus/pull/8273)


# 在UI界面上添加TSDB标签对的总数  

这算一个TSDB数据基本信息完善,把标签对总数数据显示了出来

![add-label-pair](https://res.cloudinary.com/lyp/image/upload/v1616047735/hugo/blog.github.io/prometheus/version/2.25/add-label-pair.png)

# BugFix  

## 在启动时删除2.21以前版本的临时数据  

这个Issue在[https://github.com/prometheus/prometheus/issues/8180](https://github.com/prometheus/prometheus/issues/8180)  

是一位用户在2.15.2时遇到的一个问题,后来升级到了2.22.1版本.  

在Prometheus压缩或保留失败时产生了一些`*.tmp`文件,例如`01EQ0DZ14E04F7P51Q3NA1562G.tmp`,而且prometheus永远也没有情理这些文件,导致这些临时文件越来越多.如果你已经在生产环境看到了一些tmp文件并且越来越多的话,是时候升级prometheus了,否则这些临时文件会越来越多,直到磁盘空间满载.  

PR地址:[https://github.com/prometheus/prometheus/pull/8353](https://github.com/prometheus/prometheus/pull/8353)  


# 注意 本文还处于创作阶段,将会尽快完善