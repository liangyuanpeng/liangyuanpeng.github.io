---
layout:     post 
slug:      "push-metrics-to-prometheus"
title:      "主动推送metrics到prometheus"
subtitle:   ""
description: ""
date:       2021-11-25
author:     "梁远鹏"
image: "https://res.cloudinary.com/lyp/image/upload/v1635353670/hugo/banner/pexels-helena-lopes-2253275.jpg"
published: true
tags:
    - cncf 
    - tech
    - prometheus
categories: [ CloudNative ]
---

# 前言  

一般情况下应用程序配合prometheus收集应用程序的metrics是需要应用程序暴露metrics来让prometheus主动收集信息.  

而如果玩过springboot metrics对接influxdb的就会知道,这种情况下使用的是push模式,也就是应用程序主动将metrics推送到influxdb.  

想进一步了解的push模式到influxdb的可以看看`micrometer-registry-influx`,这里不会展开讲这个.  

# 主动推送metrics到prometheus有什么优势?  

## 只要支持prometheus远程写协议的软件都支持  

由于prometheus不适合存储长久的数据,因此市面上有一些开源项目希望完善prometheus存储长久数据的能力,这些软件都支持prometheus的远程写协议,因此`prometheus-spring-boot-starter`都对这些软件天然支持.  

举几个例子:  

1. m3db  
2. VictoriaMetrics
3. thanos
4. Cortex
5. ...

如果你的程序实现了prometheus远程写协议,那么也可以使用`prometheus-spring-boot-starter`.

## 数据上不会有假象

这里涉及到metrics的收集工作使用push模式还是pull模式,如果在一些网络限制的情况下,使用push可能会更有好一些.  

例如机器A是运行着应用程序,机器B需要从机器A拉取应用程序的metrics,但是呢机器B是访问不通机器A的(比如机器B是云端服务器,机器A是本地服务器),  

这时候使用pull模式的话就需要使用另外的方式将机器A的metrics首先拉取到然后转发到一个机器B可以访问的地方(Prometheus的PushGateway),机器B就直接从pushGateway拉取metrics.  

这样有一个问题就是如果机器A的应用程序都挂了,但是机器B依然可以从pushGateway拉取metrics,造成机器A程序正常的假象.  

## 服务再多也不需要服务发现  

由于push模式是知道prometheus的地址的,因此如果一个程序扩容了如果是pull模式的话prometheus需要知道新节点的地址,然后才能pull.  

如果没有使用服务发现的话那么需要在配置文件添加上新节点的metircs地址,如果使用了服务发现那么就依靠元数据服务/注册中心的服务发现能力来提供地址,这种情况下就存在元数据服务/注册中心的一个性能瓶颈问题.

而使用push模式就不存在需要配置prometheus的情况,当然也不需要服务发现之类的,因为根本就没有对接过服务发现!

# 难道push模式就没什么缺点吗?  

软件工程没有银弹! 缺点自然也是有的.

## 安全问题

想象一下,如果你的metrics push地址(prometheus)被某些有心人发现了,那么很有可能就会对这个地址发起攻击,将服务器的带宽占用了甚至有可能让prometheus崩溃.  

## 无法对metrics做relabel操作  

用prometheus pull的时候可以在存储metrics之前对metrics做一些操作，例如relable.添加label,修改label的值,丢弃某些label,只保留某些label等等.而这些在push模式下是做不到的,除非push端分别实现了这些功能.

# 后续计划  

后续会计划将metrics直接推送到pulsar,并且会开源一个`pulsar-io-prometheus`,最终的产物就是可以将metrics推送到pulsar这个中间媒介,下一步由pulsar function/sink来将metrics通过HTTP推送metrics到prometheus.  

这种情况下让用户可以有更多的选择,例如有另外的团队希望可以较快的拿到应用程序的metrics然后做一下其他计算(例如程序CPU达到xx要做扩容的动作等等).  

另外的计划是了主动HTTP推送metrics时支持basic认证以及支持按照metrics name过滤某些metrics.  

最后,附上Github地址:[prometheus-spring-boot-starter](https://github.com/yunhorn/prometheus-spring-boot-starter).欢迎参与进来!
