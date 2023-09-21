---
layout:     post 
slug:   "springboot-support-prometheus"
title:      "springboot添加prometheus支持"
subtitle:   ""
description: ""
date:       2021-03-12
author:     "梁远鹏"
image: "/img/banner/stargazing_1.jpeg"
published: true
tags:
    - SpringBoot
    - prometheus
    - metrics
categories: 
    - cloudnative
---

# 前言 

云原生时代Golang语言开始火热起来,Docker、Kubernetes、Istio、Knative、Prometheus、Influx等等云原生领域的前沿软件都是用GO语言来实现的,其中监控领域的佼佼者莫过于Prometheus,更是被OpenMetrics以推进Prometheus metrics格式作为标准发展,而Java作为最常用轮子也最全的语言自然也会紧跟着步伐,本文来看看SpringBoot如何支持Prometheus生态。  

# Micrometer  

在正式开始之前先来了解一下`Micrometer`,SpringBoot也是依靠`Micrometer`和Prometheus来集成,但不仅仅是Prometheus,InfluxDB、Elasticsearch、StatsD、Datadog、Graphite等等中间件都可以依靠Micrometer来对接.  

这就像Java日志领域当中的`SLF4J`,你只需要引入`SLF4J`和对应实现的依赖,程序就可以使用`SLF4J`的对象去打印日志,而不需要没替换一个新的日志系统,你的程序的LOG对象就需要全部替换为新的对象.  

`Micrometer`也是如此,在文章[微服务监控:SpringBoot-Micrometer-Influx](https://liangyuanpeng.com/post/springboot-micrometer-influx/)当中已经有例子来演示SpringBoot依靠Micrometer将metrics数据发送到InfluxDB,本文只不过再演示一次`Micrometer`对接Prometheus而已.SpringBoot2在actuator中引入了Micrometer,可以说内置了prometheus支持也不为过.  

# 暴露prometheus metrics路径

让SpringBoot程序支持Prometheus抓取需要做的就是启用`/actuator/prometheus`路径,提供给prometheus抓取metrics.  

## 引入相关依赖  

只需要在pom文件中引入两个相关依赖就可以了:  

```xml
        <dependency>
            <groupId>io.micrometer</groupId>
            <artifactId>micrometer-registry-prometheus</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
```  

## 启用/actuator/prometheus  

只需要在springboot的yml配置文件添加以下内容即可:

```yaml
management:
  metrics:
    tags:
      application: ${spring.application.name}
      port: ${server.port}
      ip: ${spring.cloud.client.ip-address}
  endpoints:
    web:
      base-path: /actuator  #默认 /actuator
      exposure:
        include: '*'
```   

其中主要的部分是`management.endpoints.web.exposure.include`,意思是actuator下的路径开放哪一些路径,上述的配置是开放所有路径,项目启动后可以在浏览器访问`http://{IP}:{PORT}/actuator`看看都有哪一些路径.  

也可以选择性的开放部分路径,例如仅开放`/actuator/prometheus`和`/actuator/health`路径,那么配置文件应该是下面的样子:  

```yaml
management:
  metrics:
    tags:
      application: ${spring.application.name}
      port: ${server.port}
      ip: ${spring.cloud.client.ip-address}
  endpoints:
    web:
      base-path: /actuator  #默认 /actuator
      exposure:
        include: 'prometheus,health'
        # exclude: '' #排除哪些路径
```  

同样的,也可以选择性的只关闭某一个路径,如上述`exclude`展示,使用`exclude`来排除某些路径.  

在配置好`prometheus`路径开放只有可以访问`http://{IP}:{PORT}/actuator/prometheus`来看看prometheus能够抓取到的metrics.  

![springboot-prometheus](https://res.cloudinary.com/lyp/image/upload/v1615534837/hugo/blog.github.io/prometheus/springboot-prometheus.png)

其中上述配置`management.metrics.tags....`的作用是可以在配置文件直接添加tag,例如我们再给所有metrics添加一个`author`的tag,配置如下:  

```yaml
management:
  metrics:
    tags:
      application: ${spring.application.name}
      port: ${server.port}
      ip: ${spring.cloud.client.ip-address}
      author: liangyuanpeng
  endpoints:
    web:
      base-path: /actuator  #默认 /actuator
      exposure:
        include: 'prometheus,health'
        # exclude: '' #排除哪些路径
```  

![springboot-prometheus-tag](https://res.cloudinary.com/lyp/image/upload/v1615534837/hugo/blog.github.io/prometheus/springboot-prometheus-tag.png)  

可以看到`tag`已经在metrics加上了.

# 结语  

操作下来其实也不是很难对吧,主要归功于SpringBoot生态的成熟度,正因为如此即使Java内存使用量大也依然是使用最多的语言.  

# Tips  

本文没有写部署Prometheus的部分,如果有同学希望本文添加这部分内容可以留言让我知道,我会考虑是否添加Prometheus部分内容. :)


