---
layout:     post 
slug:      "springboot-micrometer-influx"
title:      "微服务监控:SpringBoot-Micrometer-Influx"
subtitle:   ""
description: "微服务监控:SpringBoot-Micrometer-Influx."  
date:       2020-03-08
author:     "梁远鹏"
image: "img/banner-pexels.jpg"
published: true
tags: 
    - SpringBoot
    - micrometer
    - influx
categories: 
    - DevOps
---


# 前言  
聊到微服务监控,首先需要考虑的一个技术选型问题就是使用推数据还是使用拉数据的方式进行数据的收集,这个问题这里不进行具体讲解.本文使用``micrometer-registry-influx``这个组件使用推的方式进行数据的收集.  

讲到这里不得不说一下``micrometer``这个内容,这个可以理解是java监控领域的slf4j.上层实现有很多组件,influx,prometheus,telegraf等都有提供支持.  

# 前提

1. [influxdb](https://www.influxdata.com/)  

本文不进行influxdb的部署讲解,所以需要提前准备好influxdb.  

使用的版本是influx-1.x,编写本文时``micrometer-registry-influx``还不支持Influx2.

快速验证推荐使用docker部署influxdb的方式,网上有很多答案.


# 项目配置  

1. 引入依赖
```
<dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
        <dependency>
            <groupId>io.micrometer</groupId>
            <artifactId>micrometer-registry-influx</artifactId>
        </dependency>
```  

2. 配置文件配置  

这里演示的是yml格式的配置文件,添加下列内容到配置文件中

```
management:
  metrics:
    export:
      influx:
        enabled: true
        db: spring
        uri: http://192.168.1.16:31001
        step: 10s
#        user-name: admin
#        password: admin123
        auto-create-db: true
```  

上述配置内容中  
``enabled``: 打开数据推送开关  
``db``: influxdb中存储数据的数据库  
``uri``: influxdb的地址  
``step``: 数据推送的间隔  
``user-name``: 帐号  
``password``: 密码  
``auto-create-db``: 是否自动创建数据库  

# 验证数据是否正常产生  

1. 启动SpringBoot项目  
2. 进入到influxdb中,查看datbase:  

```
> show databases
name: databases
name
----
_internal
spring
```  

这里可以看到已经生成了一个spring的数据库,可以进入到这个数据库查看里面生成了一些什么数据  

```
> use spring
Using database spring
> show measurements
name: measurements
name
----
jvm_buffer_count
jvm_buffer_memory_used
jvm_buffer_total_capacity
jvm_classes_loaded
jvm_classes_unloaded
jvm_gc_live_data_size
jvm_gc_max_data_size
jvm_gc_memory_allocated
jvm_gc_memory_promoted
jvm_gc_pause
jvm_memory_committed
jvm_memory_max
jvm_memory_used
jvm_threads_daemon
jvm_threads_live
jvm_threads_peak
jvm_threads_states
logback_events
process_cpu_usage
process_start_time
process_uptime
system_cpu_count
system_cpu_usage
tomcat_sessions_active_current
tomcat_sessions_active_max
tomcat_sessions_alive_max
tomcat_sessions_created
tomcat_sessions_expired
tomcat_sessions_rejected
```  

上述measurement就是springboot开启actuator后默认生成的metrics  

到目前为止,一个最简单的SpringBoot项目通过micrometer将数据推送到influxdb的例子就完成了.

