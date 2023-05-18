---
layout:     post 
slug:      "node-exporter-basic"
title:      "给NodeExporter添加Baisc认证"
subtitle:   ""
description: ""
date:   2021-03-17
author:     "梁远鹏"
image: "/img/banner-pexels.jpg"
published: false
tags:
    - node_exporter
    - metrics
categories: 
    - cloudnative
---  

# 前言  

```shell
htpasswd -nBC 10 admin
```  

`-B`表示进行`bcrypt`加密  


```yaml
root@yh-console:/usr/local/smartoilets/node-exporter/node_exporter-1.1.2.linux-amd64# cat web.yml 
basic_auth_users:
  admin: $2y$10$lCIS22AwWPasI3gB7HYaK.tTwT.Y6CbTdffHMCEQPYBVTBvvshP2W
```

```shell
./node_exporter --web.listen-address=":9200"  --web.config=web.yml
```  

访问不了 

```shell
[root@node123 ~]# curl 192.168.3.75:9200/metrics
Unauthorized
```  

curl添加basic认证信息再次请求  
```shell
curl -u admin:admin 192.168.3.75:9200/metrics
```