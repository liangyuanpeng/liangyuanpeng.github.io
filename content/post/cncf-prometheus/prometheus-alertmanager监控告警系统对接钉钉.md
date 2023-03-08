---
layout:     post 
slug:   "prometheus-alertmanager-monitoring-dingtalk"
title:      "prometheus-alertmanager监控告警系统对接钉钉"
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
    - 钉钉
categories: 
    - CloudNative
---


# 前言

本文将会讲解alertmanager对接钉钉,并且会演示通过修改metrics值来触发alertmanager进行告警并且展示告警以及告警恢复的情况。  

在此之前你可以先查看一下本文的上一篇文章-->[prometheus-alertmanager监控告警系统快速开始](https://liangyuanpeng.com/post/prometheus-alertmanager-monitoring-quickstart/)  

docker-compose配置以及相关配置文件最终都会贴出来。 

AlertManager本身不支持钉钉通知，实现的方式是使用一个实现了钉钉通知API的webhook程序，AlertManager将告警发送到webhook程序，webhook程序再将内容转换成钉钉通知需要的格式发送到钉钉API。  

本文阅读前提: 阅读了博文[prometheus-alertmanager监控告警系统快速开始](https://liangyuanpeng.com/post/prometheus-alertmanager-monitoring-quickstart/)

# 支持钉钉的webhook程序

本文使用的是开源项目[https://github.com/timonwong/prometheus-webhook-dingtalk](https://github.com/timonwong/prometheus-webhook-dingtalk),感谢作者以及贡献者们的辛苦劳动。  

## 下载  

到目前为止,最新版本是`1.4.0`,你可以下载和本文一致的版本,在钉钉不改变API的情况下我想已经足够使用了,当然你也可以下载最新版本。  

```shell
wget https://github.com/timonwong/prometheus-webhook-dingtalk/releases/download/v1.4.0/prometheus-webhook-dingtalk-1.4.0.linux-amd64.tar.gz
tar -xvf prometheus-webhook-dingtalk-1.4.0.linux-amd64.tar.gz  
cd prometheus-webhook-dingtalk  
```  

`config.yaml`
```yaml
targets:
  webhook1:
    url: https://oapi.dingtalk.com/robot/send?access_token={token}
    # secret for signature
    secret: {secret}
```  

## 启动webhook程序  
```shell
 ./prometheus-webhook-dingtalk --config.file=config.yaml
```

到目前为止已经将接收`AlertManager`告警信息的`webhook`程序启动好了.  

# 配置AlertManager将告警发送到webhook  

如果你已经看了[prometheus-alertmanager监控告警系统快速开始](https://liangyuanpeng.com/post/prometheus-alertmanager-monitoring-quickstart/)那么应该知道新增一个webhook告警是多么容易的事情。  

首先找到你的AlertManager配置文件,找到`receivers`的部分,添加以下配置:  

```yaml

receivers:
- name: 'dingtalk'
  email_configs: 
    # send_resolved:  是否发送恢复告警 
  - to: liangyuanpeng@xxx.com  #告警发给哪个人接收
```  

然后找到配置文件`route`的部分,把`receiver`的值填写为上述新增的receivers的name,本文是`dingtalk`  
```yaml
route:
  ...
  receiver: 'dingtalk'
```  

重启AlertManager,可以访问AlertManager的status页面来确认配置是否已经生效,例如`http://{IP}:{PORT}/#/status`.  

# 触发告警 

接下来演示一下alertmanager触发告警通知钉钉的情况。使用镜像`registry.cn-shenzhen.aliyuncs.com/lan-k8s/lanapp:v0.0.1`  

这是一个SpringBoot程序,更多细节可以在页面[prometheus-alertmanager监控告警系统快速开始](https://liangyuanpeng.com/post/prometheus-alertmanager-monitoring-quickstart/)找到XXXX部分查看程序的介绍。  

## 告警通知  

设置metrics超过阀值:  
```shell
curl http://192.168.3.169:8094/index/metrics/30
```  

注意:将IP替换成实际机器IP,本文后续不再强调.  

过了一会可以在钉钉看到机器人发送了告警:  
![dingtalk-alert](https://res.cloudinary.com/lyp/image/upload/v1615478134/hugo/blog.github.io/prometheus/dingtalk-alert.png)

## 告警恢复通知  

设置metrics恢复正常值(阀值以下都可以):  
```shell
curl http://192.168.3.169:8094/index/metrics/5
```  

过一会钉钉就看到了机器人发送了告警恢复的通知:  
![dingtalk-alert-normal](https://res.cloudinary.com/lyp/image/upload/v1615478135/hugo/blog.github.io/prometheus/dingtalk-normal.png)  

# 闭幕  

到目前为止一个Metrics在SpringBoot程序中发生变化并且被Prometheus抓取到,并且检测到持续了xx分钟后由AlertManager触发告警到钉钉机器人的这样一个过程就完成了，当然`prometheus-webhook-dingtalk`这个webhook程序是否还有更高级的玩法可以自己去挖掘挖掘,比如一个告警触发多个钉钉机器人,比如配置多个钉钉机器人,由不同的告警触发不同的钉钉机器人(这在生产时很容易遇到).  

并且本文是使用`docker-compose`部署Prometheus和`AlertManager`的,在kubernetes部署下是否又有更方便的配置,应该也是我接下来会在博客当中想要写的内容.


# 注意

本文还处于持续创作当中。