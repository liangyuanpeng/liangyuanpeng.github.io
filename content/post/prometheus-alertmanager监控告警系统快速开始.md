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
    - CloudNative
---

# 本文还在创作当中，将在这几天正式发布。  

本文将会讲解通过docker-compose部署prometheus、alertmanager、lanapp(抓取metrics的应用以及接收webhook的应用),并通过修改metrics的值来触发alertmanager进行告警，本文会进行两种告警演示，第一种是webhook，第二种是email告警。  

docker-compose配置以及相关配置文件最终都会贴出来。

# TODO  
1. 数据源异常时alertmanager发送告警  
2. 邮件发送模版

# 遇到的问题: 

1. 邮件发送失败  

```
err="establish TLS connection to server: x509: certificate is valid for *.mxhichina.com, mxhichina.com, not smtp.xxx.com"
```
