---
layout:     post 
slug:   "prometheus-alertmanager-monitoring-quickstart"
title:      "prometheus-alertmanager监控告警系统快速开始"
subtitle:   ""
description: ""
date:       2021-03-11
author:     "梁远鹏"
image: "https://res.cloudinary.com/lyp/image/upload/v1544363191/hugo/blog.github.io/743a4e9227e1f14cb24a1eb6db29e183.jpg"
published: true
tags:
    - prometheus
    - docker-compose
    - alertmanager
    - webhook
    - email
categories: 
    - cloudnative
---  

# 本文还在创作当中，将在这几天正式发布。  

本文将会讲解通过docker-compose部署prometheus、alertmanager、lanapp(抓取metrics的应用以及接收webhook的应用),并通过修改metrics的值来触发alertmanager进行告警，本文会进行两种告警演示，第一种是webhook，第二种是email告警。  

docker-compose配置以及相关配置文件最终都会贴出来。

# TODO  
1. 数据源异常时alertmanager发送告警  
2. 邮件发送模版  
3. 对接飞书  
4. 对接slack

# 遇到的问题: 

1. 邮件发送失败  

```
err="establish TLS connection to server: x509: certificate is valid for *.mxhichina.com, mxhichina.com, not smtp.xxx.com"
```

# 前言  

Prometheus已经成为当前时代的监控系统中的主流软件,但仅仅靠Prometheus抓取Metrics是不够的，我们需要将这些Metrics使用起来，这才是价值所在。而Metrics可以用在两个方面，第一个是Metrics可视化，可以清楚的看到Metrics的趋势变化。第二个用处是告警，当某个指标在某个时间点或时间段飙升超过预定阀值时发出警告，提醒相关人员当前发生的事情。  

# Prometheus集成AlertManager告警 

本文主要讲述告警的部分，分为webhook告警和Email告警。  

比较常用的是Email告警，而WebHook更适合企业内部定制化告警，例如需要将告警输出到消息队列中，消息消费者再进行相应处理。  

在正式展示具体配置之前可以先想一想，这样一个Email告警需要有什么样子的配置呢?这里简单列一下看看和你想的一不一样。  

1. 邮件的服务器相关配置，例如用的是哪个邮件服务器、邮件服务器端口号、告警邮箱的帐号、告警邮箱的密码。  
2. 邮件告警的接收人，触发了邮件告警肯定有一个邮件甚至多个地址需要接收邮件。  
3. 邮件的标题  
4. 邮件的内容  

接下来看看AlertManager邮件相关配置:  
```
global:
  resolve_timeout: 5m
  smtp_from: 'xxx@xxx.com' #告警邮件显示邮件发送人
  smtp_smarthost: 'smtp.xxx.com:{port}'   # 邮件服务器  域名:端口
  smtp_auth_username: 'xxx@xxx.com' #帐号
  smtp_auth_password: 'password'  #密码
  smtp_require_tls: false  #是否必须TLS

route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'email'  #与下面name对应,标识使用哪一个告警 自定义的name
receivers:
- name: 'dingtalk'
  webhook_configs:
  - url: http://{IP}:8060/dingtalk/webhook1/send  
```

其中IP填写为正确的webhook程序所在IP。

# 注意

本文还处于持续创作当中。