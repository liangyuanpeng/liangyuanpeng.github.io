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

# 本文还在创作当中，将在这几天正式发布。  

本文将会讲解alertmanager对接钉钉,并且会演示通过修改metrics值来触发alertmanager进行告警并且展示告警以及告警恢复的情况。  

在此之前你可以先查看一下本文的上一篇文章-->[https://liangyuanpeng.com/post/prometheus-alertmanager-monitoring-quickstart/](https://liangyuanpeng.com/post/prometheus-alertmanager-monitoring-quickstart/)  

docker-compose配置以及相关配置文件最终都会贴出来。 

AlertManager本身不支持钉钉通知，实现的方式是使用一个实现了钉钉通知API的webhook程序，AlertManager将告警发送到webhook程序，webhook程序再将内容转换成钉钉通知需要的格式发送到钉钉API。

# 注意：本文还处于持续创作当中。